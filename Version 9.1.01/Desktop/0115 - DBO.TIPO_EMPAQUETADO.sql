
CREATE TABLE DBO.TIPO_EMPAQUETADO(
	TIPO_EMPAQUETADO_ID	NUMERIC(10,0) NOT NULL,
	DESCRIPCION			VARCHAR(100),
	ACTIVO				CHAR(1)
)
GO
ALTER TABLE TIPO_EMPAQUETADO
ADD CONSTRAINT PK_TIPO_EMPAQUETADO PRIMARY KEY(TIPO_EMPAQUETADO_ID)

GO
INSERT INTO TIPO_EMPAQUETADO (TIPO_EMPAQUETADO_ID,DESCRIPCION,ACTIVO)VALUES(1,'CLASICO','1')
INSERT INTO TIPO_EMPAQUETADO (TIPO_EMPAQUETADO_ID,DESCRIPCION,ACTIVO)VALUES(2,'ITSA','1')
INSERT INTO TIPO_EMPAQUETADO (TIPO_EMPAQUETADO_ID,DESCRIPCION,ACTIVO)VALUES(3,'PAPIERTTEI','1')