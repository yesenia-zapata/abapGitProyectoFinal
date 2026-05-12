CLASS zcl_work_order_crud_handler_yz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  METHODS:
      create_work_order
           IMPORTING is_data TYPE zworkorder_ot
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
        RETURNING VALUE(rv_msg) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_work_order_crud_handler_yz IMPLEMENTATION.

    METHOD create_work_order.

        AUTHORITY-CHECK OBJECT 'ZOT_AUT_YZ'
             ID 'ACTVT' FIELD '01'.

        IF sy-subrc <> 0.
          rv_msg = 'Sin autorización para crear'.
          RETURN.
        ENDIF.

        " Pasamos los campos directamente respetando sus tipos técnicos
        IF NEW zcl_work_order_validator_yz( )->validate_create_order(
               iv_customer_id   = is_data-customer_id
               iv_technician_id = is_data-technician_id
               iv_priority      = is_data-priority ).
          INSERT zworkorder_ot FROM @is_data.

          rv_msg = 'Orden creada'.

        ENDIF.

      ENDMETHOD.

      METHOD read_work_order.

        SELECT SINGLE *
        FROM zworkorder_ot
        WHERE work_order_id = @iv_id
            INTO @rs_data.

      ENDMETHOD.

      METHOD update_work_order.

        DATA: lo_lock TYPE REF TO if_abap_lock_object.

            TRY.
                " Instanciar el objeto de bloque
                lo_lock = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZWORKORDER_YZ' ).

                "Intentar bloquear la orden de trabajo específica
                lo_lock->enqueue(
                    it_parameter = VALUE #( (  name = 'WORK_ORDER_ID' value = REF #( is_data-work_order_id ) ) )
                ).

              CATCH cx_abap_foreign_lock.
                rv_msg = 'ERROR: La orden está bloqueada por otro usuario'.
                RETURN.
              CATCH cx_abap_lock_failure.
                rv_msg = 'ERROR: Fallo al intentar bloquear'.
                RETURN.
            ENDTRY.

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

        ENDIF.
        "Liberar el bloqueo al terminar
        lo_lock->dequeue(
            it_parameter = VALUE #( (  name = 'WORK_ORDER_ID' value = REF #( is_data-work_order_id ) ) )
        ).

      ENDMETHOD.

      METHOD delete_work_order.

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

      ENDMETHOD.

ENDCLASS.
