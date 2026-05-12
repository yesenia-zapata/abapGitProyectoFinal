CLASS zcl_load_master_data_yz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_load_master_data_yz IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM zcustomer_ot.

    DELETE FROM ztechnician_ot.

    INSERT zcustomer_ot FROM @( VALUE #( customer_id = '00000001' name = 'Logali' ) ).

    INSERT ztechnician_ot FROM @( VALUE #( technician_id = 'T001' name = 'Admin' ) ).

    out->write( 'Datos maestros cargados' ).

  ENDMETHOD.

ENDCLASS.
