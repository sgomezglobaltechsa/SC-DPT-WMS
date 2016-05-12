/****** OBJECT:  STOREDPROCEDURE [DBO].[LOCATOREGRESO]    SCRIPT DATE: 03/30/2015 10:42:47 ******/
IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[ABAST_MOB_TAREAS_CAMBIASERIE]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [DBO].[ABAST_MOB_TAREAS_CAMBIASERIE]
GO

CREATE PROCEDURE [DBO].[ABAST_MOB_TAREAS_CAMBIASERIE]
	@ABAST_ID			BIGINT,
	@CLIENTE_ID			VARCHAR(15),
	@PRODUCTO_ID		VARCHAR(30),
	@POSICION_COD		VARCHAR(45),
	@NRO_LOTE			VARCHAR(100),
	@NRO_PARTIDA		VARCHAR(100),
	@NRO_SERIE			VARCHAR(100),
	@NRO_SERIE_DEST		VARCHAR(100),
	@NRO_BULTO			VARCHAR(100),
	@CONTENEDORA		BIGINT,
	@RETORNO			VARCHAR(1)	OUTPUT
AS
BEGIN

	DECLARE @CONT_E			NUMERIC(2,0)
	DECLARE @CONSUMO_DEL	NUMERIC(20,0)
	DECLARE @NEW_RL			NUMERIC(20,0)
	DECLARE @LINEA			NUMERIC(10,0)
	
	
	SELECT	@CONT_E=COUNT(ACL.CONSUMO_ID)
	FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
			INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
			INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
			LEFT JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
	WHERE	ACL.ABAST_ID=@ABAST_ID
			AND ((@POSICION_COD IS NULL)OR(P.POSICION_COD=@POSICION_COD))
			AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
			AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
			AND ((@NRO_SERIE_DEST IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE_DEST))
			AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO))
	
	IF @CONT_E=0 BEGIN
	
		--ACA TENGO QUE PERMUTAR LA SERIE SI ES POSIBLE.
		SELECT	@NEW_RL=RL.RL_ID
		FROM	RL_DET_DOC_TRANS_POSICION RL
				INNER JOIN DET_DOCUMENTO_TRANSACCION DDT ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
				INNER JOIN DET_DOCUMENTO DD ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				INNER JOIN CATEGORIA_LOGICA CL ON (RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID=CL.CAT_LOG_ID )
				INNER JOIN POSICION P ON (RL.POSICION_ACTUAL=P.POSICION_ID)
				LEFT JOIN ESTADO_MERCADERIA_RL EM ON (RL.CLIENTE_ID=EM.CLIENTE_ID AND RL.EST_MERC_ID=EM.EST_MERC_ID) 	
				INNER JOIN DOCUMENTO D ON(DD.DOCUMENTO_ID=D.DOCUMENTO_ID)
		WHERE	RL.DOC_TRANS_ID_EGR IS NULL
				AND RL.NRO_LINEA_TRANS_EGR IS NULL
				AND RL.DISPONIBLE='1'
				AND ISNULL(EM.DISP_EGRESO,'1')='1'
				AND ISNULL(EM.PICKING,'1')='1'
				AND P.POS_LOCKEADA='0' 
				AND ISNULL(P.ABASTECIBLE,'0')='0'
				AND P.PICKING='0'
				AND CL.DISP_EGRESO='1' 
				AND CL.PICKING='1'
				AND RL.CAT_LOG_ID<>'TRAN_EGR' --PARA ASEGURARME QUE NO ESTE EN PROCESO DE EGRESO
				AND D.CLIENTE_ID = @CLIENTE_ID
				AND DD.PRODUCTO_ID=@PRODUCTO_ID
				AND DD.NRO_SERIE=@NRO_SERIE_DEST
				AND P.POSICION_COD=@POSICION_COD
				
		IF @NEW_RL IS NULL BEGIN
			RAISERROR ('NO ES POSIBLE REALIZAR EL CAMBIO DE SERIES. LA SERIE INDICADA NO SE ENCUENTRA DISPONIBLE.',16,1)
			RETURN
		END
		ELSE
		BEGIN
		
			SELECT	@LINEA=MAX(ACL.NRO_LINEA)+1
			FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
					INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
					INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
					LEFT JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
			WHERE	ACL.ABAST_ID=@ABAST_ID		
			
			--LIBERO LA RL
			UPDATE	RL_DET_DOC_TRANS_POSICION 
			SET		DISPONIBLE='1'
			WHERE	RL_ID IN(	SELECT	ACL.RL_ID
								FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
										INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
										INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
										LEFT JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
								WHERE	ACL.ABAST_ID=@ABAST_ID
										AND ((@POSICION_COD IS NULL)OR(P.POSICION_COD=@POSICION_COD))
										AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
										AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
										AND ((@NRO_SERIE_DEST IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE))
										AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO)))
			--BORRO EL CONSUMO ANTERIOR
			DELETE	FROM ABAST_CONSUMO_LOCATOR 
			WHERE	CONSUMO_ID IN(	SELECT	ACL.CONSUMO_ID
									FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
											INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
											INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
											LEFT JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
									WHERE	ACL.ABAST_ID=@ABAST_ID
											AND ((@POSICION_COD IS NULL)OR(P.POSICION_COD=@POSICION_COD))
											AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
											AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
											AND ((@NRO_SERIE_DEST IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE))
											AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO)))
			
			--GENERO UN NUEVO CONSUMO.
			INSERT INTO ABAST_CONSUMO_LOCATOR(	ABAST_ID,	NRO_LINEA,	CLIENTE_ID,		PRODUCTO_ID,	CANTIDAD,	RL_ID,		SALDO,	TIPO,	FECHA,		PROCESADO,	EN_PROGRESO,	NRO_CONTENEDORA)
									VALUES	 (	@ABAST_ID,	@LINEA,		@CLIENTE_ID,	@PRODUCTO_ID,	 1,			@NEW_RL,	0,		'1',	GETDATE(),	'S',		'1',			@CONTENEDORA)
									
			UPDATE RL_DET_DOC_TRANS_POSICION SET DISPONIBLE='0' WHERE RL_ID=@NEW_RL;
			
			SET @RETORNO='1'
		
		END
	END
	ELSE
	BEGIN
	
		UPDATE	ABAST_CONSUMO_LOCATOR
		SET		EN_PROGRESO=NULL,
				NRO_CONTENEDORA=NULL
		FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
				INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
				INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				LEFT JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
		WHERE	ACL.ABAST_ID=@ABAST_ID
				AND ((@POSICION_COD IS NULL)OR(P.POSICION_COD=@POSICION_COD))
				AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
				AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
				AND ((@NRO_SERIE_DEST IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE))
				AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO))
				
		UPDATE	ABAST_CONSUMO_LOCATOR
		SET		EN_PROGRESO='1',
				NRO_CONTENEDORA=@CONTENEDORA
		FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
				INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
				INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				LEFT JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
		WHERE	ACL.ABAST_ID=@ABAST_ID
				AND ((@POSICION_COD IS NULL)OR(P.POSICION_COD=@POSICION_COD))
				AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
				AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
				AND ((@NRO_SERIE_DEST IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE_DEST))
				AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO))				

		SET @RETORNO='1'
	END	
END