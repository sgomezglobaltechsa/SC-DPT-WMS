IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_DEV_EGRESO_CON_GUIA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SYS_DEV_EGRESO_CON_GUIA]
GO

CREATE PROCEDURE [dbo].[SYS_DEV_EGRESO_CON_GUIA]      
 @NRO_GUIA AS VARCHAR(100) OUTPUT,    
 @IMPORTE_FLETE NUMERIC(9,2)OUTPUT,
 @PESO_TOTAL NUMERIC(15,3) OUTPUT,
 @TOTAL_BULTOS NUMERIC(10) OUTPUT 
AS      
 DECLARE @QTY AS NUMERIC(10,0)      
 DECLARE @ERRORSAVE INT      
 DECLARE @AUXNROLINEA BIGINT      
 DECLARE @CONTROLEXPEDICION CHAR(1)      
 DECLARE @TIPOCOMP AS VARCHAR(5)      
 DECLARE @USUARIO  AS VARCHAR(20)      
 DECLARE @COUNT  AS SMALLINT      
 DECLARE @CONTROLA AS CHAR(1) 
 DECLARE @CANT_VERIF INT       
 DECLARE @VIAJE_ID AS VARCHAR(100)

BEGIN      

BEGIN TRY

  --///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--INICIO DE VERIFICACION DE CANTIDAD A INFORMAR AL ERP PARA FACTURAR 
    
    SET @CANT_VERIF = 0
    
    SELECT @CANT_VERIF=COUNT(*) FROM     
		(SELECT DOCUMENTO_ID , PRODUCTO_ID , SUM(CANTIDAD) AS CANTIDAD
		FROM DET_DOCUMENTO GROUP BY DOCUMENTO_ID , PRODUCTO_ID) DOC
	INNER JOIN 
		(SELECT DD.DOCUMENTO_ID ,DD.PRODUCTO_ID ,SUM(P.CANT_CONFIRMADA) AS CANT_CONFIRMADA
	     FROM  DET_DOCUMENTO DD        
	     INNER JOIN DOCUMENTO D ON (DD.DOCUMENTO_ID=D.DOCUMENTO_ID)        
	     INNER JOIN PICKING P ON (DD.DOCUMENTO_ID=P.DOCUMENTO_ID AND DD.NRO_LINEA=P.NRO_LINEA)        
	     INNER JOIN UC_EMPAQUE U ON (U.UC_EMPAQUE = P.NRO_UCEMPAQUETADO)
	     WHERE U.NRO_GUIA = @NRO_GUIA
	     GROUP BY DD.DOCUMENTO_ID ,DD.PRODUCTO_ID) 
			PICK ON (PICK.DOCUMENTO_ID = DOC.DOCUMENTO_ID AND PICK.PRODUCTO_ID=DOC.PRODUCTO_ID)
	WHERE DOC.CANTIDAD < PICK.CANT_CONFIRMADA
    
    IF @CANT_VERIF > 0 
			RAISERROR('VERIFICACION DE CANTIDADES FALLIDA AL INFORMAR AL ERP PARA FACTURAR, POR FAVOR NOTIFIQUE A SISTEMAS',16,1)
    
    --FIN DE VERIFICACION DE CANTIDAD A INFORMAR AL ERP PARA FACTURAR 
    --///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
  
--INSERTO CABECERA    
	INSERT INTO SYS_DEV_DOCUMENTO      
	SELECT	DISTINCT       
			SID.CLIENTE_ID,       
			CASE WHEN SID.TIPO_DOCUMENTO_ID='E04' THEN 'E05' WHEN SID.TIPO_DOCUMENTO_ID='E08' THEN 'E09' ELSE SID.TIPO_DOCUMENTO_ID END,       
			SID.CPTE_PREFIJO,       
			SID.CPTE_NUMERO,       
			GETDATE(), --FECHA_CPTE,       
			SID.FECHA_SOLICITUD_CPTE,   --?    
			SID.AGENTE_ID, --?      
			@PESO_TOTAL,--PESO_TOTAL,       
			SID.UNIDAD_PESO,       
			SID.VOLUMEN_TOTAL,       
			SID.UNIDAD_VOLUMEN,       
			@TOTAL_BULTOS,--TOTAL_BULTOS,       
			SID.ORDEN_DE_COMPRA,       
			SID.OBSERVACIONES,       
			CAST(D.CPTE_PREFIJO AS VARCHAR(20)) + CAST(D.CPTE_NUMERO  AS VARCHAR(20)),       
			SID.NRO_DESPACHO_IMPORTACION,       
			SID.DOC_EXT,       
			SID.CODIGO_VIAJE,       
			SID.INFO_ADICIONAL_1,       
			SID.INFO_ADICIONAL_2,       
			SID.INFO_ADICIONAL_3,       
			D.TIPO_COMPROBANTE_ID,        
			NULL,       
			NULL,       
			'P',       
			GETDATE(),      
			NULL, --FLG_MOVIMIENTO
			SID.CUSTOMS_1,
			SID.CUSTOMS_2,
			SID.CUSTOMS_3,
			@NRO_GUIA, --NRO_GUIA
			@IMPORTE_FLETE, --IMPORTE_FLETE
			U.TRANSPORTE_ID, --TRANSPORTE_ID
			SID.INFO_ADICIONAL_4,
			SID.INFO_ADICIONAL_5,
			SID.INFO_ADICIONAL_6
	FROM	SYS_INT_DOCUMENTO SID INNER JOIN DOCUMENTO D	ON (SID.CLIENTE_ID=D.CLIENTE_ID AND SID.DOC_EXT=D.NRO_REMITO)      
			INNER JOIN PICKING P							ON  P.DOCUMENTO_ID = D.DOCUMENTO_ID AND P.CLIENTE_ID = D.CLIENTE_ID    
			INNER JOIN UC_EMPAQUE U							ON U.UC_EMPAQUE = P.NRO_UCEMPAQUETADO 
	WHERE	U.NRO_GUIA = @NRO_GUIA
 
--OBTENGO EL VIAJE: 

DECLARE @CURR_VIAJE CURSOR
SET @CURR_VIAJE = CURSOR FOR   
	SELECT	DISTINCT VIAJE_ID 
	FROM	PICKING P INNER JOIN UC_EMPAQUE UE
			ON (UE.UC_EMPAQUE = P.NRO_UCEMPAQUETADO)
	WHERE	UE.NRO_GUIA = @NRO_GUIA
	
OPEN @CURR_VIAJE
	
FETCH NEXT FROM @CURR_VIAJE INTO  @VIAJE_ID   
WHILE @@FETCH_STATUS = 0                      
BEGIN    	
	
--INSERTO LOS QUE NO SE PROCESARON POR FALTA DE STOCK Y NO ESTAN EN SYS_DEV_DOCUMENTO

INSERT INTO SYS_DEV_DOCUMENTO
SELECT	DISTINCT SID.CLIENTE_ID,
		CASE WHEN SID.TIPO_DOCUMENTO_ID='E04' THEN 'E05' WHEN SID.TIPO_DOCUMENTO_ID='E08' THEN 'E09' ELSE SID.TIPO_DOCUMENTO_ID END, 
		SID.CPTE_PREFIJO, 
		SID.CPTE_NUMERO, 
		GETDATE(), --FECHA_CPTE, 
		SID.FECHA_SOLICITUD_CPTE, 
		SID.AGENTE_ID, 
		SID.PESO_TOTAL, 
		SID.UNIDAD_PESO, 
		SID.VOLUMEN_TOTAL, 
		SID.UNIDAD_VOLUMEN, 
		SID.TOTAL_BULTOS, 
		SID.ORDEN_DE_COMPRA, 
		SID.OBSERVACIONES, 
		NULL, 
		SID.NRO_DESPACHO_IMPORTACION, 
		SID.DOC_EXT, 
		SID.CODIGO_VIAJE, 
		SID.INFO_ADICIONAL_1, 
		SID.INFO_ADICIONAL_2, 
		SID.INFO_ADICIONAL_3, 
		NULL, 	
		NULL, 
		NULL, 
		'P', 
		GETDATE(),
		NULL, --FLG_MOVIMIENTO
		SID.CUSTOMS_1,
		SID.CUSTOMS_2,
		SID.CUSTOMS_3,
		NULL, --NRO_GUIA
		NULL, --IMPORTE_FLETE
		NULL,  --TRANSPORTE_ID
		SID.INFO_ADICIONAL_4,
		SID.INFO_ADICIONAL_5,
		SID.INFO_ADICIONAL_6
FROM	SYS_INT_DOCUMENTO SID
		LEFT JOIN DOCUMENTO D ON (SID.CLIENTE_ID = D.CLIENTE_ID AND SID.DOC_EXT = D.NRO_REMITO)
WHERE	SID.CODIGO_VIAJE = @VIAJE_ID
		--PARA TOMAR SOLO LOS QUE NO TIENEN DOCUMENTO
		AND NOT EXISTS(SELECT 1 FROM DOCUMENTO D2 WHERE D2.DOCUMENTO_ID = D.DOCUMENTO_ID)
		--PARA TOMAR SOLO LOS QUE NO FUERON YA INSERTADOS
		AND NOT EXISTS (SELECT 1 FROM SYS_DEV_DOCUMENTO SDV WHERE SDV.DOC_EXT = SID.DOC_EXT)

 IF @@ERROR <> 0 BEGIN      
  SET @ERRORSAVE = @@ERROR      
  RAISERROR('ERROR AL INSERTAR EN SYS_DEV_DOCUMENTO, CODIGO_ERROR: %S',16,1,@ERRORSAVE)      
  RETURN      
 END     
--INSERTO DETALLE    

--INSERTO LOS PRODUCTOS QUE NO SE CARGARON EN EL DOCUMENTO Y TAMBIEN
--LOS DE LOS DOC_EXT QUE NO SE PROCESARON

	INSERT INTO SYS_DEV_DET_DOCUMENTO
	SELECT	 SIDD.DOC_EXT
			,SIDD.NRO_LINEA
			,SIDD.CLIENTE_ID
			,SIDD.PRODUCTO_ID
			,SIDD.CANTIDAD_SOLICITADA
			,'0' --CANTIDAD CONFIRMADA
			,SIDD.EST_MERC_ID
			,SIDD.CAT_LOG_ID
			,NULL AS NRO_BULTO
			,SIDD.DESCRIPCION
			,SIDD.NRO_LOTE
			,SIDD.NRO_PALLET
			,SIDD.FECHA_VENCIMIENTO
			,SIDD.NRO_DESPACHO
			,SIDD.NRO_PARTIDA
			,SIDD.UNIDAD_ID
			,NULL AS UNIDAD_CONTENEDORA_ID
			,NULL AS PESO
			,NULL AS UNIDAD_PESO
			,NULL AS VOLUMEN
			,NULL AS UNIDAD_VOLUMEN
			,NULL AS PROP1
			,NULL AS PROP2
			,NULL AS PROP3
			,NULL AS LARGO
			,NULL AS ALTO
			,NULL AS ANCHO
			,NULL AS DOC_BACK_ORDER
			,NULL AS ESTADO
			,NULL AS FECHA_ESTADO
			,'P' AS ESTADO_GT
			,GETDATE() AS FECHA_ESTADO_GT
			,NULL AS DOCUMENTO_ID
			,NULL AS NAVE_ID
			,NULL AS NAVE_COD
			,NULL --FLG_MOVIMIENTO
			,SIDD.CUSTOMS_1
			,SIDD.CUSTOMS_2
			,SIDD.CUSTOMS_3
			,NULL --NRO DE CMR
	FROM	SYS_INT_DET_DOCUMENTO SIDD
			INNER JOIN SYS_INT_DOCUMENTO SID ON (SID.CLIENTE_ID = SIDD.CLIENTE_ID AND SID.DOC_EXT = SIDD.DOC_EXT)
			LEFT JOIN DOCUMENTO D ON (SIDD.CLIENTE_ID = D.CLIENTE_ID AND SIDD.DOCUMENTO_ID = D.DOCUMENTO_ID)
			--LEFT JOIN DET_DOCUMENTO DD ON (SIDD.DOCUMENTO_ID = DD.DOCUMENTO_ID AND SIDD.CLIENTE_ID = D.CLIENTE_ID)
	WHERE	SID.CODIGO_VIAJE = @VIAJE_ID
			AND SIDD.PRODUCTO_ID NOT IN (SELECT DISTINCT PRODUCTO_ID FROM DET_DOCUMENTO WHERE DOCUMENTO_ID = D.DOCUMENTO_ID)
			AND SID.DOC_EXT NOT IN (SELECT DOC_EXT FROM SYS_DEV_DET_DOCUMENTO WHERE DOC_EXT = SID.DOC_EXT)
			AND SID.DOC_EXT IN (SELECT DOC_EXT FROM SYS_DEV_DOCUMENTO WHERE DOC_EXT = SID.DOC_EXT)
	
	IF @@ERROR <> 0 BEGIN      
		SET @ERRORSAVE = @@ERROR      
		RAISERROR('ERROR AL INSERTAR EN SYS_DEV_DET_DOCUMENTO, CODIGO_ERROR: %S',16,1,@ERRORSAVE)      
		RETURN      
	END  
   
FETCH NEXT FROM @CURR_VIAJE INTO @VIAJE_ID   
  
END       
CLOSE @CURR_VIAJE
DEALLOCATE @CURR_VIAJE

	INSERT INTO SYS_DEV_DET_DOCUMENTO      
	SELECT	 D.NRO_REMITO AS DOC_EXT      
			,(P.PICKING_ID) AS NRO_LINEA      
			,DD.CLIENTE_ID      
			,DD.PRODUCTO_ID      
			,DD.CANT_SOLICITADA      
			,P.CANT_CONFIRMADA      
			,DD.EST_MERC_ID      
			,DD.CAT_LOG_ID_FINAL      
			,NULL AS NRO_BULTO      
			,DD.DESCRIPCION      
			,DD.NRO_LOTE      
			,DD.PROP1 AS NRO_PALLET      
			,DD.FECHA_VENCIMIENTO      
			,NULL AS NRO_DESPACHO      
			,DD.NRO_PARTIDA      
			,UNIDAD_ID      
			,NULL AS UNIDAD_CONTENEDORA_ID      
			,NULL AS PESO      
			,NULL AS UNIDAD_PESO      
			,NULL AS VOLUMEN      
			,NULL AS UNIDAD_VOLUMEN      
			,DBO.GET_PROPERTY(DD.CLIENTE_ID,D.NRO_REMITO,DD.PRODUCTO_ID,1) AS PROP1      
			,DBO.GET_PROPERTY(DD.CLIENTE_ID,D.NRO_REMITO,DD.PRODUCTO_ID,2) AS PROP2      
			,DBO.GET_PROPERTY(DD.CLIENTE_ID,D.NRO_REMITO,DD.PRODUCTO_ID,3) AS PROP3      
			,NULL AS LARGO      
			,NULL AS ALTO      
			,DD.NRO_LINEA AS ANCHO --NRO DE LINEA      
			,NULL AS DOC_BACK_ORDER      
			,NULL AS ESTADO      
			,NULL AS FECHA_ESTADO      
			,'P' AS ESTADO_GT      
			,GETDATE() AS FECHA_ESTADO_GT      
			,P.DOCUMENTO_ID      
			,DBO.AJ_NAVECOD_TO_NAVE_ID(P.NAVE_COD) AS NAVE_ID      
			,P.NAVE_COD       
			,NULL  --FLG_MOVIMIENTO
			,NULL
			,NULL
			,NULL   
			,NULL  --NRO_CMR 
	FROM	DET_DOCUMENTO DD      
			INNER JOIN DOCUMENTO D		ON (DD.DOCUMENTO_ID=D.DOCUMENTO_ID)      
			INNER JOIN PICKING P		ON (DD.DOCUMENTO_ID=P.DOCUMENTO_ID AND DD.NRO_LINEA=P.NRO_LINEA)      
			INNER JOIN UC_EMPAQUE U		ON U.UC_EMPAQUE = P.NRO_UCEMPAQUETADO 
	WHERE	U.NRO_GUIA = @NRO_GUIA

--SE DESHABILITA ESTE SP QUE SOLO AGRUPA LOS REGISTROS DE SYS_DEV_DET_DOCUMENTO
--ESTE EN CIERTOS CASOS, MUY POCOS, NO DEJA EN LA SYS_DEV_DET_DOCUMENTO LOS REGISTROS QUE CORRESPONDEN
--EXEC DBO.PEDIDOMULTIPRODUCTO_HOJACARGA @NRO_GUIA
 
DECLARE @CLIENTE_ID VARCHAR(30)
DECLARE @PEDIDO VARCHAR(100)
DECLARE @CURR_DOC CURSOR
SET @CURR_DOC = CURSOR FOR           
	SELECT	DISTINCT     
			P.CLIENTE_ID,      
			D.NRO_REMITO      
	FROM PICKING P      
	INNER JOIN DOCUMENTO D ON D.DOCUMENTO_ID = P.DOCUMENTO_ID      
	INNER JOIN UC_EMPAQUE U ON P.NRO_UCEMPAQUETADO = U.UC_EMPAQUE      
	WHERE U.NRO_GUIA = @NRO_GUIA    
OPEN @CURR_DOC      
FETCH NEXT FROM @CURR_DOC INTO @CLIENTE_ID,@PEDIDO      
WHILE @@FETCH_STATUS = 0                      
BEGIN    
	--NOTIFICACION DE EGRESO PARA EL ERP       
	BEGIN TRY
		EXEC ERP_CARGAR_DATOS @CLIENTE_ID, @PEDIDO
	END TRY
	BEGIN CATCH
		set @cliente_id=@CLIENTE_ID
	END CATCH
	FETCH NEXT FROM @CURR_DOC INTO @CLIENTE_ID,@PEDIDO      
END       
CLOSE @CURR_DOC      
DEALLOCATE @CURR_DOC   


 IF @@ERROR <> 0 BEGIN      
  SET @ERRORSAVE = @@ERROR      
  RAISERROR('ERROR AL INSERTAR EN SYS_DEV_DET_DOCUMENTO, CODIGO_ERROR: %S',16,1,@ERRORSAVE)      
  RETURN      
 END      
      
 IF @@ERROR <> 0 BEGIN      
  SET @ERRORSAVE = @@ERROR      
  RAISERROR('ERROR AL REALIZAR LA ACTUALIZACION EN CIERRE DE PICKING, CODIGO_ERROR: %S',16,1,@ERRORSAVE)      
  RETURN      
 END      
END TRY
BEGIN CATCH
  EXEC USP_RETHROWERROR
END CATCH
      
END

GO

