ALTER TABLE CLIENTE_PARAMETROS
ADD FLG_USA_ID_INTERNO_DEVOLUCION CHAR(1) NOT NULL DEFAULT('0');
GO
INSERT INTO sys_tabColumns VALUES('CLIENTE_PARAMETROS',	'FLG_USA_ID_INTERNO_DEVOLUCION',20,'CHAR','Y','1',NULL,NULL,'1',NULL);
GO
INSERT INTO SYS_DET_TABLA VALUES('CLIENTE_PARAMETROS','FLG_USA_ID_INTERNO_DEVOLUCION',	'Dev. - Utiliza Nro. Interno','S','1','0');
GO
