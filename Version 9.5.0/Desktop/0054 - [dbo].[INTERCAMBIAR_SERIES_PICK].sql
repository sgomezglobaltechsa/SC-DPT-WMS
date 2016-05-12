
/****** Object:  StoredProcedure [dbo].[INTERCAMBIAR_SERIES_PICK]    Script Date: 05/06/2015 15:45:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INTERCAMBIAR_SERIES_PICK]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[INTERCAMBIAR_SERIES_PICK]
GO

CREATE PROCEDURE [dbo].[INTERCAMBIAR_SERIES_PICK]
(
 @CLIENTE_ID		VARCHAR(15),
 @PRODUCTO_ID		VARCHAR(30),
 @VIAJE_ID			VARCHAR(100),
 @NRO_SERIE_ACTUAL	VARCHAR(50),
 @NRO_SERIE_NUEVA	VARCHAR(50),
 @OUT				VARCHAR(1) OUTPUT
)

AS 
BEGIN
	SET XACT_ABORT ON
    DECLARE @EXISTE_EN_PICKING_SN	INT
    DECLARE @DOC_TRANS_ID_EGR_AC	NUMERIC(20,0)
    DECLARE @DOC_TRANS_ID_EGR_NW	NUMERIC(20,0)
    DECLARE @NRO_LINEA_TRANS_EGR_AC NUMERIC(20,0)
    DECLARE @NRO_LINEA_TRANS_EGR_NW NUMERIC(20,0)
    DECLARE @RL_ACTUAL				NUMERIC(20,0)
    DECLARE @RL_NUEVA				NUMERIC(20,0)
    DECLARE @PICKING_ACTUAL			NUMERIC(20,0)
    DECLARE @PICKING_NUEVA			NUMERIC(20,0)
    DECLARE @DOCID_AC				NUMERIC(20,0)
    DECLARE @DOCID_NW				NUMERIC(20,0)
    DECLARE @NROLINEA_AC			NUMERIC(20,0)
    DECLARE @NROLINEA_NW			NUMERIC(20,0)
    DECLARE @DOC_ID_ING_NUEVA		NUMERIC(20,0)
    DECLARE @NRO_LINEA_ING_NUEVA	NUMERIC(20,0)
    DECLARE @CAT_LOG_ID_FINAL		VARCHAR(50)
    DECLARE @PreEgrId				NUMERIC(20,0)
    DECLARE @PALLET_HOMBRE			VARCHAR(1)
    DECLARE @USUARIO_AC				VARCHAR(20)
    DECLARE @PALLET_PICKING_AC		NUMERIC(20,0)
    DECLARE @FECHA_INICIO_AC		DATETIME
    DECLARE @USUARIO_NW				VARCHAR(20)
    DECLARE @PALLET_PICKING_NW		NUMERIC(20,0)
    DECLARE @FECHA_INICIO_NW		DATETIME
    DECLARE @FINICIO				DATETIME
    DECLARE @USUARIOPICK			VARCHAR(20)
    DECLARE @PALLET_PICKING			NUMERIC(20,0)
    DECLARE @PERMUTACION			NUMERIC(20,0)
	DECLARE	@RL_ORIGEN				NUMERIC(20,0)
	DECLARE	@DOC_TR_ORIGEN			NUMERIC(20,0)
	DECLARE	@LIN_TR_ORIGEN			NUMERIC(20,0)
	DECLARE @DOC_ORIGEN				NUMERIC(20,0)
	DECLARE @LIN_ORIGEN				NUMERIC(20,0)
	DECLARE @RL_DESTINO				NUMERIC(20,0)
	DECLARE @DOC_TR_DESTINO			NUMERIC(20,0)
	DECLARE @LIN_TR_DESTINO			NUMERIC(20,0)
	DECLARE @DOC_DESTINO			NUMERIC(20,0)
	DECLARE @LIN_DESTINO			NUMERIC(20,0)
	DECLARE @F_INICIO_SERIE_NUEVA	DATETIME
	DECLARE @PLT_PICK_SERIE_NUEVA	VARCHAR(100)
	DECLARE @USUARIO_SERIE_NUEVA	VARCHAR(100)
	DECLARE @VIAJE_ID_CTRL			VARCHAR(100)
	DECLARE @MSG					VARCHAR(1000)
    BEGIN TRY
		/*
		SET @MSG= 'CLIENTE_ID: ' + @CLIENTE_ID + ', PRODUCTO_ID: ' + @PRODUCTO_ID + ', VIAJE_ID: ' + @VIAJE_ID + ', SERIE ACT.: ' + @NRO_SERIE_ACTUAL + ', SERIE NUEVA: ' + @NRO_SERIE_NUEVA
		RAISERROR(@MSG,16,1)
		*/ 
        SELECT @PALLET_HOMBRE=flg_pallet_hombre
        FROM cliente_parametros
        WHERE CLIENTE_ID=@CLIENTE_ID
              
		--ENCUENTRO LA NAVE DE PRE EGRESO
              
        SELECT @PreEgrId=Nave_Id
        FROM Nave
        WHERE Pre_Egreso='1' --SI LLEGUE ACA ES PORQUE LAS 2 SERIES SON VALIDAS.
        
        --ME FIJO SI LA SERIE NUEVA EXISTE EN PICKING Y NO FUE PICKEADA      
        SELECT	@EXISTE_EN_PICKING_SN=COUNT(*)
        FROM	PICKING
        WHERE	CLIENTE_ID=@CLIENTE_ID 
				AND PRODUCTO_ID=@PRODUCTO_ID 
				AND NRO_SERIE=@NRO_SERIE_NUEVA
				AND VIAJE_ID=@VIAJE_ID
				AND FECHA_FIN IS NULL
        
        IF @EXISTE_EN_PICKING_SN>0
        BEGIN --LA SERIE EXISTE EN PICKING
        
			SELECT	@VIAJE_ID_CTRL=VIAJE_ID
			FROM	PICKING
			WHERE	NRO_SERIE=@NRO_SERIE_ACTUAL
			--cambio tarea tomada
			IF @VIAJE_ID=@VIAJE_ID_CTRL BEGIN
				--PARA CUANDO EL VIAJE ES EL MISMO
				SELECT	@FINICIO=FECHA_INICIO,@USUARIOPICK=USUARIO,@PALLET_PICKING=PALLET_PICKING
				FROM	PICKING
				WHERE	CLIENTE_ID=@CLIENTE_ID AND PRODUCTO_ID=@PRODUCTO_ID AND VIAJE_ID=@VIAJE_ID AND NRO_SERIE=@NRO_SERIE_ACTUAL
	            
				UPDATE	PICKING SET FECHA_INICIO=NULL,USUARIO=NULL,PALLET_PICKING=NULL
				WHERE	CLIENTE_ID=@CLIENTE_ID AND PRODUCTO_ID=@PRODUCTO_ID AND VIAJE_ID=@VIAJE_ID AND NRO_SERIE=@NRO_SERIE_ACTUAL
	            
				UPDATE	PICKING SET FECHA_INICIO=@FINICIO,USUARIO=@USUARIOPICK,PALLET_PICKING=@PALLET_PICKING
				WHERE	CLIENTE_ID=@CLIENTE_ID AND PRODUCTO_ID=@PRODUCTO_ID AND VIAJE_ID=@VIAJE_ID AND NRO_SERIE=@NRO_SERIE_NUEVA
			END
        END
        ELSE
        BEGIN
			--ES PERMUTACION.
			SELECT	@PERMUTACION=COUNT(DISTINCT P.VIAJE_ID)
			FROM	PICKING P
			WHERE	P.NRO_SERIE IN(@NRO_SERIE_ACTUAL,@NRO_SERIE_NUEVA)
					AND P.FECHA_FIN IS NULL
					AND P.FIN_PICKING IN(0,1)			
								
			IF @PERMUTACION=1 BEGIN
				SET @PERMUTACION=0
			END
			ELSE
			BEGIN
				SET @PERMUTACION=1
			END
			
			IF @PERMUTACION = 0 BEGIN
			
				SELECT	@DOC_TRANS_ID_EGR_AC=RL.DOC_TRANS_ID_EGR,@NRO_LINEA_TRANS_EGR_AC=RL.NRO_LINEA_TRANS_EGR,
						@RL_ACTUAL=RL.RL_ID,@PICKING_ACTUAL=P.PICKING_ID,@DOCID_AC=P.DOCUMENTO_ID,
						@NROLINEA_AC=P.NRO_LINEA,@USUARIO_AC=P.USUARIO,@PALLET_PICKING_AC=P.PALLET_PICKING,
						@FECHA_INICIO_AC=P.FECHA_INICIO
				FROM	RL_DET_DOC_TRANS_POSICION RL
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT ON (RL.DOC_TRANS_ID_EGR=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS_EGR=DDT.NRO_LINEA_TRANS)
						INNER JOIN DET_DOCUMENTO DD ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
						INNER JOIN PICKING P ON (DD.DOCUMENTO_ID=P.DOCUMENTO_ID AND DD.NRO_LINEA=P.NRO_LINEA)
				WHERE	P.CLIENTE_ID=@CLIENTE_ID AND P.PRODUCTO_ID=@PRODUCTO_ID AND P.VIAJE_ID=@VIAJE_ID AND P.NRO_SERIE=@NRO_SERIE_ACTUAL
	            
				SELECT	@RL_NUEVA=RL.RL_ID,@DOC_ID_ING_NUEVA=DD.DOCUMENTO_ID,@NRO_LINEA_ING_NUEVA=DD.NRO_LINEA
				FROM	RL_DET_DOC_TRANS_POSICION RL
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT ON (RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
						INNER JOIN DET_DOCUMENTO DD ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				WHERE	DD.CLIENTE_ID=@CLIENTE_ID AND DD.PRODUCTO_ID=@PRODUCTO_ID AND DD.NRO_SERIE=@NRO_SERIE_NUEVA --YA TENGO LAS RL QUE VOY A USAR.
	                  
				--SE PUSO DISPONIBLE LA CATEGORIA PORQUE NO SE GUARDA UN HISTORICO DE LA CATEGORIA PREVIA AL EGRESO.
				--COMO PROPUESTA DE MEJORA SE DEBERIA GUARDAR ESTE HISTORICO EN POSIBLEMENTE RL PARA RECUPERAR EL ESTADO
				--PREVIO AL EGRESO.

				IF (@RL_ACTUAL IS NULL) BEGIN
					RAISERROR('NO SE ENCONTRARON LOS DATOS PARA LA SERIE DE ORIGEN %s.',16,1,@NRO_SERIE_ACTUAL)
					RETURN
				END
				
				IF (@RL_NUEVA IS NULL) BEGIN
					RAISERROR('NO SE ENCONTRARON LOS DATOS PARA LA SERIE DE DESTINO %s.',16,1,@NRO_SERIE_NUEVA)
					RETURN
				END
					                  
				UPDATE	Rl_Det_Doc_Trans_posicion SET Disponible='1',Doc_Trans_Id_Egr=NULL,Nro_Linea_Trans_Egr=NULL,Posicion_Actual=Posicion_Anterior,Posicion_Anterior=NULL,Nave_Actual=Nave_Anterior,Nave_Anterior=1,Cat_log_id='DISPONIBLE'
				WHERE	Rl_Id=@RL_ACTUAL
	                  
				--Consumo la Nueva Rl
				UPDATE	Rl_Det_Doc_Trans_Posicion SET Disponible='0',Posicion_Anterior=Posicion_Actual,Posicion_Actual=NULL,Nave_Anterior=Nave_Actual,Nave_Actual=@PreEgrId,Doc_Trans_id_Egr=@DOC_TRANS_ID_EGR_AC,Nro_Linea_Trans_Egr=@NRO_LINEA_TRANS_EGR_AC,Cat_log_Id='TRAN_EGR'
				WHERE	Rl_id=@RL_NUEVA --AHORA TENGO QUE ACTUALIZAR PICKING CAMBIANDO LOS DOCUMENTOS DE EGRESO ACTUALIZANDO LOS DATOS
						--O SEA, EL PICKING DE LA SERIE ACTUAL TENGO QUE LLEVARLO AL DE LA SERIE NUEVA.
	                  
				INSERT INTO PICKING
				SELECT	DISTINCT
						DD.DOCUMENTO_ID,DD.NRO_LINEA,DD.CLIENTE_ID,DD.PRODUCTO_ID,ISNULL(LTRIM(RTRIM(D.NRO_DESPACHO_IMPORTACION)),LTRIM(RTRIM(DD.DOCUMENTO_ID))) AS VIAJE,'0' --'TIPO_CAJA' AS TIPO_CAJA --
						,P.DESCRIPCION,DD.CANTIDAD,ISNULL(N.NAVE_COD,N2.NAVE_COD) AS NAVE,ISNULL(POS.POSICION_COD,N.NAVE_COD) AS POSICION,'1' --ISNULL(LTRIM(RTRIM(D.SUCURSAL_DESTINO)),ISNULL(LTRIM(RTRIM(D.NRO_REMITO)),LTRIM(RTRIM(D.DOCUMENTO_ID))))
						,DD.PROP1,NULL AS FECHA_INICIO,NULL AS FECHA_FIN,NULL AS USUARIO,NULL AS CANT_CONFIRMADA,NULL AS PALLET_PICKING,0 AS SALTO_PICKING,'0' AS PALLET_CONTROLADO,NULL AS USUARIO_CONTROL_PICKING,'0' AS ST_ETIQUETAS,'0' AS ST_CAMION,'0' AS FACTURADO,'0' AS FIN_PICKING,'0' AS ST_CONTROL_EXP,NULL AS FECHA_CONTROL_PALLET,NULL AS TERMINAL_CONTROL_PALLET,NULL AS FECHA_CONTROL_EXP,NULL AS USUARIO_CONTROL_EXP,NULL AS TERMINAL_CONTROL_EXPEDICION,NULL AS FECHA_CONTROL_FAC,NULL AS USUARIO_CONTROL_FAC,NULL AS TERMINAL_CONTROL_FAC,NULL AS VEHICULO_ID,NULL AS PALLET_COMPLETO,NULL AS HIJO,NULL AS QTY_CONTROLADO,NULL AS PALLET_FINAL,NULL AS PALLET_CERRADO,NULL AS USUARIO_PF,NULL AS TERMINAL_PF,'0' AS REMITO_IMPRESO,NULL AS NRO_REMITO_PF,NULL AS PICKING_ID_REF,NULL AS BULTOS_CONTROLADOS,NULL AS BULTOS_NO_CONTROLADOS,@PALLET_HOMBRE AS FLG_PALLET_HOMBRE --CAMBIAR
						,0 AS TRANSF_TERMINANDA --CAMBIAR
						,DDING.nro_lote,DDING.nro_partida,DDING.nro_serie,NULL AS ESTADO,NULL AS NRO_UCDESCONSOLIDACION,NULL AS FECHA_DESCONSOLIDACION,NULL AS USUARIO_DESCONSOLIDACION,NULL AS TERMINAL_DESCONSOLIDACION,NULL AS NRO_UEMPAQUETADO,NULL AS UCEMPAQUETADO_MEDIDAS,NULL AS FECHA_UCEMPAQUETADO,NULL AS UCEMPAQUETADO_PESO
				FROM	DOCUMENTO D
						INNER JOIN DET_DOCUMENTO DD ON (D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT ON (DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL ON (RL.DOC_TRANS_ID_EGR=DDT.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS_EGR)
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDTING ON (RL.DOC_TRANS_ID=DDTING.DOC_TRANS_ID AND DDTING.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
						INNER JOIN DET_DOCUMENTO DDING ON (DDING.DOCUMENTO_ID=DDTING.DOCUMENTO_ID AND DDING.NRO_LINEA=DDTING.NRO_LINEA_DOC)
						INNER JOIN PRODUCTO P ON (DD.CLIENTE_ID=P.CLIENTE_ID AND DD.PRODUCTO_ID=P.PRODUCTO_ID)
						LEFT JOIN NAVE N ON (RL.NAVE_ANTERIOR=N.NAVE_ID)
						LEFT JOIN POSICION POS ON (RL.POSICION_ANTERIOR=POS.POSICION_ID)
						LEFT JOIN NAVE N2 ON (POS.NAVE_ID=N2.NAVE_ID)
				WHERE	RL.RL_ID=@RL_NUEVA
	            
				UPDATE	PICKING SET USUARIO=@USUARIO_AC,PALLET_PICKING=@PALLET_PICKING_AC,FECHA_INICIO=@FECHA_INICIO_AC
				WHERE	CLIENTE_ID=@CLIENTE_ID AND VIAJE_ID=@VIAJE_ID AND NRO_SERIE=@NRO_SERIE_NUEVA
	            
				DELETE	FROM PICKING
				WHERE	PICKING_ID=@PICKING_ACTUAL
	            
				DELETE	FROM Consumo_Locator_Egr
				WHERE	Documento_id=@DOCID_AC AND Nro_linea=@NROLINEA_AC
	            
				INSERT INTO Consumo_Locator_Egr(Documento_Id,Nro_Linea,Cliente_Id,Producto_Id,Cantidad,RL_ID,Saldo,Tipo,Fecha,Procesado) VALUES (@DOCID_AC,@NROLINEA_AC,@CLIENTE_ID,@PRODUCTO_ID,1,@RL_NUEVA,0,2,GETDATE(),'S')
			END 
			ELSE
			BEGIN
				--PERMUTACION=1
				
				--0.  RECUPERO DATOS PARA COMENZAR CON EL PROCESO.
				SELECT	@DOC_TRANS_ID_EGR_AC=RL.DOC_TRANS_ID_EGR,@NRO_LINEA_TRANS_EGR_AC=RL.NRO_LINEA_TRANS_EGR,
						@RL_ACTUAL=RL.RL_ID,@PICKING_ACTUAL=P.PICKING_ID,@DOCID_AC=P.DOCUMENTO_ID,
						@NROLINEA_AC=P.NRO_LINEA,@USUARIO_AC=P.USUARIO,@PALLET_PICKING_AC=P.PALLET_PICKING,
						@FECHA_INICIO_AC=P.FECHA_INICIO
				FROM	RL_DET_DOC_TRANS_POSICION RL
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT ON (RL.DOC_TRANS_ID_EGR=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS_EGR=DDT.NRO_LINEA_TRANS)
						INNER JOIN DET_DOCUMENTO DD ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
						INNER JOIN PICKING P ON (DD.DOCUMENTO_ID=P.DOCUMENTO_ID AND DD.NRO_LINEA=P.NRO_LINEA)
				WHERE	P.CLIENTE_ID=@CLIENTE_ID 
						AND P.PRODUCTO_ID=@PRODUCTO_ID 
						AND P.VIAJE_ID=@VIAJE_ID 
						AND P.NRO_SERIE=@NRO_SERIE_ACTUAL
							
				SELECT	@F_INICIO_SERIE_NUEVA=FECHA_INICIO, @PLT_PICK_SERIE_NUEVA=PALLET_PICKING,
						@USUARIO_SERIE_NUEVA=USUARIO
				FROM	PICKING
				WHERE	NRO_SERIE=@NRO_SERIE_NUEVA
								
				--1. TENGO QUE RECUPERAR LAS ID'S PARA PERMUTAR.
				SELECT	@RL_ORIGEN		=RL.RL_ID, 
						@DOC_TR_ORIGEN	=RL.DOC_TRANS_ID_EGR, 
						@LIN_TR_ORIGEN	=RL.NRO_LINEA_TRANS_EGR,
						@DOC_ORIGEN		=P.DOCUMENTO_ID,
						@LIN_ORIGEN		=P.NRO_LINEA
				FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
						ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
						ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL
						ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID_EGR AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS_EGR)
				WHERE	P.CLIENTE_ID=@CLIENTE_ID
						AND P.NRO_SERIE=@NRO_SERIE_ACTUAL

						
				SELECT	@RL_DESTINO		=RL.RL_ID, 
						@DOC_TR_DESTINO	=RL.DOC_TRANS_ID_EGR, 
						@LIN_TR_DESTINO	=RL.NRO_LINEA_TRANS_EGR,
						@DOC_DESTINO	=P.DOCUMENTO_ID,
						@LIN_DESTINO	=P.NRO_LINEA						
				FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
						ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
						ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL
						ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID_EGR AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS_EGR)
				WHERE	P.CLIENTE_ID=@CLIENTE_ID
						AND P.NRO_SERIE =@NRO_SERIE_NUEVA
						
				IF (@DOC_TR_ORIGEN IS NULL) BEGIN
					RAISERROR('NO SE ENCONTRARON LOS DATOS PARA LA SERIE DE ORIGEN %s.',16,1,@NRO_SERIE_ACTUAL)
					RETURN
				END
				
				IF (@DOC_TR_DESTINO IS NULL) BEGIN
					RAISERROR('NO SE ENCONTRARON LOS DATOS PARA LA SERIE DE DESTINO %s.',16,1,@NRO_SERIE_NUEVA)
					RETURN
				END
				
				--2. TENGO QUE PERMUTAR LAS RL'S.
				UPDATE	RL_DET_DOC_TRANS_POSICION SET DOC_TRANS_ID_EGR=@DOC_TR_DESTINO, NRO_LINEA_TRANS_EGR=@LIN_TR_DESTINO
				WHERE	RL_ID=@RL_ORIGEN
				
				UPDATE	RL_DET_DOC_TRANS_POSICION SET DOC_TRANS_ID_EGR=@DOC_TR_ORIGEN, NRO_LINEA_TRANS_EGR=@LIN_TR_ORIGEN
				WHERE	RL_ID=@RL_DESTINO
				
				--3. ELIMINO LOS REGISTROS DE PICKING PARA LA PERMUTACION.
				DELETE FROM PICKING WHERE DOCUMENTO_ID=@DOC_ORIGEN AND NRO_LINEA=@LIN_ORIGEN;
				DELETE FROM PICKING WHERE DOCUMENTO_ID=@DOC_DESTINO AND NRO_LINEA=@LIN_DESTINO;
				
				--4. TENGO QUE CAMBIAR LA TABLA DE PICKING.
				INSERT INTO PICKING
				SELECT	DISTINCT
						DD.DOCUMENTO_ID,DD.NRO_LINEA,DD.CLIENTE_ID,DD.PRODUCTO_ID,ISNULL(LTRIM(RTRIM(D.NRO_DESPACHO_IMPORTACION)),LTRIM(RTRIM(DD.DOCUMENTO_ID))) AS VIAJE,'0' --'TIPO_CAJA' AS TIPO_CAJA --
						,P.DESCRIPCION,DD.CANTIDAD,ISNULL(N.NAVE_COD,N2.NAVE_COD) AS NAVE,ISNULL(POS.POSICION_COD,N.NAVE_COD) AS POSICION,'1' --ISNULL(LTRIM(RTRIM(D.SUCURSAL_DESTINO)),ISNULL(LTRIM(RTRIM(D.NRO_REMITO)),LTRIM(RTRIM(D.DOCUMENTO_ID))))
						,DD.PROP1,NULL AS FECHA_INICIO,NULL AS FECHA_FIN,NULL AS USUARIO,NULL AS CANT_CONFIRMADA,NULL AS PALLET_PICKING,0 AS SALTO_PICKING,'0' AS PALLET_CONTROLADO,NULL AS USUARIO_CONTROL_PICKING,'0' AS ST_ETIQUETAS,'0' AS ST_CAMION,'0' AS FACTURADO,'0' AS FIN_PICKING,'0' AS ST_CONTROL_EXP,NULL AS FECHA_CONTROL_PALLET,NULL AS TERMINAL_CONTROL_PALLET,NULL AS FECHA_CONTROL_EXP,NULL AS USUARIO_CONTROL_EXP,NULL AS TERMINAL_CONTROL_EXPEDICION,NULL AS FECHA_CONTROL_FAC,NULL AS USUARIO_CONTROL_FAC,NULL AS TERMINAL_CONTROL_FAC,NULL AS VEHICULO_ID,NULL AS PALLET_COMPLETO,NULL AS HIJO,NULL AS QTY_CONTROLADO,NULL AS PALLET_FINAL,NULL AS PALLET_CERRADO,NULL AS USUARIO_PF,NULL AS TERMINAL_PF,'0' AS REMITO_IMPRESO,NULL AS NRO_REMITO_PF,NULL AS PICKING_ID_REF,NULL AS BULTOS_CONTROLADOS,NULL AS BULTOS_NO_CONTROLADOS,@PALLET_HOMBRE AS FLG_PALLET_HOMBRE --CAMBIAR
						,0 AS TRANSF_TERMINANDA --CAMBIAR
						,DDING.nro_lote,DDING.nro_partida,DDING.nro_serie,NULL AS ESTADO,NULL AS NRO_UCDESCONSOLIDACION,NULL AS FECHA_DESCONSOLIDACION,NULL AS USUARIO_DESCONSOLIDACION,NULL AS TERMINAL_DESCONSOLIDACION,NULL AS NRO_UEMPAQUETADO,NULL AS UCEMPAQUETADO_MEDIDAS,NULL AS FECHA_UCEMPAQUETADO,NULL AS UCEMPAQUETADO_PESO
				FROM	DOCUMENTO D
						INNER JOIN DET_DOCUMENTO DD ON (D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT ON (DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL ON (RL.DOC_TRANS_ID_EGR=DDT.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS_EGR)
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDTING ON (RL.DOC_TRANS_ID=DDTING.DOC_TRANS_ID AND DDTING.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
						INNER JOIN DET_DOCUMENTO DDING ON (DDING.DOCUMENTO_ID=DDTING.DOCUMENTO_ID AND DDING.NRO_LINEA=DDTING.NRO_LINEA_DOC)
						INNER JOIN PRODUCTO P ON (DD.CLIENTE_ID=P.CLIENTE_ID AND DD.PRODUCTO_ID=P.PRODUCTO_ID)
						LEFT JOIN NAVE N ON (RL.NAVE_ANTERIOR=N.NAVE_ID)
						LEFT JOIN POSICION POS ON (RL.POSICION_ANTERIOR=POS.POSICION_ID)
						LEFT JOIN NAVE N2 ON (POS.NAVE_ID=N2.NAVE_ID)
				WHERE	RL.RL_ID IN(@RL_ORIGEN,@RL_DESTINO)
	            
				UPDATE	PICKING SET USUARIO=@USUARIO_AC,PALLET_PICKING=@PALLET_PICKING_AC,FECHA_INICIO=@FECHA_INICIO_AC
				WHERE	CLIENTE_ID=@CLIENTE_ID AND VIAJE_ID=@VIAJE_ID AND NRO_SERIE=@NRO_SERIE_NUEVA

				UPDATE	PICKING SET USUARIO=@USUARIO_SERIE_NUEVA,PALLET_PICKING=@PLT_PICK_SERIE_NUEVA,FECHA_INICIO=@F_INICIO_SERIE_NUEVA
				WHERE	CLIENTE_ID=@CLIENTE_ID AND NRO_SERIE=@NRO_SERIE_ACTUAL	

				UPDATE consumo_locator_egr SET rl_id = @RL_DESTINO, tipo = 2, fecha = GETDATE() WHERE Documento_id=@DOC_ORIGEN AND Nro_linea=@LIN_ORIGEN AND cliente_id = @CLIENTE_ID AND producto_id = @PRODUCTO_ID
				
				UPDATE consumo_locator_egr SET rl_id = @RL_ORIGEN WHERE Documento_id=@DOC_DESTINO AND Nro_linea=@LIN_DESTINO AND cliente_id = @CLIENTE_ID AND producto_id = @PRODUCTO_ID							

			END
        END
        
        SET @OUT='1'
    END TRY
    BEGIN CATCH
        SET @OUT='0'
        EXEC usp_RethrowError
    END CATCH
END

GO


