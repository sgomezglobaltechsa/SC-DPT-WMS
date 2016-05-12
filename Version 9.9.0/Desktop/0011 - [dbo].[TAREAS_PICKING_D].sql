IF  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TAREAS_PICKING_D]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[TAREAS_PICKING_D]
GO

CREATE PROCEDURE [dbo].[TAREAS_PICKING_D]
	@USUARIO 			AS VARCHAR(30),
	@VIAJE_ID 			AS VARCHAR(100),
	@PALLET_I			AS VARCHAR(30),
	@RUTA_I				AS VARCHAR(100),
	@CLIENTE			AS VARCHAR(30)=NULL,
	@VH					AS VARCHAR(40)=NULL,
	@PALLETCOMPLETO		AS NUMERIC(10),
	@NAVECALLE			AS VARCHAR(50)=NULL
AS
	DECLARE @VERIFICACION 	AS NUMERIC(20)
	DECLARE @VIAJEID 		AS VARCHAR(100)
	DECLARE @PRODUCTO_ID	AS VARCHAR(50)
	DECLARE @DESCRIPCION	AS VARCHAR(200)
	DECLARE @QTY			AS NUMERIC(20,5)
	DECLARE @POSICION_COD	AS VARCHAR(45)
	DECLARE @PALLET			AS VARCHAR(100)
	DECLARE @RUTA			AS VARCHAR(100)--SE USA INTERNAMENTE Y SE DEVUELVE A LA APLICACION
	DECLARE @UNIDAD_ID		AS VARCHAR(5)
	DECLARE @TQUERY			AS VARCHAR(1)
	DECLARE @PICKING_ID		AS INT
	DECLARE @VAL_COD_EGR	AS CHAR(1)
	DECLARE @CLIENTE_ID		AS VARCHAR(15)
	DECLARE @NRO_LOTE		AS VARCHAR(50)
	DECLARE @TOMARUTA		AS CHAR(1)
	DECLARE @PALLETCOMP		AS CHAR(1)
	DECLARE @NRO_LINEA		AS NUMERIC(20,0)
	DECLARE @NRO_CONTENEDORA AS VARCHAR(50)
	DECLARE @DOCUMENTO_ID AS NUMERIC(20,0)
	DECLARE @LOTEPROVEEDOR	AS VARCHAR(100)
	DECLARE @NRO_PARTIDA	AS VARCHAR(100)
	DECLARE @NRO_SERIE		AS VARCHAR(50)
	DECLARE @NRO_SERIE_STOCK AS VARCHAR(50)

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

	BEGIN

	
	--DETERMINO SI TOMO TODA LA RUTA.
	SELECT	@TOMARUTA=ISNULL(FLG_TOMAR_RUTA,'0')
	FROM	CLIENTE_PARAMETROS
	WHERE	CLIENTE_ID=@CLIENTE

	SELECT	@PALLETCOMP=ISNULL(FLG_ACTIVA_PC_PN,'0')
	FROM	CLIENTE_PARAMETROS
	WHERE	CLIENTE_ID=@CLIENTE

	IF @VIAJE_ID <> '0'	
	BEGIN
		SELECT @VERIFICACION= DBO.VERIFICA_FIN_VIAJES(@VIAJE_ID)
		IF @VERIFICACION=1	
		BEGIN
			RAISERROR ('1', 16, 1)
			Return(99)
		END
		ELSE
		BEGIN
			
			SELECT @VERIFICACION= 0--Dbo.Fx_Fin_Viaje_Usuario(@VIAJE_ID,@USUARIO)
			IF @VERIFICACION=1	
			BEGIN
				RAISERROR ('1', 16, 1)
				Return(99)
			END
		END
		IF @RUTA_I<>'0' AND @RUTA_I IS NOT NULL
		BEGIN
			SELECT @VERIFICACION= DBO.FX_FIN_RUTA(@VIAJE_ID,@RUTA_I)
			IF @VERIFICACION=1	
			BEGIN
				RAISERROR('2',16,1)
				Return(99)
			END

			ELSE
			BEGIN
				
				SELECT @VERIFICACION= DBO.FX_FIN_RUTA_USUARIO(@VIAJE_ID,@RUTA_I,@USUARIO)
				IF (@VERIFICACION=1)
				BEGIN
					IF (@TOMARUTA='1')
					BEGIN
						SET @RUTA_I= NULL
					END
					ELSE
					BEGIN
						IF @TOMARUTA='0'
						BEGIN
							Set @RUTA_I=null
						END
						ELSE
						BEGIN
							RAISERROR('2',16,1)
							Return(99)
						END
					END
				END
			END	
		END
	END --FIN VERIFICACIONES.

 	IF @VIAJE_ID='0'	
	BEGIN	
		SET @TQUERY='1'
	END
	ELSE
	BEGIN
		IF @VIAJE_ID IS NOT NULL AND @RUTA_I IS NOT NULL 
		BEGIN
			SET @TQUERY='2'
		END
		ELSE 
		BEGIN
			IF @VIAJE_ID IS NOT NULL AND @RUTA_I IS NULL AND 0=0 --Fin Ruta
			BEGIN
				SET @TQUERY='3'
			END
		END
	END --FIN TQUERY

	

	IF @TQUERY='1' BEGIN--Por aca pase y termine
		
			SELECT 	TOP 1
					@VIAJEID=SP.VIAJE_ID, @PRODUCTO_ID=SP.PRODUCTO_ID,@DESCRIPCION=SP.DESCRIPCION, 
					@QTY=SUM(SP.CANTIDAD),@POSICION_COD= SP.POSICION_COD,@PALLET=SP.PROP1,@RUTA=SP.RUTA,
					@UNIDAD_ID=PROD.UNIDAD_ID, @VAL_COD_EGR=PROD.VAL_COD_EGR,@CLIENTE_ID=SP.CLIENTE_ID,
					@NRO_LOTE=CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END,
					@NRO_SERIE_STOCK = SP.NRO_SERIE,--@NRO_LINEA= SP.NRO_LINEA, --LO AGREGUE PARA QUE ACTUALICE POR NRO_LINEA Y NO TODAS LAS TAREAS
					@NRO_CONTENEDORA =DD.NRO_BULTO,@LOTEPROVEEDOR = DD.NRO_LOTE, @NRO_PARTIDA = DD.NRO_PARTIDA
					,@NRO_SERIE = DD.NRO_SERIE
			FROM 	PICKING SP
					LEFT JOIN POSICION POS ON(SP.POSICION_COD=POS.POSICION_COD)
					INNER JOIN PRIORIDAD_VIAJE SPV
					ON(LTRIM(RTRIM(UPPER(SPV.VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID))))
					INNER JOIN PRODUCTO PROD
					ON(PROD.CLIENTE_ID=SP.CLIENTE_ID AND PROD.PRODUCTO_ID=SP.PRODUCTO_ID)
					INNER JOIN RL_SYS_CLIENTE_USUARIO SU ON(SP.CLIENTE_ID=SU.CLIENTE_ID)
					INNER JOIN DET_DOCUMENTO DD ON(SP.DOCUMENTO_ID=DD.DOCUMENTO_ID AND SP.NRO_LINEA=DD.NRO_LINEA)
					INNER JOIN CLIENTE C ON(SP.CLIENTE_ID=C.CLIENTE_ID)
					INNER JOIN CLIENTE_PARAMETROS CP ON(C.CLIENTE_ID=CP.CLIENTE_ID)
			WHERE 	SPV.PRIORIDAD = (	SELECT 	MIN(ISNULL(PRIORIDAD,0))
										FROM	PRIORIDAD_VIAJE
										WHERE	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID))))
					AND SU.USUARIO_ID=@USUARIO
					AND ((CP.FLG_ACTIVA_PC_PN='0') OR (DBO.VERIFICA_PALLET_FINAL(SP.POSICION_COD,SP.VIAJE_ID,SP.RUTA, SP.PROP1)=@PALLETCOMPLETO))
					AND SP.FLG_PALLET_HOMBRE = SP.TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
					AND	SP.FECHA_INICIO IS NULL
					AND	SP.FECHA_FIN IS NULL			
					AND	SP.USUARIO IS NULL
					AND	SP.CANT_CONFIRMADA IS NULL 														
					AND	SP.VIAJE_ID IN (SELECT 	VIAJE_ID
										FROM  	RL_VIAJE_USUARIO
										WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID)))
												AND	LTRIM(RTRIM(UPPER(USUARIO_ID))) =LTRIM(RTRIM(UPPER(@USUARIO)))
					AND SP.NAVE_COD	IN(	SELECT 	NAVE_COD
										FROM 	NAVE N INNER JOIN RL_USUARIO_NAVE RLNU
												ON(N.NAVE_ID=RLNU.NAVE_ID)
										WHERE	N.NAVE_COD=SP.NAVE_COD
												AND LTRIM(RTRIM(UPPER(RLNU.USUARIO_ID)))=LTRIM(RTRIM(UPPER(@USUARIO)))
										)
										)
					AND SP.FIN_PICKING <>'2'
					AND ((@CLIENTE IS NULL) OR(SP.CLIENTE_ID=@CLIENTE))
					AND	((@VH IS NULL)OR(SP.POSICION_COD IN(SELECT 	POSICION_COD
															FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																	INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																	INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
															WHERE 	VEHICULO_ID=@VH
																	AND((CP.FLG_PICKING_CN='0')OR (CN.CALLE_COD=@NAVECALLE))
															UNION 
															SELECT 	NAVE_COD AS POSICION_COD
															FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																	ON(V.NAVE_ID=N2.NAVE_ID)
															WHERE	VEHICULO_ID=@VH
																	AND((CP.FLG_PICKING_CN='0')OR(N2.NAVE_COD=@NAVECALLE))
																	)))
			GROUP BY	
					SP.VIAJE_ID,	SP.PRODUCTO_ID,		SP.DESCRIPCION,		SP.RUTA,		SP.POSICION_COD,
					CAST(CASE ISNULL(CP.FLG_RECORRIDO_PALLET_FINAL,'0')	WHEN '1' THEN (CASE ISNUMERIC(SP.TIPO_CAJA) WHEN 1 THEN (CASE SP.TIPO_CAJA WHEN 0 THEN 9999 ELSE SP.TIPO_CAJA END) ELSE 9999 END) ELSE 9999 END AS INT),
					SP.PROP1,PROD.UNIDAD_ID,
					SPV.PRIORIDAD, PROD.VAL_COD_EGR,SP.CLIENTE_ID, POS.ORDEN_PICKING,CP.FLG_SOLICITA_LOTE, 
					CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END,SP.NRO_SERIE,DD.NRO_BULTO
					,DD.NRO_LOTE,DD.NRO_PARTIDA,DD.NRO_SERIE
			ORDER BY
					SPV.PRIORIDAD ASC,SP.RUTA, 
					CAST(CASE ISNULL(CP.FLG_RECORRIDO_PALLET_FINAL,'0')	WHEN '1' THEN (CASE ISNUMERIC(SP.TIPO_CAJA) WHEN 1 THEN (CASE SP.TIPO_CAJA WHEN 0 THEN 9999 ELSE SP.TIPO_CAJA END) ELSE 9999 END) ELSE 9999 END AS INT) ASC,
					POS.ORDEN_PICKING, SP.POSICION_COD ASC, SP.PRODUCTO_ID


			UPDATE 	PICKING SET FECHA_INICIO = GETDATE(),USUARIO=UPPER(LTRIM(RTRIM(@USUARIO))),PALLET_PICKING=@PALLET_I,
					VEHICULO_ID=@VH		
			FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
					ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)			
			WHERE  	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID )))
					AND LTRIM(RTRIM(UPPER(P.PRODUCTO_ID)))=LTRIM(RTRIM(UPPER(@PRODUCTO_ID)))
					--AND LTRIM(RTRIM(UPPER(P.DESCRIPCION)))=LTRIM(RTRIM(UPPER(@DESCRIPCION)))
					AND FLG_PALLET_HOMBRE = TRANSF_TERMINADA
					AND LTRIM(RTRIM(UPPER(P.POSICION_COD)))=LTRIM(RTRIM(UPPER(@POSICION_COD)))
					AND ((ISNULL(@PALLET,'1') IS NULL) OR(LTRIM(RTRIM(UPPER(ISNULL(P.PROP1,'1')))) = LTRIM(RTRIM(UPPER(ISNULL(@PALLET,'1'))))))
					AND LTRIM(RTRIM(UPPER(P.RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
					AND ((ISNULL(@LOTEPROVEEDOR,'1') IS NULL) OR (ISNULL(DD.NRO_LOTE,'1')=ISNULL(@LOTEPROVEEDOR,'1')))
					AND ((ISNULL(@NRO_PARTIDA,'XFFF') IS NULL) OR (ISNULL(DD.NRO_PARTIDA,'XFFF')=ISNULL(@NRO_PARTIDA,'XFFF')))
					AND ((@VH IS NULL OR @VH='') 
							OR(	POSICION_COD IN(	SELECT 	POSICION_COD
													FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
															INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
															INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
													WHERE 	VEHICULO_ID=@VH
													UNION 
													SELECT 	NAVE_COD AS POSICION_COD
													FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
															ON(V.NAVE_ID=N2.NAVE_ID)
													WHERE	VEHICULO_ID=@VH)))
					AND (ISNULL(@NRO_SERIE_STOCK,'1') IS NULL OR ISNULL(P.NRO_SERIE,'1') = ISNULL(@NRO_SERIE_STOCK,'1'))
					AND (ISNULL(@NRO_CONTENEDORA,'1') IS NULL OR ISNULL(DD.NRO_BULTO,'1') = ISNULL(@NRO_CONTENEDORA,'1'))

					
					--AND P.NRO_LINEA =@NRO_LINEA 
					--Catalina Castillo.Tracker 4741
					--AND P.PICKING_ID=@PICKING_ID 
			if @tomaruta='1'
			begin --Comienzo a tomar toda la ruta.
				DECLARE T_RUTA CURSOR FOR
				SELECT 	PICKING_ID
				FROM	PICKING P
				WHERE	((@PALLETCOMP='0') OR (DBO.VERIFICA_PALLET_FINAL(P.POSICION_COD,P.VIAJE_ID,P.RUTA, P.PROP1)=@PALLETCOMPLETO))
						AND P.NAVE_COD IN(	SELECT	NAVE_COD
											FROM 	NAVE N INNER JOIN RL_USUARIO_NAVE RLNU
													ON(N.NAVE_ID=RLNU.NAVE_ID)
											WHERE	N.NAVE_COD=P.NAVE_COD
													AND RLNU.USUARIO_ID=@USUARIO)
													AND LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
													AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
													AND FECHA_INICIO IS NULL AND FECHA_FIN  IS NULL AND USUARIO IS NULL
													AND	((@VH IS NULL) OR(	POSICION_COD IN(	SELECT 	POSICION_COD
																								FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																										INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																										INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																								WHERE 	VEHICULO_ID=@VH
																								UNION 
																								SELECT 	NAVE_COD AS POSICION_COD
																								FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																										ON(V.NAVE_ID=N2.NAVE_ID)
																								WHERE	VEHICULO_ID=@VH)))
				OPEN T_RUTA

				FETCH NEXT FROM T_RUTA INTO @PICKING_ID
				WHILE @@FETCH_STATUS=0 
					BEGIN
					If 0=0 
						Begin
							UPDATE	PICKING SET USUARIO =@USUARIO 
							FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
									ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
							WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID))) 
									AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA))) 
									AND PICKING_ID=@PICKING_ID
									--AND (DBO.VERIFICA_PALLET_FINAL(@POSICION_COD,@VIAJEID,@RUTA, @PALLET)=@PALLETCOMPLETO)
									AND FECHA_INICIO IS NULL AND FECHA_FIN IS NULL AND CANT_CONFIRMADA IS NULL AND PALLET_PICKING IS NULL
									AND USUARIO IS NULL
									AND
									((@VH IS NULL) OR(	POSICION_COD IN(	SELECT 	POSICION_COD
																			FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																					INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																					INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																			WHERE 	VEHICULO_ID=@VH
																			UNION 
																			SELECT 	NAVE_COD AS POSICION_COD
																			FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																					ON(V.NAVE_ID=N2.NAVE_ID)
																			WHERE	VEHICULO_ID=@VH)))
							FETCH NEXT FROM T_RUTA INTO @PICKING_ID
						End
					END
				CLOSE T_RUTA
				DEALLOCATE T_RUTA
			End
			IF @PRODUCTO_ID IS NOT NULL 
			BEGIN
				SELECT 	@VIAJEID AS VIAJE_ID,@PRODUCTO_ID AS PRODUCTO_ID, @DESCRIPCION AS DESCRIPCION, 
						@QTY AS QTY, @POSICION_COD AS POSICION_COD, @PALLET AS PALLET,@RUTA AS RUTA,
						@UNIDAD_ID AS UNIDAD_ID,@VAL_COD_EGR AS VAL_COD_EGR,@CLIENTE_ID AS CLIENTE_ID,
						@NRO_LOTE AS NRO_LOTE,
						@NRO_SERIE_STOCK AS NRO_SERIE_STOCK,
						@NRO_CONTENEDORA AS NRO_CONTENEDORA,	
						@LOTEPROVEEDOR AS LOTE_PROVEEDOR,@NRO_PARTIDA AS NRO_PARTIDA,
						@NRO_SERIE AS NRO_SERIE
				RETURN
			END
		END --FIN TQUERY=1
	ELSE
		BEGIN
			IF @TQUERY='2'
				BEGIN
					
					SELECT 	TOP 1
							@VIAJEID=SP.VIAJE_ID, @PRODUCTO_ID=SP.PRODUCTO_ID, 
							@DESCRIPCION=SP.DESCRIPCION, @QTY=SUM(SP.CANTIDAD),@POSICION_COD= SP.POSICION_COD,
							@PALLET = SP.PROP1,@RUTA=SP.RUTA
							,@UNIDAD_ID=PROD.UNIDAD_ID, @VAL_COD_EGR=PROD.VAL_COD_EGR,
							@CLIENTE_ID = SP.CLIENTE_ID,
							@NRO_LOTE=CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END,
							@NRO_SERIE_STOCK = SP.NRO_SERIE,
							@NRO_CONTENEDORA =DD.NRO_BULTO,@LOTEPROVEEDOR = DD.NRO_LOTE, @NRO_PARTIDA = DD.NRO_PARTIDA,
							@NRO_SERIE = DD.NRO_SERIE
					FROM 	PICKING SP 
							LEFT JOIN POSICION POS ON(SP.POSICION_COD=POS.POSICION_COD)
							INNER JOIN PRIORIDAD_VIAJE SPV
							ON(LTRIM(RTRIM(UPPER(SPV.VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID))))
							INNER JOIN PRODUCTO PROD
							ON(PROD.CLIENTE_ID=SP.CLIENTE_ID AND PROD.PRODUCTO_ID=SP.PRODUCTO_ID)
							INNER JOIN RL_SYS_CLIENTE_USUARIO SU ON(SP.CLIENTE_ID=SU.CLIENTE_ID)
							INNER JOIN DET_DOCUMENTO DD ON(SP.DOCUMENTO_ID=DD.DOCUMENTO_ID AND SP.NRO_LINEA=DD.NRO_LINEA)
							INNER JOIN CLIENTE C ON(SP.CLIENTE_ID=C.CLIENTE_ID)
							INNER JOIN CLIENTE_PARAMETROS CP ON(C.CLIENTE_ID=CP.CLIENTE_ID)
					WHERE 					
							SP.FECHA_INICIO IS NULL
							AND ((CP.FLG_ACTIVA_PC_PN='0') OR (DBO.VERIFICA_PALLET_FINAL(SP.POSICION_COD,SP.VIAJE_ID,SP.RUTA, SP.PROP1)=@PALLETCOMPLETO))
							AND	SP.FECHA_FIN IS NULL			
							AND SP.CANT_CONFIRMADA IS NULL
							AND SU.USUARIO_ID=@USUARIO
							AND SP.FLG_PALLET_HOMBRE = SP.TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
							AND SPV.PRIORIDAD = (	SELECT 	MIN(PRIORIDAD)
													FROM	PRIORIDAD_VIAJE
													WHERE	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID))))
							AND	UPPER(LTRIM(RTRIM(SP.VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJE_ID)))
							and
							SP.VIAJE_ID IN (SELECT 	VIAJE_ID
											FROM  	RL_VIAJE_USUARIO
											WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID)))
													AND LTRIM(RTRIM(UPPER(USUARIO_ID))) =LTRIM(RTRIM(UPPER(@USUARIO))))				
							AND SP.SALTO_PICKING = (	SELECT 	MIN(ISNULL(SALTO_PICKING,0))
														FROM 	PICKING 
														WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJE_ID)))
																AND FECHA_INICIO IS NULL
																--AND USUARIO=SP.USUARIO
																AND FECHA_FIN IS NULL
																AND CANT_CONFIRMADA IS NULL
																AND ((@RUTA_I='9999') OR(LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA_I))))))
							AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA_I)))
							AND ((@CLIENTE IS NULL) OR (SP.CLIENTE_ID=@CLIENTE))
							AND	((@VH IS NULL) OR(SP.POSICION_COD IN(	SELECT 	POSICION_COD
																		FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																				INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																				INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																		WHERE 	VEHICULO_ID=@VH
																		UNION 
																		SELECT 	NAVE_COD AS POSICION_COD
																		FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																				ON(V.NAVE_ID=N2.NAVE_ID)
																		WHERE	VEHICULO_ID=@VH)))

				GROUP BY	SP.VIAJE_ID, SP.PRODUCTO_ID,SP.DESCRIPCION, SP.RUTA,
							CAST(CASE ISNULL(CP.FLG_RECORRIDO_PALLET_FINAL,'0')	WHEN '1' THEN (CASE ISNUMERIC(SP.TIPO_CAJA) WHEN 1 THEN (CASE SP.TIPO_CAJA WHEN 0 THEN 9999 ELSE SP.TIPO_CAJA END) ELSE 9999 END) ELSE 9999 END AS INT),
							SP.PROP1,PROD.UNIDAD_ID, PROD.VAL_COD_EGR,SP.CLIENTE_ID,POS.ORDEN_PICKING, CP.FLG_SOLICITA_LOTE
							,CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END,SP.NRO_SERIE,DD.NRO_BULTO
							,DD.NRO_LOTE, DD.NRO_PARTIDA, DD.NRO_SERIE, SP.POSICION_COD
				ORDER BY	SP.RUTA,
							CAST(CASE ISNULL(CP.FLG_RECORRIDO_PALLET_FINAL,'0')	WHEN '1' THEN (CASE ISNUMERIC(SP.TIPO_CAJA) WHEN 1 THEN (CASE SP.TIPO_CAJA WHEN 0 THEN 9999 ELSE SP.TIPO_CAJA END) ELSE 9999 END) ELSE 9999 END AS INT) ASC,
							POS.ORDEN_PICKING, SP.POSICION_COD ASC, SP.PRODUCTO_ID
				

				UPDATE 	PICKING SET FECHA_INICIO = GETDATE(),USUARIO=UPPER(LTRIM(RTRIM(@USUARIO))),PALLET_PICKING=@PALLET_I,
						VEHICULO_ID=@VH	
				FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
						ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
				WHERE  	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID))) AND P.PRODUCTO_ID=@PRODUCTO_ID 
						--AND P.DESCRIPCION=@DESCRIPCION 
						AND POSICION_COD=@POSICION_COD
						AND FLG_PALLET_HOMBRE = TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
						AND ((ISNULL(@PALLET,'1') IS NULL) OR(LTRIM(RTRIM(UPPER(ISNULL(P.PROP1,'1')))) = LTRIM(RTRIM(UPPER(ISNULL(@PALLET,'1'))))))
						AND ((ISNULL(@LOTEPROVEEDOR,'1') IS NULL) OR (ISNULL(DD.NRO_LOTE,'1')=ISNULL(@LOTEPROVEEDOR,'1')))
						AND ((ISNULL(@NRO_PARTIDA,'XFFF') IS NULL) OR (ISNULL(DD.NRO_PARTIDA,'XFFF')=ISNULL(@NRO_PARTIDA,'XFFF')))
						AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
						AND FECHA_INICIO IS NULL 
						AND FECHA_FIN IS NULL 
						AND CANT_CONFIRMADA IS NULL 
						AND PALLET_PICKING IS NULL
						AND	((@VH IS NULL OR @VH = '') OR(	POSICION_COD IN(SELECT 	POSICION_COD
																			FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																					INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																					INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																			WHERE 	VEHICULO_ID=@VH
																			UNION 
																			SELECT 	NAVE_COD AS POSICION_COD
																			FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																					ON(V.NAVE_ID=N2.NAVE_ID)
																			WHERE	VEHICULO_ID=@VH)))
						AND (ISNULL(@NRO_SERIE_STOCK,'1') IS NULL OR ISNULL(P.NRO_SERIE,'1') = ISNULL(@NRO_SERIE_STOCK,'1'))
						AND (ISNULL(@NRO_CONTENEDORA,'1') IS NULL OR (ISNULL(DD.NRO_BULTO,'1') = ISNULL(@NRO_CONTENEDORA,'1')))
						--AND P.NRO_LINEA =@NRO_LINEA
						--Catalina Castillo.Tracker 4741
						--AND P.PICKING_ID=@PICKING_ID 


				IF @PRODUCTO_ID IS NOT NULL 
					BEGIN
						SELECT 	@VIAJEID AS VIAJE_ID,@PRODUCTO_ID AS PRODUCTO_ID, @DESCRIPCION AS DESCRIPCION, 
								@QTY AS QTY, @POSICION_COD AS POSICION_COD, @PALLET AS PALLET,@RUTA AS RUTA,
								@UNIDAD_ID AS UNIDAD_ID, @VAL_COD_EGR AS VAL_COD_EGR,@CLIENTE_ID AS CLIENTE_ID,
								@NRO_LOTE AS NRO_LOTE,
								@NRO_SERIE_STOCK AS NRO_SERIE_STOCK,	
								@NRO_CONTENEDORA AS NRO_CONTENEDORA,
								@LOTEPROVEEDOR AS LOTE_PROVEEDOR,
								@NRO_PARTIDA AS NRO_PARTIDA,
								@NRO_SERIE AS NRO_SERIE
						RETURN
					END
						
				END --FIN TQUERY=2
			ELSE 
				BEGIN
					IF @TQUERY='3'
						BEGIN
							SELECT 		TOP 1
										@VIAJEID=SP.VIAJE_ID, @PRODUCTO_ID=SP.PRODUCTO_ID, 
										@DESCRIPCION=SP.DESCRIPCION, @QTY=SUM(SP.CANTIDAD),@POSICION_COD= SP.POSICION_COD,
										@PALLET = SP.PROP1,@RUTA=SP.RUTA
										,@UNIDAD_ID=PROD.UNIDAD_ID, @VAL_COD_EGR=PROD.VAL_COD_EGR,
										@CLIENTE_ID = SP.CLIENTE_ID,
										@NRO_LOTE=CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END,
										@NRO_SERIE_STOCK = SP.NRO_SERIE,--@NRO_LINEA= SP.NRO_LINEA, --LO AGREGUE PARA QUE ACTUALICE POR NRO_LINEA Y NO TODAS LAS TAREAS
										@NRO_CONTENEDORA =DD.NRO_BULTO
										,@LOTEPROVEEDOR = DD.NRO_LOTE,@NRO_PARTIDA=DD.NRO_PARTIDA, @NRO_SERIE = DD.NRO_SERIE
							FROM 		PICKING SP
										LEFT JOIN POSICION POS ON(SP.POSICION_COD=POS.POSICION_COD)
										INNER JOIN PRIORIDAD_VIAJE SPV
										ON(LTRIM(RTRIM(UPPER(SPV.VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID))))
										INNER JOIN PRODUCTO PROD
										ON(PROD.CLIENTE_ID=SP.CLIENTE_ID AND PROD.PRODUCTO_ID=SP.PRODUCTO_ID)
										INNER JOIN RL_SYS_CLIENTE_USUARIO SU ON(SP.CLIENTE_ID=SU.CLIENTE_ID)
										INNER JOIN DET_DOCUMENTO DD ON(SP.DOCUMENTO_ID=DD.DOCUMENTO_ID AND SP.NRO_LINEA=DD.NRO_LINEA)
										INNER JOIN CLIENTE C ON(SP.CLIENTE_ID=C.CLIENTE_ID)
										INNER JOIN CLIENTE_PARAMETROS CP ON(C.CLIENTE_ID=CP.CLIENTE_ID)
							WHERE 		SP.FECHA_INICIO IS NULL
										AND ((CP.FLG_ACTIVA_PC_PN='0') OR (DBO.VERIFICA_PALLET_FINAL(SP.POSICION_COD,SP.VIAJE_ID,SP.RUTA, SP.PROP1)=@PALLETCOMPLETO))
										AND SP.FLG_PALLET_HOMBRE = SP.TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
										AND	SP.FECHA_FIN IS NULL			
										AND	SP.USUARIO IS NULL
										AND	SP.CANT_CONFIRMADA IS NULL
										AND SPV.PRIORIDAD = (	SELECT 	MIN(PRIORIDAD)
																FROM	PRIORIDAD_VIAJE
																WHERE	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID))))
										AND SU.USUARIO_ID=@USUARIO
										AND	SP.VIAJE_ID IN (SELECT 	VIAJE_ID
															FROM  	RL_VIAJE_USUARIO
															WHERE 	VIAJE_ID=SP.VIAJE_ID
																	AND
																	USUARIO_ID =@USUARIO)
										AND SP.NAVE_COD	IN(	SELECT 	NAVE_COD
															FROM 	NAVE N INNER JOIN RL_USUARIO_NAVE RLNU
																	ON(N.NAVE_ID=RLNU.NAVE_ID)
															WHERE	N.NAVE_COD=SP.NAVE_COD
																	AND RLNU.USUARIO_ID=@USUARIO
															)
										AND LTRIM(RTRIM(UPPER(SP.VIAJE_ID)))=UPPER(LTRIM(RTRIM(@VIAJE_ID)))
										AND ((@CLIENTE IS NULL) OR (SP.CLIENTE_ID=@CLIENTE))
										AND
										((@VH IS NULL) OR(SP.POSICION_COD IN(	SELECT 	POSICION_COD
																				FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																						INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																						INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																				WHERE 	VEHICULO_ID=@VH
																				UNION 
																				SELECT 	NAVE_COD AS POSICION_COD
																				FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																						ON(V.NAVE_ID=N2.NAVE_ID)
																				WHERE	VEHICULO_ID=@VH)))
																				
										AND SP.SALTO_PICKING = (	SELECT 	MIN(ISNULL(SALTO_PICKING,0))
																	FROM 	PICKING 
																	WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJE_ID)))
																			AND FECHA_INICIO IS NULL
																			AND FECHA_FIN IS NULL
																			AND CANT_CONFIRMADA IS NULL
																			AND ((@TOMARUTA='0') OR(
																			LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA_I))))))
																
							GROUP BY	SP.VIAJE_ID, SP.PRODUCTO_ID, SP.DESCRIPCION, SP.RUTA,SP.POSICION_COD, 
							
										CAST(CASE ISNULL(CP.FLG_RECORRIDO_PALLET_FINAL,'0')	WHEN '1' THEN (CASE ISNUMERIC(SP.TIPO_CAJA) WHEN 1 THEN (CASE SP.TIPO_CAJA WHEN 0 THEN 9999 ELSE SP.TIPO_CAJA END) ELSE 9999 END) ELSE 9999 END AS INT)
										, SP.PROP1,
										PROD.UNIDAD_ID, PROD.VAL_COD_EGR, SP.CLIENTE_ID,POS.ORDEN_PICKING,CP.FLG_SOLICITA_LOTE, --DD.PROP2
										CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END,SP.NRO_SERIE,DD.NRO_BULTO
										,DD.NRO_LOTE,DD.NRO_PARTIDA,DD.NRO_SERIE
							ORDER BY	SP.RUTA,
										CAST(CASE ISNULL(CP.FLG_RECORRIDO_PALLET_FINAL,'0')	WHEN '1' THEN (CASE ISNUMERIC(SP.TIPO_CAJA) WHEN 1 THEN (CASE SP.TIPO_CAJA WHEN 0 THEN 9999 ELSE SP.TIPO_CAJA END) ELSE 9999 END) ELSE 9999 END AS INT)ASC,
										POS.ORDEN_PICKING, SP.POSICION_COD ASC, SP.PRODUCTO_ID
										
							if @tomaruta='1'
							begin
							DECLARE T_RUTA CURSOR FOR
								SELECT 	PICKING_ID
								FROM	PICKING P
								WHERE	P.NAVE_COD IN(	SELECT 	NAVE_COD
														FROM 	NAVE N INNER JOIN RL_USUARIO_NAVE RLNU
																ON(N.NAVE_ID=RLNU.NAVE_ID)
														WHERE	N.NAVE_COD=P.NAVE_COD
																AND RLNU.USUARIO_ID=@USUARIO)
																AND LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
																AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
																AND ((@PALLETCOMP='0') OR (DBO.VERIFICA_PALLET_FINAL(P.POSICION_COD,P.VIAJE_ID,P.RUTA, P.PROP1)=@PALLETCOMPLETO))
																AND	((@VH IS NULL) OR(	POSICION_COD IN(SELECT 	POSICION_COD
																										FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																												INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																												INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																										WHERE 	VEHICULO_ID=@VH
																										UNION 
																										SELECT 	NAVE_COD AS POSICION_COD
																										FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																												ON(V.NAVE_ID=N2.NAVE_ID)
																										WHERE	VEHICULO_ID=@VH)))
				
							OPEN T_RUTA
							FETCH NEXT FROM T_RUTA INTO @PICKING_ID
							WHILE @@FETCH_STATUS=0 
								BEGIN
								If 0=0 
									Begin
										UPDATE PICKING SET USUARIO =@USUARIO 
										WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
												AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
												AND PICKING_ID=@PICKING_ID
												AND
												((@VH IS NULL) OR(	POSICION_COD IN(	SELECT 	POSICION_COD
																						FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																								INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																								INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																						WHERE 	VEHICULO_ID=@VH
																						UNION 
																						SELECT 	NAVE_COD AS POSICION_COD
																						FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																								ON(V.NAVE_ID=N2.NAVE_ID)
																						WHERE	VEHICULO_ID=@VH)))

										FETCH NEXT FROM T_RUTA INTO @PICKING_ID
									End
								END
				
								CLOSE T_RUTA
								DEALLOCATE T_RUTA
							END
							UPDATE 	PICKING SET FECHA_INICIO = GETDATE(),USUARIO=UPPER(LTRIM(RTRIM(@USUARIO))),PALLET_PICKING=@PALLET_I,
									VEHICULO_ID=@VH	
							FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
									ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
							WHERE  	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
									AND FLG_PALLET_HOMBRE = TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
									AND P.PRODUCTO_ID=@PRODUCTO_ID 
									--AND P.DESCRIPCION=@DESCRIPCION 
									AND POSICION_COD=@POSICION_COD
									AND ((ISNULL(@LOTEPROVEEDOR,'1') IS NULL) OR (ISNULL(DD.NRO_LOTE,'1')=ISNULL(@LOTEPROVEEDOR,'1')))
									AND ((ISNULL(@NRO_PARTIDA,'XFFF') IS NULL) OR (ISNULL(DD.NRO_PARTIDA,'XFFF')=ISNULL(@NRO_PARTIDA,'XFFF')))
									AND ((ISNULL(@PALLET,'1') IS NULL) OR(LTRIM(RTRIM(UPPER(ISNULL(P.PROP1,'1')))) = LTRIM(RTRIM(UPPER(ISNULL(@PALLET,'1'))))))
									AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
									AND	((@VH IS NULL OR @VH='') OR(POSICION_COD IN(SELECT 	POSICION_COD
																					FROM 	RL_VEHICULO_POSICION V INNER JOIN POSICION P ON(V.POSICION_ID=P.POSICION_ID)
																							INNER JOIN CALLE_NAVE CN ON(P.CALLE_ID=CN.CALLE_ID)
																							INNER JOIN NAVE NAV ON(P.NAVE_ID=NAV.NAVE_ID)
																					WHERE 	VEHICULO_ID=@VH
																					UNION 
																					SELECT 	NAVE_COD AS POSICION_COD
																					FROM	RL_VEHICULO_POSICION V INNER JOIN NAVE N2
																							ON(V.NAVE_ID=N2.NAVE_ID)
																					WHERE	VEHICULO_ID=@VH)))
									AND (ISNULL(@NRO_SERIE_STOCK,'1') IS NULL OR ISNULL(P.NRO_SERIE,'1') = ISNULL(@NRO_SERIE_STOCK,'1'))
									AND (ISNULL(@NRO_CONTENEDORA,'1') IS NULL OR ISNULL(DD.NRO_BULTO,'1') = ISNULL(@NRO_CONTENEDORA,'1'))


							IF @PRODUCTO_ID IS NOT NULL 
							BEGIN
								SELECT 	@VIAJEID AS VIAJE_ID,@PRODUCTO_ID AS PRODUCTO_ID, @DESCRIPCION AS DESCRIPCION, 
										@QTY AS QTY, @POSICION_COD AS POSICION_COD, @PALLET AS PALLET,@RUTA AS RUTA,
										@UNIDAD_ID AS UNIDAD_ID, @VAL_COD_EGR AS VAL_COD_EGR,@CLIENTE_ID AS CLIENTE_ID,
										@NRO_LOTE AS NRO_LOTE,
										@NRO_SERIE_STOCK AS NRO_SERIE_STOCK,	
										@NRO_CONTENEDORA AS NRO_CONTENEDORA
										,@LOTEPROVEEDOR AS LOTE_PROVEEDOR
										,@NRO_PARTIDA AS NRO_PARTIDA
										,@NRO_SERIE AS NRO_SERIE										
					END
				END
			END 
		END--END ELSE
	
END-- FIN PROCEDURE















GO


