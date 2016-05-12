
/****** Object:  StoredProcedure [dbo].[EMPAQUE_DETALLE_UC_CONS]    Script Date: 12/02/2014 15:55:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EMPAQUE_DETALLE_UC_CONS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EMPAQUE_DETALLE_UC_CONS]
GO

CREATE PROCEDURE [dbo].[EMPAQUE_DETALLE_UC_CONS]
	@NRO_UC			VARCHAR(100) OUTPUT
AS
BEGIN
	SELECT	 P.PRODUCTO_ID
			,P.DESCRIPCION
			,SUM(CANT_CONFIRMADA) CANTIDAD
			,SUM(CANT_CONFIRMADA)-X.QTY QTY
			,X.QTY PENDIENTE
	FROM	PICKING P INNER JOIN DOCUMENTO D
			ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID),
			(	SELECT	SUM(P1.CANT_CONFIRMADA) QTY,P1.PRODUCTO_ID,P1.NRO_UCDESCONSOLIDACION
				FROM	PICKING P1
				WHERE	P1.NRO_UCDESCONSOLIDACION=@NRO_UC
						--AND NRO_UCEMPAQUETADO IS NULL
				GROUP BY
						P1.PRODUCTO_ID,P1.NRO_UCDESCONSOLIDACION
			)X
	WHERE	ESTADO='2'
			AND P.NRO_UCDESCONSOLIDACION=@NRO_UC
			AND P.PRODUCTO_ID=X.PRODUCTO_ID
			AND P.NRO_UCDESCONSOLIDACION=X.NRO_UCDESCONSOLIDACION
	GROUP BY
			P.PRODUCTO_ID, X.QTY,P.DESCRIPCION
END

GO