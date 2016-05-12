
/****** Object:  StoredProcedure [dbo].[Estacion_GetProductos_Egr]    Script Date: 02/27/2013 17:22:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




Create    PROCEDURE [dbo].[Estacion_GetProductos_Egr_Desk]
@Picking_id		Numeric(20,0) 	Output,
@Tipo			Numeric(1,0)	Output
As
Begin
	Declare @Producto_id	as varchar(30)
	Declare @Cliente_id		as varchar(15)
	Declare @Nro_Partida	as varchar(50)
	Declare @Documento_id	as Numeric(20,0)
	Declare @Nro_linea		as Numeric(10,0)

	Select 	 @Producto_id	= Producto_id
			,@Cliente_id	= Cliente_id
			,@Documento_Id	= Documento_id
			,@Nro_linea		= Nro_linea
	From	Picking (nolock)
	Where 	Picking_id		= @Picking_id


	If @Tipo=0
	Begin
		
		Select	@Nro_Partida=Nro_partida
		From	Det_Documento (nolock)
		Where	Documento_id=@Documento_id
				and Nro_linea=@Nro_Linea

		SELECT
				 dd.cliente_id				As CLIENTE_ID
				,dd.producto_id 			As PRODUCTO_ID
				,dd.DESCRIPCION				As DESCRIPCION
				,rl.cantidad				AS CANTIDAD
				,dd.NRO_BULTO				AS NRO_BULTO
				,dd.NRO_LOTE				AS NRO_LOTE
				,RL.EST_MERC_ID				AS EST_MERC_ID
				,dd.NRO_DESPACHO			AS NRO_DESPACHO
				,dd.NRO_PARTIDA				AS NRO_PARTIDA
				,dd.UNIDAD_ID				AS UNIDAD_ID
				,dd.PROP1					AS NRO_PALLET
				,dd.PROP2					AS PROP2
				,dd.PROP3					AS PROP3
				,RL.CAT_LOG_ID				AS CAT_LOG_ID
				,dd.fecha_vencimiento		AS FECHA_VENCIMIENTO
				,'POS' 						AS UBICACION
				,p.posicion_cod 			AS POSICION
				,isnull(p.orden_picking,999)AS ORDEN
				,rl.rl_id					AS RL_ID
		FROM 	rl_det_doc_trans_posicion rl (nolock)
				inner join det_documento_transaccion ddt (nolock) on(rl.doc_trans_id=ddt.doc_trans_id and rl.nro_linea_trans=ddt.nro_linea_trans)
				inner join det_documento dd (nolock) ON (ddt.documento_id=dd.documento_id AND ddt.nro_linea_doc=dd.nro_linea)
				inner join categoria_logica cl (nolock) on (rl.cliente_id=cl.cliente_id and rl.cat_log_id=cl.cat_log_id and cl.disp_egreso='1' and cl.picking='1')
				inner join posicion p (nolock) on (rl.posicion_actual=p.posicion_id and p.pos_lockeada='0' and p.picking='1')
				left join estado_mercaderia_rl em (nolock) on (rl.cliente_id=em.cliente_id and rl.est_merc_id=em.est_merc_id)
		WHERE
				rl.doc_trans_id_egr is null
				and rl.nro_linea_trans_egr is null
				and rl.disponible='1'
				and isnull(em.disp_egreso,'1')='1'
				and isnull(em.picking,'1')='1'
				and rl.cat_log_id<>'TRAN_EGR'
				and dd.producto_id	=@Producto_id
				and dd.cliente_id	=@Cliente_id
				and dd.Nro_Partida	=@Nro_Partida
	
		UNION 
		SELECT
				 dd.cliente_id
				,dd.producto_id as Producto_Id
				,dd.DESCRIPCION
				,rl.cantidad
				,dd.NRO_BULTO
				,dd.NRO_LOTE
				,RL.EST_MERC_ID
				,dd.NRO_DESPACHO
				,dd.NRO_PARTIDA
				,dd.UNIDAD_ID
				,dd.PROP1
				,dd.PROP2
				,dd.PROP3
				,RL.CAT_LOG_ID
				,dd.fecha_vencimiento
				,'NAV' as ubicacion
				,n.nave_cod as posicion
				,isnull(n.orden_locator,999) as orden
				,rl.rl_id
		FROM 	rl_det_doc_trans_posicion rl (nolock)
				inner join det_documento_transaccion ddt (nolock) on(rl.doc_trans_id=ddt.doc_trans_id and rl.nro_linea_trans=ddt.nro_linea_trans)
				inner join det_documento dd (nolock) ON (ddt.documento_id=dd.documento_id AND ddt.nro_linea_doc=dd.nro_linea)
				inner join categoria_logica cl (nolock) on (rl.cliente_id=cl.cliente_id and rl.cat_log_id=cl.cat_log_id and cl.disp_egreso='1' and cl.picking='1')
				inner join nave n (nolock) on (rl.nave_actual=n.nave_id and n.disp_egreso='1' and n.pre_egreso='0' and n.pre_ingreso='0' and n.picking='1')
				left join estado_mercaderia_rl em (nolock) on (rl.cliente_id=em.cliente_id and rl.est_merc_id=em.est_merc_id) 
		WHERE
				rl.doc_trans_id_egr is null
				and rl.nro_linea_trans_egr is null
				and rl.disponible='1'
				and isnull(em.disp_egreso,'1')='1'
				and isnull(em.picking,'1')='1'
				and rl.cat_log_id<>'TRAN_EGR'
				and dd.producto_id	=@Producto_id
				and dd.cliente_id	=@Cliente_id
				and dd.Nro_Partida	=@Nro_Partida

	End
	Else
	Begin
		SELECT
				 dd.cliente_id				As CLIENTE_ID
				,dd.producto_id 			As PRODUCTO_ID
				,dd.DESCRIPCION				As DESCRIPCION
				,rl.cantidad				AS CANTIDAD
				,dd.NRO_BULTO				AS NRO_BULTO
				,dd.NRO_LOTE				AS NRO_LOTE
				,RL.EST_MERC_ID				AS EST_MERC_ID
				,dd.NRO_DESPACHO			AS NRO_DESPACHO
				,dd.NRO_PARTIDA				AS NRO_PARTIDA
				,dd.UNIDAD_ID				AS UNIDAD_ID
				,dd.PROP1					AS NRO_PALLET
				,dd.PROP2					AS PROP2
				,dd.PROP3					AS PROP3
				,RL.CAT_LOG_ID				AS CAT_LOG_ID
				,dd.fecha_vencimiento		AS FECHA_VENCIMIENTO
				,'POS' 						AS UBICACION
				,p.posicion_cod 			AS POSICION
				,isnull(p.orden_picking,999)AS ORDEN
				,rl.rl_id					AS RL_ID
		FROM 	rl_det_doc_trans_posicion rl (nolock)
				inner join det_documento_transaccion ddt (nolock) on(rl.doc_trans_id=ddt.doc_trans_id and rl.nro_linea_trans=ddt.nro_linea_trans)
				inner join det_documento dd (nolock) ON (ddt.documento_id=dd.documento_id AND ddt.nro_linea_doc=dd.nro_linea)
				inner join categoria_logica cl (nolock) on (rl.cliente_id=cl.cliente_id and rl.cat_log_id=cl.cat_log_id and cl.disp_egreso='1' and cl.picking='1')
				inner join posicion p (nolock) on (rl.posicion_actual=p.posicion_id and p.pos_lockeada='0' and p.picking='1')
				left join estado_mercaderia_rl em (nolock) on (rl.cliente_id=em.cliente_id and rl.est_merc_id=em.est_merc_id)
		WHERE
				rl.doc_trans_id_egr is null
				and rl.nro_linea_trans_egr is null
				and rl.disponible='1'
				and isnull(em.disp_egreso,'1')='1'
				and isnull(em.picking,'1')='1'
				and rl.cat_log_id<>'TRAN_EGR'
				and dd.producto_id	=@Producto_id
				and dd.cliente_id	=@Cliente_id
	
		UNION 
		SELECT
				 dd.cliente_id
				,dd.producto_id as Producto_Id
				,dd.DESCRIPCION
				,rl.cantidad
				,dd.NRO_BULTO
				,dd.NRO_LOTE
				,RL.EST_MERC_ID
				,dd.NRO_DESPACHO
				,dd.NRO_PARTIDA
				,dd.UNIDAD_ID
				,dd.PROP1
				,dd.PROP2
				,dd.PROP3
				,RL.CAT_LOG_ID
				,dd.fecha_vencimiento
				,'NAV' as ubicacion
				,n.nave_cod as posicion
				,isnull(n.orden_locator,999) as orden
				,rl.rl_id
		FROM 	rl_det_doc_trans_posicion rl (nolock)
				inner join det_documento_transaccion ddt (nolock) on(rl.doc_trans_id=ddt.doc_trans_id and rl.nro_linea_trans=ddt.nro_linea_trans)
				inner join det_documento dd (nolock) ON (ddt.documento_id=dd.documento_id AND ddt.nro_linea_doc=dd.nro_linea)
				inner join categoria_logica cl (nolock) on (rl.cliente_id=cl.cliente_id and rl.cat_log_id=cl.cat_log_id and cl.disp_egreso='1' and cl.picking='1')
				inner join nave n (nolock) on (rl.nave_actual=n.nave_id and n.disp_egreso='1' and n.pre_egreso='0' and n.pre_ingreso='0' and n.picking='1')
				left join estado_mercaderia_rl em (nolock) on (rl.cliente_id=em.cliente_id and rl.est_merc_id=em.est_merc_id) 
		WHERE
				rl.doc_trans_id_egr is null
				and rl.nro_linea_trans_egr is null
				and rl.disponible='1'
				and isnull(em.disp_egreso,'1')='1'
				and isnull(em.picking,'1')='1'
				and rl.cat_log_id<>'TRAN_EGR'
				and dd.producto_id	=@Producto_id
				and dd.cliente_id	=@Cliente_id

	End

End --Fin Procedure.






