ALTER TABLE CLIENTE_PARAMETROS ADD FLG_PICK_CONFIRMA_PALLET VARCHAR(1)

GO
INSERT INTO sys_tabcolumns VALUES('CLIENTE_PARAMETROS',	'FLG_PICK_CONFIRMA_PALLET',	28,	'CHAR',	'Y',	'1',	NULL,	NULL,	1,	NULL)

GO

INSERT INTO SYS_DET_TABLA VALUES('CLIENTE_PARAMETROS',	'FLG_PICK_CONFIRMA_PALLET',	'Pik - Confirma Pallet',	'S',	1,	0)

GO

UPDATE CLIENTE_PARAMETROS SET FLG_PICK_CONFIRMA_PALLET='0'