IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[ABAST_CAMBIOUSUARIO]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [DBO].[ABAST_CAMBIOUSUARIO]
GO

CREATE  PROCEDURE [DBO].[ABAST_CAMBIOUSUARIO]
@ABAST_ID		BIGINT			OUTPUT,
@USUARIO		VARCHAR(100)	OUTPUT,
@TIPO			VARCHAR(1)		OUTPUT
AS
BEGIN

	IF @TIPO='1' BEGIN --SACO EL USUARIO.
		UPDATE DET_ABASTECIMIENTO SET USUARIO=NULL WHERE ABAST_ID=@ABAST_ID
	END
	
	IF @TIPO='2' BEGIN
		UPDATE DET_ABASTECIMIENTO SET USUARIO=@USUARIO WHERE ABAST_ID=@ABAST_ID
	END
END