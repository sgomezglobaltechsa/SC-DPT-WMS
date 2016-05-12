/****** Object:  StoredProcedure [dbo].[SetUCDesconsolidacionxproducto]    Script Date: 10/04/2013 12:16:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetUCDesconsolidacionxproducto]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SetUCDesconsolidacionxproducto]
GO

CREATE PROCEDURE [dbo].[SetUCDesconsolidacionxproducto]    
 @VIAJE_ID  VARCHAR(100) OUTPUT,    
 @SKU    VARCHAR(30)  OUTPUT,    
 @QTY    BIGINT   OUTPUT,    
 @UC_DESCON VARCHAR(100) OUTPUT    
AS    
BEGIN    
 SET XACT_ABORT ON    
 DECLARE @CUR  CURSOR    
 DECLARE @PICK  NUMERIC(20,0)    
 DECLARE @QTYP  FLOAT    
 DECLARE @NEWPICK NUMERIC(20,0)

 --para el check de integridad
 DECLARE @DOCUMENTO_ID INT
 DECLARE @PRODUCTO_ID VARCHAR(100)
 DECLARE @CANT_DOC REAL --CANTIDAD EN DET_DOCUMENTO
 DECLARE @CANT_PICK REAL --CANTIDAD EN PICKING    
 
begin tran      
begin try
      
 SET @CUR = CURSOR FOR    
 --TODOS LOS PICKING_ID SIN DESCONSOLIDAR DEL PRODUCTO.     
  SELECT P.PICKING_ID, P.CANT_CONFIRMADA
  FROM PICKING P     
   INNER JOIN DOCUMENTO D    
			ON P.DOCUMENTO_ID = D.DOCUMENTO_ID    
			AND P.CLIENTE_ID = D.CLIENTE_ID  
   
 INNER JOIN DOCUMENTO_X_CONTENEDORADESCONSOLIDACION DC  
  ON D.NRO_REMITO = DC.DOCUMENTO_ID  
	AND DC.NROUCDESCONSOLIDACION = @UC_DESCON

  WHERE     
   P.PRODUCTO_ID=LTRIM(RTRIM(UPPER(@SKU)))    
   AND P.VIAJE_ID = @VIAJE_ID    
   AND P.NRO_UCDESCONSOLIDACION IS NULL
   AND P.CANT_CONFIRMADA <> 0
	
  ORDER BY D.FECHA_ALTA_GTW,D.NRO_REMITO 

    
 OPEN @CUR    
 FETCH @CUR INTO @PICK, @QTYP    
 WHILE @@FETCH_STATUS=0    
 BEGIN    
  IF @QTY=0     
  BEGIN    
   BREAK    
  END     
      
  IF @QTYP<=@QTY    
  --SI SON IGUALES SE UPDATEA PICKING, NO HAY SPLITS    
  BEGIN    
   UPDATE PICKING SET NRO_UCDESCONSOLIDACION=@UC_DESCON 
   WHERE PICKING_ID=@PICK    
   SET @QTY=@QTY-@QTYP
   
       
  END    
  ELSE--IF @QTYP>@QTY    
  --SI LA CANTIDAD DE PICKING ES MAYOR A LA QUE QUIERE CONSOLIDAR.    
  --SPLIT DE PICKING.    
  BEGIN    
   INSERT INTO PICKING    
   SELECT   DOCUMENTO_ID,
			NRO_LINEA,
			CLIENTE_ID,
			PRODUCTO_ID,
			VIAJE_ID,
			TIPO_CAJA,
			DESCRIPCION,
			CANTIDAD,
			NAVE_COD,
			POSICION_COD,
			RUTA,
			PROP1,
			FECHA_INICIO,
			FECHA_FIN,
			USUARIO,
			CANT_CONFIRMADA,
			PALLET_PICKING,
			SALTO_PICKING,
			PALLET_CONTROLADO,
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
			TRANSF_TERMINADA,
			NRO_LOTE,
			NRO_PARTIDA,
			NRO_SERIE,
			ESTADO,
			NRO_UCDESCONSOLIDACION,
			FECHA_DESCONSOLIDACION,
			USUARIO_DESCONSOLIDACION,
			TERMINAL_DESCONSOLIDACION,
			NRO_UCEMPAQUETADO,
			UCEMPAQUETADO_MEDIDAS,
			FECHA_UCEMPAQUETADO,
			UCEMPAQUETADO_PESO
    FROM	[dbo].[PICKING]    
	WHERE	[PICKING_ID]=@PICK    
    
   SELECT @NEWPICK= SCOPE_IDENTITY()    
   --ACTUALIZO LAS CANTIDADES DEL SPLIT    
   UPDATE PICKING SET CANT_CONFIRMADA=@QTY, CANTIDAD=@QTY,NRO_UCDESCONSOLIDACION=@UC_DESCON  WHERE PICKING_ID=@PICK    
   UPDATE PICKING SET CANT_CONFIRMADA=@QTYP-@QTY, CANTIDAD=@QTYP-@QTY WHERE PICKING_ID=@NEWPICK    
   
   
   SET @QTY=0    
  END    
  
  --/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   --inicio de prueba de integridad
   SELECT @DOCUMENTO_ID=DOCUMENTO_ID, @PRODUCTO_ID = PRODUCTO_ID FROM PICKING where PICKING_ID=@PICK   
   
   SELECT @CANT_DOC = SUM(ISNULL(CANTIDAD,0)) FROM DET_DOCUMENTO WHERE DOCUMENTO_ID=@DOCUMENTO_ID AND PRODUCTO_ID=@PRODUCTO_ID

   SELECT @CANT_PICK = SUM(ISNULL(CANT_CONFIRMADA,0)) FROM PICKING WHERE DOCUMENTO_ID=@DOCUMENTO_ID AND PRODUCTO_ID=@PRODUCTO_ID

	 IF @CANT_PICK > @CANT_DOC 
		BEGIN
			RAISERROR('SE ESTA PRODUCIENDO UNA INCONSISTENCIA AL ACTUALIZAR LA TABLA PICKING, LA CANTIDAD CONFIRMADA ES MAYOR A LA CANTIDAD DEL DOCUMENTO, POR FAVOR INFORMAR A SISTEMAS.',18,1)
		END

   --fin de prueba de integridad
   --/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  FETCH @CUR INTO @PICK, @QTYP    
 END    
 CLOSE @CUR    
 DEALLOCATE @CUR    
commit 
 
end try 
begin catch
 IF XACT_STATE() <> 0 ROLLBACK   
 EXEC usp_RethrowError   
end catch

 
 
END;

GO


