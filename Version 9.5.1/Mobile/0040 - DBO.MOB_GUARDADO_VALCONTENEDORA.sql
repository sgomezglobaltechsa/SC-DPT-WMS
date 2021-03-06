
/****** Object:  StoredProcedure [dbo].[MOB_GUARDADO_VALCONTENEDORA]    Script Date: 10/20/2015 12:33:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MOB_GUARDADO_VALCONTENEDORA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[MOB_GUARDADO_VALCONTENEDORA]
GO

CREATE PROCEDURE [dbo].[MOB_GUARDADO_VALCONTENEDORA]
@NRO_CONTENEDORA	VARCHAR(50),
@ERROR				VARCHAR(1)		OUTPUT,
@DESC_ERROR			VARCHAR(4000)	OUTPUT,
@USUARIO			VARCHAR(100)
AS 
BEGIN
	SET @ERROR='0'
	SET XACT_ABORT ON
	------------------------------------------------------------------------------------------------------------
	--1. VERIFICO SI EXISTE EL MATERIAL.
	------------------------------------------------------------------------------------------------------------	
	IF NOT EXISTS(	SELECT	1
					FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD
							ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
					WHERE	D.TIPO_OPERACION_ID='ING'
							AND DD.NRO_BULTO=@NRO_CONTENEDORA)BEGIN
		SET @ERROR ='1'
		SET @DESC_ERROR='No existe el numero de contendora ' + @NRO_CONTENEDORA + '.'
		RETURN
	END						
	------------------------------------------------------------------------------------------------------------	
	--2. VERIFICO QUE NO ESTE UBICADO.
	------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS(	SELECT	1
					FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD
							ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
							ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
							INNER JOIN RL_DET_DOC_TRANS_POSICION RL
							ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
							INNER JOIN NAVE N
							ON(RL.NAVE_ACTUAL=N.NAVE_ID AND N.PRE_INGRESO='1')
							INNER JOIN CATEGORIA_LOGICA CL
							ON(RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID =CL.CAT_LOG_ID AND CL.CATEG_STOCK_ID ='TRAN_ING')
					WHERE	D.TIPO_OPERACION_ID='ING'
							AND DD.NRO_BULTO=@NRO_CONTENEDORA
							AND D.STATUS<>'D40'
							)BEGIN
		SET @ERROR ='1'
		SET @DESC_ERROR='La contenedora ' + @NRO_CONTENEDORA + ', no esta pendiente de guardado.'
		RETURN
	END		
	------------------------------------------------------------------------------------------------------------	
	--3. TIENE PERMISOS EL USUARIO PARA VER ESTE CLIENTE?
	------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS(	SELECT	1
					FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD
							ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
							INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
							ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
							INNER JOIN RL_DET_DOC_TRANS_POSICION RL
							ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
							INNER JOIN NAVE N
							ON(RL.NAVE_ACTUAL=N.NAVE_ID AND N.PRE_INGRESO='1')
							INNER JOIN CATEGORIA_LOGICA CL
							ON(RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID =CL.CAT_LOG_ID AND CL.CATEG_STOCK_ID ='TRAN_ING')
							INNER JOIN RL_SYS_CLIENTE_USUARIO RS
							ON(RL.CLIENTE_ID=RS.CLIENTE_ID)
					WHERE	D.TIPO_OPERACION_ID='ING'
							AND DD.NRO_BULTO=@NRO_CONTENEDORA
							AND RS.USUARIO_ID =@USUARIO 
							AND D.STATUS<>'D40'
							)BEGIN
		SET @ERROR ='1'
		SET @DESC_ERROR='El usuario no tiene permisos para trabajar con el cliente asociado a la contenedora.'
		RETURN
	END			
	------------------------------------------------------------------------------------------------------------
	--4. RESERVO LA CONTENEDORA
	------------------------------------------------------------------------------------------------------------
	INSERT INTO SYS_LOCK_PALLET(DOCUMENTO_ID, NRO_LINEA ,PALLET, USUARIO_ID,TERMINAL,LOCK,FECHA_LOCK)
	SELECT	DD.DOCUMENTO_ID,DD.NRO_LINEA,DD.NRO_BULTO,@USUARIO,HOST_NAME(),'1',GETDATE()
	FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD
			ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
			INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
			ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
			INNER JOIN RL_DET_DOC_TRANS_POSICION RL
			ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
			INNER JOIN NAVE N
			ON(RL.NAVE_ACTUAL=N.NAVE_ID AND N.PRE_INGRESO='1')
			INNER JOIN CATEGORIA_LOGICA CL
			ON(RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID =CL.CAT_LOG_ID AND CL.CATEG_STOCK_ID ='TRAN_ING')
	WHERE	D.TIPO_OPERACION_ID='ING'
			AND DD.NRO_BULTO=@NRO_CONTENEDORA
			AND D.STATUS<>'D40'		
	------------------------------------------------------------------------------------------------------------	
	--5. EXTRAIGO LOS DATOS PARA OPERAR EN MOBILE.			
	------------------------------------------------------------------------------------------------------------	
	SELECT	RL.CLIENTE_ID,DD.PRODUCTO_ID,DD.DESCRIPCION,SUM(RL.CANTIDAD) AS CANTIDAD
	FROM	DOCUMENTO D INNER JOIN DET_DOCUMENTO DD
			ON(D.DOCUMENTO_ID=DD.DOCUMENTO_ID)
			INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
			ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
			INNER JOIN RL_DET_DOC_TRANS_POSICION RL
			ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
			INNER JOIN NAVE N
			ON(RL.NAVE_ACTUAL=N.NAVE_ID AND N.PRE_INGRESO='1')
			INNER JOIN CATEGORIA_LOGICA CL
			ON(RL.CLIENTE_ID=CL.CLIENTE_ID AND RL.CAT_LOG_ID =CL.CAT_LOG_ID AND CL.CATEG_STOCK_ID ='TRAN_ING')
	WHERE	D.TIPO_OPERACION_ID='ING'
			AND DD.NRO_BULTO=@NRO_CONTENEDORA
			AND D.STATUS<>'D40'					
	GROUP BY
			RL.CLIENTE_ID,DD.PRODUCTO_ID,DD.DESCRIPCION						
END
GO
