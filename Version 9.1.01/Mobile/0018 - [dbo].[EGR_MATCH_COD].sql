
/****** Object:  StoredProcedure [dbo].[EGR_MATCH_COD]    Script Date: 10/25/2013 17:30:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EGR_MATCH_COD]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EGR_MATCH_COD]
GO

/****** Object:  StoredProcedure [dbo].[EGR_MATCH_COD]    Script Date: 10/25/2013 17:30:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[EGR_MATCH_COD]
	@PRODUCTO_ID 	AS VARCHAR(30),
	@CLIENTE_ID		AS VARCHAR(15),
	@CODE			AS VARCHAR(50),
	@VALIDO 		AS SMALLINT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	DECLARE @DUN14 		VARCHAR(50)
	DECLARE @EAN13 		VARCHAR(50)
	DECLARE @USUARIO		VARCHAR(50)
	--DECLARE @CLIENTE_ID	VARCHAR(15)
	DECLARE @CONTADOR	FLOAT

	SET @VALIDO='0'

	SELECT @USUARIO=USUARIO_ID FROM #TEMP_USUARIO_LOGGIN

	--SELECT DISTINCT @CLIENTE_ID= CLIENTE_ID FROM PICKING WHERE PRODUCTO_ID=UPPER(LTRIM(RTRIM(@PRODUCTO_ID))) AND USUARIO=UPPER(LTRIM(RTRIM(@USUARIO))) AND FECHA_INICIO IS NOT NULL AND FECHA_FIN IS NULL AND CANT_CONFIRMADA IS NULL
	
	SELECT 	@CONTADOR=COUNT(*)
	FROM	RL_PRODUCTO_CODIGOS
	WHERE	CLIENTE_ID=@CLIENTE_ID
			AND PRODUCTO_ID=@PRODUCTO_ID

	IF @CONTADOR=0
	BEGIN
		RAISERROR ('El producto tiene marcado validaci�n al egreso, pero no se definieron c�digos EAN13/DUN14. Por favor, verifique el maestro de productos',16,1)
		RETURN
	END

	SELECT 	@CONTADOR=COUNT(*)
	FROM	RL_PRODUCTO_CODIGOS
	WHERE	CLIENTE_ID=@CLIENTE_ID
			AND PRODUCTO_ID=@PRODUCTO_ID
			AND CODIGO=@CODE


	IF @CONTADOR=0
	BEGIN
		RAISERROR('El codigo ingresado no se corresponde con los cargados en el maestro de productos.',16,1)
	END
	ELSE
	BEGIN
		SET @VALIDO='1'
	END
END

GO


