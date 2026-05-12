CLASS zcl_work_order_validator_yz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  CONSTANTS:

      BEGIN OF c_priority,
        high TYPE zde_priority_yz VALUE 'A',
        low  TYPE zde_priority_yz VALUE 'B',
      END OF c_priority,

      BEGIN OF c_status,
        PE TYPE zde_status_yz VALUE 'PE',
        CO  TYPE zde_status_yz VALUE 'CO',
      END OF c_status.

  METHODS:
      validate_create_order
        IMPORTING iv_customer_id   TYPE n
                  iv_technician_id TYPE c
                  iv_priority      TYPE c
        RETURNING VALUE(rv_valid)  TYPE abap_bool,

      validate_update_order
        IMPORTING iv_work_order_id TYPE n
                  iv_status        TYPE c
        RETURNING VALUE(rv_valid)  TYPE abap_bool,

      validate_delete_order
        IMPORTING iv_work_order_id TYPE n
                  iv_status TYPE c
         RETURNING VALUE(rv_valid) TYPE abap_bool.


  PROTECTED SECTION.

  PRIVATE SECTION.
  METHODS:

      check_customer_exists
            IMPORTING iv_id TYPE n
            RETURNING VALUE(rv_exists) TYPE abap_bool,

      check_technician_exists
            IMPORTING iv_id TYPE c
            RETURNING VALUE(rv_exists) TYPE abap_bool,

      check_order_exists
            IMPORTING iv_id TYPE n
            RETURNING VALUE(rv_exists) TYPE abap_bool,

      check_order_history
            IMPORTING iv_id TYPE n
            RETURNING VALUE(rv_exists) TYPE abap_bool.


ENDCLASS.



CLASS zcl_work_order_validator_yz IMPLEMENTATION.

    METHOD validate_create_order.
        "El Cliente/Técnico deben existir y prioridad ser A o B
        rv_valid = COND #( WHEN check_customer_exists( iv_customer_id ) = abap_true AND
                                check_technician_exists( iv_technician_id ) = abap_true AND
                                ( iv_priority = c_priority-high OR iv_priority = c_priority-low )
                           THEN abap_true
                           ELSE abap_false
                           ).
      ENDMETHOD.

      METHOD validate_update_order.
        "Solo si existe y estado es 'PE' (Pendiente)
        rv_valid = COND #( WHEN check_order_exists( iv_work_order_id ) = abap_true AND
                                iv_status = c_status-PE
                           THEN abap_true
                           ELSE abap_false
                          ).
      ENDMETHOD.

      METHOD validate_delete_order.

      " Validar que la orden exista
      IF check_order_exists( iv_work_order_id ) = abap_false.
        rv_valid = abap_false.
        RETURN.
      ENDIF.

      "Validar que el estado sea 'PE' (Pendiente)
      IF iv_status <> c_status-PE.
        rv_valid = abap_false.
        RETURN.
      ENDIF.

      "Validar Historial (REQUISITO CRÍTICO)
      IF check_order_history( iv_work_order_id ) = abap_true.
        " Si tiene historial, significa que ha sido modificada y no debe borrarse
        rv_valid = abap_false.
        RETURN.
      ENDIF.

        " Si pasa todos los filtros, permitimos el borrado
        rv_valid = abap_true.
      ENDMETHOD.


      METHOD check_customer_exists.

        SELECT SINGLE @abap_true
        FROM zcustomer_ot
        WHERE customer_id = @iv_id
            INTO @rv_exists.

      ENDMETHOD.

      METHOD check_technician_exists.

        SELECT SINGLE @abap_true
        FROM ztechnician_ot
        WHERE technician_id = @iv_id
            INTO @rv_exists.

      ENDMETHOD.

      METHOD check_order_exists.

        SELECT SINGLE @abap_true
        FROM zworkorder_ot
        WHERE work_order_id = @iv_id
            INTO @rv_exists.

      ENDMETHOD.


    METHOD check_order_history.
      " Verificamos si existe alguna entrada para esta orden en la tabla de historial
      SELECT SINGLE @abap_true
        FROM zworder_hist_ot
        WHERE work_order_id = @iv_id
        INTO @rv_exists.

      " Si no encuentra nada, rv_exists será abap_false por defecto
    ENDMETHOD.



ENDCLASS.
