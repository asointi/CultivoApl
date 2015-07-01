set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/05/17
-- Description:	Maneja informacion de la recepcion de las ordenes de pedido del cultivo
-- =============================================

alter PROCEDURE [dbo].[na_editar_despacho_orden_pedido_cultivo_version2] 

@accion nvarchar(50),
@id_verifica_detalle_orden_pedido_cultivo int,
@id_despacho_orden_pedido_cultivo int,
@fecha nvarchar(8), 
@hora nvarchar(8),
@unidades int, 
@usuario_cobol nvarchar(50),
@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2),
@idc_grado_flor nvarchar(2),
@id_tipo_compra int

as

if(@accion = 'reprogramar')
begin
	if(@id_despacho_orden_pedido_cultivo = 0)
	begin
		insert into despacho_orden_pedido_cultivo (id_verifica_detalle_orden_pedido_cultivo, id_estado_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, unidades, usuario_cobol)
		select @id_verifica_detalle_orden_pedido_cultivo, 
		estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo, 
		variedad_flor.id_variedad_flor, 
		grado_flor.id_grado_flor, 
		[dbo].[concatenar_fecha_hora_COBOL] (@fecha, @hora),
		@unidades, 
		@usuario_cobol
		from estado_orden_pedido_cultivo,
		tipo_flor,
		variedad_flor,
		grado_flor
		where estado_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor

		set @id_despacho_orden_pedido_cultivo = scope_identity()

		update despacho_orden_pedido_cultivo
		set id_despacho_orden_pedido_cultivo_padre = @id_despacho_orden_pedido_cultivo
		where id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo
	end
	else
	begin
		insert into despacho_orden_pedido_cultivo (id_verifica_detalle_orden_pedido_cultivo, id_estado_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, unidades, usuario_cobol, id_descontar, id_despacho_orden_pedido_cultivo_padre)
		select @id_verifica_detalle_orden_pedido_cultivo, 
		estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo, 
		variedad_flor.id_variedad_flor, 
		grado_flor.id_grado_flor, 
		[dbo].[concatenar_fecha_hora_COBOL] (@fecha, @hora),
		@unidades, 
		@usuario_cobol,
		@id_despacho_orden_pedido_cultivo,
		despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo_padre
		from estado_orden_pedido_cultivo,
		tipo_flor,
		variedad_flor,
		grado_flor,
		despacho_orden_pedido_cultivo
		where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo
		and estado_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
	end
end
else
if(@accion = 'consultar_saldos')
begin
	select convert(datetime,convert(nvarchar,isnull(recibo_flor.fecha_transaccion, ''),101)) as fecha_recibo,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.fecha_transaccion as fecha_creacion,
	orden_pedido_cultivo.numero_consecutivo,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	case
		when despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo is null then tipo_flor.idc_tipo_flor
		else (
				select t.idc_tipo_flor 
				from tipo_flor as t, 
				variedad_flor as v, 
				despacho_orden_pedido_cultivo as d
				where t.id_tipo_flor = v.id_tipo_flor 
				and v.id_variedad_flor = d.id_variedad_flor
				and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_despacho_orden_pedido_cultivo
			)
	end as idc_tipo_flor,
	case
		when despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo is null then ltrim(rtrim(tipo_flor.nombre_tipo_flor))
		else (
				select ltrim(rtrim(t.nombre_tipo_flor))
				from tipo_flor as t, 
				variedad_flor as v, 
				despacho_orden_pedido_cultivo as d
				where t.id_tipo_flor = v.id_tipo_flor 
				and v.id_variedad_flor = d.id_variedad_flor
				and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_despacho_orden_pedido_cultivo
			)
	end as nombre_tipo_flor,
	case
		when despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo is null then variedad_flor.idc_variedad_flor
		else (
				select v.idc_variedad_flor 
				from variedad_flor as v, 
				despacho_orden_pedido_cultivo as d
				where v.id_variedad_flor = d.id_variedad_flor
				and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_despacho_orden_pedido_cultivo
			)
	end as idc_variedad_flor,	
	case
		when despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo is null then ltrim(rtrim(variedad_flor.nombre_variedad_flor))
		else (
				select ltrim(rtrim(v.nombre_variedad_flor))
				from variedad_flor as v, 
				despacho_orden_pedido_cultivo as d
				where v.id_variedad_flor = d.id_variedad_flor
				and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_despacho_orden_pedido_cultivo
			)
	end as nombre_variedad_flor,	
	case
		when despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo is null then grado_flor.idc_grado_flor
		else (
				select g.idc_grado_flor 
				from grado_flor as g, 
				despacho_orden_pedido_cultivo as d
				where g.id_grado_flor = d.id_grado_flor
				and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_despacho_orden_pedido_cultivo
			)
	end as idc_grado_flor,	
	case
		when despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo is null then ltrim(rtrim(grado_flor.nombre_grado_flor))
		else (
				select ltrim(rtrim(g.nombre_grado_flor))
				from grado_flor as g, 
				despacho_orden_pedido_cultivo as d
				where g.id_grado_flor = d.id_grado_flor
				and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_despacho_orden_pedido_cultivo
			)
	end as nombre_grado_flor,	
	verifica_detalle_orden_pedido_cultivo.fecha_aprobada as fecha_original,
	case
		when despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor is null then verifica_detalle_orden_pedido_cultivo.fecha_aprobada
		else convert(datetime,convert(nvarchar, despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 101))
	end as fecha,
	'23:30:00' as hora_original,
	case
		when despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor is null then '23:30:00'
		else convert(nvarchar, despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 108)
	end as hora,
	verifica_detalle_orden_pedido_cultivo.unidades as unidades_originales,
	isnull(despacho_orden_pedido_cultivo.unidades, 0) -
	(
		select isnull(sum(d.unidades), 0)
		from despacho_orden_pedido_cultivo as d
		where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_descontar
	) as unidades,	
	detalle_orden_pedido_cultivo.comentario,
	cuenta_interna.nombre as usuario_aprueba,
	verifica_detalle_orden_pedido_cultivo.fecha_transaccion as fecha_aprobacion,
	case
		when e.nombre_estado_orden_pedido is null then 'Aprobada' 
		else e.nombre_estado_orden_pedido 
	end as nombre_estado,
	estado_orden_pedido_cultivo.nombre_estado_orden_pedido as nombre_estado_original,
	isnull(despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo, 0) as id_despacho_orden_pedido_cultivo,
	convert(datetime,convert(nvarchar, isnull(despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,''), 101)) as fecha_reprogramacion into #temp
	from tipo_compra,
	cuenta_interna,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo left join despacho_orden_pedido_cultivo on verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo
	left join estado_orden_pedido_cultivo as e on e.id_estado_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	left join detalle_recibo_flor on despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
	left join recibo_flor on recibo_flor.id_recibo_flor = detalle_recibo_flor.id_recibo_flor,
	estado_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
	and estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	and estado_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Aprobada'
	and cuenta_interna.id_cuenta_interna = verifica_detalle_orden_pedido_cultivo.id_cuenta_interna

	select despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo,
	detalle_recibo_flor.unidades -
	isnull((
		SELECT SUM(d.unidades)
		from detalle_devolucion_flor as d
		where detalle_recibo_flor.id_detalle_recibo_flor = d.id_detalle_recibo_flor
	), 0) as unidades into #recepcion
	from despacho_orden_pedido_cultivo,
	detalle_recibo_flor
	where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo

	select #temp.fecha_recibo,
	#temp.fecha_inicial,
	#temp.fecha_final,
	#temp.id_tipo_compra,
	#temp.nombre_tipo_compra,
	#temp.id_orden_pedido_cultivo,
	#temp.descripcion,
	#temp.fecha_creacion,
	#temp.numero_consecutivo,
	#temp.id_detalle_orden_pedido_cultivo,
	#temp.id_verifica_detalle_orden_pedido_cultivo,
	#temp.idc_tipo_flor,
	#temp.nombre_tipo_flor,
	#temp.idc_variedad_flor,
	#temp.nombre_variedad_flor,
	#temp.idc_grado_flor,
	#temp.nombre_grado_flor,
	#temp.fecha,
	#temp.hora,
	#temp.unidades - 
	isnull((
		select sum(#recepcion.unidades)
		from #recepcion
		where #recepcion.id_despacho_orden_pedido_cultivo = #temp.id_despacho_orden_pedido_cultivo
	),0) as unidades,	
	#temp.comentario,
	#temp.usuario_aprueba,
	#temp.fecha_aprobacion,
	#temp.nombre_estado,
	#temp.id_despacho_orden_pedido_cultivo,
	#temp.fecha_reprogramacion into #temp2
	from #temp
	group by #temp.fecha_recibo,
	#temp.fecha_inicial,
	#temp.fecha_final,
	#temp.id_tipo_compra,
	#temp.nombre_tipo_compra,
	#temp.id_orden_pedido_cultivo,
	#temp.descripcion,
	#temp.fecha_creacion,
	#temp.numero_consecutivo,
	#temp.id_detalle_orden_pedido_cultivo,
	#temp.id_verifica_detalle_orden_pedido_cultivo,
	#temp.idc_tipo_flor,
	#temp.nombre_tipo_flor,
	#temp.idc_variedad_flor,
	#temp.nombre_variedad_flor,
	#temp.idc_grado_flor,
	#temp.nombre_grado_flor,
	#temp.fecha,
	#temp.hora,
	#temp.unidades,
	#temp.comentario,
	#temp.usuario_aprueba,
	#temp.fecha_aprobacion,
	#temp.nombre_estado,
	#temp.id_despacho_orden_pedido_cultivo,
	#temp.fecha_reprogramacion

	union all

	select #temp.fecha_recibo,
	#temp.fecha_inicial,
	#temp.fecha_final,
	#temp.id_tipo_compra,
	#temp.nombre_tipo_compra,
	#temp.id_orden_pedido_cultivo,
	#temp.descripcion,
	#temp.fecha_creacion,
	#temp.numero_consecutivo,
	#temp.id_detalle_orden_pedido_cultivo,
	#temp.id_verifica_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	#temp.fecha_original,
	#temp.hora_original,
	#temp.unidades_originales -
	isnull((
		select sum(t.unidades)
		from #temp as t
		where t.id_verifica_detalle_orden_pedido_cultivo = #temp.id_verifica_detalle_orden_pedido_cultivo
	),0) as unidades,
	#temp.comentario,
	#temp.usuario_aprueba,
	#temp.fecha_aprobacion,
	#temp.nombre_estado_original,
	0,
	#temp.fecha_reprogramacion
	from #temp,
	tipo_flor,
	variedad_flor,
	grado_flor
	where unidades_originales > unidades
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = #temp.id_variedad_flor
	and grado_flor.id_grado_flor = #temp.id_grado_flor
	group by #temp.fecha_recibo,
	#temp.fecha_inicial,
	#temp.fecha_final,
	#temp.id_tipo_compra,
	#temp.nombre_tipo_compra,
	#temp.id_orden_pedido_cultivo,
	#temp.descripcion,
	#temp.fecha_creacion,
	#temp.numero_consecutivo,
	#temp.id_detalle_orden_pedido_cultivo,
	#temp.id_verifica_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	#temp.fecha_original,
	#temp.hora_original,
	#temp.unidades_originales,
	#temp.comentario,
	#temp.usuario_aprueba,
	#temp.fecha_aprobacion,
	#temp.nombre_estado_original,
	#temp.fecha_reprogramacion

	select * 
	from #temp2
	where unidades > 0
	and nombre_estado not in ('Recibida', 'Cancelada')
	and id_tipo_compra > = 
	case
		when @id_tipo_compra = 0 then 1
		else @id_tipo_compra
	end
	and id_tipo_compra < = 
	case
		when @id_tipo_compra = 0 then 999
		else @id_tipo_compra
	end
	and 
	(
		convert(datetime, @fecha) < = fecha_recibo
		or fecha_recibo = convert(datetime, '')
	)
	order by numero_consecutivo,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor

	drop table #temp
	drop table #temp2
	drop table #recepcion
end
else
if(@accion = 'cancelar')
begin
	if(@id_despacho_orden_pedido_cultivo = 0)
	begin
		insert into despacho_orden_pedido_cultivo (id_verifica_detalle_orden_pedido_cultivo, id_estado_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, unidades, usuario_cobol)
		select verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo, 
		estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo, 
		detalle_orden_pedido_cultivo.id_variedad_flor, 
		detalle_orden_pedido_cultivo.id_grado_flor, 
		getdate(),
		@unidades, 
		@usuario_cobol
		from estado_orden_pedido_cultivo,
		detalle_orden_pedido_cultivo,
		verifica_detalle_orden_pedido_cultivo
		where estado_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Cancelada'
		and verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = @id_verifica_detalle_orden_pedido_cultivo
		and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo		

		set @id_despacho_orden_pedido_cultivo = scope_identity()

		update despacho_orden_pedido_cultivo
		set id_despacho_orden_pedido_cultivo_padre = @id_despacho_orden_pedido_cultivo
		where id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo
	end
	else
	begin
		insert into despacho_orden_pedido_cultivo (id_verifica_detalle_orden_pedido_cultivo, id_estado_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, unidades, usuario_cobol, id_descontar, id_despacho_orden_pedido_cultivo_padre)
		select @id_verifica_detalle_orden_pedido_cultivo, 
		estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo, 
		variedad_flor.id_variedad_flor, 
		grado_flor.id_grado_flor, 
		getdate(),
		@unidades, 
		@usuario_cobol,
		@id_despacho_orden_pedido_cultivo,
		despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo_padre
		from estado_orden_pedido_cultivo,
		tipo_flor,
		variedad_flor,
		grado_flor,
		despacho_orden_pedido_cultivo
		where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo
		and estado_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Cancelada'
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
	end
end