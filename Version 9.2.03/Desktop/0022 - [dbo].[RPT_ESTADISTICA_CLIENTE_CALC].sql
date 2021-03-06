/****** Object:  StoredProcedure [dbo].[RPT_ESTADISTICA_CLIENTE]    Script Date: 09/02/2014 13:20:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_ESTADISTICA_CLIENTE_CALC]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[RPT_ESTADISTICA_CLIENTE_CALC]
GO

CREATE PROCEDURE [dbo].[RPT_ESTADISTICA_CLIENTE_CALC]
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	DECLARE @CUR_CLIENTE_ID	CURSOR;
	DECLARE @CLIENTE_ID		VARCHAR(15)
	DECLARE @FCAL			DATETIME
	DECLARE	@FDESDE			DATETIME
	DECLARE @FHASTA			DATETIME
	DECLARE @MSG			VARCHAR(100)
	
	IF CURSOR_STATUS('global','@CUR_CLIENTE_ID')>=-1
	BEGIN
		DEALLOCATE @CUR_CLIENTE_ID
	END
	

	SET @CUR_CLIENTE_ID=CURSOR FOR 
	SELECT	DISTINCT CLIENTE_ID, F_SNAP
	FROM	SNAP_EXISTENCIAS S
	WHERE	NOT EXISTS(	SELECT	1
						FROM	C_ESTADISTICAS_RPT C
						WHERE	C.CLIENTE_ID=S.CLIENTE_ID
								AND F_ORDENAMIENTO=CONVERT(DATETIME,CONVERT(VARCHAR,S.F_SNAP,103),103))
	ORDER BY
			F_SNAP,CLIENTE_ID
	
	OPEN @CUR_CLIENTE_ID
	FETCH NEXT FROM @CUR_CLIENTE_ID INTO @CLIENTE_ID, @FCAL
	WHILE @@FETCH_STATUS=0 BEGIN
		
		SET @FDESDE=convert(datetime,CONVERT(varchar,@fcal,103),103)
		SET @FHASTA=convert(datetime,CONVERT(varchar,@fcal,103),103)
		
		BEGIN TRY
		
		INSERT INTO C_ESTADISTICAS_RPT (CLIENTE_ID, CLIENTE, FECHA, Q_POS_OCUPADAS, Q_VOL_PROD, QTY_DOC_ING,
										PRODUCTOS_DIST_ING, VOL_ING, CANTIDAD_INGRESO, QTY_DOC_EGR,
										PRODUCTOS_DIST_EGR, VOL_EGR, CANTIDAD_EGRESO, F_ORDENAMIENTO)
		SELECT	@CLIENTE_ID						AS CLIENTE_ID,
				ZZZ.CLIENTE						AS CLIENTE,
				CONVERT(VARCHAR,ZZZ.FECHA,103)	AS FECHA,
				SUM(ZZZ.Q_POS_OCUPADAS)			AS Q_POS_OCUPADAS,	
				SUM(ZZZ.Q_VOL_PROD)				AS Q_VOL_PROD,
				SUM(ZZZ.QTY_DOC_ING)			AS QTY_DOC_ING,
				SUM(ZZZ.PRODUCTOS_DIST_ING)		AS PRODUCTOS_DIST_ING,
				SUM(ZZZ.VOL_ING)				AS VOL_ING,
				SUM(ZZZ.CANTIDAD_INGRESO)		AS CANTIDAD_INGRESO,
				SUM(ZZZ.QTY_DOC_EGR)			AS QTY_DOC_EGR,
				SUM(ZZZ.PRODUCTOS_DIST_EGR)		AS PRODUCTOS_DIST_EGR,
				SUM(ZZZ.VOL_EGR)				AS VOL_EGR,
				SUM(ZZZ.CANTIDAD_EGRESO)		AS CANTIDAD_EGRESO,
				CONVERT(DATETIME,CONVERT(VARCHAR,ZZZ.FECHA,103),103)	
												AS F_ORDENAMIENTO
		FROM	(		
			SELECT  X.CLIENTE				AS CLIENTE,	
					X.FECHA					AS FECHA,											
					0						AS QTY_DOC_ING,
					0						AS PRODUCTOS_DIST_ING,
					0						AS VOL_ING,
					0						AS CANTIDAD_INGRESO,
					0						AS QTY_DOC_EGR,
					0						AS PRODUCTOS_DIST_EGR,
					0						AS VOL_EGR,
					0						AS CANTIDAD_EGRESO,				
					SUM(X.Q_POS_OCUPADAS)	AS Q_POS_OCUPADAS,
					SUM(X.Q_VOL_PROD)		AS Q_VOL_PROD
			FROM
				(SELECT DISTINCT  
						 C.RAZON_SOCIAL						AS CLIENTE
						,SE.F_SNAP							AS FECHA
						,QPOS.CTN							AS Q_POS_OCUPADAS			
						,(SUM(SE.CANTIDAD * ((ISNULL(PR.ALTO,0)*ISNULL(PR.ANCHO,0)*ISNULL(PR.LARGO,0))))/1000000)							
															AS Q_VOL_PROD

				FROM    SNAP_EXISTENCIAS SE (NOLOCK)INNER JOIN POSICION P	(NOLOCK)ON(SE.POSICION_ACTUAL=P.POSICION_ID)
						INNER JOIN NAVE N									(NOLOCK)ON(P.NAVE_ID = N.NAVE_ID)
						INNER JOIN CLIENTE C								(NOLOCK)ON(SE.CLIENTE_ID=C.CLIENTE_ID)
						LEFT JOIN DET_DOCUMENTO_TRANSACCION DDT				(NOLOCK)ON(DDT.DOC_TRANS_ID=SE.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=SE.NRO_LINEA_TRANS)
						LEFT JOIN DET_DOCUMENTO DD							(NOLOCK)ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
						LEFT JOIN PRODUCTO PR								(NOLOCK)ON(DD.CLIENTE_ID=PR.CLIENTE_ID AND DD.PRODUCTO_ID=PR.PRODUCTO_ID)
						-------------------------------------------------------------------------------------------------------------------
						INNER JOIN( SELECT  COUNT(DISTINCT S.POSICION_ACTUAL) CTN, S.CLIENTE_ID, S.F_SNAP, P.NAVE_ID
									FROM    SNAP_EXISTENCIAS S (NOLOCK)INNER JOIN POSICION P(NOLOCK) ON(S.POSICION_ACTUAL=P.POSICION_ID)
									WHERE   S.DISPONIBLE='1' 
									GROUP BY S.CLIENTE_ID, S.F_SNAP,P.NAVE_ID)QPOS    
						ON(SE.CLIENTE_ID=QPOS.CLIENTE_ID AND SE.F_SNAP=QPOS.F_SNAP AND P.NAVE_ID=QPOS.NAVE_ID)
						-------------------------------------------------------------------------------------------------------------------
				WHERE   SE.DISPONIBLE='1'											
						AND ((@CLIENTE_ID IS NULL)OR(SE.CLIENTE_ID= @CLIENTE_ID))			
						AND ((@FDESDE IS NULL)OR(SE.F_SNAP BETWEEN @FDESDE AND DATEADD(DAY,1,@FHASTA)))
				GROUP BY
						C.RAZON_SOCIAL, SE.F_SNAP, QPOS.CTN
						
				UNION ALL
				
				SELECT  DISTINCT  
						C.RAZON_SOCIAL						AS CLIENTE
						,SE.F_SNAP							AS FECHA						
						,0									AS Q_POS_OCUPADAS
						--,X2.PVOL							AS Q_VOL_PROD
						,sum((SE.CANTIDAD * ((ISNULL(PR.ALTO,0)*ISNULL(PR.ANCHO,0)*ISNULL(PR.LARGO,0))/1000000)))AS Q_VOL_PROD
				FROM    SNAP_EXISTENCIAS SE INNER JOIN CLIENTE C	(NOLOCK)ON(SE.CLIENTE_ID=C.CLIENTE_ID)
						LEFT JOIN POSICION P						(NOLOCK)ON(SE.POSICION_ACTUAL=P.POSICION_ID)
						LEFT JOIN DET_DOCUMENTO_TRANSACCION DDT		(NOLOCK)ON(SE.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND SE.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
						LEFT JOIN DET_DOCUMENTO DD					(NOLOCK)ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
						LEFT JOIN PRODUCTO PR						(NOLOCK)ON(DD.CLIENTE_ID=PR.CLIENTE_ID AND DD.PRODUCTO_ID=PR.PRODUCTO_ID)
				WHERE   SE.DISPONIBLE='1'						
						AND ((@CLIENTE_ID IS NULL)OR(SE.CLIENTE_ID= @CLIENTE_ID))
						AND ((@FDESDE IS NULL)OR(SE.F_SNAP BETWEEN @FDESDE AND DATEADD(DAY,1,@FHASTA)))
				group by
						c.RAZON_SOCIAL,SE.F_SNAP
		) X				
		GROUP BY X.FECHA, X.CLIENTE
				
		UNION ALL

		--CANTIDAD DE DOCUMENTOS DE INGRESO. OK
		SELECT	C.RAZON_SOCIAL AS CLIENTE,
				D.FECHA_FIN_GTW		AS FECHA,	
				COUNT(D.DOCUMENTO_ID) AS QTY_DOC_ING,
				0 AS PRODUCTOS_DIST_ING,
				0 AS VOL_ING,
				0 AS CANTIDAD_INGRESO,
				0 AS QTY_DOC_EGR,
				0 AS PRODUCTOS_DIST_EGR,
				0 AS VOL_EGR,
				0 AS CANTIDAD_EGRESO,
				0 AS Q_POS_OCUPADAS,
				0 AS Q_VOL_PROD
		FROM	DOCUMENTO D (NOLOCK)
				--INNER JOIN DET_DOCUMENTO DD		ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
				--INNER JOIN DET_DOCUMENTO_TRANSACCION DDT	ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
				INNER JOIN CLIENTE C(NOLOCK)				ON(D.CLIENTE_ID = C.CLIENTE_ID)
		WHERE	TIPO_OPERACION_ID='ING'
				AND D.STATUS = 'D40'
				AND ((@CLIENTE_ID IS NULL)OR(D.CLIENTE_ID=@CLIENTE_ID))	
				AND ((@FDESDE IS NULL)OR(D.FECHA_FIN_GTW BETWEEN @FDESDE AND DATEADD(DAY,1,@FHASTA)))
		GROUP BY D.FECHA_FIN_GTW, C.RAZON_SOCIAL

		UNION ALL	
		
		--VOLUMEN INGRESADO.
		SELECT	X.RAZON_SOCIAL					AS CLIENTE,
				x.FECHA_FIN_GTW					AS FECHA,	
				0								AS QTY_DOC_ING,
				COUNT(DISTINCT X.PRODUCTO_ID)	AS PRODUCTOS_DIST_ING,
				SUM(X.VOL_ING)					AS VOL_ING, 
				SUM(X.CANTIDAD)					AS CANTIDAD_INGRESO,
				0								AS QTY_DOC_EGR,
				0								AS PRODUCTOS_DIST_EGR,
				0								AS VOL_EGR,
				0								AS CANTIDAD_EGRESO,
				0								AS Q_POS_OCUPADAS,
				0								AS Q_VOL_PROD				
		FROM	(	SELECT	DD.PRODUCTO_ID, (ISNULL(P.ALTO,0)*ISNULL(P.LARGO,0)*ISNULL(P.ANCHO,0))/1000000 AS VOL_ING,DD.CANTIDAD, D.FECHA_FIN_GTW, C.RAZON_SOCIAL
					FROM	DOCUMENTO D (NOLOCK)INNER JOIN DET_DOCUMENTO DD	(NOLOCK)	ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT		(NOLOCK)	ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
							INNER JOIN PRODUCTO P							(NOLOCK)	ON(DD.CLIENTE_ID=P.CLIENTE_ID AND DD.PRODUCTO_ID=P.PRODUCTO_ID)
							INNER JOIN CLIENTE C							(NOLOCK)	ON(D.CLIENTE_ID = C.CLIENTE_ID)
					WHERE	TIPO_OPERACION_ID='ING'
							AND D.STATUS = 'D40' 
							AND ((@CLIENTE_ID IS NULL)OR(D.CLIENTE_ID=@CLIENTE_ID))	
							AND ((@FDESDE IS NULL)OR(D.FECHA_FIN_GTW BETWEEN @FDESDE AND DATEADD(DAY,1,@FHASTA)))
							)X	
		GROUP BY x.FECHA_FIN_GTW, x.RAZON_SOCIAL
		
		UNION ALL		
						
		--CANTIDAD DE DOCUMENTOS DE EGRESO.
		SELECT	C.RAZON_SOCIAL AS CLIENTE,			
				D.FECHA_FIN_GTW				AS FECHA,			
				0 AS QTY_DOC_ING,
				0 AS PRODUCTOS_DIST_ING,
				0 AS VOL_ING,
				0 AS CANTIDAD_INGRESO,
				COUNT(D.DOCUMENTO_ID) AS QTY_DOC_EGR,
				0 AS PRODUCTOS_DIST_EGR,
				0 AS VOL_EGR,
				0 AS CANTIDAD_EGRESO,
				0 AS Q_POS_OCUPADAS,
				0 AS Q_VOL_PROD
		FROM	DOCUMENTO D (NOLOCK)
				INNER JOIN CLIENTE C(NOLOCK)				ON(D.CLIENTE_ID = C.CLIENTE_ID)
		WHERE	TIPO_OPERACION_ID='EGR'
				AND D.STATUS = 'D40'
				AND ((@CLIENTE_ID IS NULL)OR(D.CLIENTE_ID=@CLIENTE_ID))				
				AND ((@FDESDE IS NULL)OR(D.FECHA_FIN_GTW BETWEEN @FDESDE AND DATEADD(DAY,1,@FHASTA)))
		GROUP BY D.FECHA_FIN_GTW, C.RAZON_SOCIAL
		
		UNION ALL		
		
		--VOLUMEN EGRESADO.
		SELECT	X.RAZON_SOCIAL AS CLIENTE,			
				x.FECHA_FIN_GTW		AS FECHA,			
				0 AS QTY_DOC_ING,
				0 AS PRODUCTOS_DIST_ING,
				0 AS VOL_ING, 
				0 AS CANTIDAD_INGRESO,
				0 AS QTY_DOC_EGR,
				COUNT(DISTINCT X.PRODUCTO_ID) AS PRODUCTOS_DIST_EGR,
				SUM(X.VOL_ING) AS VOL_EGR,
				SUM(X.CANTIDAD) AS CANTIDAD_EGRESO,
				0 AS Q_POS_OCUPADAS,
				0 AS Q_VOL_PROD				
		FROM	(	SELECT	DD.PRODUCTO_ID, (ISNULL(P.ALTO,0)*ISNULL(P.LARGO,0)*ISNULL(P.ANCHO,0))/1000000 AS VOL_ING,DD.CANTIDAD, D.FECHA_FIN_GTW, C.RAZON_SOCIAL
					FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD	(NOLOCK)	ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT(NOLOCK)	ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
							INNER JOIN PRODUCTO P					(NOLOCK)	ON(DD.CLIENTE_ID=P.CLIENTE_ID AND DD.PRODUCTO_ID=P.PRODUCTO_ID)
							INNER JOIN PICKING PIC					(NOLOCK)	ON(PIC.DOCUMENTO_ID=DD.DOCUMENTO_ID AND PIC.NRO_LINEA=DD.NRO_LINEA)
							INNER JOIN CLIENTE C					(NOLOCK)	ON(D.CLIENTE_ID = C.CLIENTE_ID)
					WHERE	TIPO_OPERACION_ID='EGR'
							AND D.STATUS = 'D40'
							AND ((@CLIENTE_ID IS NULL)OR(D.CLIENTE_ID=@CLIENTE_ID))	
							AND ((@FDESDE IS NULL)OR(D.FECHA_FIN_GTW BETWEEN @FDESDE AND DATEADD(DAY,1,@FHASTA)))
							)X	
		GROUP BY x.FECHA_FIN_GTW, x.RAZON_SOCIAL
										
		) ZZZ				
		GROUP BY CONVERT(VARCHAR,ZZZ.FECHA,103), ZZZ.CLIENTE, CONVERT(DATETIME,CONVERT(VARCHAR,ZZZ.FECHA,103),103)
		ORDER BY CONVERT(DATETIME,CONVERT(VARCHAR,ZZZ.FECHA,103),103) ASC
		
		END TRY
		BEGIN CATCH
			SET @MSG='CLIENTE: ' + @CLIENTE_ID + 'FECHA: ' + CONVERT(VARCHAR,@FDESDE,103)
			PRINT(@MSG)
		END CATCH
		
		FETCH NEXT FROM @CUR_CLIENTE_ID INTO @CLIENTE_ID, @FCAL
	END
	CLOSE @CUR_CLIENTE_ID
	DEALLOCATE @CUR_CLIENTE_ID
END;


GO


