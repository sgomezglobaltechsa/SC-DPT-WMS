/****** Object:  StoredProcedure [dbo].[ABAST_MOB_TAREAS_DETALLE]    Script Date: 05/19/2015 16:58:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ABAST_MOB_TAREAS_DETALLE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ABAST_MOB_TAREAS_DETALLE]
GO

CREATE PROCEDURE [dbo].[ABAST_MOB_TAREAS_DETALLE]
@ABAST_ID			BIGINT,
@NRO_CONTENEDORA	BIGINT
AS
BEGIN

	DECLARE @EN_PROGRESO	VARCHAR(1)
	DECLARE @POSICION_COD	VARCHAR(45)
	DECLARE @NRO_LOTE		VARCHAR(100)
	DECLARE @NRO_PARTIDA	VARCHAR(100)
	DECLARE @NRO_SERIE		VARCHAR(100)
	DECLARE @NRO_BULTO		VARCHAR(100)
	DECLARE @CANTIDAD		NUMERIC(20,5)
	DECLARE @TAREA_TOMADA	NUMERIC(20,0)
	DECLARE @CONT_ORIGINAL	BIGINT
	declare @msg			varchar(100)
	
	set @msg=''
	
	SELECT	@TAREA_TOMADA=COUNT(*)
	FROM	ABAST_CONSUMO_LOCATOR	
	WHERE	ABAST_ID=ABAST_ID
			AND EN_PROGRESO='1'
			AND ISNULL(EN_CONTENEDOR,'0')='0'
			AND ISNULL(FINALIZADO,'0')='0'
	
	IF @TAREA_TOMADA=1 BEGIN
		
		SELECT	TOP 1
				@POSICION_COD=ISNULL(P.POSICION_COD, N.NAVE_COD),
				@NRO_LOTE=DD.NRO_LOTE, 
				@NRO_PARTIDA=DD.NRO_PARTIDA, 
				@NRO_SERIE=DD.NRO_SERIE, 
				@NRO_BULTO=DD.NRO_BULTO,
				@CANTIDAD=SUM(RL.CANTIDAD),
				@CONT_ORIGINAL=ACL.NRO_CONTENEDORA
		FROM	DET_ABASTECIMIENTO DA INNER JOIN ABAST_CONSUMO_LOCATOR ACL		ON(DA.ABAST_ID=ACL.ABAST_ID)
				INNER JOIN RL_DET_DOC_TRANS_POSICION RL							ON(ACL.RL_ID=RL.RL_ID)
				INNER JOIN DET_DOCUMENTO_TRANSACCION DDT						ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
				INNER JOIN DET_DOCUMENTO DD										ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				LEFT JOIN POSICION P											ON(RL.POSICION_ACTUAL=P.POSICION_ID)
				LEFT JOIN NAVE N												ON(RL.NAVE_ACTUAL=N.NAVE_ID)
		WHERE	DA.ABAST_ID=@ABAST_ID
				AND ISNULL(ACL.EN_PROGRESO,'0')in('0','1')
				AND ISNULL(ACL.FINALIZADO,'0')='0'
		GROUP BY
				ISNULL(P.POSICION_COD, N.NAVE_COD), DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, DD.NRO_BULTO, P.ORDEN_PICKING, ACL.NRO_CONTENEDORA
		ORDER BY
				P.ORDEN_PICKING		
				
		IF @NRO_CONTENEDORA<>@CONT_ORIGINAL BEGIN
		
			UPDATE	ABAST_CONSUMO_LOCATOR
			SET		EN_PROGRESO='1', 
					NRO_CONTENEDORA=@NRO_CONTENEDORA
			FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
					INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
					INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
					INNER JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
			WHERE	ACL.ABAST_ID=@ABAST_ID
					AND ((@POSICION_COD IS NULL)OR(P.POSICION_COD=@POSICION_COD))
					AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
					AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
					AND ((@NRO_SERIE IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE))
					AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO))
					
			UPDATE	ABAST_CONSUMO_LOCATOR
			SET		EN_PROGRESO='1', 
					NRO_CONTENEDORA=@NRO_CONTENEDORA
			FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
					INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
					INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
					INNER JOIN NAVE N														ON(RL.NAVE_ACTUAL=N.NAVE_ID)
			WHERE	ACL.ABAST_ID=@ABAST_ID
					AND ((@POSICION_COD IS NULL)OR(N.NAVE_COD=@POSICION_COD))
					AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
					AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
					AND ((@NRO_SERIE IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE))
					AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO))					
					
		END
		SELECT	@POSICION_COD		AS POSICION_COD, 
				@NRO_LOTE			AS NRO_LOTE, 
				@NRO_PARTIDA		AS NRO_PARTIDA, 
				@NRO_SERIE			AS NRO_SERIE, 
				@NRO_BULTO			AS NRO_BULTO,
				@CANTIDAD			AS CANTIDAD			
	END
	ELSE
	BEGIN
		
		
		SELECT	@EN_PROGRESO=EN_PROGRESO
		FROM	DET_ABASTECIMIENTO
		WHERE	ABAST_ID=@ABAST_ID
		
		IF @EN_PROGRESO='0' BEGIN
			--SI NO SE ENCUENTRA EN PROGRESO LO PONGO COMO ACTIVO.	
			UPDATE	DET_ABASTECIMIENTO
			SET		EN_PROGRESO='1',
					F_INICIO=GETDATE()
			WHERE	ABAST_ID=@ABAST_ID				
		END

		SELECT	TOP 1
				@POSICION_COD=ISNULL(P.POSICION_COD,N.NAVE_COD),
				@NRO_LOTE=DD.NRO_LOTE, 
				@NRO_PARTIDA=DD.NRO_PARTIDA, 
				@NRO_SERIE=DD.NRO_SERIE, 
				@NRO_BULTO=DD.NRO_BULTO,
				@CANTIDAD=SUM(RL.CANTIDAD)
		FROM	DET_ABASTECIMIENTO DA INNER JOIN ABAST_CONSUMO_LOCATOR ACL		ON(DA.ABAST_ID=ACL.ABAST_ID)
				INNER JOIN RL_DET_DOC_TRANS_POSICION RL							ON(ACL.RL_ID=RL.RL_ID)
				INNER JOIN DET_DOCUMENTO_TRANSACCION DDT						ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
				INNER JOIN DET_DOCUMENTO DD										ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				LEFT JOIN POSICION P											ON(RL.POSICION_ACTUAL=P.POSICION_ID)
				LEFT JOIN NAVE N												ON(RL.NAVE_ACTUAL=N.NAVE_ID)
		WHERE	DA.ABAST_ID=@ABAST_ID
				AND ISNULL(ACL.EN_PROGRESO,'0')='0'
				AND ISNULL(ACL.FINALIZADO,'0')='0'
				AND ISNULL(ACL.EN_CONTENEDOR,'0')='0'
		GROUP BY
				ISNULL(P.POSICION_COD,N.NAVE_COD), DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, DD.NRO_BULTO, P.ORDEN_PICKING
		ORDER BY
				P.ORDEN_PICKING
		
		UPDATE	ABAST_CONSUMO_LOCATOR
		SET		EN_PROGRESO='1', 
				NRO_CONTENEDORA=@NRO_CONTENEDORA
		FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
				INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
				INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				INNER JOIN POSICION P													ON(RL.POSICION_ACTUAL=P.POSICION_ID)
		WHERE	ACL.ABAST_ID=@ABAST_ID
				AND ISNULL(ACL.EN_PROGRESO,'0')='0'
				AND ((@POSICION_COD IS NULL)OR(P.POSICION_COD=@POSICION_COD))
				AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
				AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
				AND ((@NRO_SERIE IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE))
				AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO))

		UPDATE	ABAST_CONSUMO_LOCATOR
		SET		EN_PROGRESO='1', 
				NRO_CONTENEDORA=@NRO_CONTENEDORA
		FROM	ABAST_CONSUMO_LOCATOR ACL INNER JOIN RL_DET_DOC_TRANS_POSICION RL		ON(ACL.RL_ID=RL.RL_ID)
				INNER JOIN DET_DOCUMENTO_TRANSACCION DDT								ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
				INNER JOIN DET_DOCUMENTO DD												ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
				INNER JOIN NAVE N														ON(RL.NAVE_ACTUAL=N.NAVE_ID)
		WHERE	ACL.ABAST_ID=@ABAST_ID
				AND ISNULL(ACL.EN_PROGRESO,'0')='0'
				AND ((@POSICION_COD IS NULL)OR(N.NAVE_COD=@POSICION_COD))
				AND ((@NRO_LOTE IS NULL)OR(DD.NRO_LOTE=@NRO_LOTE))
				AND ((@NRO_PARTIDA IS NULL)OR(DD.NRO_PARTIDA=@NRO_PARTIDA))
				AND ((@NRO_SERIE IS NULL)OR(DD.NRO_SERIE=@NRO_SERIE))
				AND ((@NRO_BULTO IS NULL)OR(DD.NRO_BULTO=@NRO_BULTO))				
		
		IF (@POSICION_COD IS NOT NULL)BEGIN
			SELECT	@POSICION_COD		AS POSICION_COD, 
					@NRO_LOTE			AS NRO_LOTE, 
					@NRO_PARTIDA		AS NRO_PARTIDA, 
					@NRO_SERIE			AS NRO_SERIE, 
					@NRO_BULTO			AS NRO_BULTO,
					@CANTIDAD			AS CANTIDAD
		END
	END
								
END	--FIN PROCEDURE.


GO


