/****** Object:  StoredProcedure [dbo].[GENERAR_SNAPSHOT]    Script Date: 03/14/2013 15:43:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_STOCK_VOLUMEN_BY_POS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[RPT_STOCK_VOLUMEN_BY_POS]
GO
CREATE PROCEDURE [dbo].[RPT_STOCK_VOLUMEN_BY_POS]
	@FDESDE			DATETIME OUTPUT,
	@FHASTA			DATETIME OUTPUT,
	@NAVE_ID		VARCHAR(15)OUTPUT,
	@POSICION_ID	VARCHAR(45)OUTPUT
AS
BEGIN
	SELECT  DISTINCT  
			 CONVERT(VARCHAR,SE.F_SNAP,103)   AS FECHA
			,N.NAVE_COD                       AS NAVE_COD
			,P.POSICION_COD					  AS POSICION_COD
			,QVOL.VOL_POS					  AS VOL_POS
			,PVOL.PVOL                        AS Q_VOL_PROD
			,(QVOL.VOL_POS - PVOL.PVOL)       AS Q_VOL_DISP
			,GETDATE()						  AS F_IMP
			,HOST_NAME()					  AS TERMINAL
	FROM    SNAP_EXISTENCIAS SE INNER JOIN POSICION P 
			ON(SE.POSICION_ACTUAL=P.POSICION_ID)
			INNER JOIN NAVE N                         
			ON(P.NAVE_ID = N.NAVE_ID)
			INNER JOIN CLIENTE C                      
			ON(SE.CLIENTE_ID=C.CLIENTE_ID)
			LEFT JOIN ( SELECT  Y.CLIENTE_ID,Y.F_SNAP,Y.POSICION_ID,SUM(Y.VOL) AS VOL_POS
						FROM    ( SELECT  DISTINCT P.POSICION_ID,P.NAVE_ID, S.CLIENTE_ID, S.F_SNAP, (ISNULL(P.ALTO,0)*ISNULL(P.ANCHO,0)*ISNULL(P.LARGO,0))/1000000 AS VOL
								  FROM    SNAP_EXISTENCIAS S INNER JOIN POSICION P ON(S.POSICION_ACTUAL=P.POSICION_ID)
								  WHERE   S.DISPONIBLE='1'
								)Y
						GROUP BY Y.CLIENTE_ID,Y.F_SNAP,Y.POSICION_ID
					   )QVOL
	                    
			ON(SE.CLIENTE_ID=QVOL.CLIENTE_ID AND SE.F_SNAP=QVOL.F_SNAP AND P.POSICION_ID=QVOL.POSICION_ID) 
			-------------------------------------------------------------------------------------------------------------------
			LEFT JOIN (  SELECT  F.CLIENTE_ID,F.F_SNAP,F.NAVE_ID,SUM(F.PVOL) AS PVOL
						  FROM    ( SELECT  S.CLIENTE_ID, S.F_SNAP, P.NAVE_ID
											,S.CANTIDAD * ((ISNULL(PR.ALTO,0)*ISNULL(PR.ANCHO,0)*ISNULL(PR.LARGO,0))/1000000) AS PVOL
									FROM    SNAP_EXISTENCIAS S INNER JOIN POSICION P  ON(S.POSICION_ACTUAL=P.POSICION_ID)
											INNER JOIN DET_DOCUMENTO_TRANSACCION DDT  ON(DDT.DOC_TRANS_ID=S.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=S.NRO_LINEA_TRANS)
											INNER JOIN DET_DOCUMENTO DD               ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
											INNER JOIN PRODUCTO PR                    ON(DD.CLIENTE_ID=PR.CLIENTE_ID AND DD.PRODUCTO_ID=PR.PRODUCTO_ID)
								  )F
						  GROUP BY
								  F.CLIENTE_ID,F.F_SNAP,F.NAVE_ID
					  )PVOL
			ON(SE.CLIENTE_ID=PVOL.CLIENTE_ID AND SE.F_SNAP=PVOL.F_SNAP AND N.NAVE_ID=PVOL.NAVE_ID)
			-------------------------------------------------------------------------------------------------------------------
	WHERE   SE.DISPONIBLE='1'
			AND ((@FDESDE IS NULL)OR(dbo.trunc(SE.F_SNAP) BETWEEN @FDESDE AND @FHASTA))
			AND ((@NAVE_ID IS NULL)OR(N.NAVE_ID=@NAVE_ID))
			AND ((@POSICION_ID IS NULL)OR(P.POSICION_ID=@POSICION_ID))
	UNION ALL
	SELECT  DISTINCT  
			 CONVERT(VARCHAR,SE.F_SNAP,103)   AS FECHA
			,N.NAVE_COD                       AS NAVE_COD
			,NULL							  AS POSICION_COD
			,NULL							  AS VOL_POS
			,PVOL.PVOL                        AS Q_VOL_PROD
			,NULL							  AS Q_VOL_DISP
			,GETDATE()						  AS F_IMP
			,HOST_NAME()					  AS TERMINAL			
	FROM    SNAP_EXISTENCIAS SE INNER JOIN NAVE N                         
			ON(N.NAVE_ID = N.NAVE_ID AND NAVE_TIENE_LAYOUT='0' AND PRE_INGRESO='0' AND PRE_EGRESO='0')
			INNER JOIN CLIENTE C                      
			ON(SE.CLIENTE_ID=C.CLIENTE_ID)
			INNER JOIN (  SELECT  F.CLIENTE_ID,F.F_SNAP,F.NAVE_ID,SUM(F.PVOL) AS PVOL
						  FROM    ( SELECT  S.CLIENTE_ID, S.F_SNAP, N.NAVE_ID
											,S.CANTIDAD * ((ISNULL(PR.ALTO,0)*ISNULL(PR.ANCHO,0)*ISNULL(PR.LARGO,0))/1000000) AS PVOL
									FROM    SNAP_EXISTENCIAS S INNER JOIN NAVE N	  ON(S.NAVE_ACTUAL=N.NAVE_ID)
											INNER JOIN DET_DOCUMENTO_TRANSACCION DDT  ON(DDT.DOC_TRANS_ID=S.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=S.NRO_LINEA_TRANS)
											INNER JOIN DET_DOCUMENTO DD               ON(DDT.DOCUMENTO_ID=DD.DOCUMENTO_ID AND DDT.NRO_LINEA_DOC=DD.NRO_LINEA)
											INNER JOIN PRODUCTO PR                    ON(DD.CLIENTE_ID=PR.CLIENTE_ID AND DD.PRODUCTO_ID=PR.PRODUCTO_ID)
								  )F
						  GROUP BY
								  F.CLIENTE_ID,F.F_SNAP,F.NAVE_ID
					  )PVOL
			ON(SE.CLIENTE_ID=PVOL.CLIENTE_ID AND SE.F_SNAP=PVOL.F_SNAP AND N.NAVE_ID=PVOL.NAVE_ID)
			-------------------------------------------------------------------------------------------------------------------
	WHERE   SE.DISPONIBLE='1'
			AND ((@FDESDE IS NULL)OR(dbo.trunc(SE.F_SNAP) BETWEEN @FDESDE AND @FHASTA))
			AND ((@NAVE_ID IS NULL)OR(N.NAVE_ID=@NAVE_ID))
			AND ((@POSICION_ID IS NULL)OR(N.NAVE_ID=-1))				
END;			