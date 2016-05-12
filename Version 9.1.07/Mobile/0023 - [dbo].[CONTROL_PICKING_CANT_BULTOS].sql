/****** Object:  StoredProcedure [dbo].[CONTROL_PICKING_CANT_BULTOS]    Script Date: 05/22/2014 12:39:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CONTROL_PICKING_CANT_BULTOS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CONTROL_PICKING_CANT_BULTOS]
GO

CREATE        PROCEDURE [dbo].[CONTROL_PICKING_CANT_BULTOS]
	@PALLET_PIC AS NUMERIC(20,0),
	@CANTIDAD	AS NUMERIC(20,0) OUTPUT,
	@PALLET_CONTROLADO AS VARCHAR(1) OUTPUT
AS
BEGIN

	SELECT 	@CANTIDAD=cast(SUM(P.CANT_CONFIRMADA) as int), @PALLET_CONTROLADO=P.PALLET_CONTROLADO 
	FROM 	PICKING P INNER JOIN DET_DOCUMENTO DD
			ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
			INNER JOIN DOCUMENTO D
			ON(DD.DOCUMENTO_ID=D.DOCUMENTO_ID)
	WHERE	P.PALLET_PICKING=@PALLET_PIC  
			AND P.FECHA_INICIO IS NOT NULL 
			AND P.FECHA_FIN IS NOT NULL 
			AND P.USUARIO IS NOT NULL 
			AND P.PALLET_PICKING IS NOT NULL 
			AND P.CANT_CONFIRMADA>0
			AND D.STATUS<>'D40'
	GROUP BY 
			PALLET_PICKING,PALLET_CONTROLADO			
END