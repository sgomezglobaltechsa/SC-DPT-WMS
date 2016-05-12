IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenerarEtiquetaEmpaque]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GenerarEtiquetaEmpaque]
GO
create PROCEDURE [dbo].[GenerarEtiquetaEmpaque]
(
	@CLIENTE_ID		VARCHAR(15)		OUTPUT,
	@VIAJE_ID		VARCHAR(100)	OUTPUT,
	@USUARIO		VARCHAR(20)		OUTPUT,
	@TERMINAL		VARCHAR(100)	OUTPUT
)
AS
BEGIN
	DECLARE @DOCUMENTO_ID AS NUMERIC(20,0)
	DECLARE @VIAJEIDANTERIOR AS VARCHAR(100)
	
	--INSERTO EN LA TABLA DE PEDIDOS INFORMADOS AL ERP
	INSERT INTO INFORME_PEDIDOS_EMPAQUE_ERP
	VALUES (@CLIENTE_ID, @VIAJE_ID, GETDATE(), @USUARIO, @TERMINAL)

	--SEPARO PEDIDO DE LA OLA
	SELECT @DOCUMENTO_ID = DOCUMENTO_ID, @VIAJEIDANTERIOR = NRO_REMITO FROM DOCUMENTO WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @VIAJE_ID

	UPDATE SYS_INT_DOCUMENTO SET CODIGO_VIAJE = DOC_EXT WHERE DOC_EXT = @VIAJEIDANTERIOR

	UPDATE DOCUMENTO SET NRO_DESPACHO_IMPORTACION = NRO_REMITO WHERE DOCUMENTO_ID = @DOCUMENTO_ID

	UPDATE PICKING SET VIAJE_ID = @VIAJEIDANTERIOR WHERE DOCUMENTO_ID = @DOCUMENTO_ID

	--INFORMO DEVOLUCION
	EXEC SYS_DEV_EGRESO_EMPAQUE @VIAJE_ID
	--EJECUTO SP DEL CLIENTE PARA INFORMAR AL ERP.
END


