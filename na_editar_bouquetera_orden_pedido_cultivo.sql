set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/05/27
-- Description:	Maneja informacion de las ordenes de pedido del cultivo en la base de datos de la Bouquetera
-- =============================================

ALTER PROCEDURE [dbo].[na_editar_bouquetera_orden_pedido_cultivo] 

@accion nvarchar(255),
@id_orden_pedido_cultivo int,
@marca nvarchar(5), 
@fecha_inicial NVARCHAR(15), 
@fecha_final NVARCHAR(15), 
@unidades_por_pieza int, 
@cantidad_piezas int, 
@valor_unitario decimal(20,4), 
@comentario nvarchar(1024),
@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2),
@idc_grado_flor nvarchar(2),
@idc_farm nvarchar(2),
@idc_tapa nvarchar(2),
@idc_caja nvarchar(2),
@id_comprador int,
@usuario_cobol nvarchar(50),
@descripcion nvarchar(1024),
@fecha_consulta nvarchar(15)

as

if(@accion = 'consultar_comprador')
begin
	select comprador.id_comprador,
	comprador.nombre_comprador 
	from comprador
	order by comprador.nombre_comprador
end
else
if(@accion = 'consultar_orden_pedido_cultivo')
begin
	select orden_pedido_cultivo.id_orden_pedido_cultivo,
	comprador.id_comprador,
	comprador.nombre_comprador,
	orden_pedido_cultivo.fecha_transaccion,
	orden_pedido_cultivo.usuario_cobol,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo
	from orden_pedido_cultivo,
	comprador
	where comprador.id_comprador = orden_pedido_cultivo.id_comprador
	and comprador.id_comprador = @id_comprador
	order by orden_pedido_cultivo.fecha_transaccion
end
else
if(@accion = 'insertar_orden_pedido_cultivo')
begin
	declare @numero_consecutivo int

	select @numero_consecutivo = max(orden_pedido_cultivo.numero_consecutivo)
	from orden_pedido_cultivo,
	comprador
	where comprador.id_comprador = orden_pedido_cultivo.id_comprador
	and comprador.id_comprador = @id_comprador

	if(@numero_consecutivo is null)
	begin
		set @numero_consecutivo = 1
	end
	else
	begin
		set @numero_consecutivo = @numero_consecutivo + 1
	end

	insert into orden_pedido_cultivo (id_comprador, usuario_cobol, descripcion, numero_consecutivo)
	values (@id_comprador, @usuario_cobol, @descripcion, @numero_consecutivo)

	select scope_identity() as id_orden_pedido_cultivo
end
else
if(@accion = 'insertar_detalle_orden_pedido_cultivo')
begin
	declare @fecha_automatica datetime,
	@id_detalle_orden_pedido_cultivo_aux int,
	@id_variedad_flor int,
	@id_grado_flor int,
	@id_despacho_orden_pedido_cultivo_aux int

	select @id_variedad_flor = variedad_flor.id_variedad_flor, 
	@id_grado_flor = grado_flor.id_grado_flor
	from tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor

	insert into detalle_orden_pedido_cultivo (id_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, id_farm, id_tapa, id_caja, marca, fecha_inicial, fecha_final, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario)
	select @id_orden_pedido_cultivo, 
	@id_variedad_flor, 
	@id_grado_flor, 
	farm.id_farm, 
	tapa.id_tapa, 
	caja.id_caja, 
	@marca, 
	@fecha_inicial, 
	@fecha_final, 
	@unidades_por_pieza, 
	@cantidad_piezas, 
	@valor_unitario, 
	@comentario
	from tipo_caja,
	caja,
	farm,
	tapa
	where farm.idc_farm = @idc_farm
	and tapa.idc_tapa = @idc_tapa
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja

	set @id_detalle_orden_pedido_cultivo_aux = scope_identity()

	if(convert(datetime, @fecha_inicial) < convert(datetime, @fecha_final))
	begin
		set @fecha_automatica = @fecha_final
	end
	else
	begin
		set @fecha_automatica = @fecha_inicial
	end

	set @fecha_automatica = dateadd(hh, 23, @fecha_automatica)
	set @fecha_automatica = dateadd(mi, 59, @fecha_automatica)

	insert into despacho_orden_pedido_cultivo (id_detalle_orden_pedido_cultivo, id_estado_despacho_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, cantidad_piezas, usuario_cobol)
	select @id_detalle_orden_pedido_cultivo_aux, 
	estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo, 
	@id_variedad_flor, 
	@id_grado_flor, 
	@fecha_automatica, 
	@cantidad_piezas, 
	'SQL'
	from estado_despacho_orden_pedido_cultivo
	where estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Activa'

	set @id_despacho_orden_pedido_cultivo_aux = scope_identity()

	update despacho_orden_pedido_cultivo
	set id_despacho_orden_pedido_cultivo_padre = @id_despacho_orden_pedido_cultivo_aux
	where id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo_aux
end
else
if(@accion = 'consultar_detalle_orden_pedido_cultivo')
begin
	select orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.fecha_transaccion,
	orden_pedido_cultivo.usuario_cobol,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
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
	detalle_orden_pedido_cultivo.marca,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.unidades_por_pieza,
	detalle_orden_pedido_cultivo.cantidad_piezas,
	detalle_orden_pedido_cultivo.valor_unitario,
	detalle_orden_pedido_cultivo.comentario
	from orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	tapa,
	tipo_caja,
	caja,
	comprador
	where comprador.id_comprador = orden_pedido_cultivo.id_comprador
	and comprador.id_comprador = @id_comprador
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
	and farm.id_farm = detalle_orden_pedido_cultivo.id_farm
	and tapa.id_tapa = detalle_orden_pedido_cultivo.id_tapa
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = detalle_orden_pedido_cultivo.id_caja
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
	and detalle_orden_pedido_cultivo.fecha_inicial > =
	case
		when @fecha_consulta = '' then convert(datetime, '20000101')
		else convert(datetime, @fecha_consulta)
	end
	and detalle_orden_pedido_cultivo.fecha_final < =
	case
		when @fecha_consulta = '' then convert(datetime, '20500101')
		else convert(datetime, @fecha_consulta)
	end
	and orden_pedido_cultivo.id_orden_pedido_cultivo > =
	case
		when @id_orden_pedido_cultivo = 0 then 1
		else @id_orden_pedido_cultivo
	end
	and orden_pedido_cultivo.id_orden_pedido_cultivo < =
	case
		when @id_orden_pedido_cultivo = 0 then 99999999
		else @id_orden_pedido_cultivo
	end
	order by tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	farm.nombre_farm,
	tapa.nombre_tapa,
	caja.nombre_caja,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final
end
