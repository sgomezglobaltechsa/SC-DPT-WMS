/****** Object:  StoredProcedure [dbo].[EMPAQUETADO_VALSKU]    Script Date: 10/03/2013 12:43:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EMPAQUETADO_VALSKU]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EMPAQUETADO_VALSKU]
GO

CREATE PROCEDURE [dbo].[EMPAQUETADO_VALSKU]
@CONTENEDORA		VARCHAR(100) OUTPUT,
@PRODUCTO_ID		VARCHAR(30) OUTPUT	
AS
BEGIN

	DECLARE @COUNT		SMALLINT
	DECLARE @CLIENTE	VARCHAR(15)


	SELECT	TOP 1 @CLIENTE=CLIENTE_ID
	FROM	PICKING
	WHERE	NRO_UCDESCONSOLIDACION=@CONTENEDORA
    ORDER BY FECHA_DESCONSOLIDACION DESC
	
	SELECT	@COUNT=COUNT(*)
	FROM	RL_PRODUCTO_CODIGOS
	WHERE CODIGO=@PRODUCTO_ID
        AND CLIENTE_ID = @CLIENTE

	IF @COUNT>0
	BEGIN
		--QUIERE DECIR QUE ES UN CODIGO.
		SELECT	@PRODUCTO_ID=PRODUCTO_ID
		FROM	RL_PRODUCTO_CODIGOS
		WHERE CODIGO=@PRODUCTO_ID
          AND CLIENTE_ID = @CLIENTE
	END 

	SELECT	SUM(CANT_CONFIRMADA)
			,P.DESCRIPCION
	FROM	PICKING P INNER JOIN DOCUMENTO D
			ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
	WHERE	ESTADO='2'
			AND EXISTS (SELECT	1
						FROM	#TMP_EMPAQUE_CAB T
						WHERE	T.PEDIDO=D.NRO_REMITO)
			AND P.NRO_UCDESCONSOLIDACION=@CONTENEDORA
			AND P.PRODUCTO_ID=@PRODUCTO_ID
			AND P.NRO_UCEMPAQUETADO IS NULL		
	GROUP BY
			P.PRODUCTO_ID,P.DESCRIPCION,NRO_UCDESCONSOLIDACION
END
GO


