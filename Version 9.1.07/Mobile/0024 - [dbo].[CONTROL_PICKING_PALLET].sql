/****** Object:  StoredProcedure [dbo].[CONTROL_PICKING_PALLET]    Script Date: 05/22/2014 12:50:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CONTROL_PICKING_PALLET]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CONTROL_PICKING_PALLET]
GO

CREATE        PROCEDURE [dbo].[CONTROL_PICKING_PALLET]
	@PALLET_PIC AS NUMERIC(20,0),
	@USUARIO AS VARCHAR(30)
AS
BEGIN
	SELECT 	
			P.PRODUCTO_ID AS PRODUCTO_ID, P.DESCRIPCION AS DESCRIPCION, cast(SUM(P.CANT_CONFIRMADA) as int) AS CANTIDAD
	FROM 	PICKING P INNER JOIN DET_DOCUMENTO DD
			ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
			INNER JOIN DOCUMENTO D
			ON(DD.DOCUMENTO_ID=D.DOCUMENTO_ID)
	WHERE	P.PALLET_PICKING=@PALLET_PIC 
			AND P.FECHA_INICIO IS NOT NULL 
			AND	P.FECHA_FIN IS NOT NULL 
			AND P.USUARIO IS NOT NULL 
			AND P.PALLET_PICKING IS NOT NULL 
			AND P.CANT_CONFIRMADA>0
			AND D.STATUS<>'D40'
	GROUP BY 
			P.PRODUCTO_ID, P.DESCRIPCION
	
	--NO COMENTAR SE LEVANTA EN OTRO TABLE PARA SU USO POSTERIOR.
	SELECT 	CAST(SUM(CANT_CONFIRMADA) AS INT)
	FROM 	PICKING 
	WHERE 	PALLET_PICKING=@PALLET_PIC

	EXEC DBO.CONTROL_PICKING_STATUS @PALLET=@PALLET_PIC,@USUARIO=@USUARIO,@STATUS='1'
END

GO


