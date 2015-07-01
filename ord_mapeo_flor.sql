set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_mapeo_flor]

@id_flor int,
@id_mapeo_flor int,
@id_cliente_pedido int,
@nombre_mapeo_mark nvarchar(255),
@nombre_mapeo_bouquet nvarchar(255),
@nombre_mapeo_type nvarchar(255),
@nombre_mapeo_grade nvarchar(255),
@nombre_mapeo_notes nvarchar(255),
@accion nvarchar(255)

as

declare @compone_bouquet_rosa bit

if(@accion = 'consultar')
begin
--	select @compone_bouquet_rosa = tipo_flor.compone_bouquet_rosa 
--	from tipo_flor,
--	variedad_flor,
--	grado_flor,
--	flor,
--	mapeo_flor
--	where flor.id_variedad_flor = variedad_flor.id_variedad_flor
--	and flor.id_grado_flor = grado_flor.id_grado_flor
--	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
--	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
--	and isnull(nombre_mapeo_bouquet,'') = isnull(@nombre_mapeo_bouquet,'')
--	and isnull(nombre_mapeo_type,'') = isnull(@nombre_mapeo_type,'')
--	and isnull(nombre_mapeo_grade,'') = isnull(@nombre_mapeo_grade,'')
--	and mapeo_flor.id_cliente_pedido = @id_cliente_pedido
--	and mapeo_flor.id_flor = flor.id_flor
--
--	if(@compone_bouquet_rosa = 1) 
--	begin
		select mapeo_flor.id_mapeo_flor, 
		flor.id_flor,
		flor.surtido, 
		@compone_bouquet_rosa as compone_bouquet_rosa, 
		(
			select 
			case 
				when count(*) = 0 then 0 
				else 1 
			end 
			from mapeo_flor_notes 
			where mapeo_flor_notes.id_mapeo_flor = mapeo_flor.id_mapeo_flor
			and isnull(mapeo_flor_notes.nombre_mapeo_notes,'') = isnull(@nombre_mapeo_notes,'')
		)  as cantidad
		from
		flor,
		mapeo_flor,
		variedad_flor,
		grado_flor		
		where isnull(mapeo_flor.nombre_mapeo_mark,'') = isnull(@nombre_mapeo_mark,'')
		and isnull(mapeo_flor.nombre_mapeo_bouquet,'') = isnull(@nombre_mapeo_bouquet,'')
		and isnull(mapeo_flor.nombre_mapeo_type,'') = isnull(@nombre_mapeo_type,'')
		and isnull(mapeo_flor.nombre_mapeo_grade,'') = isnull(@nombre_mapeo_grade,'')
		and mapeo_flor.id_cliente_pedido = @id_cliente_pedido
		and mapeo_flor.id_flor = flor.id_flor
		and flor.id_variedad_flor = variedad_flor.id_variedad_flor
		and flor.id_grado_flor = grado_flor.id_grado_flor
		and variedad_flor.disponible = 1
		and grado_flor.disponible = 1
--	end
--	else 
--	if(@compone_bouquet_rosa = 0)
--	begin
--		select mapeo_flor.id_mapeo_flor, 
--		flor.id_flor,
--		flor.surtido, 
--		@compone_bouquet_rosa as compone_bouquet_rosa,
--		0 as cantidad 
--		from mapeo_flor, 
--		flor,
--		variedad_flor,
--		grado_flor		
--		where isnull(mapeo_flor.nombre_mapeo_bouquet,'') = isnull(@nombre_mapeo_bouquet,'')
--		and isnull(mapeo_flor.nombre_mapeo_type,'') = isnull(@nombre_mapeo_type,'')
--		and isnull(mapeo_flor.nombre_mapeo_grade,'') = isnull(@nombre_mapeo_grade,'')
--		and mapeo_flor.id_cliente_pedido = @id_cliente_pedido
--		and mapeo_flor.id_flor = flor.id_flor
--		and flor.id_variedad_flor = variedad_flor.id_variedad_flor
--		and flor.id_grado_flor = grado_flor.id_grado_flor
--		and variedad_flor.disponible = 1
--		and grado_flor.disponible = 1
--	end
end
else
if(@accion = 'insertar')
begin
	declare @conteo_aux int

	select @compone_bouquet_rosa = tipo_flor.compone_bouquet_rosa 
	from tipo_flor, 
	variedad_flor, 
	grado_flor, 
	flor
	where flor.id_variedad_flor = variedad_flor.id_variedad_flor
	and flor.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and flor.id_flor = @id_flor

	select @conteo_aux = count(*)
	from mapeo_flor
	where mapeo_flor.id_flor = @id_flor
	and mapeo_flor.id_cliente_pedido = @id_cliente_pedido
	and isnull(mapeo_flor.nombre_mapeo_mark,'') = isnull(@nombre_mapeo_mark,'')
	and isnull(mapeo_flor.nombre_mapeo_bouquet, '') = isnull(@nombre_mapeo_bouquet,'')
	and isnull(mapeo_flor.nombre_mapeo_type, '') = isnull(@nombre_mapeo_type,'')
	and isnull(mapeo_flor.nombre_mapeo_grade,'') = isnull(@nombre_mapeo_grade,'')

	if(@compone_bouquet_rosa = 1)
	begin
		if(@conteo_aux = 0)
		begin
			declare @id_mapeo_flor_aux int
			
			insert into mapeo_flor (id_flor, id_cliente_pedido, nombre_mapeo_mark, nombre_mapeo_bouquet, nombre_mapeo_type, nombre_mapeo_grade)
			values (@id_flor, @id_cliente_pedido, @nombre_mapeo_mark, @nombre_mapeo_bouquet, @nombre_mapeo_type, @nombre_mapeo_grade)
	
			set @id_mapeo_flor_aux = scope_identity()

			insert into mapeo_flor_notes (id_mapeo_flor, nombre_mapeo_notes)
			values (@id_mapeo_flor_aux, @nombre_mapeo_notes)

			return @id_mapeo_flor_aux
		end
	end
	else
	begin
	if(@conteo_aux = 0)
		begin
			insert into mapeo_flor (id_flor, id_cliente_pedido, nombre_mapeo_bouquet, nombre_mapeo_type, nombre_mapeo_grade, nombre_mapeo_mark)
			values (@id_flor, @id_cliente_pedido, @nombre_mapeo_bouquet, @nombre_mapeo_type, @nombre_mapeo_grade, @nombre_mapeo_mark)

			return scope_identity()		
		end
	end
end
else
if(@accion = 'consultar_notes')
begin
	select isnull(mapeo_flor_notes.nombre_mapeo_notes,'') as nombre_mapeo_notes
	from mapeo_flor,
	mapeo_flor_notes
	where mapeo_flor.id_mapeo_flor = @id_mapeo_flor
	and mapeo_flor.id_mapeo_flor = mapeo_flor_notes.id_mapeo_flor
	order by mapeo_flor_notes.nombre_mapeo_notes
end
else
if(@accion = 'insertar_notes')
begin
	declare @conteo int
	
	select @conteo = count(*)
	from mapeo_flor_notes
	where id_mapeo_flor = @id_mapeo_flor
	and isnull(nombre_mapeo_notes,'') = isnull(@nombre_mapeo_notes,'')
	
	if(@conteo = 0)
	begin
		insert into mapeo_flor_notes (id_mapeo_flor, nombre_mapeo_notes)
		values (@id_mapeo_flor, @nombre_mapeo_notes)
	end
end
else
if(@accion = 'modificar')
begin
	update mapeo_flor
	set id_flor = @id_flor
	where id_mapeo_flor = @id_mapeo_flor
end
else
if(@accion = 'eliminar')
begin
	delete mapeo_flor
	where id_mapeo_flor = @id_mapeo_flor
end