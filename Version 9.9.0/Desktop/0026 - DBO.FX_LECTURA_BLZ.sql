CREATE FUNCTION DBO.FX_LECTURA_BLZ(@STRING AS VARCHAR(MAX)) RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @RET VARCHAR(100)

	SELECT	@RET=LTRIM(RTRIM(REPLACE(REPLACE(STRING,'NETO',''),'kg','')))
	FROM	DBO.Split(@STRING,'@@@@')
	WHERE	STRING LIKE 'NETO%'

	RETURN @RET

END