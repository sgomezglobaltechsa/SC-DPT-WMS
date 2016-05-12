IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MOB_DELETE_REMITO_TMP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[MOB_DELETE_REMITO_TMP]
GO


create PROCEDURE [dbo].[MOB_DELETE_REMITO_TMP] 
	@ID_PROVEEDOR VARCHAR(20),
	@REMITO		  VARCHAR(20)
AS

	declare @USUARIO varchar(20)
	SELECT @USUARIO=USUARIO_ID FROM #TEMP_USUARIO_LOGGIN

	DELETE FROM TMP_REMITO
	where idproveedor=@ID_PROVEEDOR and remito =@REMITO
	AND usuario=@usuario



GO


