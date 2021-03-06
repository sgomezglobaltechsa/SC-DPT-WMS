/****** Object:  StoredProcedure [dbo].[GENERAR_SNAPSHOT]    Script Date: 09/03/2014 09:38:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GENERAR_SNAPSHOT]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GENERAR_SNAPSHOT]
GO


CREATE PROCEDURE [dbo].[GENERAR_SNAPSHOT]
AS
BEGIN
  DECLARE @FSNAP  DATETIME;
  DECLARE @CTRL   NUMERIC(20,0);
  DECLARE @LIST   VARCHAR(4000);
  BEGIN 
  TRY
    SET @FSNAP=GETDATE();
    
    SELECT  @CTRL=COUNT(*)
    FROM    dbo.SNAP_EXISTENCIAS
    WHERE   CONVERT(VARCHAR,F_SNAP,103)=CONVERT(VARCHAR,@FSNAP,103);
    
    IF @CTRL=0
    BEGIN
      PRINT('Tomando snap.')
      INSERT INTO dbo.SNAP_EXISTENCIAS( F_SNAP, RL_ID, DOC_TRANS_ID, NRO_LINEA_TRANS, POSICION_ANTERIOR, POSICION_ACTUAL, 
                                        CANTIDAD, TIPO_MOVIMIENTO_ID, ULTIMA_ESTACION, ULTIMA_SECUENCIA, NAVE_ANTERIOR, NAVE_ACTUAL, 
                                        DOCUMENTO_ID, NRO_LINEA, DISPONIBLE, DOC_TRANS_ID_EGR, NRO_LINEA_TRANS_EGR, DOC_TRANS_ID_TR, 
                                        NRO_LINEA_TRANS_TR, CLIENTE_ID, CAT_LOG_ID, CAT_LOG_ID_FINAL, EST_MERC_ID) 
      SELECT  @FSNAP,RL_ID, DOC_TRANS_ID, NRO_LINEA_TRANS, POSICION_ANTERIOR, POSICION_ACTUAL, 
              CANTIDAD, TIPO_MOVIMIENTO_ID, ULTIMA_ESTACION, ULTIMA_SECUENCIA, NAVE_ANTERIOR, NAVE_ACTUAL, 
              DOCUMENTO_ID, NRO_LINEA, DISPONIBLE, DOC_TRANS_ID_EGR, NRO_LINEA_TRANS_EGR, DOC_TRANS_ID_TR, 
              NRO_LINEA_TRANS_TR, CLIENTE_ID, CAT_LOG_ID, CAT_LOG_ID_FINAL, EST_MERC_ID
      FROM    RL_DET_DOC_TRANS_POSICION;       
      
      --------------------------------------------------------------------------------------------------------------------------------
      --MANDO A CALCULAR EL REPORTE ESTADISTICO.
      --------------------------------------------------------------------------------------------------------------------------------
      EXEC [dbo].[RPT_ESTADISTICA_CLIENTE_CALC]
      --------------------------------------------------------------------------------------------------------------------------------
    END
    ELSE
    BEGIN
      Exec dbo.SP_SENDMAIL 'Se intento ejecutar nuevamente la toma de la foto del Stock','WARP', 'GENERAR_SNAPSHOT'
    END
  END TRY
  BEGIN 
  CATCH
    --Bloque para control de errores.
    Exec dbo.SP_SENDMAIL 'Ocurrio un error inesperado al ejecutar la toma de la foto del stock.','WARP', 'GENERAR_SNAPSHOT'
  END CATCH
END; --Fin Procedimiento.

GO


