/****** Object:  UserDefinedFunction [dbo].[MOB_TR_VERFICA_PALLET_POSICION]    Script Date: 10/01/2015 12:36:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MOB_TR_VERFICA_PALLET_POSICION]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[MOB_TR_VERFICA_PALLET_POSICION]
GO

CREATE FUNCTION [dbo].[MOB_TR_VERFICA_PALLET_POSICION](
	@PALLET		VARCHAR(100),
	@POSICION	VARCHAR(45)
)RETURNS SMALLINT
AS
BEGIN
	DECLARE @CONT	SMALLINT,
			@RET	SMALLINT
	
	SELECT	@CONT=COUNT(RL.RL_ID)
	FROM	DET_DOCUMENTO DD INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
			ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
			INNER JOIN RL_DET_DOC_TRANS_POSICION RL
			ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
			INNER JOIN POSICION P
			ON(RL.POSICION_ACTUAL=P.POSICION_ID)
	WHERE	DD.PROP1=@PALLET
			AND P.POSICION_COD=@POSICION
			
	IF @CONT=0 BEGIN
		SET @RET=0
	END ELSE BEGIN
		SET @RET=1
	END
	
	RETURN @RET			
END
GO


