
/****** Object:  StoredProcedure [dbo].[FUNCIONES_INVENTARIO_API#CREA_DATOS_AJUS]    Script Date: 04/10/2015 11:28:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FUNCIONES_INVENTARIO_API#CREA_DATOS_AJUS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FUNCIONES_INVENTARIO_API#CREA_DATOS_AJUS]
GO

CREATE PROCEDURE [dbo].[FUNCIONES_INVENTARIO_API#CREA_DATOS_AJUS]
	@P_DOC_TRANS_ID AS NUMERIC(20) output
AS
BEGIN
	
	DECLARE @V_INVENTARIO_ID AS NUMERIC(20)
	DECLARE @V_INV_ID AS NUMERIC(20)
	DECLARE @V_MARBETE_ID AS NUMERIC(20)
	DECLARE @V_F_CREADATAJU AS DATETIME
	DECLARE @V_F_LOCKGRABA AS DATETIME
	DECLARE @V_LOCKGRABA AS VARCHAR(1)
	DECLARE @V_CONT AS NUMERIC(20)
	DECLARE @V_CONT2 AS NUMERIC(20)
	DECLARE @V_NAVE_ID AS NUMERIC(20)
	DECLARE @V_POSICION_ID AS NUMERIC(20)
	DECLARE @V_CLIENTE_ID	AS VARCHAR(15)
	DECLARE @V_PRODUCTO_ID AS VARCHAR(30)
	DECLARE @V_CONTEO1 AS NUMERIC(20,5)
	DECLARE @V_CONTEO2 AS NUMERIC(20,5)
	DECLARE @V_CONTEO3 AS NUMERIC(20,5)
	DECLARE @V_CANT_STOCK_CONT_1 AS NUMERIC(20,5)
	DECLARE @V_CANT_STOCK_CONT_2 AS NUMERIC(20,5)
	DECLARE @V_CANT_STOCK_CONT_3 AS NUMERIC(20,5)
	DECLARE @V_DIFF AS NUMERIC(20,5)
	DECLARE @S_TRACK AS VARCHAR(15)
	DECLARE @V_CERRADO AS VARCHAR(1)

	SET XACT_ABORT ON

	BEGIN TRY
	
		SELECT @V_INVENTARIO_ID = INVENTARIO_ID, @V_F_CREADATAJU = F_CREADATAJU, @V_F_LOCKGRABA= F_LOCKGRABA, @V_LOCKGRABA = LOCKGRABA, @V_CERRADO = CERRADO
		FROM INVENTARIO WHERE DOC_TRANS_ID  =@P_DOC_TRANS_ID

		IF @V_CERRADO <> 1
			BEGIN
				BEGIN TRAN

					SELECT	@V_CONT = COUNT(I.INVENTARIO_ID)
						FROM	DET_CONTEO D
								INNER JOIN DET_INVENTARIO I ON (I.INVENTARIO_ID = D.INVENTARIO_ID AND I.MARBETE = D.MARBETE)				
						WHERE	D.INVENTARIO_ID = @V_INVENTARIO_ID
							--AND (((ISNULL(D.CONTEO3, ISNULL(D.CONTEO2, D.CONTEO1)) - I.CANTIDAD) <> 0 AND  MODO_INGRESO = 'S') or (MODO_INGRESO = 'M'))				   
							--AND NOT EXISTS (SELECT * FROM DET_INVENTARIO_AJU DA WHERE DA.INVENTARIO_ID = I.INVENTARIO_ID AND DA.MARBETE = I.MARBETE)

					IF @V_CONT > 0 
						BEGIN
							DECLARE CUR CURSOR FOR 
								SELECT	D.INVENTARIO_ID, D.MARBETE, D.NAVE_ID, D.POSICION_ID, D.CLIENTE_ID, D.PRODUCTO_ID,
										I.CANT_STOCK_CONT_1, I.CANT_STOCK_CONT_2,I.CANT_STOCK_CONT_3, D.CONTEO1, D.CONTEO2, D.CONTEO3
								FROM	DET_CONTEO D
										INNER JOIN DET_INVENTARIO I ON (I.INVENTARIO_ID = D.INVENTARIO_ID AND I.MARBETE = D.MARBETE)				
								WHERE	D.INVENTARIO_ID = @V_INVENTARIO_ID 
								   --AND (((ISNULL(D.CONTEO3, ISNULL(D.CONTEO2, D.CONTEO1)) - I.CANTIDAD) <> 0 AND  MODO_INGRESO = 'S') or (MODO_INGRESO = 'M'))
								   --AND NOT EXISTS (SELECT * FROM DET_INVENTARIO_AJU DA WHERE DA.INVENTARIO_ID = I.INVENTARIO_ID AND DA.MARBETE = I.MARBETE)
										
							
							OPEN CUR 
							FETCH NEXT FROM CUR INTO @V_INV_ID, @V_MARBETE_ID, @V_NAVE_ID, @V_POSICION_ID, @V_CLIENTE_ID, @V_PRODUCTO_ID, 
													@V_CANT_STOCK_CONT_1, @V_CANT_STOCK_CONT_2, @V_CANT_STOCK_CONT_3, @V_CONTEO1, @V_CONTEO2, @V_CONTEO3 
							
							WHILE @@FETCH_STATUS = 0
							BEGIN
								
								SET @V_DIFF=0
								
								IF @V_CONTEO3 IS NOT NULL 
									BEGIN
										SET @V_DIFF = @V_CONTEO3 - @V_CANT_STOCK_CONT_3	
										SET @S_TRACK= 3							
									END												
								ELSE IF @V_CONTEO2 IS NOT NULL											
									BEGIN
										SET @V_DIFF = @V_CONTEO2 - @V_CANT_STOCK_CONT_2
										SET @S_TRACK= 2
									END 
								ELSE IF @V_CONTEO1 IS NOT NULL
									BEGIN
										SET @V_DIFF = @V_CONTEO1 - @V_CANT_STOCK_CONT_1
										SET @S_TRACK= 1
									END																						
																
								SELECT @V_CONT2 = COUNT(INVENTARIO_ID) FROM DET_INVENTARIO_AJU WHERE INVENTARIO_ID = @V_INVENTARIO_ID AND MARBETE = @V_MARBETE_ID
								
								IF @V_CONT2 = 0
									BEGIN
										IF @V_DIFF <> 0																	
											BEGIN
												INSERT INTO DET_INVENTARIO_AJU 
												(INVENTARIO_ID, MARBETE, NAVE_ID, POSICION_ID, CLIENTE_ID, PRODUCTO_ID, CANT_AJU, PROCESADO)
												VALUES (@V_INVENTARIO_ID, @V_MARBETE_ID, @V_NAVE_ID, @V_POSICION_ID, @V_CLIENTE_ID, @V_PRODUCTO_ID, @V_DIFF, 'N')
											END
									END									
								ELSE IF @V_CONT2 > 0														
									BEGIN	
										IF @V_DIFF = 0
											BEGIN
												DELETE FROM DET_INVENTARIO_AJU WHERE INVENTARIO_ID = @V_INVENTARIO_ID AND MARBETE = @V_MARBETE_ID
												--INSERT INTO DET_INVENTARIO_AJU (INVENTARIO_ID, MARBETE, NAVE_ID, POSICION_ID, CLIENTE_ID, PRODUCTO_ID, CANT_AJU, PROCESADO, PROCESADO2)
												--VALUES (@V_INVENTARIO_ID, @V_MARBETE_ID, @V_NAVE_ID, @V_POSICION_ID, @V_CLIENTE_ID, @V_PRODUCTO_ID, @V_DIFF, 'U', @S_TRACK)
											END
										ELSE IF @V_DIFF <> 0
											BEGIN																	
												UPDATE DET_INVENTARIO_AJU SET CANT_AJU = @V_DIFF  
												WHERE INVENTARIO_ID = @V_INVENTARIO_ID AND MARBETE = @V_MARBETE_ID
											END																									
									END								
														
								FETCH NEXT FROM CUR INTO @V_INV_ID, @V_MARBETE_ID, @V_NAVE_ID, @V_POSICION_ID, @V_CLIENTE_ID, @V_PRODUCTO_ID, 
													@V_CANT_STOCK_CONT_1, @V_CANT_STOCK_CONT_2, @V_CANT_STOCK_CONT_3, @V_CONTEO1, @V_CONTEO2, @V_CONTEO3 
													
							END

							CLOSE CUR
							DEALLOCATE CUR	
			
						END	

				UPDATE INVENTARIO SET F_CREADATAJU = GETDATE() WHERE INVENTARIO_ID = @V_INVENTARIO_ID
			
    		COMMIT
		END

	END TRY
	
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK			
		EXEC usp_RethrowError
		CLOSE CUR
		DEALLOCATE CUR	
	END CATCH

END --PROCEDURE

GO
