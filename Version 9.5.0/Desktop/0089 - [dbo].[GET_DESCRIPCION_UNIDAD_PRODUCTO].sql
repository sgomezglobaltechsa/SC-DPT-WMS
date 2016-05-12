
/****** Object:  StoredProcedure [dbo].[GET_DESCRIPCION_UNIDAD_PRODUCTO]    Script Date: 07/10/2015 11:28:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GET_DESCRIPCION_UNIDAD_PRODUCTO]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GET_DESCRIPCION_UNIDAD_PRODUCTO]
GO

CREATE procedure [dbo].[GET_DESCRIPCION_UNIDAD_PRODUCTO]
@CLIENTE_ID		VARCHAR(20),
@PRODUCTO_ID	VARCHAR(30),
@DESCRIPCION	VARCHAR(200) OUTPUT,
@UNIDAD			VARCHAR(50)  OUTPUT,
@USA_NROLOTE	VARCHAR(1)   OUTPUT,
@USA_NROPARTIDA VARCHAR(1)   OUTPUT,
@USA_FECHAV		VARCHAR(1)   OUTPUT
AS
BEGIN

SELECT @DESCRIPCION = P.DESCRIPCION,@UNIDAD = UM.DESCRIPCION, @USA_NROLOTE = ingLoteProveedor, @USA_NROPARTIDA = ingPartida
FROM PRODUCTO P
INNER JOIN UNIDAD_MEDIDA UM ON(P.UNIDAD_ID = UM.UNIDAD_ID)
WHERE P.CLIENTE_ID = @CLIENTE_ID
AND P.PRODUCTO_ID = @PRODUCTO_ID

SELECT @USA_FECHAV = COUNT(*)
FROM MANDATORIO_PRODUCTO 
WHERE CLIENTE_ID = @CLIENTE_ID
AND PRODUCTO_ID = @PRODUCTO_ID
AND CAMPO = 'FECHA_VENCIMIENTO'

END

GO


