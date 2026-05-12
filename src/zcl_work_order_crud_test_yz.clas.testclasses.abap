*"* use this source file for your ABAP unit test classes
CLASS ltcl_work_order_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: mo_cut TYPE REF TO zcl_work_order_crud_handler_yz. " Class Under Test

    METHODS:
      setup,
      test_create_success FOR TESTING,
      test_create_invalid_customer FOR TESTING,
      test_delete_with_history FOR TESTING
        RAISING
          cx_abap_lock_failure.
ENDCLASS.

CLASS ltcl_work_order_test IMPLEMENTATION.

  METHOD setup.
    " Se ejecuta antes de cada test
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_create_success.
    " Preparar datos de prueba
    DATA(ls_order) = VALUE zworkorder_ot(
        work_order_id = '99999'
        customer_id   = '1' " Asegúrate que este cliente existe en tu tabla de test
        priority      = 'A'
        status        = 'PE' ).

    DATA(lv_msg) = mo_cut->create_work_order( ls_order ).

    " Verificar resultado con la clase de aserción de SAP
    cl_abap_unit_assert=>assert_char_cp(
      act = lv_msg
      exp = 'SUCCESS*'
      msg = 'La creación debería ser exitosa con datos válidos' ).
  ENDMETHOD.

  METHOD test_delete_with_history.
    " Intentar borrar una orden que sabemos tiene historial
    DATA(lv_id) = '10001'. " ID de ejemplo que insertaste en tu setup de datos

    DATA(lv_msg) = mo_cut->delete_work_order( conv #( lv_id ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lv_msg
      exp = 'ERROR*'
      msg = 'No se debe permitir borrar órdenes con historial' ).
  ENDMETHOD.

  METHOD test_create_invalid_customer.
    " Intentamos crear una orden con un cliente que NO existe (ej: 99999999)
        DATA(ls_order) = VALUE zworkorder_ot(
            work_order_id = '88888'
            customer_id   = '99999999'
            priority      = 'B'
            status        = 'PE' ).

        DATA(lv_msg) = mo_cut->create_work_order( ls_order ).

        " El test pasa si el mensaje contiene 'ERROR'
        cl_abap_unit_assert=>assert_char_cp(
          act = lv_msg
          exp = 'ERROR*'
          msg = 'Debería fallar porque el cliente no existe' ).

  ENDMETHOD.

ENDCLASS.
