set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_verificacion_detalle_pedido_bouquetera] 

@accion nvarchar(255),
@id_estado_orden_pedido_cultivo int,
@id_cuenta_interna int,
@id_detalle_orden_pedido_cultivo int,
@unidades int, 
@observacion nvarchar(255), 
@fecha_aprobada datetime,
@accion2 nvarchar(255) = null

as

if(@accion = 'consultar_pendientes')
begin
	select estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo,
	estado_orden_pedido_cultivo.nombre_estado_orden_pedido,
	verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	sum(verifica_detalle_orden_pedido_cultivo.unidades) as unidades into #verifica_detalle_orden_pedido_cultivo
	from verifica_detalle_orden_pedido_cultivo,
	estado_orden_pedido_cultivo
	where estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	group by estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo,
	estado_orden_pedido_cultivo.nombre_estado_orden_pedido,
	verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo

	select id_detalle_orden_pedido_cultivo,
	sum(unidades) as unidades into #verifica_detalle_orden_pedido_cultivo_agrupado
	from #verifica_detalle_orden_pedido_cultivo
	group by id_detalle_orden_pedido_cultivo

	select detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo into #faltantes
	from detalle_orden_pedido_cultivo
	where not exists
	(
		select *
		from #verifica_detalle_orden_pedido_cultivo_agrupado
		where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #verifica_detalle_orden_pedido_cultivo_agrupado.id_detalle_orden_pedido_cultivo
		and detalle_orden_pedido_cultivo.unidades = #verifica_detalle_orden_pedido_cultivo_agrupado.unidades 
	)

	select tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.fecha_transaccion as fecha_transaccion_orden,
	orden_pedido_cultivo.usuario_cobol as usuario_creador_orden,
	orden_pedido_cultivo.descripcion as descripcion_orden,
	orden_pedido_cultivo.numero_consecutivo as numero_consecutivo_orden,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.comentario as comentario_detalle_pedido,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.unidades as unidades_totales,
	(
		select isnull(sum(unidades),0)
		from #verifica_detalle_orden_pedido_cultivo
		where nombre_estado_orden_pedido = 'Aprobada'
		and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	) as unidades_aprobadas,
	(
		select isnull(sum(unidades),0)
		from #verifica_detalle_orden_pedido_cultivo
		where nombre_estado_orden_pedido = 'Rechazada'
		and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	) as unidades_rechazadas into #resultado
	from #faltantes,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	orden_pedido_cultivo,
	tipo_compra
	where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #faltantes.id_detalle_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra

	if(@accion2 is null)
	begin
		select id_tipo_compra,
		nombre_tipo_compra,
		id_orden_pedido_cultivo,
		fecha_transaccion_orden,
		usuario_creador_orden,
		descripcion_orden,
		numero_consecutivo_orden,
		id_detalle_orden_pedido_cultivo,
		fecha_inicial,
		fecha_final,
		comentario_detalle_pedido,
		idc_tipo_flor,
		nombre_tipo_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		idc_grado_flor,
		nombre_grado_flor,
		unidades_totales,
		unidades_aprobadas,
		unidades_rechazadas 
		from #resultado
		order by numero_consecutivo_orden,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor
	end
	else
	if(@accion2 = 'consultar_saldo_pendiente')
	begin
		select id_tipo_compra,
		nombre_tipo_compra,
		id_orden_pedido_cultivo,
		fecha_transaccion_orden,
		usuario_creador_orden,
		descripcion_orden,
		numero_consecutivo_orden,
		id_detalle_orden_pedido_cultivo,
		fecha_inicial,
		fecha_final,
		comentario_detalle_pedido,
		idc_tipo_flor,
		nombre_tipo_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		idc_grado_flor,
		nombre_grado_flor,
		unidades_totales,
		unidades_aprobadas,
		unidades_rechazadas 
		from #resultado
		union all
		select tipo_compra.id_tipo_compra,
		tipo_compra.nombre_tipo_compra,
		orden_pedido_cultivo.id_orden_pedido_cultivo,
		orden_pedido_cultivo.fecha_transaccion as fecha_transaccion_orden,
		orden_pedido_cultivo.usuario_cobol as usuario_creador_orden,
		orden_pedido_cultivo.descripcion as descripcion_orden,
		orden_pedido_cultivo.numero_consecutivo as numero_consecutivo_orden,
		detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
		detalle_orden_pedido_cultivo.fecha_inicial,
		detalle_orden_pedido_cultivo.fecha_final,
		detalle_orden_pedido_cultivo.comentario as comentario_detalle_pedido,
		tipo_flor.idc_tipo_flor,
		ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
		variedad_flor.idc_variedad_flor,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
		grado_flor.idc_grado_flor,
		ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
		detalle_orden_pedido_cultivo.unidades as unidades_totales,
		(
			select isnull(sum(unidades),0)
			from #verifica_detalle_orden_pedido_cultivo
			where nombre_estado_orden_pedido = 'Aprobada'
			and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		) as unidades_aprobadas,
		(
			select isnull(sum(unidades),0)
			from #verifica_detalle_orden_pedido_cultivo
			where nombre_estado_orden_pedido = 'Rechazada'
			and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		) as unidades_rechazadas 
		from detalle_orden_pedido_cultivo,
		verifica_detalle_orden_pedido_cultivo,
		tipo_flor,
		variedad_flor,
		grado_flor,
		orden_pedido_cultivo,
		tipo_compra
		where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
		and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
		and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
		and tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
		and not exists
		(
			select *
			from #faltantes
			where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #faltantes.id_detalle_orden_pedido_cultivo
		)
		group by tipo_compra.id_tipo_compra,
		tipo_compra.nombre_tipo_compra,
		orden_pedido_cultivo.id_orden_pedido_cultivo,
		orden_pedido_cultivo.fecha_transaccion,
		orden_pedido_cultivo.usuario_cobol,
		orden_pedido_cultivo.descripcion,
		orden_pedido_cultivo.numero_consecutivo,
		detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
		detalle_orden_pedido_cultivo.fecha_inicial,
		detalle_orden_pedido_cultivo.fecha_final,
		detalle_orden_pedido_cultivo.comentario,
		tipo_flor.idc_tipo_flor,
		ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
		variedad_flor.idc_variedad_flor,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
		grado_flor.idc_grado_flor,
		ltrim(rtrim(grado_flor.nombre_grado_flor)),
		detalle_orden_pedido_cultivo.unidades
	end

	drop table #verifica_detalle_orden_pedido_cultivo
	drop table #verifica_detalle_orden_pedido_cultivo_agrupado
	drop table #faltantes
end
else
if(@accion = 'consultar_estado_orden_pedido')
begin
	select id_estado_orden_pedido_cultivo,
	nombre_estado_orden_pedido
	from estado_orden_pedido_cultivo
	where nombre_estado_orden_pedido in ('Aprobada', 'Rechazada')
end
else
if(@accion = 'insertar_verificacion_pedido')
begin
	if(@id_estado_orden_pedido_cultivo = 4)
	begin
		select @fecha_aprobada = fecha_final 
		from detalle_orden_pedido_cultivo
		where id_detalle_orden_pedido_cultivo = @id_detalle_orden_pedido_cultivo
	end

	insert into verifica_detalle_orden_pedido_cultivo (id_cuenta_interna, id_detalle_orden_pedido_cultivo, id_estado_orden_pedido_cultivo, unidades, observacion, fecha_aprobada)
	values (@id_cuenta_interna, @id_detalle_orden_pedido_cultivo, @id_estado_orden_pedido_cultivo, @unidades, @observacion, @fecha_aprobada)

	select scope_identity() as id_verifica_detalle_orden_pedido_cultivo
end