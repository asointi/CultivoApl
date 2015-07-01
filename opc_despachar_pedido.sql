set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[opc_despachar_pedido] 

@accion nvarchar(255),
@id_comprador int,
@id_cuenta_interna int, 
@id_detalle_orden_pedido_cultivo int, 
@id_estado_despacho_orden_pedido_cultivo int, 
@id_variedad_flor int, 
@id_grado_flor int, 
@fecha_estimada_despacho_flor datetime, 
@cantidad_piezas int,
@accion2 nvarchar(255) = null

as

if(@accion = 'consultar_pedidos_pendientes')
begin
	select despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido,
	sum(despacho_orden_pedido_cultivo.cantidad_piezas) as cantidad_piezas into #despacho_orden_pedido_cultivo
	from despacho_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo
	where estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo
	group by despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido

	select id_detalle_orden_pedido_cultivo,
	sum(cantidad_piezas) as cantidad_piezas into #despacho_orden_pedido_cultivo_agrupado
	from #despacho_orden_pedido_cultivo
	group by id_detalle_orden_pedido_cultivo

	select detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	farm.id_farm,
	ltrim(rtrim(farm.nombre_farm)) + ' [' + farm.idc_farm + ']' as nombre_farm,
	orden_pedido_cultivo.descripcion as descripcion_pedido,
	orden_pedido_cultivo.numero_consecutivo,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	tapa.id_tapa,
	ltrim(rtrim(tapa.nombre_tapa)) + ' [' + tapa.idc_tapa + ']' as nombre_tapa,
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)) + ' [' + tipo_caja.idc_tipo_caja + caja.idc_caja + ']' as nombre_caja,
	detalle_orden_pedido_cultivo.marca,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.unidades_por_pieza,
	detalle_orden_pedido_cultivo.cantidad_piezas as piezas_totales,
	isnull((
		select #despacho_orden_pedido_cultivo.cantidad_piezas
		from #despacho_orden_pedido_cultivo
		where #despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		and #despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'
	), 0) as piezas_aprobadas,
	isnull((
		select #despacho_orden_pedido_cultivo.cantidad_piezas
		from #despacho_orden_pedido_cultivo
		where #despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		and #despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Cancelada'
	), 0) as piezas_rechazadas,
	detalle_orden_pedido_cultivo.valor_unitario,
	detalle_orden_pedido_cultivo.comentario as comentario_detalle_pedido into #resultado
	from detalle_orden_pedido_cultivo,
	orden_pedido_cultivo,
	comprador,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	caja,
	tipo_caja
	where not exists
	(
		select *
		from #despacho_orden_pedido_cultivo_agrupado
		where #despacho_orden_pedido_cultivo_agrupado.id_detalle_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		and #despacho_orden_pedido_cultivo_agrupado.cantidad_piezas = detalle_orden_pedido_cultivo.cantidad_piezas
	)
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and farm.id_farm = orden_pedido_cultivo.id_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
	and tapa.id_tapa = detalle_orden_pedido_cultivo.id_tapa
	and caja.id_caja = detalle_orden_pedido_cultivo.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and comprador.id_comprador = orden_pedido_cultivo.id_comprador
	and comprador.id_comprador = @id_comprador

	if(@accion2 is null)
	begin
		select * 
		from #resultado
		order by numero_consecutivo,
		nombre_farm,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor
	end
	else
	if(@accion2 = 'consultar_reprogramacion')
	begin
		select id_detalle_orden_pedido_cultivo,
		0 as id_despacho_orden_pedido_cultivo,
		id_farm,
		nombre_farm,
		descripcion_pedido,
		numero_consecutivo,
		id_tipo_flor,
		nombre_tipo_flor,
		id_variedad_flor,
		nombre_variedad_flor,
		id_grado_flor,
		nombre_grado_flor,
		id_tapa,
		nombre_tapa,
		id_caja,
		nombre_caja,
		marca,
		fecha_inicial,
		unidades_por_pieza,
		piezas_totales - (piezas_aprobadas + piezas_rechazadas) as piezas_totales,
		valor_unitario,
		comentario_detalle_pedido 
		from #resultado
		union all
		select detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
		despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo,
		farm.id_farm,
		ltrim(rtrim(farm.nombre_farm)) + ' [' + farm.idc_farm + ']' as nombre_farm,
		orden_pedido_cultivo.descripcion as descripcion_pedido,
		orden_pedido_cultivo.numero_consecutivo,
		tipo_flor.id_tipo_flor,
		ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
		variedad_flor.id_variedad_flor,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		grado_flor.id_grado_flor,
		ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
		tapa.id_tapa,
		ltrim(rtrim(tapa.nombre_tapa)) + ' [' + tapa.idc_tapa + ']' as nombre_tapa,
		caja.id_caja,
		ltrim(rtrim(caja.nombre_caja)) + ' [' + tipo_caja.idc_tipo_caja + caja.idc_caja + ']' as nombre_caja,
		detalle_orden_pedido_cultivo.marca,
		despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
		detalle_orden_pedido_cultivo.unidades_por_pieza,
		despacho_orden_pedido_cultivo.cantidad_piezas,
		detalle_orden_pedido_cultivo.valor_unitario,
		detalle_orden_pedido_cultivo.comentario as comentario_detalle_pedido 
		from despacho_orden_pedido_cultivo,
		estado_despacho_orden_pedido_cultivo,
		detalle_orden_pedido_cultivo,
		orden_pedido_cultivo,
		farm,
		tipo_flor,
		variedad_flor,
		grado_flor,
		tapa,
		caja,
		tipo_caja
		where not exists
		(
			select *
			from etiqueta_orden_pedido_cultivo
			where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = etiqueta_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
		)
		and estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo
		and estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'
		and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
		and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		and farm.id_farm = orden_pedido_cultivo.id_farm
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
		and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
		and tapa.id_tapa = detalle_orden_pedido_cultivo.id_tapa
		and caja.id_caja = detalle_orden_pedido_cultivo.id_caja
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		order by numero_consecutivo,
		nombre_farm,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor
	end

	drop table #resultado
	drop table #despacho_orden_pedido_cultivo
	drop table #despacho_orden_pedido_cultivo_agrupado
end
else
if(@accion = 'insertar_detalle_pedido')
begin
	insert into despacho_orden_pedido_cultivo (id_cuenta_interna, id_detalle_orden_pedido_cultivo, id_estado_despacho_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, cantidad_piezas)
	values (@id_cuenta_interna, @id_detalle_orden_pedido_cultivo, @id_estado_despacho_orden_pedido_cultivo, @id_variedad_flor, @id_grado_flor, @fecha_estimada_despacho_flor, @cantidad_piezas)

	select scope_identity() as id_despacho_orden_pedido_cultivo
end
else
if(@accion = 'estado_despacho_pedido')
begin
	select id_estado_despacho_orden_pedido_cultivo,
	nombre_estado_orden_pedido
	from estado_despacho_orden_pedido_cultivo
	where nombre_estado_orden_pedido in ('Cancelada', 'Reprogramada')
	order by id_estado_despacho_orden_pedido_cultivo
end