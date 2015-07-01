set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/05/27
-- Description:	Maneja informacion de la recepcion de las ordenes de pedido del cultivo para la base de datos BD_VM_BQT
-- =============================================

alter PROCEDURE [dbo].[na_editar_bouquetera_recibo_flor] 

@accion nvarchar(50),
@id_detalle_orden_pedido_cultivo int, 
@id_despacho_orden_pedido_cultivo int,
@fecha_estimada_recibo_flor nvarchar(8), 
@hora_estimada_recibo_flor nvarchar(8), 
@usuario_cobol nvarchar(50),
@numero_remision nvarchar(10),
@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2),
@idc_grado_flor nvarchar(2),
@id_comprador int,
@idc_pieza nvarchar(25),
@cantidad_piezas int,
@idc_farm nvarchar(2),
@idc_tapa nvarchar(2),
@idc_caja nvarchar(2)

as

declare @cantidad_piezas_saldo int,
@cantidad_piezas_originales int

if(@accion = 'consultar_saldos')
begin
	select orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	comprador.id_comprador,
	comprador.nombre_comprador,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	detalle_orden_pedido_cultivo.marca,
	detalle_orden_pedido_cultivo.comentario,
	detalle_orden_pedido_cultivo.valor_unitario,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	tapa.idc_tapa,
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo.id_descontar,
	despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo_padre,
	despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
	convert(nvarchar, despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 108) as hora_estimada_recibo_flor,
	despacho_orden_pedido_cultivo.cantidad_piezas as saldo,	
	isnull((
		select sum(d.cantidad_piezas)
		from detalle_recibo_flor,
		despacho_orden_pedido_cultivo as d
		where d.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
		and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = d.id_despacho_orden_pedido_cultivo
	),0) as cantidad_piezas_recibidas,
	estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido into #temp
	from orden_pedido_cultivo,
	comprador,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	despacho_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo,
	farm,
	tapa,
	tipo_caja,
	caja
	where farm.id_farm = detalle_orden_pedido_cultivo.id_farm
	and tapa.id_tapa = detalle_orden_pedido_cultivo.id_tapa
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = detalle_orden_pedido_cultivo.id_caja
	and comprador.id_comprador = orden_pedido_cultivo.id_comprador
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo
	and comprador.id_comprador = @id_comprador
	and tipo_flor.idc_tipo_flor > =
	case
		when @idc_tipo_flor = '' then '  '
		else @idc_tipo_flor
	end
	and tipo_flor.idc_tipo_flor < =
	case
		when @idc_tipo_flor = '' then 'ZZ'
		else @idc_tipo_flor
	end
	and variedad_flor.idc_variedad_flor > =
	case
		when @idc_variedad_flor = '' then '  '
		else @idc_variedad_flor
	end
	and variedad_flor.idc_variedad_flor < =
	case
		when @idc_variedad_flor = '' then 'ZZ'
		else @idc_variedad_flor
	end
	and grado_flor.idc_grado_flor > =
	case
		when @idc_grado_flor = '' then '  '
		else @idc_grado_flor
	end
	and grado_flor.idc_grado_flor < =
	case
		when @idc_grado_flor = '' then 'ZZ'
		else @idc_grado_flor
	end
	and farm.idc_farm > =
	case
		when @idc_farm = '' then '  '
		else @idc_farm
	end
	and farm.idc_farm < =
	case
		when @idc_farm = '' then 'ZZ'
		else @idc_farm
	end
	and tapa.idc_tapa > =
	case
		when @idc_tapa = '' then '  '
		else @idc_tapa
	end
	and tapa.idc_tapa < =
	case
		when @idc_tapa = '' then 'ZZ'
		else @idc_tapa
	end
	and tipo_caja.idc_tipo_caja + caja.idc_caja > =
	case
		when @idc_caja = '' then '  '
		else @idc_caja
	end
	and tipo_caja.idc_tipo_caja + caja.idc_caja < =
	case
		when @idc_caja = '' then 'ZZ'
		else @idc_caja
	end
	order by nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_farm,
	nombre_tapa,
	nombre_caja,
	fecha_estimada_recibo_flor

	select id_orden_pedido_cultivo,
	id_detalle_orden_pedido_cultivo,
	comentario,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_farm,
	nombre_farm,
	idc_tapa,
	nombre_tapa,
	idc_caja,
	nombre_caja,
	marca,
	valor_unitario,
	id_despacho_orden_pedido_cultivo,
	id_despacho_orden_pedido_cultivo_padre,
	fecha_estimada_recibo_flor,
	hora_estimada_recibo_flor,
	cantidad_piezas_recibidas,
	saldo - 
	isnull((
		select sum(t.saldo)
		from #temp as t
		where t.id_despacho_orden_pedido_cultivo_padre = #temp.id_despacho_orden_pedido_cultivo_padre
		and #temp.id_despacho_orden_pedido_cultivo = t.id_descontar
	), 0) as saldo,	
	id_estado_despacho_orden_pedido_cultivo,
	nombre_estado_orden_pedido,
	descripcion into #temp2
	from #temp

	select id_orden_pedido_cultivo,
	id_detalle_orden_pedido_cultivo,
	comentario,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_farm,
	nombre_farm,
	idc_tapa,
	nombre_tapa,
	idc_caja,
	nombre_caja,
	marca,
	valor_unitario,
	id_despacho_orden_pedido_cultivo,
	id_despacho_orden_pedido_cultivo_padre,
	fecha_estimada_recibo_flor,
	hora_estimada_recibo_flor,
	cantidad_piezas_recibidas,
	saldo - cantidad_piezas_recibidas as saldo,
	id_estado_despacho_orden_pedido_cultivo,
	nombre_estado_orden_pedido,
	descripcion
	from #temp2
	where (saldo - cantidad_piezas_recibidas) > 0
	and nombre_estado_orden_pedido not in ('Recibida', 'Cancelada')

	drop table #temp
	drop table #temp2
end
else
if(@accion = 'consultar_despacho_orden_pedido')
begin
	select max(id_despacho_orden_pedido_cultivo) as id_despacho_orden_pedido_cultivo into #despacho_orden_pedido_cultivo
	from despacho_orden_pedido_cultivo
	group by id_despacho_orden_pedido_cultivo_padre

	select estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido,
	convert(nvarchar, despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 101) as fecha_estimada_recibo_flor,
	convert(nvarchar, despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 108) as hora_estimada_recibo_flor,
	detalle_orden_pedido_cultivo.unidades_por_pieza,
	despacho_orden_pedido_cultivo.cantidad_piezas,
	despacho_orden_pedido_cultivo.usuario_cobol
	from despacho_orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo
	where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = @id_detalle_orden_pedido_cultivo
	and estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo
	and exists
	(
		select *
		from #despacho_orden_pedido_cultivo
		where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = #despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	)

	drop table #despacho_orden_pedido_cultivo
end
else
if(@accion = 'recibir_flor')
begin
	declare @id_recibo_flor int,
	@id_pieza int

	insert into recibo_flor (numero_remision, usuario_cobol)
	values (@numero_remision, @usuario_cobol)

	set @id_recibo_flor = scope_identity()

	select @id_pieza = pieza.id_pieza
	from pieza 
	where pieza.idc_pieza = @idc_pieza

	insert into recibo_flor_pieza (id_pieza, id_recibo_flor)
	values (@id_pieza, @id_recibo_flor)

	insert into detalle_recibo_flor (id_despacho_orden_pedido_cultivo, id_pieza)
	values (@id_despacho_orden_pedido_cultivo, @id_pieza)
end
else
if(@accion = 'cancelar')
begin
	select @cantidad_piezas_originales = despacho_orden_pedido_cultivo.cantidad_piezas,
	@cantidad_piezas_saldo = despacho_orden_pedido_cultivo.cantidad_piezas -
	isnull((
		select despacho_orden_pedido_cultivo.cantidad_piezas
		from detalle_recibo_flor
		where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
	), 0)
	from despacho_orden_pedido_cultivo
	where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo

	if(@cantidad_piezas_originales = @cantidad_piezas_saldo)
	begin
		update despacho_orden_pedido_cultivo
		set id_estado_despacho_orden_pedido_cultivo = estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo
		from estado_despacho_orden_pedido_cultivo
		where estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Cancelada'
		and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo
	end
	else
	begin
		insert into despacho_orden_pedido_cultivo (id_detalle_orden_pedido_cultivo, id_estado_despacho_orden_pedido_cultivo, fecha_estimada_recibo_flor, cantidad_piezas, usuario_cobol, id_despacho_orden_pedido_cultivo_padre)
		select despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo, 
		estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo, 
		despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor, 
		@cantidad_piezas_saldo, 
		@usuario_cobol,
		despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo_padre
		from estado_despacho_orden_pedido_cultivo,
		despacho_orden_pedido_cultivo
		where estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Cancelada'
		and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo
	end
end
else
if(@accion = 'reprogramar')
begin
	select @cantidad_piezas_saldo = despacho_orden_pedido_cultivo.cantidad_piezas -
	(
		select isnull(despacho_orden_pedido_cultivo.cantidad_piezas, 0)
		from detalle_recibo_flor
		where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
	)
	from despacho_orden_pedido_cultivo
	where despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo

	if(@cantidad_piezas > @cantidad_piezas_saldo)
	begin
		set @cantidad_piezas = @cantidad_piezas_saldo
	end

	insert into despacho_orden_pedido_cultivo (id_detalle_orden_pedido_cultivo, id_estado_despacho_orden_pedido_cultivo, fecha_estimada_recibo_flor, cantidad_piezas, usuario_cobol, id_despacho_orden_pedido_cultivo_padre, id_descontar, id_variedad_flor, id_grado_flor)
	select despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo, 
	estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo, 
	dbo.concatenar_fecha_hora_COBOL (@fecha_estimada_recibo_flor, @hora_estimada_recibo_flor), 
	@cantidad_piezas, 
	@usuario_cobol,
	despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo_padre,
	@id_despacho_orden_pedido_cultivo,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor
	from estado_despacho_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor
	where estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
end
else
if(@accion = 'consultar_remision')
begin
	select count(*) as existe
	from recibo_flor
	where numero_remision = @numero_remision
end
