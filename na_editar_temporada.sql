set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[na_editar_temporada]

@nombre_item nvarchar(255),
@id_temporada nvarchar(255),
@id_a�o nvarchar(255),
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
if(@nombre_tabla = 'a�o')
begin
	select @conteo = count(*) 
	from a�o 
	where ltrim(rtrim(nombre_a�o)) = ltrim(rtrim(@nombre_item))

	if(@accion = 'consultar')
	begin
		if(@id_a�o is null)
			set @id_a�o = '%%'

		select id_a�o,
		id_a�o as id_ano,	
		nombre_a�o 
		from a�o
		where id_a�o like @id_a�o
		order by nombre_a�o
	end
	else
	if(@accion = 'eliminar')
	begin
		delete from a�o
		where id_a�o = @id_a�o
	end
	else
	if(@accion = 'modificar')
	begin
		update a�o
		set nombre_a�o = @nombre_item
		where id_a�o = @id_a�o
	end
	else
	if(@conteo = 0)
	begin
		if(@accion = 'insertar')
		begin
			insert into a�o (nombre_a�o)
			values (@nombre_item)
			return scope_identity()
		end
	end
	else
		return -1
end
else
if(@nombre_tabla = 'temporada_a�o')
begin
	select @conteo = count(*) 
	from temporada_a�o 
	where (id_temporada = @id_temporada
	and id_a�o = @id_a�o)
	or fecha_inicial = @fecha_inicial

	if(@accion = 'consultar')
	begin
		if(@id_temporada is null)
			set @id_temporada = '%%'
		if(@id_a�o is null)
			set @id_a�o = '%%'

		select '[' + convert(nvarchar, temporada_cubo.fecha_inicial, 101) + ' - ' + convert(nvarchar, temporada_cubo.fecha_final, 101) + ']' + ' ' + temporada.nombre_temporada + ' - ' + tipo_venta.nombre_tipo_venta as nombre_completo_temporada,
		temporada_a�o.id_temporada_a�o,
		temporada_a�o.id_temporada_a�o as id_temporada_ano,
		temporada_a�o.disponible,
		temporada_cubo.id_temporada,
		temporada.nombre_temporada,
		temporada_cubo.id_a�o,
		temporada_cubo.id_a�o as id_ano,
		a�o.nombre_a�o,
		a�o.nombre_a�o as nombre_ano,
		tipo_venta.id_tipo_venta,
		tipo_venta.nombre_tipo_venta,
		temporada_cubo.fecha_inicial,
		temporada_cubo.fecha_final,
		a�o.nombre_a�o + space(1) + '-' + space(1) + temporada.nombre_temporada + space(1) + '-' + space(1) + convert(nvarchar,temporada_a�o.fecha_inicial,101) as nombre,
		convert(bit, isnull((
			select 1
			from configuracion_bd
			where configuracion_bd.id_temporada_a�o = temporada_a�o.id_temporada_a�o
		), 0)) as temporada_actual,
		convert(bit, isnull((
			select 1
			from configuracion_bd
			where configuracion_bd.id_temporada_a�o_preventa = temporada_a�o.id_temporada_a�o
		), 0)) as temporada_actual_preventa
		from temporada_cubo,
		temporada_a�o, 
		a�o,
		temporada,
		tipo_venta
		where temporada_a�o.id_temporada = temporada_cubo.id_temporada
		and temporada_a�o.id_a�o = temporada_cubo.id_a�o
		and temporada_a�o.id_a�o = a�o.id_a�o
		and temporada_a�o.id_temporada = temporada.id_temporada
		and temporada_cubo.id_temporada like @id_temporada
		and temporada_cubo.id_a�o like @id_a�o
		and temporada_a�o.id_tipo_venta = tipo_venta.id_tipo_venta
		order by temporada_cubo.fecha_inicial desc
	end
	else
	if(@accion = 'consultar_disponibles')
	begin
		select temporada_a�o.id_temporada_a�o,
		temporada_a�o.id_temporada_a�o as id_temporada_ano,
		temporada.nombre_temporada + space(1) + '(' + convert(nvarchar,temporada_cubo.fecha_inicial,101) + '-' + convert(nvarchar,temporada_cubo.fecha_final,101) + ')' as nombre_completo,
		temporada_cubo.fecha_inicial,
		temporada_cubo.fecha_final
		from temporada_cubo,
		temporada_a�o, 
		a�o,
		temporada
		where temporada_a�o.id_temporada = temporada_cubo.id_temporada
		and temporada_a�o.id_a�o = temporada_cubo.id_a�o
		and temporada_a�o.id_a�o = a�o.id_a�o
		and temporada_a�o.id_temporada = temporada.id_temporada
		and temporada_a�o.disponible = 1
		order by a�o.nombre_a�o,temporada_cubo.fecha_inicial
	end
	else
	if(@accion = 'eliminar')
	begin
		delete from temporada_a�o
		where id_temporada = @id_temporada
		and id_a�o = @id_a�o
	end
	else
	if(@accion = 'modificar')
	begin
		update temporada_a�o
		set fecha_inicial = @fecha_inicial,
		disponible = @disponible,
		id_tipo_venta = @id_tipo_venta
		where id_temporada = @id_temporada
		and id_a�o = @id_a�o
	end
	else
	if(@conteo = 0)
	begin
		if(@accion = 'insertar')
		begin
			insert into temporada_a�o (id_temporada, id_a�o, fecha_inicial, disponible, id_tipo_venta)
			values (@id_temporada, @id_a�o,@fecha_inicial, @disponible, @id_tipo_venta)
			return scope_identity()
		end
	end
	else
		return -1
end
else
if(@accion = 'consultar_temporada')
begin
	select temporada_a�o.id_temporada_a�o,
	temporada_a�o.id_temporada_a�o as id_temporada_ano,
	temporada_a�o.disponible,
	temporada_cubo.id_temporada,
	temporada.nombre_temporada,
	temporada_cubo.id_a�o,
	temporada_cubo.id_a�o as id_ano,
	a�o.nombre_a�o,
	a�o.nombre_a�o as nombre_ano,
	tipo_venta.id_tipo_venta,
	tipo_venta.nombre_tipo_venta,
	temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	a�o.nombre_a�o + space(1) + '-' + space(1) + temporada.nombre_temporada + space(1) + '-' + space(1) + convert(nvarchar,temporada_a�o.fecha_inicial,101) as nombre,
	convert(bit, isnull((
		select 1
		from configuracion_bd
		where configuracion_bd.id_temporada_a�o = temporada_a�o.id_temporada_a�o
	), 0)) as temporada_actual,
	convert(bit, isnull((
		select 1
		from configuracion_bd
		where configuracion_bd.id_temporada_a�o_preventa = temporada_a�o.id_temporada_a�o
	), 0)) as temporada_actual_preventa
	from temporada_cubo,
	temporada_a�o, 
	a�o,
	temporada,
	tipo_venta
	where temporada_a�o.id_temporada = temporada_cubo.id_temporada
	and temporada_a�o.id_a�o = temporada_cubo.id_a�o
	and temporada_a�o.id_a�o = a�o.id_a�o
	and temporada_a�o.id_temporada = temporada.id_temporada
	and temporada_a�o.id_tipo_venta = tipo_venta.id_tipo_venta
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
	temporada_a�o, 
	a�o,
	temporada,
	tipo_venta
	where temporada_a�o.id_temporada = temporada_cubo.id_temporada
	and temporada_a�o.id_a�o = temporada_cubo.id_a�o
	and temporada_a�o.id_a�o = a�o.id_a�o
	and temporada_a�o.id_temporada = temporada.id_temporada
	and temporada_a�o.id_tipo_venta = tipo_venta.id_tipo_venta
	and @fecha_inicial between
	temporada_cubo.fecha_inicial and temporada_cubo.fecha_final
end
else
if(@accion = 'consultar_temporada_por_fecha')
begin
	select temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	temporada.nombre_temporada,
	a�o.nombre_a�o,
	a�o.nombre_a�o as nombre_ano,
	tipo_venta.id_tipo_venta,
	tipo_venta.nombre_tipo_venta,
	temporada_a�o.disponible
	from temporada_cubo,
	temporada_a�o, 
	a�o,
	temporada,
	tipo_venta
	where temporada_a�o.id_temporada = temporada_cubo.id_temporada
	and temporada_a�o.id_a�o = temporada_cubo.id_a�o
	and temporada_a�o.id_a�o = a�o.id_a�o
	and temporada_a�o.id_temporada = temporada.id_temporada
	and temporada_a�o.id_tipo_venta = tipo_venta.id_tipo_venta
	and @fecha_inicial between
	temporada_cubo.fecha_inicial and temporada_cubo.fecha_final
end
else
if(@accion = 'consultar_temporada_preventas_por_defecto')
begin
	select temporada_a�o.id_temporada_a�o,
	temporada_a�o.id_temporada_a�o as id_temporada_ano,
	temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	temporada.nombre_temporada,
	a�o.nombre_a�o,
	a�o.nombre_a�o as nombre_ano,
	tipo_venta.id_tipo_venta,
	tipo_venta.nombre_tipo_venta
	from temporada_cubo,
	temporada_a�o, 
	a�o,
	temporada,
	tipo_venta,
	configuracion_bd
	where temporada_a�o.id_temporada = temporada_cubo.id_temporada
	and temporada_a�o.id_a�o = temporada_cubo.id_a�o
	and temporada_a�o.id_a�o = a�o.id_a�o
	and temporada_a�o.id_temporada = temporada.id_temporada
	and temporada_a�o.id_tipo_venta = tipo_venta.id_tipo_venta
	and temporada_a�o.id_temporada_a�o = configuracion_bd.id_temporada_a�o_preventa
end