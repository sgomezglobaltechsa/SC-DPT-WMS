BEGIN
	DECLARE @CONT	NUMERIC
	
	SELECT	@CONT=COUNT(NOMBRE)
	FROM	SECUENCIA
	WHERE	NOMBRE='UC_EMPAQUE';
	
	IF @CONT=0 BEGIN
		INSERT INTO SECUENCIA (NOMBRE,VALOR)VALUES('UC_EMPAQUE',0);
	END
END	