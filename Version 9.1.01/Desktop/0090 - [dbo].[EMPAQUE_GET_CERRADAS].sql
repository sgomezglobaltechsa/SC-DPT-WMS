/****** Object:  StoredProcedure [dbo].[EMPAQUE_GET_CERRADAS]    Script Date: 10/03/2013 15:27:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EMPAQUE_GET_CERRADAS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EMPAQUE_GET_CERRADAS]
GO

CREATE PROCEDURE [dbo].[EMPAQUE_GET_CERRADAS]          
AS          
BEGIN          
 SELECT DISTINCT          
   NRO_UCEMPAQUETADO,          
   CONVERT(VARCHAR,MAX(FECHA_UCEMPAQUETADO),103)+ ' ' +[DBO].[FXTIMEBYDETIME](MAX(FECHA_UCEMPAQUETADO)) FECHA,          
   SUM(CANT_CONFIRMADA) BULTOS,          
   CAST(CAST(U.ALTO AS NUMERIC(20,2)) AS VARCHAR) + ' x ' + CAST(CAST(U.ANCHO AS NUMERIC(20,2)) AS VARCHAR) + ' x ' + CAST(CAST(U.LARGO AS NUMERIC(20,2)) AS VARCHAR) MEDIDAS,          
   UCEMPAQUETADO_PESO,          
   ST_ETIQUETAS,        
	 isnull(U.NRO_GUIA,'') as NRO_GUIA
 FROM PICKING P INNER JOIN DOCUMENTO D          
   ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)          
   INNER JOIN UC_EMPAQUE U          
   ON(P.NRO_UCEMPAQUETADO=U.UC_EMPAQUE)          
 WHERE PALLET_CERRADO='1'          
   AND EXISTS (SELECT 1          
      FROM #TMP_EMPAQUE_CAB T          
      WHERE T.PEDIDO=D.NRO_REMITO)          
   AND NRO_UCEMPAQUETADO IS NOT NULL          
 GROUP BY          
   NRO_UCEMPAQUETADO, UCEMPAQUETADO_MEDIDAS, UCEMPAQUETADO_PESO, ST_ETIQUETAS,          
   U.ALTO, U.ANCHO, U.LARGO ,u.NRO_GUIA         
END


GO


