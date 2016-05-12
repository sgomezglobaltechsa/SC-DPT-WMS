CREATE FUNCTION DBO.GET_SIDD_CUSTOMS(@CLIENTE_ID	AS VARCHAR(15),
									 @DOC_EXT		AS VARCHAR(100),
									 @PRODUCTO_ID	AS VARCHAR(30),	
									 @COLUMN		AS CHAR(1))RETURNS VARCHAR(4000)
AS
BEGIN
	DECLARE @RET	VARCHAR(4000)
	
	IF @COLUMN='1'
	BEGIN
		SELECT @RET=CUSTOMS_1 FROM SYS_INT_DET_DOCUMENTO WHERE CLIENTE_ID=@CLIENTE_ID AND DOC_EXT=@DOC_EXT AND PRODUCTO_ID=@PRODUCTO_ID;
	END

	IF @COLUMN='2'
	BEGIN
		SELECT @RET=CUSTOMS_2 FROM SYS_INT_DET_DOCUMENTO WHERE CLIENTE_ID=@CLIENTE_ID AND DOC_EXT=@DOC_EXT AND PRODUCTO_ID=@PRODUCTO_ID;
	END

	IF @COLUMN='3'
	BEGIN
		SELECT @RET=CUSTOMS_3 FROM SYS_INT_DET_DOCUMENTO WHERE CLIENTE_ID=@CLIENTE_ID AND DOC_EXT=@DOC_EXT AND PRODUCTO_ID=@PRODUCTO_ID;
	END

	RETURN @RET;
END			