
/****** Object:  UserDefinedFunction [dbo].[ABAST_CONTROL_VOL_PESO]    Script Date: 05/22/2015 17:26:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ABAST_CONTROL_VOL_PESO]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ABAST_CONTROL_VOL_PESO]
GO


CREATE FUNCTION [dbo].[ABAST_CONTROL_VOL_PESO](
	@CANT_RLPP		NUMERIC(20,5),
	@CLIENTE_ID		VARCHAR(15),
	@PRODUCTO_ID	VARCHAR(30),
	@POSICION_ID	NUMERIC(20,0)
)RETURNS NUMERIC(20,5)
AS
BEGIN

	DECLARE @VOL_POS		NUMERIC(20,5),
			@RETORNO		NUMERIC(20,5),
			@PESO_POS		NUMERIC(20,5),
			@PESO_PROD		NUMERIC(20,5),
			@VOL_PROD		NUMERIC(20,5),
			@PESO_DISP		NUMERIC(20,5),
			@VOL_DISP		NUMERIC(20,5),
			@QTY_POR_PESO	NUMERIC(20,5),
			@QTY_POR_VOL	NUMERIC(20,5),
			@MSG			VARCHAR(400),
			@VOL_P			NUMERIC(20,5),
			@VOL_PICK		NUMERIC(20,5),
			@PESO_PICK		NUMERIC(20,5)
	
	set @retorno=@cant_rlpp;
	
	--Obtengo el peso y volumen del producto.
	SELECT	@VOL_PROD	=(ISNULL(ALTO,0)*ISNULL(ANCHO,0)*ISNULL(LARGO,0))/1000000,
			@PESO_PROD	=ISNULL(PESO,1)
	FROM	PRODUCTO
	WHERE	CLIENTE_ID=@CLIENTE_ID
			AND PRODUCTO_ID=@PRODUCTO_ID
			
	--Obtengo el peso disponible y el volumen disponible.
	SELECT	@VOL_DISP	=ISNULL(X.VOL_POS - SUM(QTY*X.VOL_PROD),0),
			@PESO_DISP	=ISNULL(X.PESO - SUM(PESO_PROD),0),
			@VOL_P		=X.VOL_POS
	FROM	(	SELECT	DD.PRODUCTO_ID,
						SUM(RL.CANTIDAD) AS QTY, 
						(ISNULL(PR.ALTO,0) * ISNULL(PR.ANCHO,0) * ISNULL(PR.LARGO,0))/1000000 AS VOL_PROD,
						(ISNULL(P.ALTO,0) * ISNULL(P.ANCHO,0) * ISNULL(P.LARGO,0))/1000000 AS VOL_POS,
						P.PESO,SUM(RL.CANTIDAD)* SUM(ISNULL(PR.PESO,0))AS PESO_PROD
				FROM	DET_DOCUMENTO DD INNER JOIN DET_DOCUMENTO_TRANSACCION DDT
						ON(DD.DOCUMENTO_ID=DDT.DOCUMENTO_ID AND DD.NRO_LINEA=DDT.NRO_LINEA_DOC)
						INNER JOIN RL_DET_DOC_TRANS_POSICION RL 
						ON(RL.DOC_TRANS_ID=DDT.DOC_TRANS_ID AND RL.NRO_LINEA_TRANS=DDT.NRO_LINEA_TRANS)
						INNER JOIN PRODUCTO PR
						ON(DD.CLIENTE_ID=PR.CLIENTE_ID AND DD.PRODUCTO_ID=PR.PRODUCTO_ID)
						INNER JOIN POSICION P
						ON(RL.POSICION_ACTUAL=P.POSICION_ID)
				WHERE	RL.POSICION_ACTUAL=@POSICION_ID	
				GROUP BY
						DD.PRODUCTO_ID,
						(ISNULL(P.ALTO,0) * ISNULL(P.ANCHO,0) * ISNULL(P.LARGO,0))/1000000,
						(ISNULL(PR.ALTO,0) * ISNULL(PR.ANCHO,0) * ISNULL(PR.LARGO,0))/1000000,
						P.PESO
			)X
	GROUP BY
			X.VOL_POS,X.PESO

	SELECT	@VOL_PICK	=SUM(X.VOL_TOT),
			@PESO_PICK	=SUM(X.PESO_TOTAL)
	FROM	(	SELECT	P.CLIENTE_ID,P.PRODUCTO_ID,PS.POSICION_ID, SUM(P.CANTIDAD) QTY,
						SUM(CANTIDAD)*((ISNULL(PR.ALTO,0)*ISNULL(PR.ANCHO,0)*ISNULL(PR.LARGO,0))/1000000) VOL_TOT,
						SUM(P.CANTIDAD)* ISNULL(PR.PESO,0) PESO_TOTAL
				FROM	PICKING P (NOLOCK) INNER JOIN POSICION PS (NOLOCK)
						ON(P.POSICION_COD=PS.POSICION_COD)
						INNER JOIN PRODUCTO PR
						ON(P.CLIENTE_ID=PR.CLIENTE_ID AND P.PRODUCTO_ID=PR.PRODUCTO_ID)
				WHERE	1=1
						AND PS.POSICION_ID=@POSICION_ID
						AND CANT_CONFIRMADA IS NULL
				GROUP BY
						P.CLIENTE_ID,P.PRODUCTO_ID,PS.POSICION_ID,(ISNULL(PR.ALTO,0)*ISNULL(PR.ANCHO,0)*ISNULL(PR.LARGO,0))/1000000,
						ISNULL(PR.PESO,0)
			)X

	SET @VOL_DISP=@VOL_DISP-ISNULL(@VOL_PICK,0)
	SET @PESO_DISP=@PESO_DISP-ISNULL(@PESO_PICK,0)

	if (@peso_prod<>0)begin 
		if @peso_prod>0 begin
			SET @QTY_POR_PESO	=floor(@peso_disp/@peso_prod);	--esto me da la cantidad de unidades que se pueden transferir por peso.
		end
	end
	
	if (@vol_prod<>0)begin 
		if @vol_prod>0 and @VOL_P<>0 begin
			SET @QTY_POR_VOL	=floor(@vol_disp/@vol_prod);	--esto me da la cantidad de unidades que se pueden transferir por volumen
		end
	end
		
	if(@retorno>@qty_por_vol)and (@qty_por_vol>0)begin
		set @retorno=@qty_por_vol
	end
	
	if (@retorno>@qty_por_peso)and (@qty_por_peso>0)begin
		set @retorno=@qty_por_peso
	end	
	
	if (@qty_por_peso<0)or (@qty_por_vol<0) begin
		set @retorno=0;
	end
	
	return @retorno;
	
END -- fin de la funcion.

GO

