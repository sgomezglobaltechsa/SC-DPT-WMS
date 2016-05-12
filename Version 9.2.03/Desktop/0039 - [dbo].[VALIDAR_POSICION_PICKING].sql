/****** Object:  StoredProcedure [dbo].[VALIDAR_POSICION_PICKING]    Script Date: 10/08/2014 11:50:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VALIDAR_POSICION_PICKING]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[VALIDAR_POSICION_PICKING]
GO

CREATE PROCEDURE [dbo].[VALIDAR_POSICION_PICKING]
(@POSICION_COD VARCHAR(45),
@OUT VARCHAR(1) OUTPUT)
AS
BEGIN
DECLARE @PICKING VARCHAR(1)
DECLARE @POS_LOCKEADA VARCHAR(1)

SET @OUT = '5'

	IF NOT EXISTS (SELECT 1 FROM POSICION WHERE POSICION_COD = @POSICION_COD)
	BEGIN
		SET @OUT='2'
	END

	IF @OUT<>'2'
	BEGIN
		SELECT @PICKING = ISNULL(PICKING,'0'), @POS_LOCKEADA = ISNULL(POS_LOCKEADA,'0') FROM POSICION WHERE POSICION_COD = @POSICION_COD

		IF @PICKING='0'
		BEGIN
			SELECT @PICKING = isnull(BESTFIT,'0') FROM POSICION WHERE POSICION_COD = @POSICION_COD
			IF @PICKING='0'
			BEGIN
				SET @OUT = '3'
				RETURN
			END 
		END

		IF @POS_LOCKEADA='1'
		BEGIN
			SET @OUT = '4'
			RETURN
		END
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM NAVE WHERE NAVE_COD = @POSICION_COD)
		BEGIN
			SET @OUT='2'
			RETURN
		END

		SELECT @PICKING = ISNULL(PICKING,'0') FROM NAVE WHERE NAVE_COD = @POSICION_COD

		IF @PICKING='0'
		BEGIN
			SET @OUT = '3'
			RETURN
		END
	END
SET @OUT = '1'

END

GO

