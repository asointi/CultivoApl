set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[na_editar_temporada]

@nombre_item nvarchar(255),
@id_temporada nvarchar(255),
@id_año nvarchar(255),
@accion nvarchar(255),
@nombre_tabla nvarchar(255),
@fecha_inicial datetime,
@disponible bit,
@id_tipo_venta int

AS

declare @conteo int

if(@nombre_tabla = 'temporada')
begin
	select @conteo = count(*) 
	from temporada 
	where ltrim(rtrim(nombre_temporada)) = ltrim(rtrim(@nombre_item))

	if(@accion = 'consultar')
	begin
		if(@id_temporada is null)
			set @id_temporada = '%%'

		select id_temporada,
		nombre_temporada 
		from temporada
		where id_temporada like @id_temporada
		order by nombre_temporada
	end
	else
	if(@accion = 'eliminar')
	begin
		delete from temporada
		where id_temporada = @id_temporada
	end
	else
	if(@accion = 'modificar')
	begin
		update temporada
		set nombre_temporada = @nombre_item
		where id_temporada = @id_temporada
	end
	else
	if(@conteo = 0)
	begin
		if(@accion = 'insertar')
		begin
			insert into temporada (nombre_temporada)
			values (@nombre_item)
			return scope_identity()
		end
	end
	else
		return -1
end
else
if(@nombre_tabla = 'año')
begin
	select @conteo = count(*) 
	from año 
	where ltrim(rtrim(nombre_año)) = ltrim(rtrim(@nombre_item))

	if(@accion = 'consultar')
	begin
		if(@id_año is null)
			set @id_año = '%%'

		select id_año,
		id_año as id_ano,	
		nombre_año 
		from año
		where id_año like @id_año
		order by nombre_año
	end
	else
	if(@accion = 'eliminar')
	begin
		delete from año
		where id_año = @id_año
	end
	else
	if(@accion = 'modificar')
	begin
		update año
		set nombre_año = @nombre_item
		where id_año = @id_año
	end
	else
	if(@conteo = 0)
	begin
		if(@accion = 'insertar')
		begin
			insert into año (nombre_año)
			values (@nombre_item)
			return scope_identity()
		end
	end
	else
		return -1
end
else
if(@nombre_tabla = 'temporada_año')
begin
	select @conteo = count(*) 
	from temporada_año 
	where (id_temporada = @id_temporada
	and id_año = @id_año)
	or fecha_inicial = @fecha_inicial

	if(@accion = 'consultar')
	begin
		if(@id_temporada is null)
			set @id_temporada = '%%'
		if(@id_año is null)
			set @id_año = '%%'

		select '[' + convert(nvarchar, temporada_cubo.fecha_inicial, 101) + ' - ' + convert(nvarchar, temporada_cubo.fecha_final, 101) + ']' + ' ' + temporada.nombre_temporada + ' - ' + tipo_venta.nombre_tipo_venta as nombre_completo_temporada,
		temporada_año.id_temporada_año,
		temporada_año.id_temporada_año as id_temporada_ano,
		temporada_año.disponible,
		temporada_cubo.id_temporada,
		temporada.nombre_temporada,
		temporada_cubo.id_año,
		temporada_cubo.id_año as id_ano,
		año.nombre_año,
		año.nombre_año as nombre_ano,
		tipo_venta.id_tipo_venta,
		tipo_venta.nombre_tipo_venta,
		temporada_cubo.fecha_inicial,
		temporada_cubo.fecha_final,
		año.nombre_año + space(1) + '-' + space(1) + temporada.nombre_temporada + space(1) + '-' + space(1) + convert(nvarchar,temporada_año.fecha_inicial,101) as nombre,
		convert(bit, isnull((
			select 1
			from configuracion_bd
			where configuracion_bd.id_temporada_año = temporada_año.id_temporada_año
		), 0)) as temporada_actual,
		convert(bit, isnull((
			select 1
			from configuracion_bd
			where configuracion_bd.id_temporada_año_preventa = temporada_año.id_temporada_año
		), 0)) as temporada_actual_preventa
		from temporada_cubo,
		temporada_año, 
		año,
		temporada,
		tipo_venta
		where temporada_año.id_temporada = temporada_cubo.id_temporada
		and temporada_año.id_año = temporada_cubo.id_año
		and temporada_año.id_año = año.id_año
		and temporada_año.id_temporada = temporada.id_temporada
		and temporada_cubo.id_temporada like @id_temporada
		and temporada_cubo.id_año like @id_año
		and temporada_año.id_tipo_venta = tipo_venta.id_tipo_venta
		order by temporada_cubo.fecha_inicial desc
	end
	else
	if(@accion = 'consultar_disponibles')
	begin
		select temporada_año.id_temporada_año,
		temporada_año.id_temporada_año as id_temporada_ano,
		temporada.nombre_temporada + space(1) + '(' + convert(nvarchar,temporada_cubo.fecha_inicial,101) + '-' + convert(nvarchar,temporada_cubo.fecha_final,101) + ')' as nombre_completo,
		temporada_cubo.fecha_inicial,
		temporada_cubo.fecha_final
		from temporada_cubo,
		temporada_año, 
		año,
		temporada
		where temporada_año.id_temporada = temporada_cubo.id_temporada
		and temporada_año.id_año = temporada_cubo.id_año
		and temporada_año.id_año = año.id_año
		and temporada_año.id_temporada = temporada.id_temporada
		and temporada_año.disponible = 1
		order by año.nombre_año,temporada_cubo.fecha_inicial
	end
	else
	if(@accion = 'eliminar')
	begin
		delete from temporada_año
		where id_temporada = @id_temporada
		and id_año = @id_año
	end
	else
	if(@accion = 'modificar')
	begin
		update temporada_año
		set fecha_inicial = @fecha_inicial,
		disponible = @disponible,
		id_tipo_venta = @id_tipo_venta
		where id_temporada = @id_temporada
		and id_año = @id_año
	end
	else
	if(@conteo = 0)
	begin
		if(@accion = 'insertar')
		begin
			insert into temporada_año (id_temporada, id_año, fecha_inicial, disponible, id_tipo_venta)
			values (@id_temporada, @id_año,@fecha_inicial, @disponible, @id_tipo_venta)
			return scope_identity()
		end
	end
	else
		return -1
end
else
if(@accion = 'consultar_temporada')
begin
	select temporada_año.id_temporada_año,
	temporada_año.id_temporada_año as id_temporada_ano,
	temporada_año.disponible,
	temporada_cubo.id_temporada,
	temporada.nombre_temporada,
	temporada_cubo.id_año,
	temporada_cubo.id_año as id_ano,
	año.nombre_año,
	año.nombre_año as nombre_ano,
	tipo_venta.id_tipo_venta,
	tipo_venta.nombre_tipo_venta,
	temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	año.nombre_año + space(1) + '-' + space(1) + temporada.nombre_temporada + space(1) + '-' + space(1) + convert(nvarchar,temporada_año.fecha_inicial,101) as nombre,
	convert(bit, isnull((
		select 1
		from configuracion_bd
		where configuracion_bd.id_temporada_año = temporada_año.id_temporada_año
	), 0)) as temporada_actual,
	convert(bit, isnull((
		select 1
		from configuracion_bd
		where configuracion_bd.id_temporada_año_preventa = temporada_año.id_temporada_año
	), 0)) as temporada_actual_preventa
	from temporada_cubo,
	temporada_año, 
	año,
	temporada,
	tipo_venta
	where temporada_año.id_temporada = temporada_cubo.id_temporada
	and temporada_año.id_año = temporada_cubo.id_año
	and temporada_año.id_año = año.id_año
	and temporada_año.id_temporada = temporada.id_temporada
	and temporada_año.id_tipo_venta = tipo_venta.id_tipo_venta
	and tipo_venta.id_tipo_venta between
	case
		when @id_tipo_venta = 0 then 1
		else @id_tipo_venta
	end
	and 
	case
		when @id_tipo_venta = 0 then 999999
		else @id_tipo_venta
	end
	order by temporada_cubo.fecha_inicial desc
end
else
if(@accion = 'consultar_tipo_venta_temporada')
begin
	select tipo_venta.id_tipo_venta,
	tipo_venta.nombre_tipo_venta	
	from temporada_cubo,
	temporada_año, 
	año,
	temporada,
	tipo_venta
	where temporada_año.id_temporada = temporada_cubo.id_temporada
	and temporada_año.id_año = temporada_cubo.id_año
	and temporada_año.id_año = año.id_año
	and temporada_año.id_temporada = temporada.id_temporada
	and temporada_año.id_tipo_venta = tipo_venta.id_tipo_venta
	and @fecha_inicial between
	temporada_cubo.fecha_inicial and temporada_cubo.fecha_final
end
else
if(@accion = 'consultar_temporada_por_fecha')
begin
	select temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	temporada.nombre_temporada,
	año.nombre_año,
	año.nombre_año as nombre_ano,
	tipo_venta.id_tipo_venta,
	tipo_venta.nombre_tipo_venta,
	temporada_año.disponible
	from temporada_cubo,
	temporada_año, 
	año,
	temporada,
	tipo_venta
	where temporada_año.id_temporada = temporada_cubo.id_temporada
	and temporada_año.id_año = temporada_cubo.id_año
	and temporada_año.id_año = año.id_año
	and temporada_año.id_temporada = temporada.id_temporada
	and temporada_año.id_tipo_venta = tipo_venta.id_tipo_venta
	and @fecha_inicial between
	temporada_cubo.fecha_inicial and temporada_cubo.fecha_final
end
else
if(@accion = 'consultar_temporada_preventas_por_defecto')
begin
	select temporada_año.id_temporada_año,
	temporada_año.id_temporada_año as id_temporada_ano,
	temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	temporada.nombre_temporada,
	año.nombre_año,
	año.nombre_año as nombre_ano,
	tipo_venta.id_tipo_venta,
	tipo_venta.nombre_tipo_venta
	from temporada_cubo,
	temporada_año, 
	año,
	temporada,
	tipo_venta,
	configuracion_bd
	where temporada_año.id_temporada = temporada_cubo.id_temporada
	and temporada_año.id_año = temporada_cubo.id_año
	and temporada_año.id_año = año.id_año
	and temporada_año.id_temporada = temporada.id_temporada
	and temporada_año.id_tipo_venta = tipo_venta.id_tipo_venta
	and temporada_año.id_temporada_año = configuracion_bd.id_temporada_año_preventa
end