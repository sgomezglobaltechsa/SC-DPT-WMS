/****** Object:  StoredProcedure [dbo].[INGRESA_PICKING_OLA]    Script Date: 06/05/2014 16:52:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INGRESA_PICKING_OLA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[INGRESA_PICKING_OLA]
GO

/****** Object:  StoredProcedure [dbo].[INGRESA_PICKING_OLA]    Script Date: 06/17/2013 18:04:17 ******/
CREATE                         PROCEDURE [dbo].[INGRESA_PICKING_OLA]
	@CLIENTE_ID VARCHAR(15) OUTPUT,
	@VIAJE_ID	VARCHAR(100) OUTPUT
AS
BEGIN
	--DECLARACIONES.
	DECLARE @TIPO_OPERACION VARCHAR(5)
	DECLARE @CANT			AS INT


	DECLARE @TCUR				CURSOR
	DECLARE @VIAJEID			VARCHAR(100)
	DECLARE @PRODUCTO_ID		VARCHAR(30)
	DECLARE @POSICION_COD	VARCHAR(50)
	DECLARE @PALLET			VARCHAR(100)
	DECLARE @RUTA				VARCHAR(100)
	DECLARE @ID				NUMERIC(20,0)		

	--START
	IF EXISTS (SELECT 1 FROM DOCUMENTO WHERE TIPO_OPERACION_ID <> 'EGR' AND NRO_DESPACHO_IMPORTACION = @VIAJE_ID AND CLIENTE_ID = @CLIENTE_ID)
		RAISERROR ('EL NRO. DE DOCUMENTO INGRESADO NO CORRESPONDE A UNA OPERACION DE EGRESO.', 16, 1)
	ELSE

	--	SELECT 	@TIPO_OPERACION = TIPO_OPERACION_ID
	--	FROM	DOCUMENTO
	--	WHERE 	DOCUMENTO_ID=@DOCUMENTO_ID
	--
	--	IF @TIPO_OPERACION <> 'EGR'
	--		BEGIN
	--			--SI LA OPERACION NO ES UN EGRESO ENTONCES...
	--			RAISERROR ('EL NRO. DE DOCUMENTO INGRESADO NO CORRESPONDE A UNA OPERACION DE EGRESO.', 16, 1)
	--		END
	--	ELSE
		BEGIN
			/*
			SELECT 	@CANT=COUNT(VIAJE_ID) 
			FROM 	PICKING
			WHERE	VIAJE_ID = @VIAJE_ID

			IF @CANT>0 
			BEGIN
				RAISERROR('El picking ya fue ingresado.',16,1)
				RETURN
			END			
			*/
			INSERT INTO PICKING 
			SELECT 	 DISTINCT
					 DD.DOCUMENTO_ID
					,DD.NRO_LINEA
					,DD.CLIENTE_ID
					,DD.PRODUCTO_ID 
					,ISNULL(LTRIM(RTRIM(D.NRO_DESPACHO_IMPORTACION)),LTRIM(RTRIM(DD.DOCUMENTO_ID))) AS VIAJE
					,ISNULL(P.TIPO_CONTENEDORA,'0') --'TIPO_CAJA' AS TIPO_CAJA --
					,P.DESCRIPCION
					,DD.CANTIDAD
					,ISNULL(N.NAVE_COD,N2.NAVE_COD) AS NAVE
					,ISNULL(POS.POSICION_COD,N.NAVE_COD) AS POSICION
					--,ISNULL(LTRIM(RTRIM(D.GRUPO_PICKING)),ISNULL(LTRIM(RTRIM(D.SUCURSAL_DESTINO)),ISNULL(D.NRO_REMITO,LTRIM(RTRIM(D.DOCUMENTO_ID)))))AS RUTA
					,[dbo].[F_RUTA_PICKING](D.CLIENTE_ID, D.NRO_REMITO)AS RUTA
					,DD.PROP1
					,NULL AS FECHA_INICIO
					,NULL AS FECHA_FIN
					,NULL AS USUARIO
					,NULL AS CANT_CONFIRMADA
					,NULL AS PALLET_PICKING
					,0 	  AS SALTO_PICKING
					,'0'  AS PALLET_CONTROLADO
					,NULL AS USUARIO_CONTROL_PICKING
					,'0'  AS ST_ETIQUETAS
					,'0'  AS ST_CAMION
					,'0'  AS FACTURADO
					,'0'  AS FIN_PICKING
					,'0'  AS ST_CONTROL_EXP
					,NULL AS FECHA_CONTROL_PALLET
					,NULL AS TERMINAL_CONTROL_PALLET
					,NULL AS FECHA_CONTROL_EXP
					,NULL AS USUARIO_CONTROL_EXP
					,NULL AS TERMINAL_CONTROL_EXPEDICION
					,NULL AS FECHA_CONTROL_FAC
					,NULL AS USUARIO_CONTROL_FAC
					,NULL AS TERMINAL_CONTROL_FAC
					,NULL AS VEHICULO_ID
					,NULL AS PALLET_COMPLETO
					,NULL AS HIJO
					,NULL AS QTY_CONTROLADO
					,NULL AS PALLET_FINAL
					,NULL AS PALLET_CERRADO
					,NULL AS USUARIO_PF
					,NULL AS TERMINAL_PF
					,'0'  AS REMITO_IMPRESO
					,NULL AS NRO_REMITO_PF
					,NULL AS PICKING_ID_REF
					,NULL AS BULTOS_CONTROLADOS
					,NULL AS BULTOS_NO_CONTROLADOS
					,ISNULL(P.TRANSF_PICKING,'0')
					,'0'  AS TRANSF_TERMINADA
					,DD.NRO_LOTE AS NRO_LOTE
					,DD.NRO_PARTIDA AS NRO_PARTIDA
					,DD.NRO_SERIE AS NRO_SERIE
					,Null as estado
					,null as nro_ucdesconsolidacion
					,null as fecha_desconsolidacion
					,null as usuario_desconsolidacion
					,null as terminal_desconsolidacion
					,null as nro_ucempaquetado
					,null as ucempaquetado_medidas
					,null as fecha_ucempaquetado
					,null as ucempaquetado_peso
			FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD		ON (D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
					INNER JOIN PRODUCTO P						ON(DD.CLIENTE_ID=P.CLIENTE_ID AND DD.PRODUCTO_ID=P.PRODUCTO_ID)
					INNER JOIN DET_DOCUMENTO_TRANSACCION DDT	ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
					INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(RL.DOC_TRANS_ID_EGR=DDT.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS_EGR)
					LEFT JOIN NAVE N							ON(RL.NAVE_ANTERIOR=N.NAVE_ID)
					LEFT JOIN POSICION POS						ON(RL.POSICION_ANTERIOR=POS.POSICION_ID)
					LEFT JOIN NAVE N2							ON(POS.NAVE_ID=N2.NAVE_ID)
					INNER JOIN CLIENTE_PARAMETROS C				ON(D.CLIENTE_ID = C.CLIENTE_ID)
			WHERE 	D.CLIENTE_ID=@CLIENTE_ID
					AND D.NRO_DESPACHO_IMPORTACION = @VIAJE_ID
					AND NOT EXISTS (SELECT	1
									FROM	PICKING PIK
									WHERE	PIK.DOCUMENTO_ID=DD.DOCUMENTO_ID
											AND PIK.NRO_LINEA=DD.NRO_LINEA);
	
			UPDATE PICKING SET TIPO_CAJA='0' WHERE LTRIM(RTRIM(TIPO_CAJA))='';

	------CONTROLO QUE SERIES FUERON OBLIGATORIAS Y CUALES NO.
	
	UPDATE	DET_DOCUMENTO
	SET		NRO_SERIE = NULL
	WHERE	DOCUMENTO_ID IN (SELECT DOCUMENTO_ID FROM DOCUMENTO WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_DESPACHO_IMPORTACION = @VIAJE_ID AND TIPO_OPERACION_ID = 'EGR')
			AND NOT EXISTS (SELECT 1 FROM SYS_INT_DET_DOCUMENTO SS
							INNER JOIN SYS_INT_DOCUMENTO S ON (SS.CLIENTE_ID = S.CLIENTE_ID AND SS.DOC_EXT = S.DOC_EXT)
							WHERE	S.DOC_EXT IN (SELECT NRO_REMITO FROM DOCUMENTO WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_DESPACHO_IMPORTACION = @VIAJE_ID AND TIPO_OPERACION_ID = 'EGR')
									AND SS.PROP3=DET_DOCUMENTO.NRO_SERIE)
	--	UPDATE DET_DOCUMENTO
	--	SET NRO_SERIE = NULL
	--	WHERE DOCUMENTO_ID = @DOCUMENTO_ID
	--			AND NOT EXISTS (SELECT 1 FROM SYS_INT_DET_DOCUMENTO SS
	--							INNER JOIN SYS_INT_DOCUMENTO S ON (SS.CLIENTE_ID = S.CLIENTE_ID AND SS.DOC_EXT = S.DOC_EXT)
	--							WHERE S.DOC_EXT = (SELECT NRO_REMITO FROM DOCUMENTO WHERE DOCUMENTO_ID = @DOCUMENTO_ID)
	--									AND PROP3=DET_DOCUMENTO.NRO_SERIE)
	------

		END --FIN ELSE
END --FIN PROCEDURE







GO


