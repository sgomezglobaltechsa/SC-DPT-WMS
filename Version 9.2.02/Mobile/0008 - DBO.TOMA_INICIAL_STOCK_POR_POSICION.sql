/****** Object:  StoredProcedure [dbo].[TOMA_INICIAL_STOCK_POR_POSICION]    Script Date: 10/30/2014 10:32:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TOMA_INICIAL_STOCK_POR_POSICION]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TOMA_INICIAL_STOCK_POR_POSICION]
GO

CREATE PROCEDURE [dbo].[TOMA_INICIAL_STOCK_POR_POSICION]
	@UBICACION	VARCHAR(45),
	@CLIENTE_ID	VARCHAR(15)
AS
BEGIN

	SELECT	CLIENTE_ID as [Cod.Cliente], 
			PRODUCTO_ID as[Cod.Producto] , 
			CANTIDAD as [Cantidad], 
			isnull(NRO_LOTE,'')as [Nro.Lote], 
			isnull(NRO_PARTIDA,'') as [Nro.Partida], 
			STOCK_ID as [Ident.] 
	FROM	MOB_TOMA_STOCK_INICIAL
	WHERE	CLIENTE_ID=@CLIENTE_ID 	
			AND UBICACION=@UBICACION 
	ORDER BY
			STOCK_ID

END
GO