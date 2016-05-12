/****** Object:  StoredProcedure [DBO].[MOB_EMPAQUE_ADD]    Script Date: 12/22/2014 15:41:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBO].[MOB_EMPAQUE_ADD]') AND type in (N'P', N'PC'))
DROP PROCEDURE [DBO].[MOB_EMPAQUE_ADD]
GO

CREATE PROCEDURE [DBO].[MOB_EMPAQUE_ADD]
	@USUARIO		VARCHAR(100),
	@VIAJE_ID		VARCHAR(100),
	@CONTENEDOR		VARCHAR(100),
	@FLG_EN_CURSO	VARCHAR(1)	OUTPUT
AS
BEGIN	
	
	SET XACT_ABORT ON
	
	DECLARE @CONT		NUMERIC(20,0)
	DECLARE @PCUR		CURSOR
	DECLARE @DOCUMENTO	NUMERIC(20,0)
	DECLARE @UC_EMPAQUE	NUMERIC(20,0)
	
	SET @FLG_EN_CURSO='0'
	
	SELECT	@CONT=COUNT(*)
	FROM	MOB_EMPAQUE_EN_PROGRESO
	WHERE	VIAJE_ID=@VIAJE_ID
			AND CONTENEDOR=@CONTENEDOR

	IF @CONT=0 BEGIN
		
		INSERT INTO MOB_EMPAQUE_EN_PROGRESO VALUES(@VIAJE_ID,@CONTENEDOR,'VALIDADO',@USUARIO,GETDATE())
		
		SET @PCUR = CURSOR FOR 		
		SELECT	DISTINCT D.DOCUMENTO_ID
		FROM	PICKING P INNER JOIN DOCUMENTO D	ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
		WHERE	P.VIAJE_ID=@VIAJE_ID
				AND P.PALLET_PICKING=@CONTENEDOR
				
		OPEN @PCUR
		FETCH @PCUR INTO @DOCUMENTO
		WHILE @@FETCH_STATUS=0
		BEGIN
			SELECT	@CONT =COUNT(*)
			FROM	MOB_EMPAQUE_UC_EMPAQUE
			WHERE	DOCUMENTO_ID=@DOCUMENTO
			
			IF @CONT =0 BEGIN
			
				EXEC dbo.GET_VALUE_FOR_SEQUENCE 'PALLET_PICKING',@UC_EMPAQUE OUTPUT
				
				INSERT INTO MOB_EMPAQUE_UC_EMPAQUE VALUES(@DOCUMENTO,@UC_EMPAQUE,'ABIERTO',GETDATE())
			
			END
			
			FETCH @PCUR INTO @DOCUMENTO
		END
		CLOSE @PCUR
		DEALLOCATE @PCUR	
		
	END ELSE BEGIN
		SET @FLG_EN_CURSO='1'
	END
	
	SELECT	CONTENEDOR
	FROM	MOB_EMPAQUE_EN_PROGRESO
	WHERE	ESTADO='VALIDADO'
			AND VIAJE_ID=@VIAJE_ID

END	