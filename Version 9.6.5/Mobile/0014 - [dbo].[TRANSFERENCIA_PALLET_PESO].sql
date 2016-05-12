IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRANSFERENCIA_PALLET_PESO]') AND type in (N'FN'))
DROP FUNCTION [dbo].[TRANSFERENCIA_PALLET_PESO]
GO

CREATE FUNCTION [dbo].[TRANSFERENCIA_PALLET_PESO](
	@DOCUMENTO_ID	NUMERIC(20,0),
	@NRO_LINEA		NUMERIC(10,0),
	@NRO_PALLET		VARCHAR(100),
	@POSICION_ID	NUMERIC(20,0)
)RETURNS VARCHAR
AS
BEGIN
	DECLARE @POS_PESO	NUMERIC(20,5)
	DECLARE @PRO_PESO	NUMERIC(20,5)
	DECLARE @PRO_CANT	NUMERIC(20,5)
	DECLARE @ING_PESO	NUMERIC(20,5)
	DECLARE @STK_PESO	NUMERIC(20,5)
	DECLARE @RETORNO	VARCHAR(1)
	DECLARE @MULTIPROD	NUMERIC(20,0)
	
	SELECT	@MULTIPROD=COUNT(NRO_LINEA)
	FROM	DET_DOCUMENTO
	WHERE	PROP1=@NRO_PALLET
	
	IF @MULTIPROD >1 BEGIN
		SET @MULTIPROD=1
	END 	
	-----------------------------------------------------------------------
	--Obtengo el control de peso.
	-----------------------------------------------------------------------
	SELECT	@PRO_PESO=P.PESO, @PRO_CANT=SUM(RL.CANTIDAD)
	FROM	DET_DOCUMENTO DD INNER JOIN PRODUCTO P
			ON(DD.CLIENTE_ID=P.CLIENTE_ID AND DD.PRODUCTO_ID=P.PRODUCTO_ID)
			INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
			ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
			INNER JOIN RL_DET_DOC_TRANS_POSICION RL 
			ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
	WHERE	DD.DOCUMENTO_ID=@DOCUMENTO_ID
			AND ((@MULTIPROD=1)OR(DD.NRO_LINEA=@NRO_LINEA))
			AND DD.PROP1=@NRO_PALLET
	GROUP BY
			P.PESO				
	
	SELECT	@POS_PESO=ISNULL(P.PESO,0)
	FROM	POSICION P
	WHERE	POSICION_ID=@POSICION_ID;
	
	IF @POS_PESO=0
	BEGIN
		RETURN '1'
	END
	
	SELECT	@STK_PESO=SUM(X.RESULTADO)
	FROM	(	SELECT	DD.CANTIDAD * ISNULL(P.PESO,0) AS RESULTADO
				FROM	DET_DOCUMENTO DD INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
						ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_TRANS)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL
						ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
						INNER JOIN PRODUCTO P
						ON(DD.CLIENTE_ID=P.CLIENTE_ID AND DD.PRODUCTO_ID=P.PRODUCTO_ID)
				WHERE	RL.POSICION_ACTUAL=@POSICION_ID
			)X
				
	SET @ING_PESO=@PRO_PESO*@PRO_CANT
	
	IF (ISNULL(@STK_PESO,0) + @ING_PESO)>@POS_PESO 
	BEGIN
		SET @RETORNO='0'--NO PUEDO UBICAR.
	END
	ELSE
	BEGIN
		SET @RETORNO='1'--SI PUEDO UBICAR.
	END
	
	RETURN @RETORNO
END

