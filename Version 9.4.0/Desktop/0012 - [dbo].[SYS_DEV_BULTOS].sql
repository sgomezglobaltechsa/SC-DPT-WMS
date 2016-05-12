
ALTER          PROCEDURE [dbo].[SYS_DEV_BULTOS]
	@DOCUMENTO_ID AS NUMERIC(20,0) OUTPUT,
	@ESTADO	AS NUMERIC(2,0) OUTPUT
AS
	DECLARE @CUR AS CURSOR
	DECLARE @DOC_EXT AS VARCHAR(100)
	DECLARE @TC AS VARCHAR(15)
	DECLARE @STATUS AS VARCHAR(5)
	DECLARE @QTY AS NUMERIC(3,0)
	DECLARE @NRO_LIN AS NUMERIC(20,0)
	DECLARE @TD AS VARCHAR(20)
	
BEGIN

	SET @CUR = CURSOR FOR
	
	SELECT	DISTINCT
			CASE TIPO_COMPROBANTE_ID WHEN 'DE' THEN NULL ELSE PROP2 END
			,TIPO_COMPROBANTE_ID
			,STATUS 
	FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD
			ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
	WHERE	D.DOCUMENTO_ID=@DOCUMENTO_ID
	
	OPEN @CUR
	FETCH NEXT FROM @CUR INTO @DOC_EXT, @TC,@STATUS
	WHILE @@FETCH_STATUS=0
		BEGIN
		
		SELECT @QTY=COUNT(*) FROM SYS_DEV_DOCUMENTO WHERE DOC_EXT=@DOC_EXT
		
		SELECT @NRO_LIN=MAX(NRO_LINEA) FROM SYS_DEV_DET_DOCUMENTO WHERE DOC_EXT=@DOC_EXT
      
		SELECT @TD=TIPO_DOCUMENTO_ID FROM SYS_INT_DOCUMENTO WHERE	DOC_EXT=@DOC_EXT

		IF (@DOC_EXT <> '' AND @DOC_EXT IS NOT NULL AND @STATUS='D40') BEGIN
      
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: DO
			IF (@TD='I01' AND @ESTADO=1 AND @TC='DO') BEGIN 
				EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT ,@ESTADO=1  ,@DOCUMENTO_ID=@DOCUMENTO_ID 
			END --IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: I01
			IF (@TD='I01' AND @ESTADO=1 AND @TC='I01') BEGIN 
				EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT ,@ESTADO=1  ,@DOCUMENTO_ID=@DOCUMENTO_ID 
			END --IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: DEVOLUCIONES
			IF (@TD='I01' AND @ESTADO=1 AND @TC='DE') BEGIN
				EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT ,@ESTADO=@ESTADO  ,@DOCUMENTO_ID=@DOCUMENTO_ID
				BREAK;
			END --IF
						
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: DO
			IF (@TD='I01' AND @ESTADO=3 AND @TC='DO') BEGIN 
				EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT ,@ESTADO=1  ,@DOCUMENTO_ID=@DOCUMENTO_ID 
			END --IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: INGRESO A PRODUCTO TERMINADO,
			--TIPO DE COMPROBANTE: PARTE DE PRODUCCION
			IF (@TD='I04' AND @ESTADO=1 AND @TC='PP') BEGIN 
				EXEC SYS_DEV_I04  @DOC_EXT=@DOC_EXT ,@ESTADO=1  ,@DOCUMENTO_ID=@DOCUMENTO_ID 
			END --IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: INGRESO A PRODUCTO TERMINADO,
			--TIPO DE COMPROBANTE: DEVOLUCIONES	
			IF (@TD='I04' AND @ESTADO=1 AND @TC='DE') BEGIN
				EXEC SYS_DEV_I04 @DOC_EXT=@DOC_EXT ,@ESTADO=@ESTADO  ,@DOCUMENTO_ID=@DOCUMENTO_ID
				BREAK;
			END --IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: NULL,
			--TIPO DE COMPROBANTE: DEVOLUCIONES          
			IF (@TD IS NULL AND @ESTADO=1 AND @TC='DE') BEGIN
				EXEC SYS_DEV_COMPROBANTES_ING @DOC_EXT=@DOC_EXT ,@ESTADO=@ESTADO  ,@DOCUMENTO_ID=@DOCUMENTO_ID
				BREAK;
			END --IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: NULL,
			--TIPO DE COMPROBANTE: INGRESO MANUAL
			IF (@TD IS NULL AND @ESTADO=1 AND @TC='IM') BEGIN
				EXEC SYS_DEV_COMPROBANTES_ING @DOC_EXT=@DOC_EXT ,@ESTADO=@ESTADO  ,@DOCUMENTO_ID=@DOCUMENTO_ID 
			END --IF
		
		END --IF
		
		--TIPO DE DOCUMENTO DE INTERFAZ: NULL,
		--TIPO DE COMPROBANTE: DEVOLUCIONES
		IF (@ESTADO=1 AND @TC='DE')BEGIN
			EXEC SYS_DEV_COMPROBANTES_ING @DOC_EXT=@DOC_EXT ,@ESTADO=@ESTADO  ,@DOCUMENTO_ID=@DOCUMENTO_ID
			RETURN
		END --IF
		
		--TIPO DE DOCUMENTO DE INTERFAZ: CREADO POR EL USUARIO,
		--TIPO DE COMPROBANTE: CREADO POR EL USUARIO
		IF (@ESTADO=1 AND NOT (@TD = 'I01' AND @TC = 'DO') 
			AND NOT (@TD = 'I01' AND @TC = 'I01')
			AND NOT (@TD = 'I01' AND @TC = 'DE')
			AND NOT (@TD = 'I04' AND @TC = 'PP') 
			AND NOT (@TD = 'I04' AND @TC = 'DE')) BEGIN 
			EXEC SYS_DEV_COMPROBANTES_ING @DOC_EXT=@DOC_EXT ,@ESTADO=@ESTADO  ,@DOCUMENTO_ID=@DOCUMENTO_ID 
			RETURN
		END -- IF
		
	FETCH NEXT FROM @CUR INTO @doc_ext, @tc,@status	
END
CLOSE @CUR
DEALLOCATE @CUR

END --PROCEDURE




