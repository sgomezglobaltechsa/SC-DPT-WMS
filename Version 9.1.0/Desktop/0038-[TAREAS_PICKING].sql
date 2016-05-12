

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TAREAS_PICKING]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TAREAS_PICKING]
GO

CREATE PROCEDURE [dbo].[TAREAS_PICKING]
	@USUARIO 			AS VARCHAR(30),
	@VIAJE_ID 			AS VARCHAR(100),
	@PALLET_I			AS VARCHAR(30),
	@RUTA_I				AS VARCHAR(100),
	@CLIENTE			AS VARCHAR(30)=NULL,
	@VH					AS VARCHAR(40)=NULL,
	@PALLETCOMPLETO		AS NUMERIC(10)
AS
	DECLARE @VERIFICACION 	AS NUMERIC(20)
	DECLARE @VIAJEID 		AS VARCHAR(30)
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

	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

	BEGIN

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
			SELECT @VERIFICACION= Dbo.Fx_Fin_Viaje_Usuario(@VIAJE_ID,@USUARIO)
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
				IF @VERIFICACION=1	
				BEGIN
					RAISERROR('2',16,1)
					Return(99)
				END
			END	
		END
	END --FIN VERIFICACIONES.


	RAISERROR('RUTA %s',16,1,@RUTA_I);
	RETURN
	
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

	IF @TQUERY='1'
		BEGIN

			SELECT 		TOP 1
						@VIAJEID=SP.VIAJE_ID, @PRODUCTO_ID=SP.PRODUCTO_ID, 
						@DESCRIPCION=SP.DESCRIPCION, @QTY=SUM(SP.CANTIDAD),@POSICION_COD= SP.POSICION_COD,
						@PALLET = SP.PROP1,@RUTA=SP.RUTA,@UNIDAD_ID=PROD.UNIDAD_ID, @VAL_COD_EGR=PROD.VAL_COD_EGR,
						@CLIENTE_ID = SP.CLIENTE_ID,
						@NRO_LOTE=CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END
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
			WHERE 		SPV.PRIORIDAD = (	SELECT 	MIN(PRIORIDAD)
											FROM	PRIORIDAD_VIAJE
											WHERE	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID)))											)								
														AND SU.USUARIO_ID=@USUARIO
						AND (DBO.VERIFICA_PALLET_FINAL(SP.POSICION_COD,SP.VIAJE_ID,SP.RUTA, SP.PROP1)=@PALLETCOMPLETO)
						AND SP.FLG_PALLET_HOMBRE = SP.TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
						AND	SP.FECHA_INICIO IS NULL
						AND	SP.FECHA_FIN IS NULL			
						AND	SP.USUARIO IS NULL
						AND	SP.CANT_CONFIRMADA IS NULL 
						AND	SP.VIAJE_ID IN (SELECT 	VIAJE_ID
											FROM  	RL_VIAJE_USUARIO
											WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID)))
													AND
													LTRIM(RTRIM(UPPER(USUARIO_ID))) =LTRIM(RTRIM(UPPER(@USUARIO)))
						AND SP.NAVE_COD	IN(	SELECT 	
													NAVE_COD
											FROM 	NAVE N INNER JOIN RL_USUARIO_NAVE RLNU
													ON(N.NAVE_ID=RLNU.NAVE_ID)
											WHERE	N.NAVE_COD=SP.NAVE_COD
													AND LTRIM(RTRIM(UPPER(RLNU.USUARIO_ID)))=LTRIM(RTRIM(UPPER(@USUARIO)))
											)
												)
						AND SP.FIN_PICKING <>'2'
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
			GROUP BY	SP.VIAJE_ID, SP.PRODUCTO_ID,SP.DESCRIPCION, SP.RUTA,SP.POSICION_COD,SP.TIPO_CAJA,SP.PROP1,PROD.UNIDAD_ID
						,SPV.PRIORIDAD, PROD.VAL_COD_EGR,SP.CLIENTE_ID, POS.ORDEN_PICKING,CP.FLG_SOLICITA_LOTE, DD.PROP2
			ORDER BY	SPV.PRIORIDAD ASC,CAST(SP.TIPO_CAJA AS NUMERIC(10,1)) DESC, POS.ORDEN_PICKING, SP.POSICION_COD ASC, SP.PRODUCTO_ID,
						DD.PROP2

			UPDATE 	PICKING SET FECHA_INICIO = GETDATE(),USUARIO=UPPER(LTRIM(RTRIM(@USUARIO))),PALLET_PICKING=@PALLET_I,
					VEHICULO_ID=@VH		
			FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
					ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)			
			WHERE  	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID )))
					AND LTRIM(RTRIM(UPPER(P.PRODUCTO_ID)))=LTRIM(RTRIM(UPPER(@PRODUCTO_ID)))
					AND LTRIM(RTRIM(UPPER(P.DESCRIPCION)))=LTRIM(RTRIM(UPPER(@DESCRIPCION)))
					AND FLG_PALLET_HOMBRE = TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
					AND LTRIM(RTRIM(UPPER(P.POSICION_COD)))=LTRIM(RTRIM(UPPER(@POSICION_COD)))
					AND ((@PALLET IS NULL) OR(LTRIM(RTRIM(UPPER(P.PROP1))) = LTRIM(RTRIM(UPPER(@PALLET)))))
					AND LTRIM(RTRIM(UPPER(P.RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
					AND ((@NRO_LOTE IS NULL) OR (DD.PROP2=@NRO_LOTE))
					AND ((@VH IS NULL) 
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

			DECLARE T_RUTA CURSOR FOR
				SELECT 	PICKING_ID
				FROM	PICKING P
				WHERE	P.NAVE_COD IN(SELECT 	
											NAVE_COD
									FROM 	NAVE N INNER JOIN RL_USUARIO_NAVE RLNU
											ON(N.NAVE_ID=RLNU.NAVE_ID)
									WHERE	N.NAVE_COD=P.NAVE_COD
											AND RLNU.USUARIO_ID=@USUARIO)
											AND LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
											AND (DBO.VERIFICA_PALLET_FINAL(P.POSICION_COD,P.VIAJE_ID,P.RUTA, P.PROP1)=@PALLETCOMPLETO)
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
								AND (DBO.VERIFICA_PALLET_FINAL(@POSICION_COD,@VIAJEID,@RUTA, @PALLET)=@PALLETCOMPLETO)
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

			IF @PRODUCTO_ID IS NOT NULL 
			BEGIN
				SELECT 	@VIAJEID AS VIAJE_ID,@PRODUCTO_ID AS PRODUCTO_ID, @DESCRIPCION AS DESCRIPCION, 
						@QTY AS QTY, @POSICION_COD AS POSICION_COD, @PALLET AS PALLET,@RUTA AS RUTA,
						@UNIDAD_ID AS UNIDAD_ID,@VAL_COD_EGR AS VAL_COD_EGR,@CLIENTE_ID AS CLIENTE_ID,
						@NRO_LOTE AS NRO_LOTE
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
							@PALLET = SP.PROP1,@RUTA=SP.RUTA,@UNIDAD_ID=PROD.UNIDAD_ID, @VAL_COD_EGR=PROD.VAL_COD_EGR,
							@CLIENTE_ID = SP.CLIENTE_ID,
							@NRO_LOTE=CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END
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
							AND (DBO.VERIFICA_PALLET_FINAL(SP.POSICION_COD,SP.VIAJE_ID,SP.RUTA, SP.PROP1)=@PALLETCOMPLETO)
							AND	SP.FECHA_FIN IS NULL			
							AND SP.CANT_CONFIRMADA IS NULL
							AND SU.USUARIO_ID=@USUARIO
							AND SP.FLG_PALLET_HOMBRE = SP.TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
							AND UPPER(LTRIM(RTRIM(SP.USUARIO)))=Ltrim(Rtrim(Upper(@Usuario)))
							AND	UPPER(LTRIM(RTRIM(SP.VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJE_ID)))
							and
							SP.VIAJE_ID IN (SELECT 	VIAJE_ID
											FROM  	RL_VIAJE_USUARIO
											WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(SP.VIAJE_ID)))													AND
													LTRIM(RTRIM(UPPER(USUARIO_ID))) =LTRIM(RTRIM(UPPER(@USUARIO))))							AND SP.SALTO_PICKING = (	SELECT 	MIN(ISNULL(SALTO_PICKING,0))
														FROM 	PICKING 
														WHERE 	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJE_ID)))
																AND FECHA_INICIO IS NULL
																AND USUARIO=SP.USUARIO
																AND FECHA_FIN IS NULL
																AND CANT_CONFIRMADA IS NULL
																AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA_I)))
													)
		
							AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA_I)))
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

				GROUP BY	SP.VIAJE_ID, SP.PRODUCTO_ID,SP.DESCRIPCION, SP.RUTA,SP.POSICION_COD,SP.TIPO_CAJA,SP.PROP1,PROD.UNIDAD_ID, PROD.VAL_COD_EGR,SP.CLIENTE_ID,POS.ORDEN_PICKING,
							CP.FLG_SOLICITA_LOTE,DD.PROP2
				ORDER BY	CAST(SP.TIPO_CAJA AS NUMERIC(10,1)) DESC,POS.ORDEN_PICKING, SP.POSICION_COD ASC, SP.PRODUCTO_ID,
							DD.PROP2
				

				UPDATE 	PICKING SET FECHA_INICIO = GETDATE(),USUARIO=UPPER(LTRIM(RTRIM(@USUARIO))),PALLET_PICKING=@PALLET_I,
						VEHICULO_ID=@VH	
				FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
						ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
				WHERE  	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID))) AND P.PRODUCTO_ID=@PRODUCTO_ID 
						AND P.DESCRIPCION=@DESCRIPCION AND POSICION_COD=@POSICION_COD
						AND FLG_PALLET_HOMBRE = TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
						AND ((@PALLET IS NULL) OR(LTRIM(RTRIM(UPPER(P.PROP1))) = LTRIM(RTRIM(UPPER(@PALLET)))))
						AND ((@NRO_LOTE IS NULL)OR(DD.PROP2=@NRO_LOTE))
						AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA_I)))
						AND FECHA_INICIO IS NULL AND FECHA_FIN IS NULL AND CANT_CONFIRMADA IS NULL AND PALLET_PICKING IS NULL
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


				IF @PRODUCTO_ID IS NOT NULL 
					BEGIN
						SELECT 	@VIAJEID AS VIAJE_ID,@PRODUCTO_ID AS PRODUCTO_ID, @DESCRIPCION AS DESCRIPCION, 
								@QTY AS QTY, @POSICION_COD AS POSICION_COD, @PALLET AS PALLET,@RUTA AS RUTA,
								@UNIDAD_ID AS UNIDAD_ID, @VAL_COD_EGR AS VAL_COD_EGR,@CLIENTE_ID AS CLIENTE_ID,
								@NRO_LOTE AS NRO_LOTE
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
										@PALLET = SP.PROP1,@RUTA=SP.RUTA,@UNIDAD_ID=PROD.UNIDAD_ID, @VAL_COD_EGR=PROD.VAL_COD_EGR,
										@CLIENTE_ID = SP.CLIENTE_ID,
										@NRO_LOTE=CASE WHEN CP.FLG_SOLICITA_LOTE='1' THEN ISNULL(DD.PROP2,NULL) ELSE NULL END
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
										AND (DBO.VERIFICA_PALLET_FINAL(SP.POSICION_COD,SP.VIAJE_ID,SP.RUTA, SP.PROP1)=@PALLETCOMPLETO)
										AND SP.FLG_PALLET_HOMBRE = SP.TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
										AND	SP.FECHA_FIN IS NULL			
										AND	SP.USUARIO IS NULL
										AND	SP.CANT_CONFIRMADA IS NULL
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

							GROUP BY	SP.VIAJE_ID, SP.PRODUCTO_ID, SP.DESCRIPCION, SP.RUTA, SP.POSICION_COD, SP.TIPO_CAJA, SP.PROP1,PROD.UNIDAD_ID, PROD.VAL_COD_EGR, SP.CLIENTE_ID,POS.ORDEN_PICKING,
										CP.FLG_SOLICITA_LOTE, DD.PROP2
							ORDER BY	CAST(SP.TIPO_CAJA AS NUMERIC(10,1)) DESC,POS.ORDEN_PICKING, SP.POSICION_COD ASC, SP.PRODUCTO_ID,
										DD.PROP2

							DECLARE T_RUTA CURSOR FOR
								SELECT 	PICKING_ID
								FROM	PICKING P
								WHERE	P.NAVE_COD IN(SELECT 	
															NAVE_COD
													FROM 	NAVE N INNER JOIN RL_USUARIO_NAVE RLNU
															ON(N.NAVE_ID=RLNU.NAVE_ID)
													WHERE	N.NAVE_COD=P.NAVE_COD
															AND RLNU.USUARIO_ID=@USUARIO)
										AND LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
										AND (DBO.VERIFICA_PALLET_FINAL(P.POSICION_COD,P.VIAJE_ID,P.RUTA, P.PROP1)=@PALLETCOMPLETO)
										AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
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

							UPDATE 	PICKING SET FECHA_INICIO = GETDATE(),USUARIO=UPPER(LTRIM(RTRIM(@USUARIO))),PALLET_PICKING=@PALLET_I,
									VEHICULO_ID=@VH	
							FROM	PICKING P INNER JOIN DET_DOCUMENTO DD
									ON(P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA=DD.NRO_LINEA)
							WHERE  	LTRIM(RTRIM(UPPER(VIAJE_ID)))=LTRIM(RTRIM(UPPER(@VIAJEID)))
									AND FLG_PALLET_HOMBRE = TRANSF_TERMINADA -- Agregado Privitera Maximiliano 06/01/2010
									AND P.PRODUCTO_ID=@PRODUCTO_ID 
									AND P.DESCRIPCION=@DESCRIPCION 
									AND POSICION_COD=@POSICION_COD
									AND ((@NRO_LOTE IS NULL)OR(DD.PROP2=@NRO_LOTE))
									AND ((@PALLET IS NULL) OR(LTRIM(RTRIM(UPPER(P.PROP1))) = LTRIM(RTRIM(UPPER(@PALLET)))))
									AND LTRIM(RTRIM(UPPER(RUTA)))=LTRIM(RTRIM(UPPER(@RUTA)))
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


							IF @PRODUCTO_ID IS NOT NULL 
							BEGIN
								SELECT 	@VIAJEID AS VIAJE_ID,@PRODUCTO_ID AS PRODUCTO_ID, @DESCRIPCION AS DESCRIPCION, 
										@QTY AS QTY, @POSICION_COD AS POSICION_COD, @PALLET AS PALLET,@RUTA AS RUTA,
										@UNIDAD_ID AS UNIDAD_ID, @VAL_COD_EGR AS VAL_COD_EGR,@CLIENTE_ID AS CLIENTE_ID,
										@NRO_LOTE AS NRO_LOTE
					END
				END
			END 
		END--END ELSE
	
END-- FIN PROCEDURE
