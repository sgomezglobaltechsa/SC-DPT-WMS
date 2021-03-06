
/****** Object:  StoredProcedure [dbo].[Mob_Guardado_ValDoc]    Script Date: 04/26/2013 14:57:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Mob_Guardado_ValDoc]
	@Documento_ID	Numeric(20,0),
	@Cliente		Varchar(30) output
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	DECLARE @CONT		SMALLINT
	DECLARE @TERMINAL	VARCHAR(100)
	DECLARE @USR		VARCHAR(100)

	select @usr=usuario_id,@terminal=terminal from #temp_usuario_loggin
	
	SELECT	@CONT= COUNT(*)
	FROM	DOCUMENTO
	WHERE	DOCUMENTO_ID=@DOCUMENTO_ID
	
	IF @CONT=0
	BEGIN
		RAISERROR('El Nro. de Documento ingresado no existe',16,1)
		RETURN
	END
	SET @CONT=NULL

	SELECT	@CONT= COUNT(*)
	FROM	DOCUMENTO
	WHERE	DOCUMENTO_ID=@DOCUMENTO_ID
			AND TIPO_OPERACION_ID='ING'
			
	IF @CONT=0
	BEGIN
		RAISERROR('El Nro. de Documento ingresado no es un documento de Ingreso.',16,1)
		RETURN
	END

	SELECT @CONT=COUNT(*) FROM SYS_LOCK_PALLET WHERE Documento_id =@Documento_ID 

	IF @CONT >0
	BEGIN
		SET @CONT=NULL
		SELECT @CONT=COUNT(*) FROM SYS_LOCK_PALLET WHERE Documento_id =@Documento_ID AND ltrim(rtrim(upper(Usuario_Id))) =ltrim(rtrim(upper(@USR)))
		IF(@CONT>0)
		BEGIN
			SELECT @CLIENTE=CLIENTE_ID FROM DOCUMENTO WHERE DOCUMENTO_ID=@Documento_ID
			RETURN
		END
		ELSE
		BEGIN
			RAISERROR('El documento se encuentra en proceso de guardado.',16,1)
			return
		END
	END 

	
	SET @CONT=NULL
	SELECT	@CONT= COUNT(*)
	FROM	DOCUMENTO
	WHERE	DOCUMENTO_ID=@DOCUMENTO_ID
			AND TIPO_OPERACION_ID='ING'
			AND STATUS='D40'
	
	IF @CONT =1
	BEGIN
		RAISERROR('El documento ya fue Ubicado',16,1)
	END 
	
	SELECT @CLIENTE=CLIENTE_ID FROM DOCUMENTO WHERE DOCUMENTO_ID=@Documento_ID
	
	INSERT INTO SYS_LOCK_PALLET
	SELECT	DOCUMENTO_ID,NRO_LINEA,ISNULL(PROP1,'9999'),@USR,@TERMINAL,1,GETDATE()
	FROM	DET_DOCUMENTO 
	WHERE	DOCUMENTO_ID = @Documento_ID;
			
END

