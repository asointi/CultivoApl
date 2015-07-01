set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/06/19
-- Description:	Informacion necesaria para extraer reportes
-- =============================================

alter PROCEDURE [dbo].[na_reportes_compras_bouquetera] 

@accion nvarchar(50),
@id_tipo_compra int,
@fecha_inicial datetime,
@fecha_final datetime

as

if(@accion = 'reporte_historia')
begin
	select 1 as orden,
	'xConfirmar' as estado,
	tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.comentario,
	detalle_orden_pedido_cultivo.unidades,
	convert(datetime,convert(nvarchar,orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_transaccion,
	convert(nvarchar,orden_pedido_cultivo.fecha_transaccion, 108) as hora_transaccion,
	orden_pedido_cultivo.usuario_cobol,
	convert(datetime, '') as fecha_reprogramacion,
	convert(datetime, '') as fecha_aprobacion into #temp
	from tipo_compra,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor

	union all
	select 2 as orden,
	estado_orden_pedido_cultivo.nombre_estado_orden_pedido as estado,
	tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.comentario,
	verifica_detalle_orden_pedido_cultivo.unidades,
	convert(datetime,convert(nvarchar,verifica_detalle_orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_transaccion,
	convert(nvarchar,verifica_detalle_orden_pedido_cultivo.fecha_transaccion, 108) as hora_transaccion,
	cuenta_interna.nombre as usuario_cobol,
	convert(datetime, ''),
	verifica_detalle_orden_pedido_cultivo.fecha_aprobada
	from tipo_compra,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	verifica_detalle_orden_pedido_cultivo,
	estado_orden_pedido_cultivo,
	cuenta_interna
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and cuenta_interna.id_cuenta_interna = verifica_detalle_orden_pedido_cultivo.id_cuenta_interna
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
	and estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	
	union all
	select 3 as orden,
	e.nombre_estado_orden_pedido as estado,
	tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.comentario,
	despacho_orden_pedido_cultivo.unidades,
	convert(datetime,convert(nvarchar,despacho_orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_transaccion,
	convert(nvarchar,despacho_orden_pedido_cultivo.fecha_transaccion, 108) as hora_transaccion,
	despacho_orden_pedido_cultivo.usuario_cobol,
	despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
	verifica_detalle_orden_pedido_cultivo.fecha_aprobada
	from tipo_compra,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	verifica_detalle_orden_pedido_cultivo,
	estado_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	estado_orden_pedido_cultivo as e
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
	and estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	and verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo
	and e.id_estado_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_orden_pedido_cultivo

	union all

	select 4 as orden,
	'Recibida' as estado,
	tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.comentario,
	detalle_recibo_flor.unidades,
	convert(datetime,convert(nvarchar,recibo_flor.fecha_transaccion, 101)) as fecha_transaccion,
	convert(nvarchar,recibo_flor.fecha_transaccion, 108) as hora_transaccion,
	recibo_flor.usuario_cobol,
	despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
	verifica_detalle_orden_pedido_cultivo.fecha_aprobada
	from tipo_compra,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	verifica_detalle_orden_pedido_cultivo,
	estado_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	estado_orden_pedido_cultivo as e,
	detalle_recibo_flor,
	recibo_flor
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
	and estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	and verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo
	and e.id_estado_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
	and recibo_flor.id_recibo_flor = detalle_recibo_flor.id_recibo_flor

	union all

	select 5 as orden,
	'Devuelta' as estado,
	tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.comentario,
	detalle_devolucion_flor.unidades,
	convert(datetime,convert(nvarchar,devolucion_flor.fecha_transaccion, 101)) as fecha_transaccion,
	convert(nvarchar,devolucion_flor.fecha_transaccion, 108) as hora_transaccion,
	devolucion_flor.usuario_cobol,
	despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
	verifica_detalle_orden_pedido_cultivo.fecha_aprobada
	from tipo_compra,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	verifica_detalle_orden_pedido_cultivo,
	estado_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	estado_orden_pedido_cultivo as e,
	detalle_recibo_flor,
	recibo_flor,
	detalle_devolucion_flor,
	devolucion_flor
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
	and estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	and verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo
	and e.id_estado_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
	and recibo_flor.id_recibo_flor = detalle_recibo_flor.id_recibo_flor
	and detalle_recibo_flor.id_detalle_recibo_flor = detalle_devolucion_flor.id_detalle_recibo_flor
	and devolucion_flor.id_devolucion_flor = detalle_devolucion_flor.id_devolucion_flor

	select *
	from #temp
	where id_tipo_compra > = 
	case
		when @id_tipo_compra = 0 then 1
		else @id_tipo_compra
	end
	and id_tipo_compra < = 
	case
		when @id_tipo_compra = 0 then 999
		else @id_tipo_compra
	end
	and (
		fecha_inicial between
		@fecha_inicial and @fecha_final 
		or fecha_final between
		@fecha_inicial and @fecha_final 
		or @fecha_inicial between
		fecha_inicial and fecha_final 
		or @fecha_final between
		fecha_inicial and fecha_final 
	) 	
	order by id_orden_pedido_cultivo,
	orden

	drop table #temp
end
else
if(@accion = 'reporte_recepcion_flor')
begin
	select tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	convert(datetime,convert(nvarchar,orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_solicitud,
	convert(nvarchar,orden_pedido_cultivo.fecha_transaccion, 108) as hora_solicitud,
	orden_pedido_cultivo.usuario_cobol as usuario_solicitud,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.unidades as unidades_solicitadas,
	detalle_orden_pedido_cultivo.comentario,
	cuenta_interna.nombre as usuario_aprobacion,
	convert(datetime,convert(nvarchar,verifica_detalle_orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_aprobacion,
	convert(nvarchar,verifica_detalle_orden_pedido_cultivo.fecha_transaccion, 108) as hora_aprobacion,
	despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo,
	convert(datetime, convert(nvarchar, despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 101)) as fecha_reprogramacion,
	convert(nvarchar, despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 108) as hora_reprogramacion,
	despacho_orden_pedido_cultivo.unidades as unidades_reprogramadas,
	despacho_orden_pedido_cultivo.usuario_cobol as usuario_reprogramacion,
	despacho_orden_pedido_cultivo.fecha_transaccion as fecha_transaccion_reprogramacion,
	convert(nvarchar, despacho_orden_pedido_cultivo.fecha_transaccion, 108) as hora_transaccion_reprogramacion,
	(
		select t.idc_tipo_flor
		from tipo_flor as t,
		variedad_flor as v,
		despacho_orden_pedido_cultivo as d
		where t.id_tipo_flor = v.id_tipo_flor
		and v.id_variedad_flor = d.id_variedad_flor
		and d.id_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	) as idc_tipo_flor_reprogramada,
	(
		select ltrim(rtrim(t.nombre_tipo_flor))
		from tipo_flor as t,
		variedad_flor as v,
		despacho_orden_pedido_cultivo as d
		where t.id_tipo_flor = v.id_tipo_flor
		and v.id_variedad_flor = d.id_variedad_flor
		and d.id_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	) as nombre_tipo_flor_reprogramada,
	(
		select v.idc_variedad_flor
		from tipo_flor as t,
		variedad_flor as v,
		despacho_orden_pedido_cultivo as d
		where t.id_tipo_flor = v.id_tipo_flor
		and v.id_variedad_flor = d.id_variedad_flor
		and d.id_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	) as idc_variedad_flor_reprogramada,
	(
		select ltrim(rtrim(v.nombre_variedad_flor))
		from tipo_flor as t,
		variedad_flor as v,
		despacho_orden_pedido_cultivo as d
		where t.id_tipo_flor = v.id_tipo_flor
		and v.id_variedad_flor = d.id_variedad_flor
		and d.id_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	) as nombre_variedad_flor_reprogramada,
	(
		select g.idc_grado_flor
		from tipo_flor as t,
		grado_flor as g,
		despacho_orden_pedido_cultivo as d
		where t.id_tipo_flor = g.id_tipo_flor
		and g.id_grado_flor = d.id_grado_flor
		and d.id_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	) as idc_grado_flor_reprogramada,
	(
		select ltrim(rtrim(g.nombre_grado_flor))
		from tipo_flor as t,
		grado_flor as g,
		despacho_orden_pedido_cultivo as d
		where t.id_tipo_flor = g.id_tipo_flor
		and g.id_grado_flor = d.id_grado_flor
		and d.id_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	) as nombre_grado_flor_reprogramada,
	recibo_flor.numero_remision,
	convert(datetime,convert(nvarchar,recibo_flor.fecha_transaccion, 101)) as fecha_recibo_flor,
	convert(nvarchar,recibo_flor.fecha_transaccion, 108) as hora_recibo_flor,
	recibo_flor.usuario_cobol as usuario_recibo_flor,
	detalle_recibo_flor.unidades as unidades_recibidas,
	isnull(devolucion_flor.numero_consecutivo,0) as numero_consecutivo_devolucion,
	isnull(devolucion_flor.usuario_cobol,'') as usuario_devolucion,
	isnull(detalle_devolucion_flor.unidades,0) as unidades_devolucion,
	convert(datetime,convert(nvarchar,isnull(devolucion_flor.fecha_transaccion,''), 101)) as fecha_devolucion_flor,
	convert(nvarchar,isnull(devolucion_flor.fecha_transaccion,''), 108) as hora_devolucion_flor,
	verifica_detalle_orden_pedido_cultivo.fecha_aprobada as fecha_aprobacion
	from orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	detalle_recibo_flor left join detalle_devolucion_flor on detalle_recibo_flor.id_detalle_recibo_flor = detalle_devolucion_flor.id_detalle_recibo_flor
	left join devolucion_flor on devolucion_flor.id_devolucion_flor = detalle_devolucion_flor.id_devolucion_flor,
	recibo_flor,
	tipo_compra,
	tipo_flor,
	variedad_flor,
	grado_flor,
	cuenta_interna
	where cuenta_interna.id_cuenta_interna = verifica_detalle_orden_pedido_cultivo.id_cuenta_interna
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
	and recibo_flor.id_recibo_flor = detalle_recibo_flor.id_recibo_flor
	and tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
	and convert(datetime,convert(nvarchar,recibo_flor.fecha_transaccion, 101)) between
	@fecha_inicial and @fecha_final
	and tipo_compra.id_tipo_compra > = 
	case
		when @id_tipo_compra = 0 then 1
		else @id_tipo_compra
	end
	and tipo_compra.id_tipo_compra < = 
	case
		when @id_tipo_compra = 0 then 999
		else @id_tipo_compra
	end
end