*&---------------------------------------------------------------------*
*& Include          ZTEST_P_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK block WITH FRAME TITLE title.

      SELECT-OPTIONS : s_ebeln FOR EKKO-EBELN.
      SELECT-OPTIONS : s_matnr FOR EKPO-MATNR.


SELECTION-SCREEN END OF BLOCK block.


INITIALIZATION.
  title = 'selection item'.