/****** Object:  StoredProcedure [dbo].[SALTO_TRANFPREPIKING]    Script Date: 02/01/2016 11:12:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SALTO_TRANFPREPIKING]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SALTO_TRANFPREPIKING]
GO

CREATE Procedure [dbo].[SALTO_TRANFPREPIKING]
@VIAJE_ID		VARCHAR(50),
@PALLET			VARCHAR(100),
@CONTENEDORA	VARCHAR(100)
--@DOCUMENTO_ID numeric(20,0),
--@NRO_LINEA numeric(10,0)
As
Begin
	DECLARE @SALTO_PICKIGN AS NUMERIC (10,0)

	SELECT 	@SALTO_PICKIGN = MAX(SALTO_PICKING) + 1
	FROM	PICKING
	WHERE 	VIAJE_ID = @VIAJE_ID

	UPDATE	PICKING SET SALTO_PICKING = @SALTO_PICKIGN
	FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
			ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
	WHERE	P.VIAJE_ID=LTRIM(RTRIM(@VIAJE_ID))
			AND ((@PALLET IS NULL) OR(P.PROP1=LTRIM(RTRIM(@PALLET))))
			AND	((@CONTENEDORA IS NULL) OR (DD.NRO_BULTO=@CONTENEDORA))

End

GO

