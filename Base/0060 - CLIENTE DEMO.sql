Insert Into CLIENTE (CLIENTE_ID,RAZON_SOCIAL,NOMBRE,CALLE,NUMERO,LOCALIDAD,PROVINCIA_ID,PAIS_ID,CODIGO_POSTAL,
ZONA_ID,EMAIL,TELEFONO_1,TELEFONO_2,TELEFONO_3,FAX,TIPO_DOCUMENTO_ID,NRO_DOCUMENTO,CATEGORIA_CLIENTE_ID,
CATEGORIA_IMPOSITIVA_ID,OBSERVACIONES,REMITO_ID) 
Values ('1','DEMO',Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null) 

Insert Into CATEGORIA_LOGICA(CLIENTE_ID,CAT_LOG_ID,DESCRIPCION,DISP_EGRESO,DISP_TRANSF,categ_stock_id,PICKING, TRANSITO)
 Values ('1','TRAN_ING','PRODUCTOS ASIGNADOS A UN INGRESO','0','0','TRAN_ING','1','0')
 
Insert Into CATEGORIA_LOGICA(CLIENTE_ID,CAT_LOG_ID,DESCRIPCION,DISP_EGRESO,DISP_TRANSF,categ_stock_id,PICKING, TRANSITO)
 Values ('1','TRAN_EGR','PRODUCTOS ASIGNADOS A UN EGRESO','0','0','TRAN_EGR','1','0')
 
Insert Into CATEGORIA_LOGICA(CLIENTE_ID,CAT_LOG_ID,DESCRIPCION,DISP_EGRESO,DISP_TRANSF,categ_stock_id,PICKING, TRANSITO)
 Values ('1','DISPONIBLE','DISPONIBLE','1','1','STOCK','1','0')
 
Insert Into CATEGORIA_LOGICA(CLIENTE_ID,CAT_LOG_ID,DESCRIPCION,DISP_EGRESO,DISP_TRANSF,categ_stock_id,PICKING, TRANSITO)
 Values ('1','ANALISIS_INV','ANALISIS DE INVENTARIO','0','0','STOCK','0','0')
 
Insert Into CATEGORIA_LOGICA(CLIENTE_ID,CAT_LOG_ID,DESCRIPCION,DISP_EGRESO,DISP_TRANSF,categ_stock_id,PICKING, TRANSITO)
 Values ('1','DIF_INV','DIFERENCIA INVENTARIO','0','0','STOCK','0','0')
 
Insert Into CLIENTE_PARAMETROS (CLIENTE_ID,FLG_GUARDADO_CAMAS,PICK_VEHICULO,FLG_GEN_NEWPICKING,FLG_PICKING_CN,
FLG_PALLET_HOMBRE,FLG_CONFIRMACION_POSICION,FLG_CROSSDOCK,TIPO_DOC_CROSSDOCK,NAVE_ID_CROSSDOCK,FLG_CONTROL_APF,
FLG_PALLET_COMPLETO, FLG_CONTROL_PICKING, FLG_SOLICITA_LOTE ,FLG_ACTIVA_PC_PN ,FLG_TOMAR_RUTA ,FLG_CONTROL_EXP)
 Values ('1','0','0','0','0','0','0','0',Null,Null,'0','0','0','0','0','0','0') 