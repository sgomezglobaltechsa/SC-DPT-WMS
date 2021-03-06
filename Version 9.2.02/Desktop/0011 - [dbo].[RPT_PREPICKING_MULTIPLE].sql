/****** Object:  StoredProcedure [dbo].[RPT_PREPICKING_MULTIPLE]    Script Date: 07/10/2014 16:39:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_PREPICKING_MULTIPLE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[RPT_PREPICKING_MULTIPLE]
GO

CREATE  PROCEDURE [dbo].[RPT_PREPICKING_MULTIPLE]
@TIPO_Q	CHAR(1) 		OUTPUT  --SI ES TODO O SOLO LAS DIFERENCIAS (1 = TODO, 0=DIFERENCIAS)
AS
BEGIN
	DECLARE @USUARIO 		VARCHAR(50)
	DECLARE @TERMINAL		VARCHAR(100)
	DECLARE @FECHA			VARCHAR(100)
	DECLARE @CODIGO_VIAJE	VARCHAR(100)
	DECLARE @PEDIDO			VARCHAR(100)
	DECLARE @CUR_VIAJES		CURSOR
	DECLARE @CLIENTE_ID		VARCHAR(15)
	DECLARE @CURDETALLE		CURSOR
	DECLARE @DOC_EXT		VARCHAR(100)
	DECLARE @NRO_LINEA		NUMERIC(20,0)
	DECLARE @PESO			NUMERIC(20,5)
	DECLARE @NRO_LOTE		VARCHAR(100)
	DECLARE @NRO_PARTIDA	VARCHAR(100)
	DECLARE @NRO_SERIE		VARCHAR(50)
	DECLARE @PRODUCTO_ID	VARCHAR(30)
	DECLARE @STOCK_DISP		NUMERIC(20,5)
	DECLARE @PREING			NUMERIC(20,5)
	DECLARE @TRANSITO		NUMERIC(20,5)
	DECLARE @NOPICK			NUMERIC(20,5)
	DECLARE @TOTAL_DEP		NUMERIC(20,5)
	DECLARE @RESTA			NUMERIC(20,5)
	DECLARE @EST_MERC_ID	VARCHAR(50)
	DECLARE @CAT_LOG_ID		VARCHAR(50)

	SELECT @USUARIO=USUARIO_ID FROM #TEMP_USUARIO_LOGGIN
	--SET @USUARIO='ADMIN'
	SET @TERMINAL=HOST_NAME()
	--SET @FECHA=CONVERT(VARCHAR,GETDATE(),103)
	SET @FECHA = CONVERT(VARCHAR(20),GETDATE(),103) + ' ' + RIGHT(CONVERT(VARCHAR(20),GETDATE(),120),8)
	
	set nocount on 
	
	BEGIN TRY	
		
		CREATE TABLE #RPT_FINAL 
			(CODIGO_VIAJE	VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,PEDIDO			VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,CLIENTE_ID		VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,PRODUCTO_ID	VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,DESCRIPCION	VARCHAR(1000)  COLLATE SQL_Latin1_General_CP1_CI_AS
			,QTY_SOL NUMERIC(30,6)
			,STOCK_DISP NUMERIC(30,6)
			,DIF NUMERIC(30,6)
			,PREING NUMERIC(30,6)
			,TRANSITO NUMERIC(30,6)
			,UBIC_NOPICK NUMERIC(30,6)
			,TOTAL_DEP NUMERIC(30,6)
			,USUARIO VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS 
			,TERMINAL VARCHAR(100)  COLLATE SQL_Latin1_General_CP1_CI_AS
			,FECHA VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_LOTE VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_PARTIDA VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_SERIE VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
			,CAT_LOG_ID VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
			,EST_MERC_ID VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
			
		CREATE TABLE #AUX 
			(CODIGO_VIAJE VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,PEDIDO VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,CLIENTE_ID VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,PRODUCTO_ID VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,DESCRIPCION VARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS
			,QTY_SOL NUMERIC(30,6)
			,STOCK_DISP NUMERIC(30,6)
			,DIF NUMERIC(30,6)
			,PREING NUMERIC(30,6)
			,TRANSITO NUMERIC(30,6)
			,UBIC_NOPICK NUMERIC(30,6)
			,TOTAL_DEP NUMERIC(30,6)
			,USUARIO VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,TERMINAL VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,FECHA VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_LOTE VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_PARTIDA VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_SERIE VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
			,CAT_LOG_ID VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
			,EST_MERC_ID VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
			
		CREATE TABLE #CONSUMO
			(CLIENTE_ID VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,PRODUCTO_ID VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_LOTE VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_PARTIDA VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_SERIE VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
			,CANTIDAD NUMERIC(30,6)
			,CAT_LOG_ID VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS
			,EST_MERC_ID VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
			
		--#SDDPESO ASIGNA A CADA CLIENTE_ID | DOC_EXT | NRO LINEA UN PESO LOGICO DE ACUERDO A LAS PROPIEDADES NRO_LOTE, NRO_PARTIDA Y NRO_SERIE
		CREATE TABLE #SDDPESO
			(CLIENTE_ID VARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AS
			,CODIGO_VIAJE VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,DOC_EXT VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
			,NRO_LINEA NUMERIC(20,0), PESO INT)
		

		INSERT INTO #SDDPESO
		SELECT	DD.CLIENTE_ID, D.CODIGO_VIAJE, DD.DOC_EXT, DD.NRO_LINEA,
				CAST((CASE
					WHEN ISNULL(NRO_LOTE,'')='' AND ISNULL(NRO_PARTIDA,'')='' AND ISNULL(PROP3,'')='' THEN 0
					WHEN ISNULL(NRO_LOTE,'')='' AND ISNULL(NRO_PARTIDA,'')='' AND ISNULL(PROP3,'')<>'' THEN 1
					WHEN ISNULL(NRO_LOTE,'')='' AND ISNULL(NRO_PARTIDA,'')<>'' AND ISNULL(PROP3,'')='' THEN 1
					WHEN ISNULL(NRO_LOTE,'')='' AND ISNULL(NRO_PARTIDA,'')<>'' AND ISNULL(PROP3,'')<>'' THEN 2
					WHEN ISNULL(NRO_LOTE,'')<>'' AND ISNULL(NRO_PARTIDA,'')='' AND ISNULL(PROP3,'')='' THEN 1
					WHEN ISNULL(NRO_LOTE,'')<>'' AND ISNULL(NRO_PARTIDA,'')='' AND ISNULL(PROP3,'')<>'' THEN 2
					WHEN ISNULL(NRO_LOTE,'')<>'' AND ISNULL(NRO_PARTIDA,'')<>'' AND ISNULL(PROP3,'')='' THEN 2
					WHEN ISNULL(NRO_LOTE,'')<>'' AND ISNULL(NRO_PARTIDA,'')<>'' AND ISNULL(PROP3,'')<>'' THEN 3
					ELSE 0
				END) AS INT) AS PESO
		FROM	SYS_INT_DET_DOCUMENTO DD (NOLOCK)
				INNER JOIN SYS_INT_DOCUMENTO D (NOLOCK) ON (DD.CLIENTE_ID = D.CLIENTE_ID AND DD.DOC_EXT = D.DOC_EXT)
				INNER JOIN #TMP_VIAJES T (NOLOCK) ON	(D.CLIENTE_ID =  T.CLIENTE_ID AND D.CODIGO_VIAJE = T.CODIGO_VIAJE AND D.DOC_EXT = T.PEDIDO)
		
		SET @CUR_VIAJES = CURSOR FOR 
			SELECT DISTINCT T.CLIENTE_ID, T.CODIGO_VIAJE
			FROM #TMP_VIAJES T 
			INNER JOIN SYS_INT_DOCUMENTO D ON (D.CLIENTE_ID =  T.CLIENTE_ID  
											  AND D.CODIGO_VIAJE = T.CODIGO_VIAJE  
											  AND D.DOC_EXT = T.PEDIDO )
			order by T.CLIENTE_ID, T.CODIGO_VIAJE
		
		
		OPEN @CUR_VIAJES 
		FETCH NEXT FROM @CUR_VIAJES INTO @CLIENTE_ID, @CODIGO_VIAJE
		While @@Fetch_Status=0  
		BEGIN
		
			TRUNCATE TABLE #AUX
			--Por cada viaje evaluo la reserva en stock para cada item ordenado segun el peso
			SET @CURDETALLE = CURSOR FOR
			SELECT	PS.DOC_EXT, PS.NRO_LINEA
			FROM	#SDDPESO PS
			WHERE	PS.CLIENTE_ID = @CLIENTE_ID AND PS.CODIGO_VIAJE = @CODIGO_VIAJE
			order by 
					PS.PESO DESC

			OPEN @CURDETALLE
			FETCH NEXT FROM @CURDETALLE INTO @DOC_EXT, @NRO_LINEA

			WHILE @@FETCH_STATUS = 0
			BEGIN

				SELECT	@NRO_LOTE = DD.NRO_LOTE, @NRO_PARTIDA = DD.NRO_PARTIDA, @NRO_SERIE = DD.PROP3, @PRODUCTO_ID = DD.PRODUCTO_ID,
						@EST_MERC_ID=DD.EST_MERC_ID, @CAT_LOG_ID=DD.CAT_LOG_ID 
				FROM	SYS_INT_DOCUMENTO D
						INNER JOIN SYS_INT_DET_DOCUMENTO DD ON (D.CLIENTE_ID = DD.CLIENTE_ID AND D.DOC_EXT = DD.DOC_EXT)
				WHERE	D.CLIENTE_ID = @CLIENTE_ID AND D.DOC_EXT = @DOC_EXT AND DD.NRO_LINEA = @NRO_LINEA


				--STOCK_DISPONIBLE
				SELECT  @STOCK_DISP = ISNULL(SUM(RL.CANTIDAD),0)
				FROM 	RL_DET_DOC_TRANS_POSICION RL
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT(NOLOCK)	ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
						INNER JOIN DET_DOCUMENTO DD				(NOLOCK)	ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
						INNER JOIN CATEGORIA_LOGICA CL			(NOLOCK)	ON (RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID=CL.CAT_LOG_ID AND CL.DISP_EGRESO='1' AND CL.PICKING='1')
						INNER JOIN POSICION P					(NOLOCK)	ON (RL.POSICION_ACTUAL=P.POSICION_ID AND P.POS_LOCKEADA='0' AND P.PICKING='1')
						LEFT JOIN ESTADO_MERCADERIA_RL EM		(NOLOCK)	ON (RL.CLIENTE_ID=EM.CLIENTE_ID AND RL.EST_MERC_ID=EM.EST_MERC_ID) 	
				WHERE	DD.CLIENTE_ID = @CLIENTE_ID AND RL.DOC_TRANS_ID_EGR IS NULL AND RL.NRO_LINEA_TRANS_EGR IS NULL AND RL.DISPONIBLE='1'	AND ISNULL(EM.DISP_EGRESO,'1')='1'
						AND ISNULL(EM.PICKING,'1')='1'	AND RL.CAT_LOG_ID<>'TRAN_EGR' AND DD.PRODUCTO_ID = @PRODUCTO_ID
						and ((isnull(@NRO_LOTE,'')='') or (DD.nro_lote = @NRO_LOTE))
						and ((isnull(@NRO_PARTIDA,'')='') or (DD.nro_partida = @NRO_PARTIDA))
						and ((isnull(@NRO_SERIE,'')='') or (DD.nro_serie = @NRO_SERIE))
						and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
						and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))

				SELECT	@STOCK_DISP = @STOCK_DISP + ISNULL(SUM(RL.CANTIDAD),0)
				FROM	RL_DET_DOC_TRANS_POSICION RL
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT(NOLOCK)	ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
						INNER JOIN DET_DOCUMENTO DD				(NOLOCK)	ON (DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
						INNER JOIN CATEGORIA_LOGICA CL			(NOLOCK)	ON (RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID=CL.CAT_LOG_ID AND CL.DISP_EGRESO='1' AND CL.PICKING='1')
						INNER JOIN NAVE N						(NOLOCK)	ON (RL.NAVE_ACTUAL=N.NAVE_ID AND N.DISP_EGRESO='1' AND N.PRE_EGRESO='0' AND N.PRE_INGRESO='0' AND N.PICKING='1')
						LEFT JOIN ESTADO_MERCADERIA_RL EM		(NOLOCK)	ON (RL.CLIENTE_ID=EM.CLIENTE_ID AND RL.EST_MERC_ID=EM.EST_MERC_ID) 
				WHERE 	DD.CLIENTE_ID = @CLIENTE_ID AND RL.DOC_TRANS_ID_EGR IS NULL AND RL.NRO_LINEA_TRANS_EGR IS NULL AND RL.DISPONIBLE='1' 	AND ISNULL(EM.DISP_EGRESO,'1')='1'
						AND ISNULL(EM.PICKING,'1')='1' AND RL.CAT_LOG_ID<>'TRAN_EGR' AND DD.PRODUCTO_ID = @PRODUCTO_ID
						and ((isnull(@NRO_LOTE,'')='') or (DD.nro_lote = @NRO_LOTE))
						and ((isnull(@NRO_PARTIDA,'')='') or (DD.nro_partida = @NRO_PARTIDA))
						and ((isnull(@NRO_SERIE,'')='') or (DD.nro_serie = @NRO_SERIE))
						and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
						and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))						

				SELECT	@RESTA = ISNULL(SUM(CANTIDAD),0)
				FROM	#CONSUMO
				WHERE	CLIENTE_ID = @CLIENTE_ID AND PRODUCTO_ID = @PRODUCTO_ID
						and ((isnull(@NRO_LOTE,'')='') or (nro_lote = @NRO_LOTE))
						and ((isnull(@NRO_PARTIDA,'')='') or (nro_partida = @NRO_PARTIDA))
						and ((isnull(@NRO_SERIE,'')='') or (nro_serie = @NRO_SERIE))
						and ((isnull(@CAT_LOG_ID,'')='') or (CAT_LOG_ID = @CAT_LOG_ID))
						and ((isnull(@EST_MERC_ID,'')='') or (EST_MERC_ID = @EST_MERC_ID))						

				SET @STOCK_DISP = @STOCK_DISP - @RESTA

				/*				
				--PREING
				SELECT	@PREING = ISNULL(SUM(RL.CANTIDAD),0)
				FROM	DET_DOCUMENTO DD (NOLOCK) 
						INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)	ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)	ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
						INNER JOIN NAVE N(NOLOCK)							ON(RL.NAVE_ACTUAL=N.NAVE_ID)
				WHERE	N.PRE_INGRESO='1' AND DD.CLIENTE_ID = @CLIENTE_ID AND DD.PRODUCTO_ID = @PRODUCTO_ID
						and ((isnull(@NRO_LOTE,'')='') or (DD.nro_lote = @NRO_LOTE))
						and ((isnull(@NRO_PARTIDA,'')='') or (DD.nro_partida = @NRO_PARTIDA))
						and ((isnull(@NRO_SERIE,'')='') or (DD.nro_serie = @NRO_SERIE))
				*/

				--PREING
				SELECT @PREING = ISNULL(SUM(X.CANT),0)	
				FROM
					(
					SELECT	ISNULL(SUM(RL.CANTIDAD),0) AS CANT
					FROM	DET_DOCUMENTO DD (NOLOCK) 
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)	ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
							INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)	ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
							INNER JOIN NAVE N(NOLOCK)							ON(RL.NAVE_ACTUAL=N.NAVE_ID)
					WHERE	DD.CLIENTE_ID = @CLIENTE_ID AND DD.PRODUCTO_ID =  @PRODUCTO_ID
							AND (N.PRE_INGRESO='1' OR RL.CAT_LOG_ID = 'TRAN_ING')
							AND ((ISNULL(@NRO_LOTE,'')='') OR (DD.NRO_LOTE = @NRO_LOTE))
							AND ((ISNULL(@NRO_PARTIDA,'')='') OR (DD.NRO_PARTIDA = @NRO_PARTIDA))
							AND ((ISNULL(@NRO_SERIE,'')='') OR (DD.NRO_SERIE = @NRO_SERIE))	
							and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
							and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))							
					UNION ALL
					SELECT	ISNULL(SUM(RL.CANTIDAD),0) AS CANT
					FROM	DET_DOCUMENTO DD (NOLOCK) 
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)	ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
							INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)	ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
							INNER JOIN NAVE N(NOLOCK)							ON(RL.NAVE_ANTERIOR=N.NAVE_ID)
					WHERE	DD.CLIENTE_ID = @CLIENTE_ID AND DD.PRODUCTO_ID =  @PRODUCTO_ID
							AND (N.PRE_INGRESO<>'1' OR RL.CAT_LOG_ID = 'TRAN_ING')
							AND ((ISNULL(@NRO_LOTE,'')='') OR (DD.NRO_LOTE = @NRO_LOTE))
							AND ((ISNULL(@NRO_PARTIDA,'')='') OR (DD.NRO_PARTIDA = @NRO_PARTIDA))
							AND ((ISNULL(@NRO_SERIE,'')='') OR (DD.NRO_SERIE = @NRO_SERIE))		
							and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
							and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))											
				) AS X

				-- TRANSITO
				SELECT 	@TRANSITO = ISNULL(SUM(B.QTY),0)
				FROM	(
						SELECT	DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, DD.CLIENTE_ID, DD.PRODUCTO_ID, SUM(RL.CANTIDAD) AS QTY,
								RL.CAT_LOG_ID, RL.EST_MERC_ID
						FROM	DET_DOCUMENTO DD (NOLOCK) INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)
								ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
								INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)
								ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
								INNER JOIN CATEGORIA_LOGICA CL(NOLOCK) 
								ON(RL.CLIENTE_ID=CL.CLIENTE_ID  AND RL.CAT_LOG_ID=CL.CAT_LOG_ID AND CL.CAT_LOG_ID NOT IN('TRAN_ING', 'TRAN_EGR') AND CL.PICKING='0' AND CL.DISP_EGRESO='0')
						GROUP BY 
								DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, DD.CLIENTE_ID, DD.PRODUCTO_ID, RL.CAT_LOG_ID, RL.EST_MERC_ID
						UNION 	ALL
						SELECT	DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, DD.CLIENTE_ID, DD.PRODUCTO_ID, SUM(RL.CANTIDAD) AS QTY,
								RL.CAT_LOG_ID,RL.EST_MERC_ID 
						FROM	DET_DOCUMENTO DD (NOLOCK) INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)
								ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
								INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)
								ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
								INNER JOIN ESTADO_MERCADERIA_RL EM(NOLOCK) 
								ON(RL.CLIENTE_ID=EM.CLIENTE_ID AND RL.EST_MERC_ID=EM.EST_MERC_ID  AND EM.PICKING='0' AND EM.DISP_EGRESO='0')
						GROUP BY 
								DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, DD.CLIENTE_ID, DD.PRODUCTO_ID, RL.CAT_LOG_ID, RL.EST_MERC_ID 
				
						)B
				WHERE	B.CLIENTE_ID = @CLIENTE_ID AND B.PRODUCTO_ID = @PRODUCTO_ID
						and ((isnull(@NRO_LOTE,'')='') or (B.nro_lote = @NRO_LOTE))
						and ((isnull(@NRO_PARTIDA,'')='') or (B.nro_partida = @NRO_PARTIDA))
						and ((isnull(@NRO_SERIE,'')='') or (B.nro_serie = @NRO_SERIE))
						and ((isnull(@CAT_LOG_ID,'')='') or (B.CAT_LOG_ID = @CAT_LOG_ID))
						and ((isnull(@EST_MERC_ID,'')='') or (B.EST_MERC_ID = @EST_MERC_ID))
													

				--TOTAL_DEP
				SELECT 	@TOTAL_DEP = ISNULL(SUM(RL.CANTIDAD),0)
				FROM	DET_DOCUMENTO DD (NOLOCK) INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)
						ON(DD.DOCUMENTO_ID= DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL
						ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
				WHERE	DD.CLIENTE_ID = @CLIENTE_ID AND DD.PRODUCTO_ID = @PRODUCTO_ID
						and ((isnull(@NRO_LOTE,'')='') or (DD.nro_lote = @NRO_LOTE))
						and ((isnull(@NRO_PARTIDA,'')='') or (DD.nro_partida = @NRO_PARTIDA))
						and ((isnull(@NRO_SERIE,'')='') or (DD.nro_serie = @NRO_SERIE))
						and ((isnull(@CAT_LOG_ID,'')='') or (RL.CAT_LOG_ID = @CAT_LOG_ID))
						and ((isnull(@EST_MERC_ID,'')='') or (RL.EST_MERC_ID = @EST_MERC_ID))							

				--NOPICK
				SELECT 	@NOPICK = ISNULL(SUM(A.QTY_UBIC),0)
				FROM	(
						SELECT	DD.CLIENTE_ID, DD.PRODUCTO_ID, DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, SUM(RL.CANTIDAD)AS QTY_UBIC,
								RL.CAT_LOG_ID,RL.EST_MERC_ID
						FROM	DET_DOCUMENTO DD (NOLOCK) INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)
								ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
								INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)
								ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
								INNER JOIN POSICION P (NOLOCK)
								ON(RL.POSICION_ACTUAL=P.POSICION_ID AND ISNULL(P.PICKING,'0')='0')
						GROUP BY 
								DD.CLIENTE_ID, DD.PRODUCTO_ID, DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE,
								RL.CAT_LOG_ID,RL.EST_MERC_ID 
						UNION ALL
						SELECT	DD.CLIENTE_ID, DD.PRODUCTO_ID, DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, SUM(RL.CANTIDAD)AS QTY_UBIC,
								RL.CAT_LOG_ID, RL.EST_MERC_ID
						FROM	DET_DOCUMENTO DD (NOLOCK) INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)
								ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
								INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)
								ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
								INNER JOIN POSICION P (NOLOCK)
								ON(RL.POSICION_ACTUAL=P.POSICION_ID AND ISNULL(P.POS_LOCKEADA,'0')='1')
						GROUP BY 
								DD.CLIENTE_ID, DD.PRODUCTO_ID, DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE,
								RL.CAT_LOG_ID,RL.EST_MERC_ID
						UNION ALL
						SELECT	DD.CLIENTE_ID, DD.PRODUCTO_ID, DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, SUM(RL.CANTIDAD)AS QTY_UBIC,
								RL.CAT_LOG_ID,RL.EST_MERC_ID
						FROM	DET_DOCUMENTO DD (NOLOCK) INNER JOIN DET_DOCUMENTO_TRANSACCION DDT (NOLOCK)
								ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
								INNER JOIN RL_DET_DOC_TRANS_POSICION RL (NOLOCK)
								ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
								INNER JOIN NAVE N (NOLOCK)
								ON(RL.NAVE_ACTUAL=N.NAVE_ID AND ISNULL(N.PICKING,'0')='0' AND N.PRE_INGRESO='0')
						GROUP BY 
								DD.CLIENTE_ID, DD.PRODUCTO_ID, DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE,
								RL.CAT_LOG_ID,RL.EST_MERC_ID 
						)A
				WHERE	A.CLIENTE_ID = @CLIENTE_ID AND A.PRODUCTO_ID = @PRODUCTO_ID
						and ((isnull(@NRO_LOTE,'')='') or (A.nro_lote = @NRO_LOTE))
						and ((isnull(@NRO_PARTIDA,'')='') or (A.nro_partida = @NRO_PARTIDA))
						and ((isnull(@NRO_SERIE,'')='') or (A.nro_serie = @NRO_SERIE))
						and ((isnull(@CAT_LOG_ID,'')='') or (A.CAT_LOG_ID = @CAT_LOG_ID))
						and ((isnull(@EST_MERC_ID,'')='') or (A.EST_MERC_ID = @EST_MERC_ID))

				INSERT INTO #AUX
				SELECT
						 D.CODIGO_VIAJE
						,D.DOC_EXT
						,DD.CLIENTE_ID
						,DD.PRODUCTO_ID
						,PX.DESCRIPCION
						,sum(DD.CANTIDAD_SOLICITADA)												QTY_SOL
						,@STOCK_DISP																STOCK_DISP
						,DBO.RPT_PREPICK_COMP(SUM(DD.CANTIDAD_SOLICITADA),ISNULL(@STOCK_DISP,0))	DIF
						,@PREING																	PREING
						,@TRANSITO																	TRANSITO
						,@NOPICK																	UBIC_NOPICK
						,@TOTAL_DEP																	TOTAL_DEP
						,@USUARIO																	USUARIO
						,@TERMINAL																	TERMINAL
						,@FECHA																		FECHA
						,DD.NRO_LOTE
						,DD.NRO_PARTIDA
						,DD.PROP3 AS NRO_SERIE
						,DD.CAT_LOG_ID
						,DD.EST_MERC_ID
				FROM	SYS_INT_DOCUMENTO D (NOLOCK) 
						INNER JOIN SYS_INT_DET_DOCUMENTO DD (NOLOCK) ON(D.CLIENTE_ID=DD.CLIENTE_ID AND D.DOC_EXT=DD.DOC_EXT)
						LEFT JOIN PRODUCTO PX (NOLOCK) ON(DD.CLIENTE_ID=PX.CLIENTE_ID AND DD.PRODUCTO_ID=PX.PRODUCTO_ID)				
				WHERE
						D.CLIENTE_ID = @CLIENTE_ID AND D.CODIGO_VIAJE=@CODIGO_VIAJE AND D.DOC_EXT = @DOC_EXT AND DD.NRO_LINEA = @NRO_LINEA
				GROUP BY
						D.CODIGO_VIAJE,D.DOC_EXT, DD.CLIENTE_ID, DD.PRODUCTO_ID, px.descripcion,DD.NRO_LOTE, DD.NRO_PARTIDA, DD.PROP3,
						DD.CAT_LOG_ID, DD.EST_MERC_ID
				ORDER BY dd.producto_id

				INSERT INTO #CONSUMO
				SELECT	CLIENTE_ID , PRODUCTO_ID, NRO_LOTE, NRO_PARTIDA, PROP3 AS NRO_SERIE, CASE WHEN (@STOCK_DISP >=CANTIDAD_SOLICITADA) THEN (CANTIDAD_SOLICITADA) ELSE @STOCK_DISP END,
						CAT_LOG_ID, EST_MERC_ID
				FROM	SYS_INT_DET_DOCUMENTO WHERE CLIENTE_ID = @CLIENTE_ID AND DOC_EXT = @DOC_EXT AND NRO_LINEA = @NRO_LINEA
			
				FETCH NEXT FROM @CURDETALLE INTO @DOC_EXT, @NRO_LINEA

			END
			CLOSE @CURDETALLE
			DEALLOCATE @CURDETALLE

			INSERT INTO #RPT_FINAL
			SELECT
			CODIGO_VIAJE
			,PEDIDO
			,CLIENTE_ID
			,(CASE
				WHEN ISNULL(NRO_LOTE,'')<>'' THEN '(*) ' + PRODUCTO_ID
				WHEN ISNULL(NRO_PARTIDA,'')<>'' THEN '(*) ' + PRODUCTO_ID
				WHEN ISNULL(NRO_SERIE,'')<>'' THEN '(*) ' + PRODUCTO_ID
				ELSE PRODUCTO_ID
			END)
			,DESCRIPCION
			,QTY_SOL
			,STOCK_DISP
			,DIF
			,PREING
			,TRANSITO
			,UBIC_NOPICK
			,TOTAL_DEP
			,USUARIO
			,TERMINAL
			,FECHA
			,NRO_LOTE
			,NRO_PARTIDA
			,NRO_SERIE
			,CAT_LOG_ID
			,EST_MERC_ID
			FROM #AUX ORDER BY CLIENTE_ID, CODIGO_VIAJE, PEDIDO, PRODUCTO_ID
			

			FETCH NEXT FROM @CUR_VIAJES INTO @CLIENTE_ID, @CODIGO_VIAJE
		END --WHILE
		
		CLOSE @CUR_VIAJES
		DEALLOCATE @CUR_VIAJES
		
		
		
		IF @TIPO_Q='1' 
				SELECT T.*, C.RAZON_SOCIAL FROM #RPT_FINAL T
				inner join CLIENTE c on (c.CLIENTE_ID = T.CLIENTE_ID)
		ELSE IF @TIPO_Q='0' 
				SELECT T.*, C.RAZON_SOCIAL FROM #RPT_FINAL T
				inner join CLIENTE c on (c.CLIENTE_ID = T.CLIENTE_ID)

				WHERE DIF <0
		ELSE
			RAISERROR('TIPO DE LISTADO NO DEFINIDO',15,1)
				
		
			
		
	END TRY
	BEGIN CATCH
		EXEC usp_RethrowError
	END CATCH	
END --FIN PROCEDURE



GO


