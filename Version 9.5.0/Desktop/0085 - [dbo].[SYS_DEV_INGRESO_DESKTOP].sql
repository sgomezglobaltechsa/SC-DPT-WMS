
/****** Object:  StoredProcedure [dbo].[SYS_DEV_INGRESO_DESKTOP]    Script Date: 06/22/2015 11:46:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_DEV_INGRESO_DESKTOP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SYS_DEV_INGRESO_DESKTOP]
GO

CREATE PROCEDURE [dbo].[SYS_DEV_INGRESO_DESKTOP]
	@DOCUMENTO_ID AS NUMERIC(20,0) OUTPUT
AS
	DECLARE @DOC_EXT			AS VARCHAR(100)
	DECLARE @STATUS_DOC			AS VARCHAR(10)
	DECLARE @QTY				AS NUMERIC(3,0)
	DECLARE @ERRORSAVE			INT
	DECLARE @E_SP				AS VARCHAR(2)
	DECLARE @CLIENTE_ID			AS VARCHAR(30)
	DECLARE @TempDocumento_id	AS VARCHAR(100)
	DECLARE @TempTipoComp		AS VARCHAR(10)
	
BEGIN

	BEGIN
	
		--ME FIJO SI EL DOCUMENTO YA ESTA FINALIZADO
		
		SELECT @STATUS_DOC=STATUS FROM DOCUMENTO WHERE DOCUMENTO_ID = @DOCUMENTO_ID
		
		IF @STATUS_DOC <> 'D40'
			RETURN
		ELSE
		
		--HAGO LA DEVOLUCION EN BASE A LOS DATOS DEL DOCUMENTO
		INSERT INTO SYS_DEV_DOCUMENTO
		SELECT	DISTINCT	D.CLIENTE_ID
				--,CASE WHEN D.TIPO_COMPROBANTE_ID='IM' THEN 'I08' WHEN D.TIPO_COMPROBANTE_ID='DE' THEN 'I08' WHEN D.TIPO_COMPROBANTE_ID='DO' THEN 'I02' ELSE D.TIPO_COMPROBANTE_ID END
				,CASE	
				WHEN D.TIPO_COMPROBANTE_ID='I01' THEN 'I02'
				ELSE D.TIPO_COMPROBANTE_ID END
				,D.CPTE_PREFIJO
				,D.CPTE_NUMERO
				,GETDATE()
				,D.FECHA_CPTE
				,D.SUCURSAL_ORIGEN
				,D.PESO_TOTAL
				,D.UNIDAD_PESO
				,D.VOLUMEN_TOTAL
				,D.UNIDAD_VOLUMEN
				,D.TOTAL_BULTOS
				,D.ORDEN_DE_COMPRA
				,D.OBSERVACIONES
				,CAST(D.CPTE_PREFIJO AS VARCHAR(20)) + '-' + CAST(D.CPTE_NUMERO  AS VARCHAR(20))
				,D.NRO_DESPACHO_IMPORTACION
				,CASE WHEN D.TIPO_COMPROBANTE_ID ='DE' 
				 THEN 'DEV'
				 ELSE D.TIPO_COMPROBANTE_ID + '-' END 
				 + CAST(D.DOCUMENTO_ID AS VARCHAR(100))				
				,D.NRO_DESPACHO_IMPORTACION--CODIGO_VIAJE
				,NULL
				,NULL
				,NULL
				,D.TIPO_COMPROBANTE_ID
				,NULL
				,NULL
				,'P'
				,GETDATE()
				,NULL --FLG_MOVIMIENTO
				,NULL --CUSTOMS_1
				,NULL --CUSTOMS_2
				,NULL --CUSTOMS_3
				,NULL AS NRO_GUIA
				,NULL AS IMPORTE_FLETE
				,NULL AS TRANSPORTE_ID
				,NULL
				,NULL
				,NULL
		FROM	DOCUMENTO D	
		WHERE	DOCUMENTO_ID = @DOCUMENTO_ID
			
	IF @@ERROR <> 0 
	BEGIN
		SET @ERRORSAVE = @@ERROR
		RAISERROR('ERROR AL INSERTAR EN SYS_DEV_DOCUMENTO, CODIGO_ERROR: %S',16,1,@ERRORSAVE)
		RETURN
	END
	
	INSERT INTO SYS_DEV_DET_DOCUMENTO
	SELECT	 CASE WHEN D.TIPO_COMPROBANTE_ID ='DE' 
			 THEN 'DEV'
			ELSE D.TIPO_COMPROBANTE_ID + '-' END 
			+ CAST(D.DOCUMENTO_ID AS VARCHAR(100))
			,DD.NRO_LINEA
			,DD.CLIENTE_ID
			,DD.PRODUCTO_ID
			,DD.CANTIDAD
			,DD.CANTIDAD
			,DD.EST_MERC_ID
			,DD.CAT_LOG_ID_FINAL
			,DD.NRO_BULTO
			,DD.DESCRIPCION
			,DD.NRO_LOTE
			,DD.PROP1 AS NRO_PALLET
			,DD.FECHA_VENCIMIENTO
			,DD.NRO_DESPACHO
			,DD.NRO_PARTIDA
			,DD.UNIDAD_ID
			,NULL AS UNIDAD_CONTENEDORA_ID
			,NULL AS PESO
			,NULL AS UNIDAD_PESO
			,NULL AS VOLUMEN
			,NULL AS UNIDAD_VOLUMEN
			,DD.PROP1--DBO.GET_PROPERTY(DD.CLIENTE_ID,D.NRO_REMITO,DD.PRODUCTO_ID,1) AS PROP1
			,DD.PROP2--DBO.GET_PROPERTY(DD.CLIENTE_ID,D.NRO_REMITO,DD.PRODUCTO_ID,2) AS PROP2
			,DD.PROP3--DBO.GET_PROPERTY(DD.CLIENTE_ID,D.NRO_REMITO,DD.PRODUCTO_ID,3) AS PROP3
			,NULL AS LARGO
			,NULL AS ALTO
			,NULL AS ANCHO
			,NULL AS DOC_BACK_ORDER
			,NULL AS ESTADO
			,NULL AS FECHA_ESTADO
			,'P' AS ESTADO_GT
			,GETDATE() AS FECHA_ESTADO_GT
			,D.DOCUMENTO_ID
			,DBO.GET_NAVE_ID(DD.DOCUMENTO_ID,DD.NRO_LINEA)
			,DBO.GET_NAVE_COD(DD.DOCUMENTO_ID,DD.NRO_LINEA)
			,NULL--FLG_MOVIMIENTO
			,NULL--CUSTOMS_1
			,NULL--CUSTOMS_2
			,NULL--CUSTOMS_3
			,CMR.NRO_CMR AS NRO_CRM
	FROM 	DET_DOCUMENTO DD	INNER JOIN DOCUMENTO D 
			ON (DD.DOCUMENTO_ID=D.DOCUMENTO_ID)
			LEFT JOIN NROCMR_POR_DOCUMENTO CMR (NOLOCK)	
			ON (CMR.CLIENTE_ID = D.CLIENTE_ID AND CMR.DOCUMENTO_ID = D.DOCUMENTO_ID	AND CMR.NRO_LINEA = DD.NRO_LINEA)
	WHERE
			D.DOCUMENTO_ID = @DOCUMENTO_ID
			
    SELECT  @E_SP=ISNULL(VALOR,'0')
    FROM    SYS_PARAMETRO_PROCESO
    WHERE   PROCESO_ID='DEV'
            AND SUBPROCESO_ID='EJECUTA_SP'
            AND PARAMETRO_ID='E_SP';
                
    if @e_sp='1' begin        
		
		SELECT	@cliente_id=CLIENTE_ID,
				@TempDocumento_id=	CASE WHEN D.TIPO_COMPROBANTE_ID ='DE' 
									THEN 'DEV'
									ELSE D.TIPO_COMPROBANTE_ID + '-' END 
									+ CAST(D.DOCUMENTO_ID AS VARCHAR(100)),
				@TempTipoComp = D.TIPO_COMPROBANTE_ID
		FROM	DOCUMENTO D
		WHERE	DOCUMENTO_ID=@DOCUMENTO_ID
		
		BEGIN TRY
		
		    if @TempTipoComp = 'DE'
				exec dbo.ERP_CARGAR_DATOS @cliente_id, @TempDocumento_id
			else	
				exec dbo.ERP_INGRESOS @cliente_id, @TempDocumento_id 
			
			INSERT INTO AUDITORIA_ERP_INGRESOS VALUES(GETDATE(),@CLIENTE_ID,@TempDocumento_id,'OK','ADMIN',HOST_NAME(),'DESKTOP',NULL,@DOCUMENTO_ID);
			
		END TRY
		BEGIN CATCH
		
			INSERT INTO AUDITORIA_ERP_INGRESOS VALUES(GETDATE(),@CLIENTE_ID,@TempDocumento_id,'ERROR','ADMIN',HOST_NAME(),'DESKTOP',ERROR_MESSAGE(),@DOCUMENTO_ID);						
			
		END CATCH
    end;

	IF @@ERROR <> 0 
	BEGIN
		SET @ERRORSAVE = @@ERROR
		RAISERROR('ERROR AL INSERTAR EN SYS_DEV_DET_DOCUMENTO, CODIGO_ERROR: %S',16,1,@ERRORSAVE)
		RETURN
	END
	
	END
END


GO


