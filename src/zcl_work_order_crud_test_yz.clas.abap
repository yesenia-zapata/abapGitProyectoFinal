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

    DATA(lv_res) = lo_crud->create_work_order(
      is_data        = VALUE #(
        work_order_id = '100'
        customer_id   = '00000001'
        technician_id = 'T001'
        priority      = 'A'
        status        = 'PE'
        description   = 'Orden de Prueba Inicial' )
        iv_bypass_auth = abap_true
         ).

    out->write( |Crear: { lv_res }| ).

  ENDMETHOD.

  METHOD test_read_work_order.

    DATA(lo_crud) = NEW zcl_work_order_crud_handler_yz( ).

    DATA(ls_data) = lo_crud->read_work_order( '100' ).

    out->write( |Leer Orden 100: { ls_data-description } - Estado: { ls_data-status }| ).

  ENDMETHOD.

  METHOD test_update_work_order.

    DATA(lo_crud) = NEW zcl_work_order_crud_handler_yz( ).

    " Intentamos actualizar el estado a Completado ('CO')

    DATA(lv_res) = lo_crud->update_work_order( VALUE #(
        work_order_id = '100'
        status        = 'CO'
        description   = 'Orden Actualizada' ) ).

    out->write( |Actualizar: { lv_res }| ).

  ENDMETHOD.

  METHOD test_delete_work_order.

    DATA(lo_crud) = NEW zcl_work_order_crud_handler_yz( ).

    " Según requerimiento, esto fallará si ya tiene historial
    DATA(lv_res) = lo_crud->delete_work_order( '100' ).

    out->write( |Eliminar: { lv_res }| ).

  ENDMETHOD.

ENDCLASS.
