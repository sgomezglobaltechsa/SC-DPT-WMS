/****** Object:  StoredProcedure [dbo].[SPLIT_PICKING_CONTENEDORA]    Script Date: 02/14/2013 17:26:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SPLIT_PICKING_CONTENEDORA]
	@PICKING_ID		NUMERIC(20,0),
	@CANTIDAD		NUMERIC(20,5),
	@OUT			CHAR(1) OUTPUT
AS
BEGIN
	DECLARE @NEW_PICK		NUMERIC(20,0)
	DECLARE @NEW_LINEA		NUMERIC(10,0)
	DECLARE @DOCUMENTO_ID	NUMERIC(20,0)
	DECLARE @NRO_LINEA		NUMERIC(10,0)
	DECLARE @NEW_RL			NUMERIC(20,0)

	SELECT	DISTINCT @DOCUMENTO_ID=DOCUMENTO_ID, @NRO_LINEA=NRO_LINEA
	FROM	PICKING
	WHERE	PICKING_ID=@PICKING_ID

	--SACO LA NUEVA LINEA.
	SELECT	@NEW_LINEA=MAX(DD.NRO_LINEA)+1
	FROM	DET_DOCUMENTO DD
	WHERE	EXISTS (SELECT	1
					FROM	PICKING PIK
					WHERE	DD.DOCUMENTO_ID=PIK.DOCUMENTO_ID
							AND PIK.PICKING_ID=@PICKING_ID)
	BEGIN TRY
		-------------------------------------------------------------------------------
		--1 SPLIT DETALLES DOCUMENTOS.
		-------------------------------------------------------------------------------
		INSERT INTO DET_DOCUMENTO
		SELECT	DOCUMENTO_ID,		@NEW_LINEA,			CLIENTE_ID,			PRODUCTO_ID,	ABS(@CANTIDAD),
				NRO_SERIE,			NRO_SERIE_PADRE,	EST_MERC_ID,		CAT_LOG_ID,		NRO_BULTO,
				DESCRIPCION,		NRO_LOTE,			FECHA_VENCIMIENTO,	NRO_DESPACHO,	NRO_PARTIDA,
				UNIDAD_ID,			PESO,				UNIDAD_PESO,		VOLUMEN,		UNIDAD_VOLUMEN,
				BUSC_INDIVIDUAL,	ISNULL(TIE_IN,'0'),	NRO_TIE_IN_PADRE,	NRO_TIE_IN,		ITEM_OK,
				CAT_LOG_ID_FINAL,	MONEDA_ID,			COSTO,				PROP1,			PROP2,
				PROP3,				LARGO,				ALTO,				ANCHO,			VOLUMEN_UNITARIO,
				PESO_UNITARIO,		CANT_SOLICITADA,	TRACE_BACK_ORDER
		FROM	DET_DOCUMENTO DD
		WHERE	EXISTS (SELECT	1
						FROM	PICKING PIK
						WHERE	DD.DOCUMENTO_ID=PIK.DOCUMENTO_ID
								AND DD.NRO_LINEA=PIK.NRO_LINEA
								AND PIK.PICKING_ID=@PICKING_ID)

		UPDATE	DET_DOCUMENTO SET CANTIDAD=CANTIDAD-@CANTIDAD
		WHERE	EXISTS (SELECT	1
						FROM	PICKING PIK
						WHERE	DET_DOCUMENTO.DOCUMENTO_ID=PIK.DOCUMENTO_ID
								AND DET_DOCUMENTO.NRO_LINEA=PIK.NRO_LINEA
								AND PIK.PICKING_ID=@PICKING_ID)

		-------------------------------------------------------------------------------	
		--2 SPLIT DET. DOCUMENTO TRANSACCION.
		-------------------------------------------------------------------------------
		INSERT INTO DET_DOCUMENTO_TRANSACCION
		SELECT	DOC_TRANS_ID,	@NEW_LINEA,				DOCUMENTO_ID,		@NEW_LINEA,
				MOTIVO_ID,		EST_MERC_ID,			CLIENTE_ID,			CAT_LOG_ID,
				ITEM_OK,		MOVIMIENTO_PENDIENTE,	DOC_TRANS_ID_REF,	NRO_LINEA_TRANS_REF
		FROM	DET_DOCUMENTO_TRANSACCION
		WHERE	DOCUMENTO_ID=@DOCUMENTO_ID AND NRO_LINEA_DOC=@NRO_LINEA;

		-------------------------------------------------------------------------------		
		--3 SPLIT RL.
		-------------------------------------------------------------------------------	
		INSERT INTO RL_DET_DOC_TRANS_POSICION(	DOC_TRANS_ID,		NRO_LINEA_TRANS,	POSICION_ANTERIOR,	POSICION_ACTUAL,
												CANTIDAD,			TIPO_MOVIMIENTO_ID,	ULTIMA_ESTACION,	ULTIMA_SECUENCIA,
												NAVE_ANTERIOR,		NAVE_ACTUAL,		DOCUMENTO_ID,		NRO_LINEA,
												DISPONIBLE,			DOC_TRANS_ID_EGR,	NRO_LINEA_TRANS_EGR,DOC_TRANS_ID_TR,
												NRO_LINEA_TRANS_TR,	CLIENTE_ID,			CAT_LOG_ID,			CAT_LOG_ID_FINAL,
												EST_MERC_ID)
		SELECT	DOC_TRANS_ID,		NRO_LINEA_TRANS,		POSICION_ANTERIOR,
				POSICION_ACTUAL,	ABS(@CANTIDAD),			TIPO_MOVIMIENTO_ID,
				ULTIMA_ESTACION,	ULTIMA_SECUENCIA,		NAVE_ANTERIOR,
				NAVE_ACTUAL,		DOCUMENTO_ID,			NRO_LINEA,
				DISPONIBLE,			DOC_TRANS_ID_EGR,		@NEW_LINEA,
				DOC_TRANS_ID_TR,	NRO_LINEA_TRANS_TR,		CLIENTE_ID,
				CAT_LOG_ID,			CAT_LOG_ID_FINAL,		EST_MERC_ID
		FROM	RL_DET_DOC_TRANS_POSICION RL
		WHERE	EXISTS(	SELECT	1
						FROM	DET_DOCUMENTO_TRANSACCION DDT
						WHERE	RL.DOC_TRANS_ID_EGR=DDT.DOC_TRANS_ID
								AND RL.NRO_LINEA_TRANS_EGR=DDT.NRO_LINEA_TRANS
								AND DDT.DOCUMENTO_ID=@DOCUMENTO_ID
								AND DDT.NRO_LINEA_DOC=@NRO_LINEA)

		SET @NEW_RL=SCOPE_IDENTITY()

		UPDATE	RL_DET_DOC_TRANS_POSICION
		SET		CANTIDAD=CANTIDAD-ABS(@CANTIDAD)
		WHERE	EXISTS(	SELECT	1
						FROM	DET_DOCUMENTO_TRANSACCION DDT
						WHERE	RL_DET_DOC_TRANS_POSICION.DOC_TRANS_ID_EGR=DDT.DOC_TRANS_ID
								AND RL_DET_DOC_TRANS_POSICION.NRO_LINEA_TRANS_EGR=DDT.NRO_LINEA_TRANS
								AND DDT.DOCUMENTO_ID=@DOCUMENTO_ID
								AND DDT.NRO_LINEA_DOC=@NRO_LINEA)
		-------------------------------------------------------------------------------	
		--4 SPLIT PICKING.
		-------------------------------------------------------------------------------		
		IF (@CANTIDAD>0)
		BEGIN
			INSERT INTO PICKING(
					DOCUMENTO_ID,		NRO_LINEA,				CLIENTE_ID,				PRODUCTO_ID,			VIAJE_ID,			TIPO_CAJA,
					DESCRIPCION,		CANTIDAD,				NAVE_COD,				POSICION_COD,			RUTA,				PROP1,
					FECHA_INICIO,		FECHA_FIN,				USUARIO,				CANT_CONFIRMADA,		PALLET_PICKING,		SALTO_PICKING,
					PALLET_CONTROLADO,	USUARIO_CONTROL_PICK,	ST_ETIQUETAS,			ST_CAMION,				FACTURADO,			FIN_PICKING,
					ST_CONTROL_EXP,		FECHA_CONTROL_PALLET,	TERMINAL_CONTROL_PALLET,FECHA_CONTROL_EXP,		USUARIO_CONTROL_EXP,TERMINAL_CONTROL_EXP,
					FECHA_CONTROL_FAC,	USUARIO_CONTROL_FAC,	TERMINAL_CONTROL_FAC,	VEHICULO_ID,			PALLET_COMPLETO,	HIJO,
					QTY_CONTROLADO,		PALLET_FINAL,			PALLET_CERRADO,			USUARIO_PF,				TERMINAL_PF,		REMITO_IMPRESO,
					NRO_REMITO_PF,		PICKING_ID_REF,			BULTOS_CONTROLADOS,		BULTOS_NO_CONTROLADOS,	FLG_PALLET_HOMBRE,	TRANSF_TERMINADA,
					NRO_LOTE,			NRO_PARTIDA,			NRO_SERIE)
			SELECT	DOCUMENTO_ID,	@NEW_LINEA,	CLIENTE_ID,	PRODUCTO_ID,	VIAJE_ID,	TIPO_CAJA,	DESCRIPCION,	ABS(@CANTIDAD),
					NAVE_COD,		POSICION_COD,	RUTA,	PROP1,	FECHA_INICIO,	FECHA_FIN,	USUARIO,	CANT_CONFIRMADA,
					PALLET_PICKING,	SALTO_PICKING,	PALLET_CONTROLADO,	USUARIO_CONTROL_PICK,	ST_ETIQUETAS,	ST_CAMION,
					FACTURADO,	FIN_PICKING,	ST_CONTROL_EXP,	FECHA_CONTROL_PALLET,	TERMINAL_CONTROL_PALLET,
					FECHA_CONTROL_EXP,	USUARIO_CONTROL_EXP,	TERMINAL_CONTROL_EXP,	FECHA_CONTROL_FAC,
					USUARIO_CONTROL_FAC,	TERMINAL_CONTROL_FAC,	VEHICULO_ID,	PALLET_COMPLETO,	HIJO,
					QTY_CONTROLADO,	PALLET_FINAL,	PALLET_CERRADO,	USUARIO_PF,	TERMINAL_PF,	REMITO_IMPRESO,
					NRO_REMITO_PF,	PICKING_ID_REF,	BULTOS_CONTROLADOS,	BULTOS_NO_CONTROLADOS,	FLG_PALLET_HOMBRE,
					TRANSF_TERMINADA,	NRO_LOTE,	NRO_PARTIDA,	NRO_SERIE
			FROM	PICKING
			WHERE	PICKING_ID=@PICKING_ID
		END
		ELSE
		BEGIN
			INSERT INTO PICKING(
					DOCUMENTO_ID,		NRO_LINEA,				CLIENTE_ID,				PRODUCTO_ID,			VIAJE_ID,			TIPO_CAJA,
					DESCRIPCION,		CANTIDAD,				NAVE_COD,				POSICION_COD,			RUTA,				PROP1,
					FECHA_INICIO,		FECHA_FIN,				USUARIO,				CANT_CONFIRMADA,		PALLET_PICKING,		SALTO_PICKING,
					PALLET_CONTROLADO,	USUARIO_CONTROL_PICK,	ST_ETIQUETAS,			ST_CAMION,				FACTURADO,			FIN_PICKING,
					ST_CONTROL_EXP,		FECHA_CONTROL_PALLET,	TERMINAL_CONTROL_PALLET,FECHA_CONTROL_EXP,		USUARIO_CONTROL_EXP,TERMINAL_CONTROL_EXP,
					FECHA_CONTROL_FAC,	USUARIO_CONTROL_FAC,	TERMINAL_CONTROL_FAC,	VEHICULO_ID,			PALLET_COMPLETO,	HIJO,
					QTY_CONTROLADO,		PALLET_FINAL,			PALLET_CERRADO,			USUARIO_PF,				TERMINAL_PF,		REMITO_IMPRESO,
					NRO_REMITO_PF,		PICKING_ID_REF,			BULTOS_CONTROLADOS,		BULTOS_NO_CONTROLADOS,	FLG_PALLET_HOMBRE,	TRANSF_TERMINADA,
					NRO_LOTE,			NRO_PARTIDA,			NRO_SERIE)
			SELECT	DOCUMENTO_ID,	@NEW_LINEA,	CLIENTE_ID,	PRODUCTO_ID,	VIAJE_ID,	TIPO_CAJA,	DESCRIPCION,	ABS(@CANTIDAD),
					NAVE_COD,		POSICION_COD,	RUTA,	PROP1,	NULL FECHA_INICIO,	NULL FECHA_FIN,	NULL USUARIO,	CANT_CONFIRMADA,
					NULL PALLET_PICKING,	SALTO_PICKING,	PALLET_CONTROLADO,	USUARIO_CONTROL_PICK,	ST_ETIQUETAS,	ST_CAMION,
					FACTURADO,	FIN_PICKING,	ST_CONTROL_EXP,	FECHA_CONTROL_PALLET,	TERMINAL_CONTROL_PALLET,
					FECHA_CONTROL_EXP,	USUARIO_CONTROL_EXP,	TERMINAL_CONTROL_EXP,	FECHA_CONTROL_FAC,
					USUARIO_CONTROL_FAC,	TERMINAL_CONTROL_FAC,	VEHICULO_ID,	PALLET_COMPLETO,	HIJO,
					QTY_CONTROLADO,	PALLET_FINAL,	PALLET_CERRADO,	USUARIO_PF,	TERMINAL_PF,	REMITO_IMPRESO,
					NRO_REMITO_PF,	PICKING_ID_REF,	BULTOS_CONTROLADOS,	BULTOS_NO_CONTROLADOS,	FLG_PALLET_HOMBRE,
					TRANSF_TERMINADA,	NRO_LOTE,	NRO_PARTIDA,	NRO_SERIE
			FROM	PICKING
			WHERE	PICKING_ID=@PICKING_ID		
		END
		UPDATE	PICKING 
		SET		CANTIDAD=CANTIDAD-ABS(@CANTIDAD)
		WHERE	PICKING_ID=@PICKING_ID

		SET @NEW_PICK=SCOPE_IDENTITY()

		SET @OUT='0'
	END TRY
	BEGIN CATCH
		SET @OUT='1'
	END CATCH
END--FIN PROCEDURE.
