
INSERT INTO ESTADO_MERCADERIA_RL
SELECT CLIENTE_ID,'DISPONIBLE','DISPONIBLE',1,1,1,0 
FROM CLIENTE WHERE CLIENTE_ID NOT IN (
SELECT CLIENTE_ID FROM ESTADO_MERCADERIA_RL WHERE EST_MERC_ID = 'DISPONIBLE')