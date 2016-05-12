/****** Object:  StoredProcedure [dbo].[ACTUALIZA_PICKING_TRANSF_PREPICKING]    Script Date: 06/18/2014 10:57:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ACTUALIZA_PICKING_TRANSF_PREPICKING]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ACTUALIZA_PICKING_TRANSF_PREPICKING]
GO

CREATE Procedure [dbo].[ACTUALIZA_PICKING_TRANSF_PREPICKING]
@Viaje_id varchar(50)
as
Begin
DECLARE @USUARIO	VARCHAR(50)

	
	SELECT @USUARIO=USUARIO_ID FROM #TEMP_USUARIO_LOGGIN
	--SET @USUARIO='SGOMEZ'

	UPDATE	PICKING SET USUARIO = NULL
	WHERE	USUARIO = @USUARIO 
			AND VIAJE_ID = @Viaje_id 
			AND TRANSF_TERMINADA = '0'
			AND FECHA_INICIO IS NULL
			AND FECHA_FIN IS NULL
			AND CANT_CONFIRMADA IS NULL
			AND ((	DOCUMENTO_ID NOT IN (	SELECT DOCUMENTO_ID FROM MOVIMIENTOSPREPICKING WHERE USUARIO_ID = @USUARIO))
					OR (NRO_LINEA NOT IN (SELECT NRO_LINEA	FROM MOVIMIENTOSPREPICKING WHERE USUARIO_ID = @USUARIO)))

End

GO


