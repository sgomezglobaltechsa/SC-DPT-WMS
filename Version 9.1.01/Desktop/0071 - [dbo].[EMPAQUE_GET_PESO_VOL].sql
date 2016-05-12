/****** Object:  StoredProcedure [dbo].[EMPAQUE_GET_PESO_VOL]    Script Date: 10/03/2013 12:19:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EMPAQUE_GET_PESO_VOL]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[EMPAQUE_GET_PESO_VOL]
GO

CREATE PROCEDURE [dbo].[EMPAQUE_GET_PESO_VOL]
AS
BEGIN

	SELECT	SUM(X.PESO) AS PESO,
			SUM(X.VOLUMEN)/1000000 AS VOLUMEN
	FROM	(	SELECT	DISTINCT
						ISNULL(P.UCEMPAQUETADO_PESO,0)	PESO
						,ISNULL(U.ALTO,0)*ISNULL(U.ANCHO,0)*ISNULL(U.LARGO,0)VOLUMEN
				FROM	PICKING P INNER JOIN DOCUMENTO D
						ON(P.DOCUMENTO_ID=D.DOCUMENTO_ID)
						INNER JOIN SUCURSAL S
						ON(D.CLIENTE_ID=S.CLIENTE_ID AND D.SUCURSAL_DESTINO=S.SUCURSAL_ID)
						INNER JOIN PRODUCTO PROD
						ON(P.CLIENTE_ID=PROD.CLIENTE_ID AND P.PRODUCTO_ID=PROD.PRODUCTO_ID)
						INNER JOIN UC_EMPAQUE U
						ON(P.NRO_UCEMPAQUETADO=U.UC_EMPAQUE)
				WHERE	P.ESTADO='2'
						AND P.FACTURADO='0'
						AND EXISTS (SELECT	1
									FROM	#TMP_EMPAQUE_CAB T
									WHERE	T.PEDIDO=D.NRO_REMITO))X
END
