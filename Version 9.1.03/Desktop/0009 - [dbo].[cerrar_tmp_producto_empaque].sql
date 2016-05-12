IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cerrar_tmp_producto_empaque]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[cerrar_tmp_producto_empaque]
GO

CREATE PROCEDURE [dbo].[cerrar_tmp_producto_empaque]
	@CLIENTE_ID         as varchar(15) OUTPUT,
	@PEDIDO_ID          as varchar(100) OUTPUT,
    @NRO_CONTENEDORA    as numeric(20) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
    
	DECLARE @PRODUCTO_ID	as varchar(30),
            @NRO_LINEA		as numeric(10),
            @GUIA			as varchar(100),
			@Control		as numeric
			
    DECLARE cur_productos CURSOR FOR
    SELECT DISTINCT PRODUCTO_ID, NRO_LINEA FROM TMP_EMPAQUE_CONTENEDORA WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID
    
    OPEN cur_productos
    FETCH cur_productos INTO @PRODUCTO_ID, @NRO_LINEA
    
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TMP_EMPAQUE_CONTENEDORA 
                            WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID
                            AND NRO_LINEA = @NRO_LINEA
                            AND PRODUCTO_ID = @PRODUCTO_ID AND PALLET_CONTROLADO = '0')
                BEGIN
                    UPDATE	PICKING
                    SET		CANTIDAD = TMP.CANTIDAD,
							CANT_CONFIRMADA = TMP.CANT_CONFIRMADA,
							PALLET_PICKING = TMP.PALLET_PICKING,
							PALLET_CONTROLADO = TMP.PALLET_CONTROLADO
                    FROM	TMP_EMPAQUE_CONTENEDORA TMP 
                    WHERE	TMP.CLIENTE_ID = @CLIENTE_ID AND TMP.NRO_REMITO = @PEDIDO_ID
							AND TMP.PRODUCTO_ID = @PRODUCTO_ID AND TMP.PALLET_PICKING = @NRO_CONTENEDORA
							AND TMP.NRO_LINEA = @NRO_LINEA
							AND PICKING.PICKING_ID = TMP.PICKING_ID
                   -- AND PICKING.PALLET_CONTROLADO = '0'
                   
                   DELETE FROM PICKING WHERE PICKING_ID IN (SELECT	P.PICKING_ID 
															FROM	PICKING P  INNER JOIN TMP_EMPAQUE_CONTENEDORA T
																	ON P.PRODUCTO_ID = T.PRODUCTO_ID AND P.DOCUMENTO_ID = T.DOCUMENTO_ID
																	AND P.PALLET_CONTROLADO = '0' AND P.PRODUCTO_ID = @PRODUCTO_ID AND P.CLIENTE_ID = @CLIENTE_ID
																	AND T.NRO_REMITO = @PEDIDO_ID AND P.NRO_LINEA = @NRO_LINEA)
                   
                END
            ELSE
                BEGIN
                    UPDATE	PICKING
                    SET		CANTIDAD = TMP.CANTIDAD,
							CANT_CONFIRMADA = TMP.CANT_CONFIRMADA
                    FROM	TMP_EMPAQUE_CONTENEDORA TMP 
                    WHERE	TMP.CLIENTE_ID = @CLIENTE_ID AND TMP.NRO_REMITO = @PEDIDO_ID
							AND TMP.PRODUCTO_ID = @PRODUCTO_ID AND TMP.PALLET_CONTROLADO = '0'
							AND TMP.NRO_LINEA = @NRO_LINEA
							AND PICKING.PICKING_ID = TMP.PICKING_ID
                    
                    IF NOT EXISTS(  SELECT	1 
                                    FROM	DOCUMENTO D INNER JOIN PICKING P ON(D.DOCUMENTO_ID = P.DOCUMENTO_ID) 
                                    WHERE	D.CLIENTE_ID = @CLIENTE_ID AND D.NRO_REMITO = @PEDIDO_ID 
											AND PRODUCTO_ID = @PRODUCTO_ID AND PALLET_PICKING = @NRO_CONTENEDORA
											AND NRO_LINEA=@NRO_LINEA)
											
                        INSERT INTO PICKING(DOCUMENTO_ID, NRO_LINEA, CLIENTE_ID, PRODUCTO_ID, VIAJE_ID, TIPO_CAJA, DESCRIPCION, CANTIDAD, NAVE_COD, 
                        POSICION_COD, RUTA, PROP1, FECHA_INICIO, FECHA_FIN, USUARIO, CANT_CONFIRMADA, PALLET_PICKING, SALTO_PICKING, PALLET_CONTROLADO, 
                        USUARIO_CONTROL_PICK, ST_ETIQUETAS, ST_CAMION, FACTURADO, FIN_PICKING, ST_CONTROL_EXP, FECHA_CONTROL_PALLET, 
                        TERMINAL_CONTROL_PALLET, FECHA_CONTROL_EXP, USUARIO_CONTROL_EXP, TERMINAL_CONTROL_EXP, FECHA_CONTROL_FAC, USUARIO_CONTROL_FAC, 
                        TERMINAL_CONTROL_FAC, VEHICULO_ID, PALLET_COMPLETO, HIJO, QTY_CONTROLADO, PALLET_FINAL, PALLET_CERRADO, USUARIO_PF, TERMINAL_PF, 
                        REMITO_IMPRESO, NRO_REMITO_PF, PICKING_ID_REF, BULTOS_CONTROLADOS, BULTOS_NO_CONTROLADOS, FLG_PALLET_HOMBRE, TRANSF_TERMINADA,NRO_LOTE,NRO_PARTIDA,NRO_SERIE,
                        ESTADO,NRO_UCDESCONSOLIDACION,FECHA_DESCONSOLIDACION,USUARIO_DESCONSOLIDACION,TERMINAL_DESCONSOLIDACION)
                        
                        SELECT	DOCUMENTO_ID, NRO_LINEA, CLIENTE_ID, PRODUCTO_ID, VIAJE_ID, TIPO_CAJA, DESCRIPCION, CANTIDAD, NAVE_COD, POSICION_COD, 
								RUTA, PROP1, FECHA_INICIO, FECHA_FIN, USUARIO, CANT_CONFIRMADA, PALLET_PICKING, SALTO_PICKING, PALLET_CONTROLADO, USUARIO_CONTROL_PICK, 
								ST_ETIQUETAS, ST_CAMION, FACTURADO, FIN_PICKING, ST_CONTROL_EXP, FECHA_CONTROL_PALLET, TERMINAL_CONTROL_PALLET, FECHA_CONTROL_EXP, 
								USUARIO_CONTROL_EXP, TERMINAL_CONTROL_EXP, FECHA_CONTROL_FAC, USUARIO_CONTROL_FAC, TERMINAL_CONTROL_FAC, VEHICULO_ID, PALLET_COMPLETO, 
								HIJO, QTY_CONTROLADO, PALLET_FINAL, PALLET_CERRADO, USUARIO_PF, TERMINAL_PF, REMITO_IMPRESO, NRO_REMITO_PF, PICKING_ID_REF, BULTOS_CONTROLADOS, 
								BULTOS_NO_CONTROLADOS, FLG_PALLET_HOMBRE, TRANSF_TERMINADA,NRO_LOTE,NRO_PARTIDA,NRO_SERIE,
								ESTADO,NRO_UCDESCONSOLIDACION,FECHA_DESCONSOLIDACION,USUARIO_DESCONSOLIDACION,TERMINAL_DESCONSOLIDACION
                        FROM	TMP_EMPAQUE_CONTENEDORA
                        WHERE	CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID
								AND PRODUCTO_ID = @PRODUCTO_ID 
								AND PALLET_PICKING = @NRO_CONTENEDORA
								AND NRO_LINEA = @NRO_LINEA
                    ELSE
                        UPDATE	PICKING
                        SET		CANTIDAD = TMP.CANTIDAD,
								CANT_CONFIRMADA = TMP.CANT_CONFIRMADA
                        FROM	TMP_EMPAQUE_CONTENEDORA TMP 
                        WHERE	TMP.CLIENTE_ID = @CLIENTE_ID AND TMP.NRO_REMITO = @PEDIDO_ID
								AND TMP.PRODUCTO_ID = @PRODUCTO_ID AND TMP.PALLET_PICKING = @NRO_CONTENEDORA
								AND TMP.NRO_LINEA = @NRO_LINEA
								AND PICKING.PICKING_ID = TMP.PICKING_ID
								AND PICKING.PALLET_PICKING = TMP.PALLET_PICKING
								AND PICKING.PALLET_CONTROLADO <> '0'
                END
            FETCH cur_productos INTO @PRODUCTO_ID, @NRO_LINEA
        END
    CLOSE cur_productos
    DEALLOCATE cur_productos
    
    --1. Aca completo la unidad contenedora en el campo nro_contenedora.
    update	PICKING set NRO_UCEMPAQUETADO=PALLET_PICKING
    from	PICKING p inner join DOCUMENTO d on(p.DOCUMENTO_ID=d.DOCUMENTO_ID)
    where	d.CLIENTE_ID=@CLIENTE_ID
			and d.NRO_REMITO=@PEDIDO_ID
			AND PICKING_ID IN(SELECT PICKING_ID FROM TMP_EMPAQUE_CONTENEDORA WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID);
			
    --2. Ademas hago que se cree la UC contenedora.
    insert into UC_EMPAQUE (UC_EMPAQUE,ALTO,ANCHO,LARGO,VOLUMEN)
    SELECT	DISTINCT
			P.NRO_UCEMPAQUETADO,0,0,0,0
    FROM	PICKING P INNER JOIN DOCUMENTO D ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
    WHERE	1=1--d.CLIENTE_ID=@CLIENTE_ID
			--and d.NRO_REMITO=@PEDIDO_ID
			AND PICKING_ID IN(SELECT PICKING_ID FROM TMP_EMPAQUE_CONTENEDORA WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID)
			and not exists (select	1 
							from	UC_EMPAQUE u2
							where	p.NRO_UCEMPAQUETADO=u2.UC_EMPAQUE);
				
    --3. Si tiene expedicion obligatoria genero la guia.
	SELECT	@control=COUNT(P.PICKING_ID)
	FROM	PICKING P INNER JOIN DOCUMENTO D ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
	WHERE	d.CLIENTE_ID=@CLIENTE_ID
			AND D.NRO_REMITO=@PEDIDO_ID
			AND P.NRO_UCEMPAQUETADO IS NULL
			
	if @control=0 begin	    
		EXEC [dbo].[GENERAR_GUIA] @PEDIDO_ID, @GUIA output
	end
	
    DELETE TMP_EMPAQUE_CONTENEDORA WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID

END


GO


