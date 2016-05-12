/****** Object:  StoredProcedure [dbo].[MOB_REGISTRA_TMP_PRODUCTO_EMPAQUE]    Script Date: 11/13/2015 15:03:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MOB_REGISTRA_TMP_PRODUCTO_EMPAQUE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[MOB_REGISTRA_TMP_PRODUCTO_EMPAQUE]
GO

CREATE PROCEDURE [dbo].[MOB_REGISTRA_TMP_PRODUCTO_EMPAQUE]
	@CLIENTE_ID         AS VARCHAR(15)	OUTPUT,
	@PEDIDO_ID          AS VARCHAR(100) OUTPUT,
	@PRODUCTO_ID        AS VARCHAR(30)	OUTPUT,
    @NRO_CONTENEDORA    AS NUMERIC(20)	OUTPUT,
    @CANT_CONTROLADA    AS NUMERIC(20,5)OUTPUT,
	@NRO_LOTE			AS VARCHAR(100) OUTPUT,
	@NRO_PARTIDA		AS VARCHAR(100) OUTPUT,
	@NRO_SERIE			AS VARCHAR(50)	OUTPUT,
	@CONTROLA_LP		AS VARCHAR(1)	OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CONT	NUMERIC(20,0)
    DECLARE @UC_EMPAQUE	NUMERIC(20,0)

	IF @CONTROLA_LP='1' BEGIN     	
		IF NOT EXISTS (	SELECT	1
						FROM	PICKING P
						INNER JOIN DET_DOCUMENTO DD ON (P.DOCUMENTO_ID = DD.DOCUMENTO_ID AND P.NRO_LINEA = DD.NRO_LINEA)
						INNER JOIN DOCUMENTO D ON (DD.DOCUMENTO_ID = D.DOCUMENTO_ID)
						WHERE	P.CLIENTE_ID = @CLIENTE_ID
								AND D.NRO_REMITO = @PEDIDO_ID
								AND P.PRODUCTO_ID = @PRODUCTO_ID
								AND ((@NRO_LOTE IS NULL AND P.NRO_LOTE IS NULL)OR(P.NRO_LOTE=@NRO_LOTE))
								AND ((@NRO_PARTIDA IS NULL AND P.NRO_PARTIDA IS NULL)OR(P.NRO_PARTIDA=@NRO_PARTIDA))
								AND ((@NRO_SERIE IS NULL AND P.NRO_SERIE IS NULL)OR(P.NRO_SERIE=@NRO_SERIE))
						)BEGIN
			RAISERROR('NO HAY PENDIENTES DE EMPAQUETADO PARA EL PRODUCTO INGRESADO.',16,1) 
		END
	END ELSE BEGIN
		IF NOT EXISTS (	SELECT	1
						FROM	PICKING P
						INNER JOIN DET_DOCUMENTO DD ON (P.DOCUMENTO_ID = DD.DOCUMENTO_ID AND P.NRO_LINEA = DD.NRO_LINEA)
						INNER JOIN DOCUMENTO D ON (DD.DOCUMENTO_ID = D.DOCUMENTO_ID)
						WHERE	P.CLIENTE_ID = @CLIENTE_ID
								AND D.NRO_REMITO = @PEDIDO_ID
								AND P.PRODUCTO_ID = @PRODUCTO_ID
						)BEGIN
			RAISERROR('NO HAY PENDIENTES DE EMPAQUETADO PARA EL PRODUCTO INGRESADO..',16,1) 
		END	
	END
    DECLARE @CANTPICKEADA AS NUMERIC(20,5),
            @CANTCONTROLADA AS NUMERIC(20,5),
            @CANTPENDIENTE AS NUMERIC(20,5),
            @NRO_LINEA AS NUMERIC(10),
            @CANT_CONFIRMADA AS NUMERIC(20,5),
            @CANTIDAD_EMPAQUE AS NUMERIC(20,5),
			@PICKING_ID AS NUMERIC(20,0)

    
    
    IF @CONTROLA_LP='1' BEGIN
		DECLARE CUR_LINEA CURSOR FOR
		SELECT	P.PICKING_ID, 
				P.CANT_CONFIRMADA - ISNULL(
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
				AND ((@NRO_LOTE IS NULL AND P.NRO_LOTE IS NULL)OR(P.NRO_LOTE=@NRO_LOTE))
				AND ((@NRO_PARTIDA IS NULL AND P.NRO_PARTIDA IS NULL)OR(P.NRO_PARTIDA=@NRO_PARTIDA))
				AND ((@NRO_SERIE IS NULL AND P.NRO_SERIE IS NULL)OR(P.NRO_SERIE=@NRO_SERIE))
		ORDER BY P.PICKING_ID
    END ELSE BEGIN
		DECLARE CUR_LINEA CURSOR FOR
		SELECT	P.PICKING_ID, 
				P.CANT_CONFIRMADA - ISNULL(
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
		ORDER BY P.PICKING_ID    
    END
    OPEN CUR_LINEA
    FETCH CUR_LINEA
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
						P.USUARIO_CONTROL_FAC,P.TERMINAL_CONTROL_FAC,P.VEHICULO_ID,P.PALLET_COMPLETO, P.HIJO, P.QTY_CONTROLADO, P.PALLET_PICKING,--P.PALLET_FINAL,
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
            
            UPDATE	TMP_EMPAQUE_CONTENEDORA
            SET		CANTIDAD = CANTIDAD - @CANTIDAD_EMPAQUE,
					CANT_CONFIRMADA = CANT_CONFIRMADA - @CANTIDAD_EMPAQUE, BULTOS_CONTROLADOS=NULL
            WHERE	PICKING_ID = @PICKING_ID AND PALLET_CONTROLADO = '0'
            
            IF EXISTS(	SELECT	1 
						FROM	TMP_EMPAQUE_CONTENEDORA 
						WHERE	PICKING_ID = @PICKING_ID AND PALLET_PICKING = @NRO_CONTENEDORA AND PALLET_CONTROLADO <> '0'
                )
                UPDATE TMP_EMPAQUE_CONTENEDORA
                SET CANTIDAD = CANTIDAD + @CANTIDAD_EMPAQUE,
                    CANT_CONFIRMADA = CANT_CONFIRMADA + @CANTIDAD_EMPAQUE
                WHERE PICKING_ID = @PICKING_ID AND PALLET_PICKING = @NRO_CONTENEDORA AND PALLET_CONTROLADO <> '0'
            ELSE
                INSERT INTO TMP_EMPAQUE_CONTENEDORA
                SELECT D.NRO_REMITO, P.PICKING_ID, P.DOCUMENTO_ID, P.NRO_LINEA, P.CLIENTE_ID, P.PRODUCTO_ID, P.VIAJE_ID, P.TIPO_CAJA, P.DESCRIPCION, 
                       @CANTIDAD_EMPAQUE [CANTIDAD], -- CANTIDAD 
                       P.NAVE_COD, P.POSICION_COD, P.RUTA, P.PROP1, P.FECHA_INICIO, P.FECHA_FIN, P.USUARIO, 
                       @CANTIDAD_EMPAQUE [CANT_CONFIRMADA], -- CANTIDAD CONTROLADA
                       @NRO_CONTENEDORA [PALLET_PICKING], -- NRO CONTENEDORA
                       P.SALTO_PICKING, 
                       '1' [PALLET_CONTROLADO], -- ESTA EN CONTENEDORA
                       P.USUARIO_CONTROL_PICK, P.ST_ETIQUETAS, P.ST_CAMION, P.FACTURADO, P.FIN_PICKING, P.ST_CONTROL_EXP, 
                       P.FECHA_CONTROL_PALLET, P.TERMINAL_CONTROL_PALLET, P.FECHA_CONTROL_EXP, P.USUARIO_CONTROL_EXP, P.TERMINAL_CONTROL_EXP, 
                       P.FECHA_CONTROL_FAC, P.USUARIO_CONTROL_FAC, P.TERMINAL_CONTROL_FAC, P.VEHICULO_ID, P.PALLET_COMPLETO, P.HIJO, 
                       P.QTY_CONTROLADO, P.PALLET_PICKING,--p.pallet_final.
                       P.PALLET_CERRADO, P.USUARIO_PF, P.TERMINAL_PF, P.REMITO_IMPRESO, P.NRO_REMITO_PF, 
                       P.PICKING_ID_REF, '1' BULTOS_CONTROLADOS, P.BULTOS_NO_CONTROLADOS, P.FLG_PALLET_HOMBRE, P.TRANSF_TERMINADA,P.NRO_LOTE,P.NRO_PARTIDA,P.NRO_SERIE,
                       P.ESTADO,P.NRO_UCDESCONSOLIDACION,P.FECHA_DESCONSOLIDACION,P.USUARIO_DESCONSOLIDACION,P.TERMINAL_DESCONSOLIDACION,
                       P.NRO_UCEMPAQUETADO,P.UCEMPAQUETADO_MEDIDAS,P.FECHA_UCEMPAQUETADO,P.UCEMPAQUETADO_PESO
                FROM DOCUMENTO D INNER JOIN PICKING P ON(D.DOCUMENTO_ID = P.DOCUMENTO_ID) 
                WHERE P.PICKING_ID = @PICKING_ID AND P.PALLET_CONTROLADO = '0'
            
            DELETE TMP_EMPAQUE_CONTENEDORA 
            WHERE PICKING_ID = @PICKING_ID AND CANTIDAD = 0 AND CANT_CONFIRMADA = 0 AND PALLET_CONTROLADO = '0'
            
            -- SI AUN EXISTE CANT_CONFIRMADA = 0, ES PORQUE HAY RESIDUO EN CANTIDAD
            IF EXISTS(SELECT 1 FROM TMP_EMPAQUE_CONTENEDORA 
                      WHERE PICKING_ID = @PICKING_ID AND CANT_CONFIRMADA = 0 AND PALLET_CONTROLADO = '0')
                BEGIN
                    -- PARA QUE NO SE PIERDA, GUARO EL RESIDUO
                     UPDATE TMP_EMPAQUE_CONTENEDORA
                     SET CANTIDAD = CANTIDAD + ( 
                                                 SELECT TMP.CANTIDAD
                                                 FROM TMP_EMPAQUE_CONTENEDORA TMP
                                                 WHERE TMP.PICKING_ID = @PICKING_ID AND TMP.CANT_CONFIRMADA = 0 AND TMP.PALLET_CONTROLADO = '0'
                                                 )
                     WHERE PICKING_ID = @PICKING_ID AND PALLET_PICKING = @NRO_CONTENEDORA AND PALLET_CONTROLADO <> '0'
                    
                    -- AHORA SI... A BORRAR!
                    DELETE TMP_EMPAQUE_CONTENEDORA 
                    WHERE PICKING_ID = @PICKING_ID AND CANT_CONFIRMADA = 0 AND PALLET_CONTROLADO = '0'
                END
            
            FETCH CUR_LINEA
            INTO @PICKING_ID, @CANT_CONFIRMADA
        END
    CLOSE CUR_LINEA
    DEALLOCATE CUR_LINEA
	
	
    SELECT @CANTPICKEADA = SUM(CANT_CONFIRMADA) 
    FROM TMP_EMPAQUE_CONTENEDORA 
    WHERE CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID AND PRODUCTO_ID = @PRODUCTO_ID AND ISNULL(NRO_LOTE,'9999999') = ISNULL(@NRO_LOTE,'') AND ISNULL(NRO_PARTIDA,'9999999') = ISNULL(@NRO_PARTIDA,'') AND ISNULL(NRO_SERIE,'9999999') = ISNULL(@NRO_SERIE,'')
    
    SELECT @CANTCONTROLADA = SUM(CANT_CONFIRMADA) 
    FROM TMP_EMPAQUE_CONTENEDORA 
    WHERE	CLIENTE_ID = @CLIENTE_ID AND NRO_REMITO = @PEDIDO_ID AND PRODUCTO_ID = @PRODUCTO_ID AND PALLET_CONTROLADO <> '0'
			AND ISNULL(NRO_LOTE,'9999999') = ISNULL(@NRO_LOTE,'') AND ISNULL(NRO_PARTIDA,'9999999') = ISNULL(@NRO_PARTIDA,'') AND ISNULL(NRO_SERIE,'9999999') = ISNULL(@NRO_SERIE,'')
    
    SELECT @CANTPENDIENTE = @CANTPICKEADA - @CANTCONTROLADA
    
    /*
    SELECT	@CONT = SUM(P.CANT_CONFIRMADA)
    FROM	PICKING P
    WHERE	EXISTS(	SELECT	1
					FROM	DOCUMENTO D
					WHERE	P.DOCUMENTO_ID=D.DOCUMENTO_ID
							AND D.NRO_REMITO=@PEDIDO_ID)
							
	IF @CONT>0 BEGIN

		EXEC DBO.GET_VALUE_FOR_SEQUENCE 'PALLET_PICKING',@UC_EMPAQUE OUTPUT
		
		INSERT INTO MOB_EMPAQUE_UC_EMPAQUE --VALUES	(@DOCUMENTO,@UC_EMPAQUE,'ABIERTO',GETDATE())	
		SELECT	DISTINCT D.DOCUMENTO_ID,@UC_EMPAQUE,'ABIERTO',GETDATE()
		FROM	DOCUMENTO D
		WHERE	D.NRO_REMITO=@PEDIDO_ID
		
	END	
	*/						
END




GO

