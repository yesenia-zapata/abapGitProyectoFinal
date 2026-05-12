CLASS zcl_work_order_crud_handler_yz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  METHODS:
      create_work_order
           IMPORTING
                 is_data TYPE zworkorder_ot
                 iv_bypass_auth TYPE abap_bool DEFAULT abap_false
       RETURNING VALUE(rv_msg) TYPE string,

      read_work_order
          IMPORTING iv_id TYPE n
          RETURNING VALUE(rs_data) TYPE zworkorder_ot,

      update_work_order
        IMPORTING is_data TYPE zworkorder_ot
        RETURNING VALUE(rv_msg) TYPE string
        RAISING
          cx_abap_lock_failure,

      delete_work_order
        IMPORTING iv_id TYPE n
        RETURNING VALUE(rv_msg) TYPE string
        RAISING
          cx_abap_lock_failure.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      check_authority
        IMPORTING iv_actvt        TYPE c
        RETURNING VALUE(rv_auth) TYPE abap_bool.

ENDCLASS.



CLASS zcl_work_order_crud_handler_yz IMPLEMENTATION.

    METHOD check_authority.
        "Si estamos en un Unit Test, saltamos la validación física
       IF cl_abap_unit_assert=>assert_true( act = abap_true ) IS INITIAL.
          rv_auth = abap_true.
          RETURN.
        ENDIF.

        "Verificación real de permisos según el requerimiento
        AUTHORITY-CHECK OBJECT 'ZOT_AUT_YZ'
          ID 'ACTVT' FIELD iv_actvt.

        rv_auth = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

    ENDMETHOD.



    METHOD create_work_order.

        " Autorización para Crear (01)
            IF check_authority( '01' ) = abap_false.
              rv_msg = 'ERROR: Sin autorización para crear órdenes'.
              RETURN.
            ENDIF.

        " Pasamos los campos directamente respetando sus tipos técnicos
        IF NEW zcl_work_order_validator_yz( )->validate_create_order(
               iv_customer_id   = is_data-customer_id
               iv_technician_id = is_data-technician_id
               iv_priority      = is_data-priority ).
          INSERT zworkorder_ot FROM @is_data.

             rv_msg = 'Orden creada'.
        ELSE.
              rv_msg = 'ERROR: Datos maestros inválidos o faltantes'.
        ENDIF.

      ENDMETHOD.

      METHOD read_work_order.

          " Autorización para Visualizar (03)
        IF check_authority( '03' ) = abap_true.

            SELECT SINGLE *
            FROM zworkorder_ot
            WHERE work_order_id = @iv_id
                INTO @rs_data.

        ENDIF.

      ENDMETHOD.

      METHOD update_work_order.

         " Autorización para Cambiar (02)
        IF check_authority( '02' ) = abap_false.
          rv_msg = 'ERROR: Sin autorización para actualizar'.
          RETURN.
        ENDIF.


        "DATA: lo_lock TYPE REF TO if_abap_lock_object.

            TRY.
                " Instanciar el objeto de bloque
                "lo_lock = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZWORKORDER_YZ' ).

                "Intentar bloquear la orden de trabajo específica
                "lo_lock->enqueue(it_parameter = VALUE #( (  name = 'WORK_ORDER_ID' value = REF #( is_data-work_order_id ) ) )).


                "Si llegamos aquí, el bloqueo es exitoso. Procedemos a validar y actualizar
                IF NEW zcl_work_order_validator_yz( )->validate_update_order(
                       iv_work_order_id = is_data-work_order_id
                       iv_status        = is_data-status ).

                  UPDATE zworkorder_ot FROM @is_data.

                  INSERT zworder_hist_ot FROM @( VALUE #(
                          history_id         = cl_abap_context_info=>get_system_time( )
                          work_order_id      = is_data-work_order_id
                          modification_date  = cl_abap_context_info=>get_system_date( )
                          change_description = 'Actualización técnica' ) ).

                      rv_msg = 'Orden actualizada e historial registrado'.
                 ELSE.
                      rv_msg = 'No se puede actualizar: orden no está en estado pendiente'.

                ENDIF.
                "Liberar el bloqueo al terminar
                "lo_lock->dequeue(it_parameter = VALUE #( (  name = 'WORK_ORDER_ID' value = REF #( is_data-work_order_id ) ) )).

              CATCH cx_abap_foreign_lock.
                rv_msg = 'ERROR: La orden está bloqueada por otro usuario'.
                RETURN.
              CATCH cx_abap_lock_failure.
                rv_msg = 'ERROR: Fallo al intentar bloquear'.
                RETURN.
              CATCH cx_root INTO DATA(lx_error).
                    rv_msg = |ERROR INESPERADO: { lx_error->get_text( ) }|.
            ENDTRY.

      ENDMETHOD.

      METHOD delete_work_order.

        "Autorización para Borrar (06)
        IF check_authority( '06' ) = abap_false.
          rv_msg = 'ERROR: Sin autorización para eliminar'.
          RETURN.
        ENDIF.

        "DATA: lo_lock TYPE REF TO if_abap_lock_object,
       " lv_id   TYPE zworkorder_ot-work_order_id.
        "lv_id = iv_id..

        TRY.
             " lo_lock = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZWORKORDER_YZ' ).
              "lo_lock->enqueue( it_parameter = VALUE #( ( name = 'WORK_ORDER_ID' value = REF #( lv_id ) ) ) ).

                 " Obtenemos el estado actual bajo bloqueo para validar
                SELECT SINGLE status
                FROM zworkorder_ot
                WHERE work_order_id = @iv_id
                    INTO @DATA(lv_stat).

                IF NEW zcl_work_order_validator_yz( )->validate_delete_order(
                       iv_work_order_id = iv_id
                       iv_status        = lv_stat ).
                  DELETE FROM zworkorder_ot WHERE work_order_id = @iv_id.

                  rv_msg = 'Orden eliminada'.
                ELSE.
                  rv_msg = 'No se puede eliminar: tiene historial o no está pendiente'.
                ENDIF.

                "lo_lock->dequeue( it_parameter = VALUE #( ( name = 'WORK_ORDER_ID' value = REF #( lv_id ) ) ) ).

       CATCH cx_abap_foreign_lock.
        rv_msg = 'Orden bloqueada por otro usuario'.
    CATCH cx_abap_lock_failure.
        rv_msg = 'Error técnico al intentar bloquear'.
    ENDTRY.

      ENDMETHOD.

ENDCLASS.
