ALTER TABLE RL_PRODUCTO_CODIGOS
ADD CANTIDAD NUMERIC(20,5)

GO

INSERT INTO sys_tabColumns VALUES('RL_PRODUCTO_CODIGOS','CANTIDAD','5','NUMBER','N',22,20,5,0,NULL)

GO

INSERT INTO SYS_DET_TABLA VALUES('RL_PRODUCTO_CODIGOS','CANTIDAD','Cantidad','S',22,'1');