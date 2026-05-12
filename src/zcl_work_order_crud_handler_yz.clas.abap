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
        RETURNING VALUE(rv_msg) TYPE string,

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
