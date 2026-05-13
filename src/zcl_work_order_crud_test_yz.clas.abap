CLASS zcl_work_order_crud_test_yz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    " Métodos de prueba según requerimiento
    METHODS:
      test_create_work_order IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      test_read_work_order   IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      test_update_work_order IMPORTING out TYPE REF TO if_oo_adt_classrun_out
                             RAISING
                               cx_abap_lock_failure,
      test_delete_work_order IMPORTING out TYPE REF TO if_oo_adt_classrun_out
                             RAISING
                               cx_abap_lock_failure.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_work_order_crud_test_yz IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  " Ejecución organizada de todas las pruebas
    out->write( '--- INICIO DE PRUEBAS CRUD ---' ).
    " Agregamos un TRY general para capturar excepciones no controladas
    TRY.
        test_create_work_order( out ).
        test_read_work_order( out ).
        test_update_work_order( out ).
        test_delete_work_order( out ).

      CATCH cx_root INTO DATA(lx_root).
        out->write( |ERROR FATAL: { lx_root->get_text( ) }| ).
    ENDTRY.

    out->write( '--- FIN DE PRUEBAS CRUD ---' ).

  ENDMETHOD.

  METHOD test_create_work_order.

    DATA(lo_crud) = NEW zcl_work_order_crud_handler_yz( ).

  " Limpiar datos previos de la orden de prueba
  "no se si con el requerimiento inicial es necesario, pero lo agrego para evitar errores por datos existentes
  DELETE FROM zworder_hist_ot WHERE work_order_id = '100'.
  DELETE FROM zworkorder_ot   WHERE work_order_id = '100'.

    DATA(lv_res) = lo_crud->create_work_order(
      is_data = VALUE #(
        work_order_id = '100'
        customer_id   = '00000001'
        technician_id = 'T001'
        priority      = 'A'
        status        = 'PE'
        description   = 'Orden de Prueba Inicial'
        creation_date = cl_abap_context_info=>get_system_date( ) )
      iv_bypass_auth = abap_true ).

    out->write( |Crear: { lv_res }| ).

  ENDMETHOD.

  METHOD test_read_work_order.

    DATA(lo_crud) = NEW zcl_work_order_crud_handler_yz( ).

    DATA(ls_data) = lo_crud->read_work_order(
      iv_id          = '100'
      iv_bypass_auth = abap_true ).

    out->write( |Leer Orden 100: { ls_data-description } - Estado: { ls_data-status }| ).

  ENDMETHOD.

  METHOD test_update_work_order.

    DATA(lo_crud) = NEW zcl_work_order_crud_handler_yz( ).

    " Leemos primero para no perder datos del registro
    DATA(ls_data) = lo_crud->read_work_order(
      iv_id          = '100'
      iv_bypass_auth = abap_true ).

    ls_data-status      = 'CO'.
    ls_data-description = 'Orden Actualizada'.

    " Intentamos actualizar el estado a Completado ('CO')
    DATA(lv_res) = lo_crud->update_work_order(
      is_data         = ls_data
      iv_bypass_auth  = abap_true ).

    out->write( |Actualizar: { lv_res }| ).

  ENDMETHOD.

  METHOD test_delete_work_order.

    DATA(lo_crud) = NEW zcl_work_order_crud_handler_yz( ).

    DATA(lv_res) = lo_crud->delete_work_order(
      iv_id          = '100'
      iv_bypass_auth = abap_true ).

    out->write( |Eliminar: { lv_res }| ).

  ENDMETHOD.

ENDCLASS.
