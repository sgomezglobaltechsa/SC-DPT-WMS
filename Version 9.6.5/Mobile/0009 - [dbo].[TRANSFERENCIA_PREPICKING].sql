IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRANSFERENCIA_PREPICKING]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TRANSFERENCIA_PREPICKING]
GO

CREATE PROCEDURE [dbo].[TRANSFERENCIA_PREPICKING]
@UBICACION_DESTINO	AS VARCHAR(45),
@VIAJE_ID			AS varchar(50),
@TIPO				AS INT
AS
BEGIN

SET XACT_ABORT ON
/*
CREATE TABLE #TEMP_USUARIO_LOGGIN (
	USUARIO_ID            VARCHAR(20)  COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS NOT NULL,
	TERMINAL              VARCHAR(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS NOT NULL,
	FECHA_LOGGIN          DATETIME     ,
	SESSION_ID            VARCHAR(60)  COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS NOT NULL,
	ROL_ID                VARCHAR(5)   COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS NOT NULL,
	EMPLAZAMIENTO_DEFAULT VARCHAR(15)  COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS NULL,
	DEPOSITO_DEFAULT      VARCHAR(15)  COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS NULL
)
	EXEC Funciones_Loggin_Api#Registra_Usuario_Loggin 'ADMIN'
--*/
DECLARE @USUARIO	VARCHAR(50)
DECLARE @TERMINAL VARCHAR(100)
DECLARE @UBICACION_ORIGEN VARCHAR(100)
DECLARE @PALLET VARCHAR(100)
DECLARE @DOCUMENTO_ID NUMERIC(20,0)
DECLARE @DOCUMENTO_ID_PIC NUMERIC(20,0)
DECLARE @CONTENEDORA VARCHAR(50)
DECLARE @NRO_LINEA NUMERIC(10,0)
DECLARE @NRO_LINEA_PIC		AS NUMERIC(10,0)
DECLARE @NAVE				AS VARCHAR(15)
DECLARE @EXISTE				AS NUMERIC(1,0)
DECLARE @RsMovimientos		AS CURSOR
DECLARE @RsSubMovimientos	AS Cursor
DECLARE @RsPicking			AS CURSOR
DECLARE @MSG				AS VARCHAR(MAX)
DECLARE @CONTROL			AS SMALLINT
DECLARE @MTIPO				AS VARCHAR(10)
DECLARE @PALLET_ANT			AS VARCHAR(100)
begin try

	SELECT @USUARIO=USUARIO_ID FROM #TEMP_USUARIO_LOGGIN
	SET @TERMINAL=HOST_NAME()

	Set @RsMovimientos = Cursor For
			SELECT	UBICACION_ORIGEN,USUARIO_ID,PALLET,CONTENEDORA
			FROM	MOVIMIENTOSPREPICKING
			WHERE 	USUARIO_ID = @USUARIO
					--AND TERMINAL = @TERMINAL
					AND VIAJE_ID = @VIAJE_ID

		Open @RsMovimientos
		Fetch Next From @RsMovimientos into	@UBICACION_ORIGEN,
											@USUARIO,
											@PALLET,
											@CONTENEDORA
											
		While @@Fetch_Status=0
		Begin	
			Set @RsSubMovimientos = Cursor For
			SELECT	DISTINCT X.DOCUMENTO_ID, X.NRO_LINEA, X.TIPO
			FROM	(	select	p.documento_id,p.nro_linea, 'T' AS TIPO
						from	det_documento dd inner join picking p
								on(dd.documento_id=p.documento_id and dd.nro_linea=p.nro_linea)
						where	((@pallet IS NULL or @TIPO=1)OR( p.prop1=@pallet))
								and ((@contenedora is null or @TIPO=2) or(@TIPO=1 AND dd.nro_bulto=@contenedora))
								and p.posicion_cod=@ubicacion_origen
								and p.fecha_inicio is null
						UNION 
						select	dd.DOCUMENTO_ID,dd.NRO_LINEA ,'A' AS ADICIONAL
						from	DET_DOCUMENTO dd inner join DET_DOCUMENTO_TRANSACCION ddt
								on(dd.DOCUMENTO_ID=ddt.DOCUMENTO_ID and dd.NRO_LINEA=ddt.NRO_LINEA_DOC)
								inner join RL_DET_DOC_TRANS_POSICION rl
								on(ddt.DOC_TRANS_ID=rl.DOC_TRANS_ID and ddt.NRO_LINEA_TRANS=rl.NRO_LINEA_TRANS)
								inner join DOCUMENTO d
								on(dd.DOCUMENTO_ID=d.DOCUMENTO_ID)
						where	((@TIPO=1 )OR(@TIPO=2 AND dd.prop1=@pallet))
								and rl.DOC_TRANS_ID_EGR is null
								and d.TIPO_OPERACION_ID='ING'		
								AND (RL.NAVE_ACTUAL=	(	SELECT 	NAVE_ID		FROM NAVE		WHERE	NAVE_COD	=LTRIM(RTRIM(UPPER(@UBICACION_ORIGEN))))
										OR RL.POSICION_ACTUAL=	(	SELECT 	POSICION_ID	FROM POSICION	WHERE	POSICION_COD=LTRIM(RTRIM(UPPER(@UBICACION_ORIGEN)))))			
					)X	
			order by
					1 desc
						
			Open @RsSubMovimientos
			Fetch Next From @RsSubMovimientos into	@DOCUMENTO_ID,
													@NRO_LINEA,
													@MTIPO
			While @@Fetch_Status=0
			Begin				
				begin try
					SET @CONTROL=NULL
					SELECT 	@CONTROL=COUNT(RL.RL_ID)
					FROM	DET_DOCUMENTO DD INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
							ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
							INNER JOIN RL_DET_DOC_TRANS_POSICION RL
							ON(DDT.DOC_TRANS_ID=RL.DOC_TRANS_ID AND DDT.NRO_LINEA_TRANS=RL.NRO_LINEA_TRANS)
					WHERE	((@pallet IS NULL)OR(PROP1=LTRIM(RTRIM(UPPER(@PALLET)))))
							AND ((@CONTENEDORA IS NULL) OR (DD.NRO_BULTO = LTRIM(RTRIM(UPPER(@CONTENEDORA)))))
							AND (RL.NAVE_ANTERIOR=	(	SELECT 	NAVE_ID		FROM NAVE		WHERE	NAVE_COD	=LTRIM(RTRIM(UPPER(@UBICACION_ORIGEN))))
							OR RL.POSICION_ANTERIOR=	(	SELECT 	POSICION_ID	FROM POSICION	WHERE	POSICION_COD=LTRIM(RTRIM(UPPER(@UBICACION_ORIGEN)))))
							AND RL.CANTIDAD >0
							
					IF @CONTROL>0 AND @MTIPO='T'
					BEGIN
						--set @MSG='tipo: t, documento: ' + CAST(@documento_id as varchar) + ', linea: ' + CAST(@nro_linea as varchar)
						--print (@msg)
						exec MOB_TRANSF_PREPICKING @UBICACION_ORIGEN,@UBICACION_DESTINO,@USUARIO,@PALLET,@CONTENEDORA,@DOCUMENTO_ID,@NRO_LINEA
					END ELSE BEGIN
						if @PALLET <> isnull(@PALLET_ANT,'ASSFASF') begin
							--set @MSG='tipo: a, documento: ' + CAST(@documento_id as varchar) + ', linea: ' + CAST(@nro_linea as varchar)
							--print (@msg)
							set @PALLET_ANT =@PALLET 
							EXEC dbo.[MOB_TRANSFERENCIA_PREPICKING_PALLET] @UBICACION_ORIGEN,@UBICACION_DESTINO,@USUARIO,@PALLET
						end
					END
					
				end try
				begin catch
					SET @MSG=ERROR_MESSAGE()
					RAISERROR('MOB_TRANSF_PREPICKING: %s',16,1,@msg)
					RETURN
				end catch

				SET @EXISTE = 0
		
				SELECT	@EXISTE = COUNT(*)
				FROM	POSICION
				WHERE 	POSICION_COD = @UBICACION_DESTINO

				IF @EXISTE = 1 
				BEGIN
					SELECT	@NAVE = NAVE_COD
					FROM	NAVE N
							INNER JOIN POSICION P ON (N.NAVE_ID = P.NAVE_ID)
					WHERE	POSICION_COD = @UBICACION_DESTINO
				END
				
				IF @EXISTE = 0 
				BEGIN
					SET	@NAVE = @UBICACION_DESTINO
				END	

				--Doy por finalizada la transferencia
				UPDATE	PICKING SET TRANSF_TERMINADA = '1'
				WHERE	DOCUMENTO_ID = @DOCUMENTO_ID
						AND NRO_LINEA = @NRO_LINEA

				--Actualiza todos los registros de pickin de ese pallet y esa contenedora
				UPDATE 	PICKING SET NAVE_COD = @NAVE, POSICION_COD = @UBICACION_DESTINO,
									SALTO_PICKING = 0, USUARIO = NULL, TRANSF_TERMINADA = '1'
				FROM	PICKING P
						INNER JOIN DET_DOCUMENTO DD ON (P.DOCUMENTO_ID=DD.DOCUMENTO_ID AND P.NRO_LINEA = DD.NRO_LINEA) 
				WHERE	1=1
						--AND (((DD.NRO_BULTO IS NULL) OR (DD.NRO_BULTO = @CONTENEDORA)) 
						AND ((@CONTENEDORA IS NULL)OR(DD.NRO_BULTO=@CONTENEDORA))
						AND ((@pallet IS NULL)OR(DD.PROP1 = @PALLET)) 
						AND P.CANT_CONFIRMADA IS NULL

				Fetch Next From @RsSubMovimientos into
									@DOCUMENTO_ID,
									@NRO_LINEA,
									@MTIPO

			end
			close @RsSubMovimientos
			deallocate @RsSubMovimientos
			
			Fetch Next From @RsMovimientos into
									@UBICACION_ORIGEN,
									@USUARIO,
									@PALLET,
									@CONTENEDORA
		end
	
	DELETE	MOVIMIENTOSPREPICKING 
	WHERE	USUARIO_ID = @USUARIO
			AND TERMINAL = @TERMINAL
			AND VIAJE_ID = @VIAJE_ID
end try
BEGIN CATCH
    -- Execute the error retrieval routine.
    if @@error<>0
	begin
		set @msg=''
		SET @MSG=ERROR_MESSAGE()
		raiserror('No se pudo completar la operacion. %s',16,1,@msg)
		return
	End
END CATCH;
END







GO

