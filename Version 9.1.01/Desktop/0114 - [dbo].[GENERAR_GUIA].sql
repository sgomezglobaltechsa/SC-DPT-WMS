/****** Object:  StoredProcedure [dbo].[GENERAR_GUIA]    Script Date: 10/15/2013 13:02:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GENERAR_GUIA]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GENERAR_GUIA]
GO

CREATE PROCEDURE [dbo].[GENERAR_GUIA]
	@PEDIDO	AS VARCHAR(100) OUTPUT,
	@NRO_GUIA AS VARCHAR(100) OUTPUT
AS
BEGIN
	DECLARE @CONT_EMP AS NUMERIC;
	DECLARE @CONT_TOT AS NUMERIC;
	DECLARE @SEQ	  AS NUMERIC(38,0);
	DECLARE @MSG	  AS VARCHAR(100)

	SELECT	@CONT_TOT=COUNT(P.PICKING_ID)
	FROM	PICKING P INNER JOIN DOCUMENTO D ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
	WHERE	D.NRO_REMITO=@PEDIDO;

	SELECT	@CONT_EMP=COUNT(P.PICKING_ID)
	FROM	PICKING P INNER JOIN DOCUMENTO D ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
	WHERE	D.NRO_REMITO=@PEDIDO
			AND P.NRO_UCEMPAQUETADO IS NOT NULL;
			
	IF @CONT_EMP=@CONT_TOT BEGIN
	
		EXEC dbo.GET_VALUE_FOR_SEQUENCE 'NRO_GUIA', @SEQ OUTPUT;
		
		UPDATE	UC_EMPAQUE SET NRO_GUIA=@SEQ
		FROM	UC_EMPAQUE U INNER JOIN PICKING P	ON(U.UC_EMPAQUE=P.NRO_UCEMPAQUETADO)
				INNER JOIN DOCUMENTO D				ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
		WHERE	D.NRO_REMITO=@PEDIDO;
		
		SET @NRO_GUIA=CAST(@SEQ AS VARCHAR(100));
	
	END

END	

GO


