
ALTER     PROCEDURE [dbo].[Frontera_PickingProceso_Cont]
@Usr	varchar(100)
AS

BEGIN
	Declare @RolID		as varchar(5)
	Declare @UsuarioId	as varchar(30)
	
	Select	@RolId		=rol_id, 
			@UsuarioId	=usuario_id 
	from	#temp_usuario_loggin

	select 	p.viaje_id as [PICKING/VIAJE]
			,round((sum(isnull(p.cant_confirmada,0))/sum(p.cantidad)*100),2) as POR_COMPLETO
			,sum(isnull(p.cantidad,0)) as QTY_BULTOS_A_PICKEAR
			,sum(isnull(p.cant_confirmada,0)) as QTY_BULTOS_PICKEADOS
			,cast(pv.prioridad as VARCHAR(20)) as PRIORIDAD_VIAJE
			,dbo.GetPickerMans(p.viaje_id) AS PICKEADORES
			,CASE p.FLG_PALLET_HOMBRE  WHEN '1' THEN 'SI' WHEN '0' THEN 'NO' END AS FLG_PALLET_HOMBRE
			,C.RAZON_SOCIAL
			,dd.nro_bulto as Nro_Contenedora
	From	documento d (nolock)
			inner join det_documento dd (nolock) on (d.documento_id=dd.documento_id)
			inner join sucursal s (nolock) on (d.cliente_id=s.cliente_id and d.sucursal_destino=s.sucursal_id)
			inner join picking p (nolock) on (dd.documento_id=p.documento_id and dd.nro_linea=p.nro_linea)
			left join prioridad_viaje pv (nolock) on (p.viaje_id=pv.viaje_id)
			inner join rl_sys_cliente_usuario su on(d.cliente_id=su.cliente_id)
			inner join cliente c on(d.cliente_id=c.cliente_id)
	Where	p.fin_picking in (0,1) 
			and su.usuario_id=@usuarioid
			and p.FECHA_INICIO is not null
			and p.FECHA_FIN is null
			and dbo.Get_Tipo_Documento_id(d.cliente_id,d.nro_remito) in (select r.tipo_documento_id from RL_ROL_INT_TIPO_DOCUMENTO R where r.rol_id=@RolId)
	GROUP BY 
			p.viaje_id,pv.prioridad,p.FLG_PALLET_HOMBRE,C.RAZON_SOCIAL,dd.nro_bulto

END
