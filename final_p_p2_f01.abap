*&---------------------------------------------------------------------*
*& Include          ZTEST_P_F01
*&------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          Z_POEC_GCO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .


    SELECT DISTINCT
  
      zekko_gco~ebeln,
      zekko_gco~bstyp,
      zekko_gco~aedat,
      zekko_gco~ernam,
      zekko_gco~waers
  
  
      FROM zekko_gco
      INNER JOIN zekpo_gco  ON zekko_gco~ebeln = zekpo_gco~ebeln
  
      WHERE
      zekko_gco~ebeln IN @s_ebeln
      AND zekpo_gco~matnr IN @s_matnr
  
      ORDER BY zekko_gco~ebeln ASCENDING
*    INTO TABLE @DATA(LT_ZEKKO) .
      INTO CORRESPONDING FIELDS OF TABLE @gt_zekko_gco .
  
  
  
**Si le purchasing document est saisi et n'est pas présent dans la table d'entête (ZEKKO_XXX),
*un message d'erreur apparaitra :
*Purchasing document xxx not found in table ZEKKO_XXX"
*Pas de controle sur le matériel
    IF sy-subrc <> 0 AND s_ebeln-low IS NOT INITIAL .
      MESSAGE : 'Purchasing document :'  && s_ebeln-low && ' not found in table ZEKKO_GCO ' TYPE 'I' .
      LEAVE LIST-PROCESSING.
    ELSEIF sy-subrc <> 0 AND s_matnr-low IS INITIAL.
      MESSAGE : 'Table ZEKKO_GCO empty ' TYPE 'I' .
      LEAVE LIST-PROCESSING.
    ENDIF.
  
  
  
    SELECT
  
      zekpo_gco~ebeln,
      zekpo_gco~ebelp,
      zekpo_gco~matnr,
      zekpo_gco~werks,
      zekpo_gco~menge,
      zekpo_gco~netpr,
      zekpo_gco~netwr,
      zekpo_gco~meins
  
    FROM zekko_gco
    LEFT OUTER JOIN zekpo_gco  ON zekko_gco~ebeln = zekpo_gco~ebeln
    WHERE
    zekko_gco~ebeln IN @s_ebeln
    AND zekpo_gco~matnr IN @s_matnr
  
    ORDER BY zekpo_gco~ebeln,zekpo_gco~ebelp ASCENDING
*  INTO TABLE @DATA(LT_ZEKPO) .
    INTO CORRESPONDING FIELDS OF TABLE @gt_zekpo_gco .
  
  ***************
  *TABLES:
  *LT_ZEKKO
  *LT_ZEKPO
  *GT_ZEKKO_GCO
  ***************
  
  *  DATA : LO_ALV TYPE REF TO CL_SALV_TABLE.
  *
  *  CL_SALV_TABLE=>FACTORY(
  *  IMPORTING
  *    R_SALV_TABLE = LO_ALV
  *  CHANGING
  *    T_TABLE      = GT_ZEKKO_GCO ).
  *
  *  LO_ALV->DISPLAY( ).
  
  
  
  
  
  
  
  
  ENDFORM.
  
  CLASS lcl_events DEFINITION.
    PUBLIC SECTION.
  
      CLASS-METHODS handle_double_click
        FOR EVENT if_salv_events_actions_table~double_click
        OF cl_salv_events_table
        IMPORTING row
                  column.
  ENDCLASS.
  
  
  CLASS lcl_events IMPLEMENTATION.
    METHOD handle_double_click.
  
      CLEAR gs_zekko_gco.
      READ TABLE gt_zekko_gco INTO gs_zekko_gco INDEX row.
      PERFORM actions_double_click.
*    MESSAGE : 'EBELN:' && GS_ZEKKO_GCO-EBELN TYPE 'I' .
*    MESSAGE : 'ROW:' && ROW && ' COLUMN:' && COLUMN  TYPE 'I' .
*    BREAK-POINT.
  
    ENDMETHOD.
  ENDCLASS.
  
  
  
  *&---------------------------------------------------------------------*
  *& Form DUAL_ALV
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM dual_alv .
  
  
  
    TRY.
  
        o_splitter_main = NEW cl_gui_splitter_container( parent = cl_gui_container=>screen0
                                                     no_autodef_progid_dynnr = abap_true
                                                     rows = 1
                                                     columns = 2 ).
  
        o_splitter_main->set_column_width( id = 1 width = 50 ).
        o_container_left = o_splitter_main->get_container( row = 1 column = 1 ).
        o_container_right = o_splitter_main->get_container( row = 1 column = 2 ).
  
  
  
  *****************
* grid 1
  *****************
  
        cl_salv_table=>factory( EXPORTING
                                    r_container    = o_container_left
                                  IMPORTING
                                    r_salv_table   = o_salv_left
                                  CHANGING
                                    t_table        = gt_zekko_gco ).
  
        """"""""""""""""""""""""""""""""""""
        ""DOUBLE CLICK HANDLER""""""""""""""
        """"""""""""""""""""""""""""""""""""
        o_events = o_salv_left->get_event( ).
        SET HANDLER lcl_events=>handle_double_click FOR o_events.
  
  
        o_salv_left->get_functions( )->set_all( ).
        o_salv_left->get_columns( )->set_optimize( abap_true ).
        o_salv_left->get_display_settings( )->set_list_header( 'HEADER' ).
        o_salv_left->get_display_settings( )->set_striped_pattern( abap_true ).
        o_salv_left->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).
  
        o_salv_left->display( ).
  
  *****************
* grid 2
  *****************
  
        cl_salv_table=>factory( EXPORTING
                                    r_container    = o_container_right
                                  IMPORTING
                                    r_salv_table   = o_salv_right
                                  CHANGING
                                    t_table        = gt_zekpo_gco ).
  
        o_salv_right->get_functions( )->set_all( ).
        o_salv_right->get_columns( )->set_optimize( abap_true ).
        o_salv_right->get_display_settings( )->set_list_header( 'ITEM' ).
        o_salv_right->get_display_settings( )->set_striped_pattern( abap_true ).
        o_salv_right->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).
  
  
  
        WRITE space.
  
      CATCH cx_salv_msg.
  
    ENDTRY.
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form ACTIONS_DOUBLE_CLICK
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM actions_double_click .
  
    CLEAR gt_zekpo_gco.
  
    DATA : lv_ebeln TYPE ebeln.
  
    lv_ebeln  = gs_zekko_gco-ebeln.
  
  
    SELECT
      zekpo_gco~mandt,
      zekpo_gco~ebeln,
      zekpo_gco~ebelp,
      zekpo_gco~matnr,
      zekpo_gco~werks,
      zekpo_gco~menge,
      zekpo_gco~netpr,
      zekpo_gco~netwr,
      zekpo_gco~meins
  
    FROM zekko_gco
    LEFT OUTER JOIN zekpo_gco  ON zekko_gco~ebeln = zekpo_gco~ebeln
  
    WHERE zekko_gco~ebeln = @lv_ebeln
  
    ORDER BY zekpo_gco~ebeln,zekpo_gco~ebelp ASCENDING
    INTO CORRESPONDING FIELDS OF TABLE @gt_zekpo_gco .
  
  
    o_salv_right->refresh( ).
    o_salv_right->display( ).
  
  
  
  
  ENDFORM.