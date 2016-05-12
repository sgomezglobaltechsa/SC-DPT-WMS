
/****** Object:  StoredProcedure [dbo].[VERIFICA_EXISTENCIAS_VIAJE]    Script Date: 10/22/2014 11:25:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VERIFICA_EXISTENCIAS_VIAJE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[VERIFICA_EXISTENCIAS_VIAJE]
GO

CREATE  PROCEDURE [dbo].[VERIFICA_EXISTENCIAS_VIAJE]
@VIAJE	VARCHAR(100) OUTPUT
AS
BEGIN
	DECLARE @CUR_VIAJES		CURSOR
	DECLARE @CURDETALLE		CURSOR
	DECLARE @CURPALLETS		CURSOR
	DECLARE @DOC_EXT		VARCHAR(100)
	DECLARE @NRO_LINEA		NUMERIC(20,0)
	DECLARE @CODIGO_VIAJE	VARCHAR(100)
	DECLARE @CLIENTE_ID		VARCHAR(15)
	DECLARE @PRODUCTO_ID	VARCHAR(30)
	DECLARE @CANTIDAD_SOLICITADA NUMERIC(20,0)
	DECLARE @NRO_LOTE		VARCHAR(100)
	DECLARE @NRO_PARTIDA	VARCHAR(100)
	DECLARE @NRO_SERIE		VARCHAR(50)
	DECLARE @EST_MERC_ID	VARCHAR(50)
	DECLARE @CAT_LOG_ID		VARCHAR(50)	
	DECLARE @STOCK_DISP		NUMERIC(20,5)
	DECLARE @RESTA			NUMERIC(20,5)
	DECLARE @PALLET_C		AS VARCHAR(1)
	DECLARE @CANTIDAD_PALLET NUMERIC(20,0)
	DECLARE @PALLET			VARCHAR(50)	
	
	set nocount on 
	
	BEGIN TRY
			
		CREATE TABLE #CONSUMO
			(CLIENTE_ID VARCHAR(100)	COLLATE SQL_Latin1_General_CP1_CI_AS
			,PRODUCTO_ID VARCHAR(100)	COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_LOTE VARCHAR(100)		COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_PARTIDA VARCHAR(100)	COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_SERIE VARCHAR(50)		COLLATE SQL_Latin1_General_CP1_CI_AS
			,CANTIDAD NUMERIC(30,6)
			,CAT_LOG_ID VARCHAR(50)		COLLATE SQL_Latin1_General_CP1_CI_AS
			,EST_MERC_ID VARCHAR(50)	COLLATE SQL_Latin1_General_CP1_CI_AS)

		SET @CUR_VIAJES = CURSOR FOR 
			SELECT DISTINCT CLIENTE_ID, CODIGO_VIAJE
			FROM SYS_INT_DOCUMENTO 
			WHERE CODIGO_VIAJE = @VIAJE
		OPEN @CUR_VIAJES 
		FETCH NEXT FROM @CUR_VIAJES INTO @CLIENTE_ID, @CODIGO_VIAJE
		While @@Fetch_Status=0  
		BEGIN
			
			SELECT	@PALLET_C = FLG_PALLET_COMPLETO 
			FROM	CLIENTE_PARAMETROS
			WHERE	CLIENTE_ID = @CLIENTE_ID
			
			SET @CURDETALLE = CURSOR FOR
			SELECT	SIDD.DOC_EXT, SIDD.NRO_LINEA
			FROM	SYS_INT_DET_DOCUMENTO SIDD
					INNER JOIN SYS_INT_DOCUMENTO SID ON (SID.CLIENTE_ID = SIDD.CLIENTE_ID AND SID.DOC_EXT = SIDD.DOC_EXT)
			WHERE	SID.CLIENTE_ID = @CLIENTE_ID AND SID.CODIGO_VIAJE = @CODIGO_VIAJE AND SIDD.FECHA_ESTADO_GT IS NULL

			OPEN @CURDETALLE
			FETCH NEXT FROM @CURDETALLE INTO @DOC_EXT, @NRO_LINEA

			WHILE @@FETCH_STATUS = 0
			BEGIN

				SELECT	@PRODUCTO_ID = DD.PRODUCTO_ID
						,@CANTIDAD_SOLICITADA = DD.CANTIDAD_SOLICITADA
						,@NRO_LOTE = DD.NRO_LOTE
						,@NRO_PARTIDA = DD.NRO_PARTIDA
						,@NRO_SERIE = DD.PROP3
						,@EST_MERC_ID=DD.EST_MERC_ID
						,@CAT_LOG_ID=DD.CAT_LOG_ID 
				FROM	SYS_INT_DOCUMENTO D
						INNER JOIN SYS_INT_DET_DOCUMENTO DD ON (D.CLIENTE_ID = DD.CLIENTE_ID AND D.DOC_EXT = DD.DOC_EXT)
				WHERE	D.CLIENTE_ID = @CLIENTE_ID 
						AND D.DOC_EXT = @DOC_EXT 
						AND DD.NRO_LINEA = @NRO_LINEA
						
				--CASO PALLET COMPLETO
				IF @PALLET_C ='1' BEGIN
					--STOCK DISPONIBLE EN POSICIONES BEST FIT
					
					SET @CURPALLETS = CURSOR FOR 
						SELECT  ISNULL(SUM(RL.CANTIDAD),0) AS CANTPALLET, DD.PROP1
						FROM 	RL_DET_DOC_TRANS_POSICION RL
								INNER JOIN DET_DOCUMENTO_TRANSACCION DDT(NOLOCK)	ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
								INNER JOIN DET_DOCUMENTO DD				(NOLOCK)	ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
								INNER JOIN CATEGORIA_LOGICA CL			(NOLOCK)	ON (RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID=CL.CAT_LOG_ID AND CL.DISP_EGRESO='1' AND CL.PICKING='1')
								INNER JOIN POSICION P					(NOLOCK)	ON (RL.POSICION_ACTUAL=P.POSICION_ID AND P.POS_LOCKEADA='0' AND ISNULL(P.BESTFIT,'0')='1' and isnull(p.picking,'0')='0')
								LEFT JOIN ESTADO_MERCADERIA_RL EM		(NOLOCK)	ON (RL.CLIENTE_ID=EM.CLIENTE_ID AND RL.EST_MERC_ID=EM.EST_MERC_ID) 	
						WHERE	DD.CLIENTE_ID = @CLIENTE_ID AND RL.DOC_TRANS_ID_EGR IS NULL 
								AND RL.NRO_LINEA_TRANS_EGR IS NULL AND RL.DISPONIBLE='1'	
								AND ISNULL(EM.DISP_EGRESO,'1')='1' AND ISNULL(EM.PICKING,'1')='1'
								AND RL.CAT_LOG_ID<>'TRAN_EGR' AND DD.PRODUCTO_ID = @PRODUCTO_ID
								and ((isnull(@NRO_LOTE,'')='') or (DD.nro_lote = @NRO_LOTE))
								and ((isnull(@NRO_PARTIDA,'')='') or (DD.nro_partida = @NRO_PARTIDA))
								and ((isnull(@NRO_SERIE,'')='') or (DD.nro_serie = @NRO_SERIE))
								and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
								and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))
								and not exists (select 1 from consumo_locator_egr where rl_id = rl.rl_id)
						GROUP BY DD.PROP1
						ORDER BY CANTPALLET DESC
					OPEN @CURPALLETS
					FETCH NEXT FROM @CURPALLETS INTO @CANTIDAD_PALLET, @PALLET
					WHILE @@FETCH_STATUS = 0
						BEGIN
						IF @CANTIDAD_PALLET < @CANTIDAD_SOLICITADA
							
							BEGIN
								IF @CANTIDAD_SOLICITADA - @CANTIDAD_PALLET >= 0
									BEGIN
										SET @CANTIDAD_SOLICITADA = @CANTIDAD_SOLICITADA - @CANTIDAD_PALLET
									END
								IF @CANTIDAD_SOLICITADA = 0
									BEGIN
										BREAK
									END
							END
						FETCH NEXT FROM @CURPALLETS INTO @CANTIDAD_PALLET, @PALLET
					END
					
					IF @CANTIDAD_SOLICITADA <> 0
						BEGIN
							SELECT 1
							RETURN
						END
				END	ELSE
				
				BEGIN
				
				--CASO SIN PALLET COMPLETO
					--STOCK DISPONIBLE EN POSICIONES
					SELECT  @STOCK_DISP = ISNULL(SUM(RL.CANTIDAD),0)
					FROM 	RL_DET_DOC_TRANS_POSICION RL
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT(NOLOCK)	ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
							INNER JOIN DET_DOCUMENTO DD				(NOLOCK)	ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
							INNER JOIN CATEGORIA_LOGICA CL			(NOLOCK)	ON (RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID=CL.CAT_LOG_ID AND CL.DISP_EGRESO='1' AND CL.PICKING='1')
							INNER JOIN POSICION P					(NOLOCK)	ON (RL.POSICION_ACTUAL=P.POSICION_ID AND P.POS_LOCKEADA='0' AND P.PICKING='1')
							LEFT JOIN ESTADO_MERCADERIA_RL EM		(NOLOCK)	ON (RL.CLIENTE_ID=EM.CLIENTE_ID AND RL.EST_MERC_ID=EM.EST_MERC_ID) 	
					WHERE	DD.CLIENTE_ID = @CLIENTE_ID AND RL.DOC_TRANS_ID_EGR IS NULL 
							AND RL.NRO_LINEA_TRANS_EGR IS NULL AND RL.DISPONIBLE='1'	
							AND ISNULL(EM.DISP_EGRESO,'1')='1' AND ISNULL(EM.PICKING,'1')='1'
							AND RL.CAT_LOG_ID<>'TRAN_EGR' AND DD.PRODUCTO_ID = @PRODUCTO_ID
							and ((isnull(@NRO_LOTE,'')='') or (DD.nro_lote = @NRO_LOTE))
							and ((isnull(@NRO_PARTIDA,'')='') or (DD.nro_partida = @NRO_PARTIDA))
							and ((isnull(@NRO_SERIE,'')='') or (DD.nro_serie = @NRO_SERIE))
							and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
							and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))
							and not exists (select 1 from consumo_locator_egr where rl_id = rl.rl_id)
							
					--STOCK DISPONIBLE EN NAVES
					SELECT	@STOCK_DISP = @STOCK_DISP + ISNULL(SUM(RL.CANTIDAD),0)
					FROM	RL_DET_DOC_TRANS_POSICION RL
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT(NOLOCK)	ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
							INNER JOIN DET_DOCUMENTO DD				(NOLOCK)	ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
							INNER JOIN CATEGORIA_LOGICA CL			(NOLOCK)	ON (RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID=CL.CAT_LOG_ID AND CL.DISP_EGRESO='1' AND CL.PICKING='1')
							INNER JOIN NAVE N						(NOLOCK)	ON (RL.NAVE_ACTUAL=N.NAVE_ID AND N.DISP_EGRESO='1' AND N.PRE_EGRESO='0' AND N.PRE_INGRESO='0' AND N.PICKING='1')
							LEFT JOIN ESTADO_MERCADERIA_RL EM		(NOLOCK)	ON (RL.CLIENTE_ID=EM.CLIENTE_ID AND RL.EST_MERC_ID=EM.EST_MERC_ID) 
					WHERE 	DD.CLIENTE_ID = @CLIENTE_ID AND RL.DOC_TRANS_ID_EGR IS NULL 
							AND RL.NRO_LINEA_TRANS_EGR IS NULL AND RL.DISPONIBLE='1' 	
							AND ISNULL(EM.DISP_EGRESO,'1')='1' AND ISNULL(EM.PICKING,'1')='1' 
							AND RL.CAT_LOG_ID<>'TRAN_EGR' AND DD.PRODUCTO_ID = @PRODUCTO_ID
							and ((isnull(@NRO_LOTE,'')='') or (DD.nro_lote = @NRO_LOTE))
							and ((isnull(@NRO_PARTIDA,'')='') or (DD.nro_partida = @NRO_PARTIDA))
							and ((isnull(@NRO_SERIE,'')='') or (DD.nro_serie = @NRO_SERIE))
							and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
							and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))	
							and not exists (select 1 from consumo_locator_egr where rl_id = rl.rl_id)	
							
						SELECT	@RESTA = ISNULL(SUM(CANTIDAD),0)
						FROM	#CONSUMO
						WHERE	CLIENTE_ID = @CLIENTE_ID AND PRODUCTO_ID = @PRODUCTO_ID
								and ((isnull(@NRO_LOTE,'')='') or (nro_lote = @NRO_LOTE))
								and ((isnull(@NRO_PARTIDA,'')='') or (nro_partida = @NRO_PARTIDA))
								and ((isnull(@NRO_SERIE,'')='') or (nro_serie = @NRO_SERIE))
								and ((isnull(@CAT_LOG_ID,'')='') or (CAT_LOG_ID = @CAT_LOG_ID))
								and ((isnull(@EST_MERC_ID,'')='') or (EST_MERC_ID = @EST_MERC_ID))						

						SET @STOCK_DISP = @STOCK_DISP - @RESTA
						
						IF @CANTIDAD_SOLICITADA > @STOCK_DISP
						BEGIN
							SELECT 1
							RETURN
						END

						INSERT INTO #CONSUMO
						SELECT	CLIENTE_ID , PRODUCTO_ID, NRO_LOTE, NRO_PARTIDA, PROP3 AS NRO_SERIE, 
								CANTIDAD_SOLICITADA,
								--CASE WHEN (@STOCK_DISP >=CANTIDAD_SOLICITADA) THEN (CANTIDAD_SOLICITADA) ELSE @STOCK_DISP END,
								CAT_LOG_ID, EST_MERC_ID
						FROM	SYS_INT_DET_DOCUMENTO WHERE CLIENTE_ID = @CLIENTE_ID AND DOC_EXT = @DOC_EXT AND NRO_LINEA = @NRO_LINEA
				END
				
			FETCH NEXT FROM @CURDETALLE INTO @DOC_EXT, @NRO_LINEA

			END
			CLOSE @CURDETALLE
			DEALLOCATE @CURDETALLE

			FETCH NEXT FROM @CUR_VIAJES INTO @CLIENTE_ID, @CODIGO_VIAJE
		END --WHILE
		
		CLOSE @CUR_VIAJES
		DEALLOCATE @CUR_VIAJES
		
		CLOSE @CURPALLETS
		DEALLOCATE @CURPALLETS

		BEGIN
			SELECT 2
			RETURN
		END
		
	END TRY
	BEGIN CATCH
		EXEC usp_RethrowError
	END CATCH	
END --FIN PROCEDURE




GO

