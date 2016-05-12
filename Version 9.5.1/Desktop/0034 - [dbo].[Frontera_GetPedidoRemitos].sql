IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Frontera_GetPedidoRemitos]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Frontera_GetPedidoRemitos]
GO

CREATE     PROCEDURE [dbo].[Frontera_GetPedidoRemitos]
@viaje_id	varchar(100) output,
@MostrarNull    CHAR(1) output
AS
BEGIN
			
	SELECT	'0'								AS [SELECCIONAR],
			D.NRO_REMITO					AS [DOCUMENTO],
			S.SUCURSAL_ID					AS [COD_CLIENTE],
			S.NOMBRE						AS [CLIENTE],
			D.NRO_DESPACHO_IMPORTACION		AS [GRUPO_PICKING/RUTA],
			COUNT(DISTINCT DD.PRODUCTO_ID)	AS [QTY_PROD],
			D.FECHA_CPTE					AS [FECHA],
			D.CPTE_PREFIJO					AS [CPTE_PREFIJO],
			D.CPTE_NUMERO					AS [CPTE_NUMERO],
			D.DOCUMENTO_ID					AS [DOCUMENTO_ID]
	FROM	PICKING P INNER JOIN DOCUMENTO D	ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
			INNER JOIN SUCURSAL S				ON(P.CLIENTE_ID=D.CLIENTE_ID AND D.SUCURSAL_DESTINO=S.SUCURSAL_ID)
			INNER JOIN DET_DOCUMENTO DD			ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
	WHERE	P.VIAJE_ID=@VIAJE_ID
	GROUP BY
			D.NRO_REMITO, S.SUCURSAL_ID, S.NOMBRE, D.NRO_DESPACHO_IMPORTACION, D.FECHA_CPTE,
			D.CPTE_PREFIJO, D.CPTE_NUMERO, D.DOCUMENTO_ID
			
END

GO


