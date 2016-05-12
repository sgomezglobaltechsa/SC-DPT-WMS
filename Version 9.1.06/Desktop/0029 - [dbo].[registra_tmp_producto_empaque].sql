
/****** Object:  StoredProcedure [dbo].[registra_tmp_producto_empaque]    Script Date: 03/21/2014 15:40:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[registra_tmp_producto_empaque]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[registra_tmp_producto_empaque]
GO

/****** Object:  StoredProcedure [dbo].[registra_tmp_producto_empaque]    Script Date: 03/21/2014 15:40:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		LRojas
-- Create date: 18/04/2012
-- Description:	Procedimiento para buscar pedidos para empaquetar
-- =============================================
CREATE PROCEDURE [dbo].[registra_tmp_producto_empaque]
	@CLIENTE_ID         as varchar(15) OUTPUT,
	@PEDIDO_ID          as varchar(100) OUTPUT,
	@PRODUCTO_ID        as varchar(30) OUTPUT,
    @NRO_CONTENEDORA    as numeric(20) OUTPUT,
    @CANT_CONTROLADA    as numeric(20,5) OUTPUT,
	@NRO_LOTE			AS VARCHAR(100) OUTPUT,
	@NRO_PARTIDA		AS VARCHAR(100) OUTPUT,
	@NRO_SERIE			AS VARCHAR(50) OUTPUT
AS
BEGIN
SET NOCOUNT ON;
    
	if not exists (	select	1
					FROM	PICKING P
					INNER JOIN DET_DOCUMENTO DD ON (P.DOCUMENTO_ID = DD.DOCUMENTO_ID AND P.NRO_LINEA = DD.NRO_LINEA)
					INNER JOIN DOCUMENTO D ON (DD.DOCUMENTO_ID = D.DOCUMENTO_ID)
					where	P.cliente_id = @CLIENTE_ID
							and D.NRO_REMITO = @pedido_id
							and P.producto_id = @producto_id
							and ((P.nro_lote = @nro_lote) or (@nro_lote IS NULL OR @NRO_LOTE = ''))
							and ((P.nro_partida = @nro_partida) or (@nro_partida IS NULL OR @NRO_PARTIDA = ''))
							and ((P.nro_serie = @nro_serie) or (@nro_serie IS NULL OR @NRO_SERIE = '')))
		raiserror('No hay pendientes de empaquetado para el producto ingresado.',16,1) 

    DECLARE @CantPickeada as numeric(20,5),
            @CantControlada as numeric(20,5),
            @CantPendiente as numeric(20,5),
            @NRO_LINEA as numeric(10),
            @CANT_CONFIRMADA as numeric(20,5),
            @CANTIDAD_EMPAQUE as numeric(20,5),
			@PICKING_ID AS NUMERIC(20,0)
			
	IF (@NRO_PARTIDA='')BEGIN
		SET @NRO_PARTIDA='9999999'
	END
	
	IF (@NRO_LOTE='')BEGIN
		SET @NRO_LOTE='9999999'
	END
	
	IF (@NRO_SERIE='')BEGIN
		SET @NRO_SERIE='9999999'
	END		
    
    DECLARE cur_linea CURSOR FOR
    
    SELECT 
			P.PICKING_ID, 
			P.CANT_CONFIRMADA - ISNULL(
			--SI YA HAY ALGO CONTROLADO DE ESE PICKING
				(	SELECT	TMP.CANT_CONFIRMADA 
					FROM	TMP_EMPAQUE_CONTENEDORA TMP
					WHERE	PICKING_ID = P.PICKING_ID 
							AND TMP.PALLET_CONTROLADO = '1')
			,0) CANT_CONFIRMADA
    FROM	DOCUMENTO D 
			INNER JOIN PICKING P 
			ON (D.DOCUMENTO_ID = P.DOCUMENTO_ID AND D.CLIENTE_ID = P.CLIENTE_ID) 
    WHERE	D.CLIENTE_ID = @CLIENTE_ID 
			AND D.NRO_REMITO = @PEDIDO_ID 
			AND P.PRODUCTO_ID = @PRODUCTO_ID 
			AND P.CANT_CONFIRMADA - ISNULL(
				(	SELECT	TMP.CANT_CONFIRMADA 
					FROM	TMP_EMPAQUE_CONTENEDORA TMP 
					WHERE	PICKING_ID = P.PICKING_ID 
							AND TMP.PALLET_CONTROLADO = '1'), 0) > 0
			AND P.PALLET_CONTROLADO = '0'
			AND (
			(ISNULL(P.NRO_LOTE,'9999999')=@NRO_LOTE 
			AND ISNULL(P.NRO_PARTIDA,'9999999')=@NRO_PARTIDA 
			AND ISNULL(P.NRO_SERIE,'9999999')=@NRO_SERIE)
			OR(
			(@NRO_LOTE IS NOT NULL OR @NRO_PARTIDA IS NOT NULL OR @NRO_SERIE IS NOT NULL)
			AND ((ISNULL(P.NRO_LOTE,'9999999')=@NRO_LOTE) OR (ISNULL(@NRO_LOTE,'')=''))
			AND ((ISNULL(P.NRO_PARTIDA,'9999999')=@NRO_PARTIDA) OR (ISNULL(@NRO_PARTIDA,'')=''))
			AND ((ISNULL(P.NRO_SERIE,'9999999')=@NRO_SERIE) OR (ISNULL(@NRO_SERIE,'')='')))
			)
    ORDER BY P.PICKING_ID
    
    OPEN cur_linea
    FETCH cur_linea
    INTO @PICKING_ID, @CANT_CONFIRMADA
    
    WHILE (@@FETCH_STATUS = 0 AND @CANT_CONTROLADA > 0)
        BEGIN
            IF NOT EXISTS(SELECT 1 FROM TMP_EMPAQUE_CONTENEDORA WHERE PICKING_ID = @PICKING_ID)
                BEGIN
                    INSERT INTO TMP_EMPAQUE_CONTENEDORA
                    SELECT	D.NRO_REMITO, P.PICKING_ID, P.DOCUMENTO_ID,P.NRO_LINEA,P.CLIENTE_ID,P.PRODUCTO_ID,P.VIAJE_ID,P.TIPO_CAJA,P.DESCRIPCION,
							P.CANTIDAD, P.NAVE_COD, P.POSICION_COD, P.RUTA,P.PROP1, P.FECHA_INICIO, P.FECHA_FIN,P.USUARIO,P.CANT_CONFIRMADA, P.PALLET_PICKING,
							P.SALTO_PICKING,P.PALLET_CONTROLADO,P.USUARIO_CONTROL_PICK,P.ST_ETIQUETAS,P.ST_CAMION,P.FACTURADO,P.FIN_PICKING,P.ST_CONTROL_EXP,
							P.FECHA_CONTROL_PALLET,P.TERMINAL_CONTROL_PALLET,FECHA_CONTROL_EXP, P.USUARIO_CONTROL_EXP,P.TERMINAL_CONTROL_EXP,P.FECHA_CONTROL_FAC,
							P.USUARIO_CONTROL_FAC,P.TERMINAL_CONTROL_FAC,P.VEHICULO_ID,P.PALLET_COMPLETO, P.HIJO, P.QTY_CONTROLADO, P.PALLET_FINAL,
							P.PALLET_CERRADO, P.USUARIO_PF,P.TERMINAL_PF,P.REMITO_IMPRESO,P.NRO_REMITO_PF,P.PICKING_ID_REF,P.BULTOS_CONTROLADOS,
							P.BULTOS_NO_CONTROLADOS, P.FLG_PALLET_HOMBRE,P.TRANSF_TERMINADA,P.NRO_LOTE,P.NRO_PARTIDA,P.NRO_SERIE,
							P.ESTADO,P.NRO_UCDESCONSOLIDACION,P.FECHA_DESCONSOLIDACION,P.USUARIO_DESCONSOLIDACION,P.TERMINAL_DESCONSOLIDACION,
							P.NRO_UCEMPAQUETADO,P.UCEMPAQUETADO_MEDIDAS,P.FECHA_UCEMPAQUETADO,P.UCEMPAQUETADO_PESO
                    FROM	DOCUMENTO D INNER JOIN PICKING P ON(D.DOCUMENTO_ID = P.DOCUMENTO_ID AND D.CLIENTE_ID = P.CLIENTE_ID) 
                    WHERE	D.CLIENTE_ID = @CLIENTE_ID AND D.NRO_REMITO = @PEDIDO_ID AND P.PRODUCTO_ID = @PRODUCTO_ID
                END
            
            IF @CANT_CONTROLADA > @CANT_CONFIRMADA
                BEGIN
                    SET @CANTIDAD_EMPAQUE = @CANT_CONFIRMADA
                    SET @CANT_CONTROLADA = @CANT_CONTROLADA - @CANT_CONFIRMADA
                END
            ELSE
                BEGIN
                    SET @CANTIDAD_EMPAQUE = @CANT_CONTROLADA
                    SET @CANT_CONTROLADA = @CANT_CONTROLADA - @CANT_CONFIRMADA
                END
            
            UPDATE TMP_EMPAQUE_CONTENEDORA
            SET CANTIDAD = CANTIDAD - @CANTIDAD_EMPAQUE,
                CANT_CONFIRMADA = CANT_CONFIRMADA - @CANTIDAD_EMPAQUE
            WHERE PICKING_ID = @PICKING_ID AND PALLET_CONTROLADO = '0'
            
            IF EXISTS(
                    SELECT 1 FROM TMP_EMPAQUE_CONTENEDORA 
                    WHERE PICKING_ID = @PICKING_ID AND PALLET_PICKING = @NRO_CONTENEDORA AND PALLET_CONTROLADO <> '0'
                )
                UPDATE TMP_EMPAQUE_CONTENEDORA
                SET CANTIDAD = CANTIDAD + @CANTIDAD_EMPAQUE,
                    CANT_CONFIRMADA = CANT_CONFIRMADA + @CANTIDAD_EMPAQUE
                WHERE PICKING_ID = @PICKING_ID AND PALLET_PICKING = @NRO_CONTENEDORA AND PALLET_CONTROLADO <> '0'
            ELSE
                INSERT INTO TMP_EMPAQUE_CONTENEDORA
                SELECT D.NRO_REMITO, P.PICKING_ID, P.DOCUMENTO_ID, P.NRO_LINEA, P.CLIENTE_ID, P.PRODUCTO_ID, P.VIAJE_ID, P.TIPO_CAJA, P.DESCRIPCION, 
                       @CANTIDAD_EMPAQUE [CANTIDAD], -- Cantidad 
                       P.NAVE_COD, P.POSICION_COD, P.RUTA, P.PROP1, P.FECHA_INICIO, P.FECHA_FIN, P.USUARIO, 
                       @CANTIDAD_EMPAQUE [CANT_CONFIRMADA], -- Cantidad Controlada
                       @NRO_CONTENEDORA [PALLET_PICKING], -- Nro Contenedora
                       P.SALTO_PICKING, 
                       '1' [PALLET_CONTROLADO], -- Esta en Contenedora
                       P.USUARIO_CONTROL_PICK, P.ST_ETIQUETAS, P.ST_CAMION, P.FACTURADO, P.FIN_PICKING, P.ST_CONTROL_EXP, 
                       P.FECHA_CONTROL_PALLET, P.TERMINAL_CONTROL_PALLET, P.FECHA_CONTROL_EXP, P.USUARIO_CONTROL_EXP, P.TERMINAL_CONTROL_EXP, 
                       P.FECHA_CONTROL_FAC, P.USUARIO_CONTROL_FAC, P.TERMINAL_CONTROL_FAC, P.VEHICULO_ID, P.PALLET_COMPLETO, P.HIJO, 
                       P.QTY_CONTROLADO, P.PALLET_FINAL, P.PALLET_CERRADO, P.USUARIO_PF, P.TERMINAL_PF, P.REMITO_IMPRESO, P.NRO_REMITO_PF, 
                       P.PICKING_ID_REF, P.BULTOS_CONTROLADOS, P.BULTOS_NO_CONTROLADOS, P.FLG_PALLET_HOMBRE, P.TRANSF_TERMINADA,P.NRO_LOTE,P.NRO_PARTIDA,P.NRO_SERIE,
                       P.ESTADO,P.NRO_UCDESCONSOLIDACION,P.FECHA_DESCONSOLIDACION,P.USUARIO_DESCONSOLIDACION,P.TERMINAL_DESCONSOLIDACION,
                       P.NRO_UCEMPAQUETADO,P.UCEMPAQUETADO_MEDIDAS,P.FECHA_UCEMPAQUETADO,P.UCEMPAQUETADO_PESO
                FROM DOCUMENTO D INNER JOIN PICKING P ON(D.DOCUMENTO_ID = P.DOCUMENTO_ID) 
                WHERE P.PICKING_ID = @PICKING_ID AND P.PALLET_CONTROLADO = '0'
            
            DELETE TMP_EMPAQUE_CONTENEDORA 
            WHERE PICKING_ID = @PICKING_ID AND CANTIDAD = 0 AND CANT_CONFIRMADA = 0 AND PALLET_CONTROLADO = '0'
            
            -- Si aun existe CANT_CONFIRMADA = 0, es porque hay residuo en CANTIDAD
            IF EXISTS(SELECT 1 FROM TMP_EMPAQUE_CONTENEDORA 
                      WHERE PICKING_ID = @PICKING_ID AND CANT_CONFIRMADA = 0 AND PALLET_CONTROLADO = '0')
                BEGIN
                    -- Para que no se pierda, guaro el residuo
                     UPDATE TMP_EMPAQUE_CONTENEDORA
                     SET CANTIDAD = CANTIDAD + ( 
                                                 SELECT TMP.CANTIDAD
                                                 FROM TMP_EMPAQUE_CONTENEDORA TMP
                                                 WHERE TMP.PICKING_ID = @PICKING_ID AND TMP.CANT_CONFIRMADA = 0 AND TMP.PALLET_CONTROLADO = '0'
                                                 )
                     WHERE PICKING_ID = @PICKING_ID AND PALLET_PICKING = @NRO_CONTENEDORA AND PALLET_CONTROLADO <> '0'
                    
                    -- Ahora si... A borrar!
                    DELETE TMP_EMPAQUE_CONTENEDORA 
                    WHERE PICKING_ID = @PICKING_ID AND CANT_CONFIRMADA = 0 AND PALLET_CONTROLADO = '0'
                END
            
            FETCH cur_linea
            INTO @PICKING_ID, @CANT_CONFIRMADA
        END
    CLOSE cur_linea
    DEALLOCATE cur_linea
	
	
    SELECT @CantPickeada = SUM(CANT_CONFIRMADA) 
    FROM TMP_EMPAQUE_CONTENEDORA 
    WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID AND PRODUCTO_ID = @PRODUCTO_ID AND ISNULL(NRO_LOTE,'9999999') = ISNULL(@NRO_LOTE,'') AND ISNULL(NRO_PARTIDA,'9999999') = ISNULL(@NRO_PARTIDA,'') AND ISNULL(NRO_SERIE,'9999999') = ISNULL(@NRO_SERIE,'')
    
    SELECT @CantControlada = SUM(CANT_CONFIRMADA) 
    FROM TMP_EMPAQUE_CONTENEDORA 
    WHERE	CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID AND PRODUCTO_ID = @PRODUCTO_ID AND PALLET_CONTROLADO <> '0'
			AND ISNULL(NRO_LOTE,'9999999') = ISNULL(@NRO_LOTE,'') AND ISNULL(NRO_PARTIDA,'9999999') = ISNULL(@NRO_PARTIDA,'') AND ISNULL(NRO_SERIE,'9999999') = ISNULL(@NRO_SERIE,'')
    
    SELECT @CantPendiente = @CantPickeada - @CantControlada
    
    SELECT @CantPickeada CantPickeada, @CantControlada CantControlada, @CantPendiente CantPendiente
END



GO


