
CREATE TABLE DBO.MOB_EMPAQUE_EN_PROGRESO(
EMPAQUE_ID			NUMERIC(20,0) NOT NULL IDENTITY(1,1),
VIAJE_ID			VARCHAR(100),
CONTENEDOR			VARCHAR(100),
ESTADO				VARCHAR(100),
USUARIO				VARCHAR(100),
FECHA				DATETIME
)
GO

ALTER TABLE DBO.MOB_EMPAQUE_EN_PROGRESO
ADD CONSTRAINT PK_MOB_EMPAQUE_EN_PROGRESO PRIMARY KEY(EMPAQUE_ID)
