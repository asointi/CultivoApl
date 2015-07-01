set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/05/31
-- Description:	Maneja informacion de las ordenes de pedido del cultivo
-- =============================================

alter PROCEDURE [dbo].[na_editar_orden_pedido_cultivo] 

@accion nvarchar(255),
@id_tipo_compra int,
@usuario_cobol nvarchar(255), 
@id_orden_pedido_cultivo int, 
@id_detalle_orden_pedido_cultivo int,
@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2), 
@idc_grado_flor nvarchar(2), 
@fecha_inicial datetime, 
@fecha_final datetime, 
@unidades int,
@comentario nvarchar(1024),
@numero_consecutivo int

as

if(@accion = 'consultar_tipo_compra')
begin
	select id_tipo_compra,
	nombre_tipo_compra
	from tipo_compra
	order by nombre_tipo_compra
end
else
if(@accion = 'consultar_orden_pedido')
begin
	select orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.fecha_transaccion,
	orden_pedido_cultivo.usuario_cobol,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo
	from orden_pedido_cultivo,
	tipo_compra
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and tipo_compra.id_tipo_compra = @id_tipo_compra
	order by orden_pedido_cultivo.numero_consecutivo
end
else
if(@accion = 'insertar_orden_pedido')
begin
	declare @id_orden_pedido_cultivo_aux int

	select @numero_consecutivo = max(orden_pedido_cultivo.numero_consecutivo)
	from orden_pedido_cultivo,
	tipo_compra
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and tipo_compra.id_tipo_compra = @id_tipo_compra

	if(@numero_consecutivo is null)
	begin
		set @numero_consecutivo = 1
	end
	else
	begin
		set @numero_consecutivo = @numero_consecutivo + 1
	end

	insert into orden_pedido_cultivo (usuario_cobol, descripcion, id_tipo_compra, numero_consecutivo)
	values (@usuario_cobol, @comentario, @id_tipo_compra, @numero_consecutivo)

	set @id_orden_pedido_cultivo_aux = scope_identity()

	select @numero_consecutivo as numero_consecutivo,
	@id_orden_pedido_cultivo_aux as id_orden_pedido_cultivo
end
else
if(@accion = 'insertar_detalle_orden_pedido')
begin
	declare @id_variedad_flor int, 
	@id_grado_flor int

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
	
	insert into detalle_orden_pedido_cultivo (id_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_inicial, fecha_final, unidades, comentario)
	values (@id_orden_pedido_cultivo, @id_variedad_flor, @id_grado_flor, @fecha_inicial, @fecha_final, @unidades, @comentario)
end
else
if(@accion = 'consultar_detalle_orden_pedido')
begin
	select tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
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
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.unidades,
	detalle_orden_pedido_cultivo.comentario
	from orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_compra
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
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
	and orden_pedido_cultivo.numero_consecutivo > =
	case
		when @numero_consecutivo = 0 then 1
		else @numero_consecutivo
	end
	and orden_pedido_cultivo.numero_consecutivo < =
	case
		when @numero_consecutivo = 0 then 99999999
		else @numero_consecutivo
	end
	order by tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final
end
else
if(@accion = 'eliminar_detalle_orden_pedido')
begin
	declare @conteo int
	
	select @conteo = count(*)
	from detalle_orden_pedido_cultivo
	where id_detalle_orden_pedido_cultivo = @id_detalle_orden_pedido_cultivo

	if(@conteo = 0)
	begin
		delete from detalle_orden_pedido_cultivo
		where id_detalle_orden_pedido_cultivo = @id_detalle_orden_pedido_cultivo

		select 1 as resultado
	end
	else
	begin
		select -1 as resultado
	end
end