/****** Object:  StoredProcedure [dbo].[reAbrirProductoEnContenedora]    Script Date: 11/25/2015 17:27:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reAbrirProductoEnContenedora]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[reAbrirProductoEnContenedora]
GO

CREATE PROCEDURE [dbo].[reAbrirProductoEnContenedora]
	-- Add the parameters for the stored procedure here
	@cliente_id		varchar(15) OUTPUT,
	@nro_remito		varchar(30) OUTPUT,
	@producto_id	varchar(30) OUTPUT,
	@cant_elegida	numeric(20,5) OUTPUT,
	@contenedora	numeric(20,0) OUTPUT,
	@check			char(1) OUTPUT

AS
BEGIN

	DECLARE @picking_id			numeric(20,0)
	DECLARE @cant_confirmada	numeric(20,5)
	DECLARE @CANT_A_LIBERAR		NUMERIC(20,5)
	DECLARE @CANT_A_CERRAR		NUMERIC(20,5)
	DECLARE @cursorFREE			cursor
	
	SET NOCOUNT ON;

	IF @check = '1'
	BEGIN
		--TENGO QUE CONTROLAR SI AUMENTO O DISMINUYO LA CANTIDAD ELEJIDA A EMPACAR
		--SELECCIONO LOS PRODUCTOS DENTRO DEL EMPAQUE
		SELECT	@CANT_CONFIRMADA = SUM(CANT_CONFIRMADA)
		FROM	PICKING
		WHERE	PALLET_PICKING = @CONTENEDORA
				AND PALLET_CONTROLADO='1'
				AND PRODUCTO_ID = @PRODUCTO_ID
				AND CLIENTE_ID = @CLIENTE_ID	

		IF (@CANT_ELEGIDA = @CANT_CONFIRMADA)
		BEGIN
		--SELECCIONO EL PRODUCTO COMPLETO PARA LIBERAR
			UPDATE	PICKING
			SET		PALLET_CONTROLADO = '0',
					NRO_UCEMPAQUETADO=null,
					UCEMPAQUETADO_PESO=null,
					USUARIO_PF=NULL
			WHERE	PALLET_PICKING = @contenedora
					and producto_id = @producto_id
		END
		ELSE
		BEGIN
			IF @CANT_ELEGIDA < @CANT_CONFIRMADA
			BEGIN
				--SE DISMINUYO LA CANTIDAD DE UN PRODUCTO AL REABRIR EL CONTENEDOR
				--SET @CANT_A_LIBERAR = @CANT_CONFIRMADA - @CANT_ELEGIDA

				SET @CANT_A_LIBERAR = @CANT_ELEGIDA
				
				SET @cursorFREE = cursor FOR
				SELECT	PICKING_ID,
						CANT_CONFIRMADA
				FROM	PICKING
				WHERE	PALLET_PICKING = @CONTENEDORA
						AND PALLET_CONTROLADO = '1'
						AND PRODUCTO_ID = @PRODUCTO_ID
						AND CLIENTE_ID = @CLIENTE_ID
				ORDER BY CANT_CONFIRMADA

				OPEN @cursorFREE
				FETCH NEXT FROM @cursorFREE INTO @picking_id, @cant_confirmada

				WHILE ((@@FETCH_STATUS = 0) AND (@CANT_A_LIBERAR - @cant_confirmada >= 0))
				BEGIN
						SET @CANT_A_LIBERAR = @CANT_A_LIBERAR - @cant_confirmada

						UPDATE	picking
						SET		pallet_picking = @contenedora,
								pallet_controlado = '0',
								NRO_UCEMPAQUETADO=null,
								UCEMPAQUETADO_PESO=null,
								USUARIO_PF=NULL
						WHERE	picking_id = @picking_id

					FETCH NEXT FROM @cursorFREE INTO @picking_id, @cant_confirmada
				END
			

				--en este punto si @cant_elegida_AUX < 0 entonces tenemos seleccionado el producto que hay que "partir"
					IF ((@CANT_A_LIBERAR - @cant_confirmada < 0) AND (@cant_a_liberar > 0) AND (@@fetch_status=0))
					BEGIN
						insert into picking 
						(DOCUMENTO_ID, NRO_LINEA, CLIENTE_ID, PRODUCTO_ID, VIAJE_ID, TIPO_CAJA, DESCRIPCION, CANTIDAD, NAVE_COD, POSICION_COD, RUTA, PROP1, FECHA_INICIO, FECHA_FIN, USUARIO, CANT_CONFIRMADA, PALLET_PICKING, SALTO_PICKING, PALLET_CONTROLADO, USUARIO_CONTROL_PICK, ST_ETIQUETAS, ST_CAMION, FACTURADO, FIN_PICKING, ST_CONTROL_EXP, FECHA_CONTROL_PALLET, TERMINAL_CONTROL_PALLET, FECHA_CONTROL_EXP, USUARIO_CONTROL_EXP, TERMINAL_CONTROL_EXP, FECHA_CONTROL_FAC, USUARIO_CONTROL_FAC, TERMINAL_CONTROL_FAC, VEHICULO_ID, PALLET_COMPLETO, HIJO, QTY_CONTROLADO, PALLET_FINAL, PALLET_CERRADO, USUARIO_PF, TERMINAL_PF, REMITO_IMPRESO, NRO_REMITO_PF, PICKING_ID_REF, BULTOS_CONTROLADOS, BULTOS_NO_CONTROLADOS, FLG_PALLET_HOMBRE, TRANSF_TERMINADA,NRO_LOTE,NRO_PARTIDA,NRO_SERIE ) 
						select	DOCUMENTO_ID,
								NRO_LINEA,
								CLIENTE_ID,
								PRODUCTO_ID,
								VIAJE_ID,
								TIPO_CAJA,
								DESCRIPCION,
								@CANT_A_LIBERAR,--CANTIDAD,     LO COMENTADO ES LO QUE ESTABA ANTES
								NAVE_COD,
								POSICION_COD,
								RUTA,
								PROP1,
								FECHA_INICIO,
								FECHA_FIN,
								USUARIO,
								@CANT_A_LIBERAR, --CANT_CONFIRMADA
								PALLET_PICKING,
								SALTO_PICKING,
								'0', --PALLET_CONTROLADO
								USUARIO_CONTROL_PICK,
								ST_ETIQUETAS,
								ST_CAMION,
								FACTURADO,
								FIN_PICKING,
								ST_CONTROL_EXP,
								FECHA_CONTROL_PALLET,
								TERMINAL_CONTROL_PALLET,
								FECHA_CONTROL_EXP,
								USUARIO_CONTROL_EXP,
								TERMINAL_CONTROL_EXP,
								FECHA_CONTROL_FAC,
								USUARIO_CONTROL_FAC,
								TERMINAL_CONTROL_FAC,
								VEHICULO_ID,
								PALLET_COMPLETO,
								HIJO,
								QTY_CONTROLADO,
								PALLET_FINAL,
								PALLET_CERRADO,
								USUARIO_PF,
								TERMINAL_PF,
								REMITO_IMPRESO,
								NRO_REMITO_PF,
								PICKING_ID_REF,
								BULTOS_CONTROLADOS,
								BULTOS_NO_CONTROLADOS,
								FLG_PALLET_HOMBRE,
								TRANSF_TERMINADA,NRO_LOTE,NRO_PARTIDA,NRO_SERIE
						from picking where picking_id = @picking_id

						UPDATE PICKING SET	CANT_CONFIRMADA = CANT_CONFIRMADA - @CANT_A_LIBERAR, 
											CANTIDAD = CANT_CONFIRMADA - @CANT_A_LIBERAR --ESTA LINEA ESTA CORREGIDA, CUALQUIER COSA BORRARLA
						WHERE PICKING_ID = @PICKING_ID
					END

				CLOSE @cursorFREE
				DEALLOCATE @cursorFREE
			END
		END
	END
END


GO


