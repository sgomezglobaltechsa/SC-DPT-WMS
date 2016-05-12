
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FIN_PICKING]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FIN_PICKING]
GO

CREATE  PROCEDURE [dbo].[FIN_PICKING]
	@USUARIO 			AS VARCHAR(30),
	@VIAJEID 			AS VARCHAR(100),
	@PRODUCTO_ID		AS VARCHAR(50),
	@POSICION_COD		AS VARCHAR(45),
	@CANT_CONF			AS FLOAT,
	@PALLET_PICKING     AS NUMERIC(20),
	@PALLET				AS VARCHAR(100),
	@RUTA				AS VARCHAR(100),
	@LOTE				AS VARCHAR(100),
	@LOTE_PROVEEDOR		AS VARCHAR(100),
	@NRO_PARTIDA		AS VARCHAR(100),
	@NRO_SERIE			AS VARCHAR(50)
AS

BEGIN
	--DECLARACIONES.
	DECLARE @PICKID 	AS NUMERIC(20,0)
	DECLARE @CANTIDAD 	AS NUMERIC(20,5)
	DECLARE @CANT_CUR 	AS NUMERIC(20,5)	
	DECLARE @DIF 		AS NUMERIC(20,5)
	DECLARE @CONT_DTO 	AS NUMERIC(20,5)
	DECLARE @VCANT 		AS NUMERIC(20,5)
	DECLARE @VINCULACION	AS INT
	DECLARE @ERRORVAR	AS INT
	declare @Qty			as numeric(20,0)
	DECLARE @COUNTPOS	AS INT
	declare @msg		as varchar(4000);

	IF LTRIM(RTRIM((@PALLET)))=''
	BEGIN
		SET @PALLET=NULL
	END
	SELECT @VINCULACION=DBO.PICKING_VER_AFECTACION(@USUARIO,@VIAJEID)
	IF @VINCULACION=0
	BEGIN
		RAISERROR('3- Ud. fue desafectado del viaje.',16,1)
		RETURN
	END	
	


	SELECT 	@CANTIDAD=SUM(P.CANTIDAD)
	FROM 	PICKING P INNER JOIN DET_DOCUMENTO DD 
			ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
	WHERE	USUARIO=LTRIM(RTRIM(UPPER(@USUARIO)))
			AND P.PRODUCTO_ID=LTRIM(RTRIM(UPPER(@PRODUCTO_ID)))
			AND POSICION_COD=LTRIM(RTRIM(UPPER(@POSICION_COD )))
			AND LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
			AND ((@PALLET IS NULL OR @PALLET='') OR(P.PROP1=LTRIM(RTRIM(UPPER(@PALLET)))))
			AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
			AND P.FECHA_INICIO IS NOT NULL
			AND P.FECHA_FIN IS NULL
			--AND ((@LOTE IS NULL ) OR (DD.PROP2=@LOTE))
			--AND ((@LOTE_PROVEEDOR IS NULL) OR (P.NRO_LOTE = @LOTE_PROVEEDOR))
			--AND ((@NRO_PARTIDA IS NULL) OR (P.NRO_PARTIDA = @NRO_PARTIDA))
			--AND ((@NRO_SERIE IS NULL) OR (P.NRO_SERIE = @NRO_SERIE))
	GROUP BY P.PRODUCTO_ID, POSICION_COD, FECHA_FIN,VIAJE_ID,P.PROP1


	DECLARE PCUR  CURSOR FOR
		SELECT 	P.PICKING_ID, P.CANTIDAD
		FROM 	PICKING P INNER JOIN DET_DOCUMENTO DD 
				ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
		WHERE	USUARIO=LTRIM(RTRIM(UPPER(@USUARIO )))
				AND P.PRODUCTO_ID=LTRIM(RTRIM(UPPER(@PRODUCTO_ID)))
				AND P.POSICION_COD=LTRIM(RTRIM(UPPER(@POSICION_COD )))
				AND P.FECHA_FIN IS NULL AND CANT_CONFIRMADA IS NULL
				AND LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
				AND ((@PALLET IS NULL OR @PALLET='') OR(P.PROP1=LTRIM(RTRIM(UPPER(@PALLET)))))
				AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
				AND P.FECHA_INICIO IS NOT NULL
				AND P.FECHA_FIN IS NULL
				--AND ((@LOTE IS NULL ) OR (DD.PROP2=@LOTE))
				--AND ((@LOTE_PROVEEDOR IS NULL) OR (P.NRO_LOTE = @LOTE_PROVEEDOR))
				--AND ((@NRO_PARTIDA IS NULL ) OR (P.NRO_PARTIDA = @NRO_PARTIDA))
				--AND ((@NRO_SERIE IS NULL) OR (P.NRO_SERIE = @NRO_SERIE))
	OPEN PCUR
	
	IF @CANTIDAD=@CANT_CONF
		BEGIN
			FETCH NEXT FROM PCUR INTO @PICKID,@CANT_CUR
			WHILE @@FETCH_STATUS = 0
			BEGIN
				UPDATE	PICKING SET 	
						FECHA_FIN=GETDATE(),
						CANT_CONFIRMADA=@CANT_CUR,
						PALLET_PICKING= @PALLET_PICKING 
				WHERE	PICKING_ID=@PICKID	

				FETCH NEXT FROM PCUR INTO @PICKID,@CANT_CUR
			END
		END
	ELSE
		BEGIN
			SET @CONT_DTO = 0
			SET @DIF=@CANTIDAD - @CANT_CONF

			FETCH NEXT FROM PCUR INTO @PICKID,@CANT_CUR
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF  @CONT_DTO=0
					BEGIN
						SET @VCANT = @CANT_CUR - @DIF

						IF @VCANT < 0
							BEGIN
								SET @VCANT=0
							END
						IF @CANT_CUR > @DIF
							BEGIN
								SET @DIF=0
							END
						ELSE
							BEGIN
								SET @DIF= @DIF - @CANT_CUR						
							END
						UPDATE PICKING SET FECHA_FIN=GETDATE(),	CANT_CONFIRMADA= @VCANT,
									PALLET_PICKING= @PALLET_PICKING 
						WHERE	PICKING_ID=@PICKID
						SET @VCANT=0	
						IF @DIF=0
							BEGIN
								SET @CONT_DTO=1
							END
						FETCH NEXT FROM PCUR INTO @PICKID,@CANT_CUR
					END
				ELSE
					BEGIN
						UPDATE PICKING SET 	
									FECHA_FIN=GETDATE(),
									CANT_CONFIRMADA=@CANT_CUR,
									PALLET_PICKING= @PALLET_PICKING 
						WHERE	PICKING_ID=@PICKID	
						FETCH NEXT FROM PCUR INTO @PICKID,@CANT_CUR
					END				
			END
		END


	SELECT 	@CANTIDAD=COUNT(PICKING_ID)
	FROM	PICKING
	WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(UPPER(RTRIM(@VIAJEID)))


	SELECT 	@DIF=COUNT(PICKING_ID)
	FROM 	PICKING 
	WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(UPPER(RTRIM(@VIAJEID)))
			AND FECHA_INICIO IS NOT NULL
			AND FECHA_FIN IS NOT NULL
			AND PALLET_PICKING IS NOT NULL
			AND USUARIO IS NOT NULL
			AND CANT_CONFIRMADA IS NOT NULL


	IF @CANTIDAD=@DIF
		BEGIN
			--FO le agrego esto para que el pedido no desaparezca
			select @Qty=isnull(count(dd.producto_id),0)  	 
			from sys_int_documento d inner join sys_int_det_documento dd on (d.cliente_id=dd.cliente_id and d.doc_ext=dd.doc_ext)
			where
			d.codigo_viaje=LTRIM(RTRIM(UPPER(@VIAJEID)))
			and dd.estado_gt is null
			if (@Qty=0) begin
				UPDATE PICKING SET FIN_PICKING='2' WHERE LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
			end --if

		END
	
	SELECT	@COUNTPOS=COUNT(*)
	FROM	POSICION
	WHERE	POSICION_COD=@POSICION_COD
	IF @COUNTPOS=1
	BEGIN
		--Es una posicion.
		Set @CountPos=null
		
		SELECT	@COUNTPOS=COUNT(*)
		FROM	RL_DET_DOC_TRANS_POSICION
		WHERE	POSICION_ACTUAL = (SELECT POSICION_ID FROM POSICION WHERE POSICION_COD=@POSICION_COD)

		If @CountPos=0
		Begin
			update posicion set pos_vacia='1' where posicion_cod=@POSICION_COD
		End
	END
	CLOSE PCUR
	DEALLOCATE PCUR

END


