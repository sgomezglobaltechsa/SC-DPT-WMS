
ALTER PROCEDURE [dbo].[Mob_IngresarPedidos]
@Codigo as nvarchar(50)

AS	
	DECLARE @CONTROLADO AS INT
	DECLARE @FINALIZADO AS INT
	DECLARE @CONTROL 	AS INT
	DECLARE @RC			AS INT
	DECLARE @EXISTE_V	AS NUMERIC(20,0)
	DECLARE @QTY		AS INT
	DECLARE @ENV		AS INT
	DECLARE @Controla	AS CHAR(1)
	DECLARE @DOCUMENTO  AS NUMERIC (20,0)
	DECLARE @VIAJE AS VARCHAR(100)

	SELECT 	@EXISTE_V=ISNULL(PICKING_ID,0),@DOCUMENTO=DOCUMENTO_ID,@VIAJE=VIAJE_ID
	FROM	PICKING
	WHERE	DOCUMENTO_ID=LTRIM(RTRIM(UPPER((	
						SELECT TOP 1 DDOC.DOCUMENTO_ID 
						FROM dbo.SYS_INT_DOCUMENTO DOC 
						INNER JOIN SYS_INT_DET_DOCUMENTO DDOC ON DDOC.CLIENTE_ID = DOC.CLIENTE_ID AND DDOC.DOC_EXT = DOC.DOC_EXT
						INNER JOIN CLIENTE_PARAMETROS CP ON CP.CLIENTE_ID = DOC.CLIENTE_ID
						INNER JOIN DOCUMENTO D ON (DDOC.DOCUMENTO_ID = D.DOCUMENTO_ID AND DDOC.CLIENTE_ID = D.CLIENTE_ID)
						WHERE DOC.TIPO_DOCUMENTO_ID IN (SELECT TP.TIPO_COMPROBANTE_ID 
							  FROM TIPO_COMPROBANTE TP
							  WHERE TP.TIPO_OPERACION_ID = 'EGR'
						 	 )
						AND D.STATUS = 'D30'
						AND DOC.DOC_EXT = @Codigo)))) AND ST_CONTROL_EXP='0'

	Select	@Controla=isnull(c.flg_control_exp,'0')
	from	picking p inner join cliente_parametros c
			on(p.cliente_id=c.cliente_id)
	where	DOCUMENTO_ID=@DOCUMENTO
	
	IF @EXISTE_V > 0
		BEGIN
			SELECT @FINALIZADO=DBO.STATUS_PICKING_PEDIDO(@EXISTE_V)
		END
	ELSE
		BEGIN
			RAISERROR('El pedido no existe',16,1)
			RETURN
		END
	
	IF @FINALIZADO =2 
		BEGIN
			-- Agregado para control de Carga.
			SELECT 	@QTY=COUNT(DD.DOC_EXT)
			FROM 	SYS_INT_DET_DOCUMENTO DD
					INNER JOIN SYS_INT_DOCUMENTO D ON (DD.CLIENTE_ID=D.CLIENTE_ID AND DD.DOC_EXT=D.DOC_EXT)
					INNER JOIN PRODUCTO PROD ON (DD.CLIENTE_ID=PROD.CLIENTE_ID AND DD.PRODUCTO_ID=PROD.PRODUCTO_ID)
			WHERE 	DD.ESTADO_GT IS NULL AND D.DOC_EXT=LTRIM(RTRIM(UPPER(@Codigo)))

			IF (@QTY>0) BEGIN
				RAISERROR('EL PEDIDO AUN TIENE PRODUCTOS PENDIENTES POR PROCESAR!',16,1)
				RETURN
			END 
			
			--Aca hago un Update para que no levante los pallet
			--que, sumado el total, den igual a 0
			update picking set st_control_exp=1 
			where  VIAJE_ID=@VIAJE
					and pallet_picking in(	select 	pallet_picking
											from	picking
											where	VIAJE_ID=@VIAJE
											group by
													pallet_picking
											having 	sum(cant_confirmada)=0
										)


			SELECT  DISTINCT   
					PALLET_PICKING as NRO_PALLET, DOCUMENTO_ID as DOCUMENTO,
					ST_CONTROL_EXP AS ST_CONTROL_EXP
			FROM    PICKING
			WHERE 	DOCUMENTO_ID =@DOCUMENTO
					AND FECHA_INICIO IS NOT NULL
					AND FECHA_FIN IS NOT NULL
					AND USUARIO IS NOT NULL
					AND CANT_CONFIRMADA IS NOT NULL
					AND PALLET_PICKING IS NOT NULL
					AND ISNULL(ST_CONTROL_EXP,'0')='0'
					AND ((@Controla='0') OR (FACTURADO=0))

			IF @@ROWCOUNT =0 
			BEGIN
				SELECT @ENV=COUNT(*) FROM RL_ENV_DOCUMENTO_VIAJE WHERE DOCUMENTO_ID=@DOCUMENTO
				IF @ENV=1
				BEGIN
					RAISERROR('El pedido ya fue controlado',16,1)				
				END
				ELSE
				BEGIN

					SELECT 1 AS EXISTE
				END

			END
		END
		ELSE
		BEGIN
			RAISERROR('El pedido se encuentra en proceso de Picking',16,1)
			RETURN
		END