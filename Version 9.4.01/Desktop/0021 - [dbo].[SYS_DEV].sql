
/****** Object:  StoredProcedure [dbo].[SYS_DEV]    Script Date: 02/05/2015 10:47:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS_DEV]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SYS_DEV]
GO

CREATE PROCEDURE [dbo].[SYS_DEV]
	@DOCUMENTO_ID AS NUMERIC(20,0) OUTPUT,
	@ESTADO	AS NUMERIC(2,0) OUTPUT
AS
	DECLARE @DOC_EXT AS VARCHAR(100)
	DECLARE @TD AS VARCHAR(20)
	DECLARE @QTY AS NUMERIC(3,0)
	DECLARE @NRO_LIN AS NUMERIC(20,0)
	DECLARE @TC AS VARCHAR(15)
	DECLARE @STATUS AS VARCHAR(5)
	DECLARE @QTY_DOC_EXT AS NUMERIC(3,0)
	DECLARE @TIENE_CONT AS NUMERIC(3,0)
	--AGREGADO DFERNANDEZ
	DECLARE @CANT AS NUMERIC(3,0)
	DECLARE @TIPOPERACION AS VARCHAR(5)
	DECLARE @CLIENTE_ID AS VARCHAR(20)
	
BEGIN

	--PRIMERO ME FIJO SI LOS DOCUMENTOS CREADOS NO VIENEN DE SYS_INT
	SELECT @CANT=COUNT(*) FROM SYS_INT_DET_DOCUMENTO WHERE DOCUMENTO_ID = @DOCUMENTO_ID
	IF (@CANT = 0)
		--SIGNIFICA QUE ES UNA CARGA DE DOCUMENTO DIRECTA
		BEGIN
			--INFORMO DESDE LA TABLA DOCUMENTO
			--ME FIJO SI ES UN INGRESO O UN EGRESO
			SELECT @TIPOPERACION=TIPO_OPERACION_ID FROM DOCUMENTO 
				WHERE DOCUMENTO_ID = @DOCUMENTO_ID
				
			IF (@TIPOPERACION = 'EGR')
				BEGIN
				EXEC SYS_DEV_EGRESO_DESKTOP @DOCUMENTO_ID
				RETURN
			END
			IF (@TIPOPERACION = 'ING')
				BEGIN
				EXEC SYS_DEV_INGRESO_DESKTOP @DOCUMENTO_ID
				RETURN
			END
			RAISERROR('ERROR EN DEVOLUCION MANUAL',16,1)
			RETURN 	
	END--IF
	
	--PUEDE SER UN DOCUMENTO DE EGRESO APROBADO DESDE LA ESTACION
	
	SELECT	@TIPOPERACION=TIPO_OPERACION_ID 
	FROM	DOCUMENTO 
	WHERE	DOCUMENTO_ID = @DOCUMENTO_ID
				
	IF (@TIPOPERACION = 'EGR')
		BEGIN
		
			SELECT	@CLIENTE_ID=CLIENTE_ID, @DOC_EXT=DOC_EXT
			FROM	SYS_INT_DET_DOCUMENTO 
			WHERE	DOCUMENTO_ID = @DOCUMENTO_ID
		
			EXEC SYS_DEV_EGRESO_PEDIDO @CLIENTE_ID, @DOC_EXT
		RETURN
	END	
	
	--DE LO CONTRARIO ES UNA CARGA DE INTERFACES MANUAL Y HAY DATOS EN SYS_INT
	
	SELECT  --@DOC_EXT=NRO_DESPACHO_IMPORTACION,
			@TC=TIPO_COMPROBANTE_ID,@STATUS=STATUS 
	FROM	DOCUMENTO WHERE DOCUMENTO_ID=@DOCUMENTO_ID
	
	SELECT	@DOC_EXT=DOC_EXT
	FROM	SYS_INT_DET_DOCUMENTO
	WHERE	DOCUMENTO_ID=@DOCUMENTO_ID
	
	SELECT @QTY=COUNT(*) FROM SYS_DEV_DOCUMENTO WHERE DOC_EXT=@DOC_EXT
	
	SELECT @TD=TIPO_DOCUMENTO_ID FROM SYS_INT_DOCUMENTO WHERE DOC_EXT=@DOC_EXT
	
	SELECT @NRO_LIN=MAX(NRO_LINEA) FROM SYS_DEV_DET_DOCUMENTO WHERE DOC_EXT=@DOC_EXT
	
	--HAGO LA DEVOLUCION NORMALMENTE	
	SELECT	@QTY_DOC_EXT=COUNT(DISTINCT PROP2)
	FROM	DOCUMENTO D 
	INNER JOIN DET_DOCUMENTO DD ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
	WHERE	D.DOCUMENTO_ID=@DOCUMENTO_ID	
	
	SELECT	@TIENE_CONT=COUNT(NRO_BULTO) 
	FROM	DET_DOCUMENTO 
	WHERE	DOCUMENTO_ID = @DOCUMENTO_ID	
	
	IF (@QTY_DOC_EXT>1 AND @STATUS='D40')
		BEGIN
			EXEC SYS_DEV_BULTOS @DOCUMENTO_ID, @ESTADO
			RETURN
	END

	IF (@TIENE_CONT>0 AND @STATUS='D40')
		BEGIN
			EXEC SYS_DEV_BULTOS @DOCUMENTO_ID, @ESTADO
			RETURN
	END	
	
	IF (@QTY_DOC_EXT=0 AND @DOC_EXT <> '')
		BEGIN 
			EXEC SYS_DEV_I01 @DOC_EXT=@DOC_EXT,@ESTADO=1,@DOCUMENTO_ID=@DOCUMENTO_ID
			RETURN
	END

	IF (@DOC_EXT <> '' AND @DOC_EXT IS NOT NULL AND @STATUS='D40')
		BEGIN
	
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: DO
			IF (@TD='I01' AND @ESTADO=1 AND @TC='DO')
				BEGIN
				EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT,@ESTADO=1,@DOCUMENTO_ID=@DOCUMENTO_ID
			END--IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: DO
			IF (@TD='I01' AND @ESTADO=1 AND @TC='I01')
				BEGIN
				EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT,@ESTADO=1,@DOCUMENTO_ID=@DOCUMENTO_ID
			END--IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: DO
			IF (@TD='I01' AND @ESTADO=3 AND @TC='DO')
				BEGIN
	     		EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT,@ESTADO=1,@DOCUMENTO_ID=@DOCUMENTO_ID
			END--IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: RECEPCION DE DO,
			--TIPO DE COMPROBANTE: DEVOLUCIONES
			IF (@TD='I01' AND @ESTADO=1 AND @TC='DE')
			BEGIN
	     		EXEC SYS_DEV_I01_BULTOS @DOC_EXT=@DOC_EXT ,@ESTADO=@ESTADO,@DOCUMENTO_ID=@DOCUMENTO_ID
			END--IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: INGRESO A PRODUCTO TERMINADO,
			--TIPO DE COMPROBANTE: PARTE DE PRODUCCION
			IF (@TD='I04' AND @ESTADO=1 AND @TC='PP')
				BEGIN
	     		EXEC SYS_DEV_I04 @DOC_EXT=@DOC_EXT,@ESTADO=1,@DOCUMENTO_ID=@DOCUMENTO_ID
			END--IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: INGRESO A PRODUCTO TERMINADO,
			--TIPO DE COMPROBANTE: DEVOLUCIONES
			IF (@TD='I04' AND @ESTADO=1 AND @TC='DE')
			BEGIN
	     		EXEC SYS_DEV_I04 @DOC_EXT=@DOC_EXT,@ESTADO=@ESTADO ,@DOCUMENTO_ID=@DOCUMENTO_ID
			END--IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: NULL
			--TIPO DE COMPROBANTE: DEVOLUCIONES
			IF (@TD IS NULL AND @ESTADO=1 AND @TC='DE')
			BEGIN
	     		EXEC SYS_DEV_COMPROBANTES_ING @DOC_EXT=@DOC_EXT,@ESTADO=@ESTADO,@DOCUMENTO_ID=@DOCUMENTO_ID
			END--IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: NULL
			--TIPO DE COMPROBANTE: INGRESO MANUAL
			IF (@TD IS NULL AND @ESTADO=1 AND @TC='IM')
				BEGIN
				EXEC SYS_DEV_COMPROBANTES_ING @DOC_EXT=@DOC_EXT,@ESTADO=@ESTADO,@DOCUMENTO_ID=@DOCUMENTO_ID
			END --IF
			
			--TIPO DE DOCUMENTO DE INTERFAZ: CREADO POR EL USUARIO,
			--TIPO DE COMPROBANTE: INGRESO
			IF (@ESTADO=1 
				AND NOT (@TD = 'I01' AND @TC = 'DO')
				AND NOT (@TD = 'I01' AND @TC = 'I01')
				AND NOT (@TD = 'I01' AND @TC = 'DE')
				AND NOT (@TD = 'I04' AND @TC = 'PP') 
				AND NOT (@TD = 'I04' AND @TC = 'DE'))
				BEGIN 
					EXEC SYS_DEV_BULTOS @DOCUMENTO_ID, @ESTADO
					RETURN
			END -- IF

	END --IF

	--TIPO DE DOCUMENTO DE INTERFAZ: NULL
	--TIPO DE COMPROBANTE: DEVOLUCIONES
	IF (@TD IS NULL AND @ESTADO=1 AND @TC='DE')
		BEGIN
	     	EXEC SYS_DEV_I08 @DOC_EXT=@DOC_EXT,@ESTADO=@ESTADO,@DOCUMENTO_ID=@DOCUMENTO_ID
	END --IF

	--TIPO DE DOCUMENTO DE INTERFAZ: INGRESO A PRODUCTO TERMINADO
	--TIPO DE COMPROBANTE: PARTE DE PRODUCCION
	IF (@TD='I04' AND @ESTADO=2 AND @TC='PP' AND @STATUS='D30')
	--ANULA EL PALLET Y GENERA UN I06
		BEGIN
			EXEC SYS_DEV_I04_D @DOC_EXT=@DOC_EXT,@ESTADO=2,@DOCUMENTO_ID=@DOCUMENTO_ID
	END --IF

END --PROCEDURE


GO


