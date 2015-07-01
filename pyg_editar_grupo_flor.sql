set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[p&g_editar_grupo_flor] 

@id_grupo_flor int,
@nombre_grupo_flor nvarchar(255),
@id_variedad_flor int,
@accion nvarchar(50)

as

declare @conteo int

if(@accion = 'crear_grupo_flor')
begin
	select @conteo = count(*)
	from grupo_flor
	where nombre_grupo_flor = @nombre_grupo_flor

	if(@conteo = 0)
	begin
		insert into grupo_flor (nombre_grupo_flor)
		values (@nombre_grupo_flor)

		select scope_identity() as id_grupo_flor
	end
	else
	begin
		select -1 as id_grupo_flor
	end
end
else
if(@accion = 'editar_grupo_flor')
begin
	select @conteo = count(*)
	from grupo_flor
	where nombre_grupo_flor = @nombre_grupo_flor

	if(@conteo = 0)
	begin
		update grupo_flor
		set nombre_grupo_flor = @nombre_grupo_flor
		where id_grupo_flor = @id_grupo_flor
		
		select 1 as id_grupo_flor
	end
	else
	begin
		select -1 as id_grupo_flor
	end
end
else
if(@accion = 'consultar_grupo_flor')
begin
	select id_grupo_flor,
	nombre_grupo_flor,
	(
		select count(*)
		from grupo_flor_variedad_flor
		where grupo_flor.id_grupo_flor = grupo_flor_variedad_flor.id_grupo_flor
	) as borrar
	from grupo_flor
	order by nombre_grupo_flor
end
else
if(@accion = 'eliminar_grupo_flor')
begin
	delete from grupo_flor
	where id_grupo_flor = @id_grupo_flor
end
else
if(@accion = 'crear_grupo_flor_variedad')
begin
	begin try
		insert into grupo_flor_variedad_flor (id_grupo_flor, id_variedad_flor)
		values (@id_grupo_flor, @id_variedad_flor)

		select scope_identity() as id_grupo_flor_variedad
	end try
	begin catch
		select -1 as id_grupo_flor_variedad
	end catch
end
else
if(@accion = 'eliminar_grupo_flor_variedad')
begin
	delete from grupo_flor_variedad_flor
	where id_grupo_flor = @id_grupo_flor
	and id_variedad_flor = @id_variedad_flor
end
else
if(@accion = 'consultar_grupo_flor_variedad')
begin
	select grupo_flor.id_grupo_flor,
	grupo_flor.nombre_grupo_flor,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grupo_flor_variedad_flor.id_grupo_flor_variedad_flor
	from grupo_flor,
	grupo_flor_variedad_flor,
	variedad_flor,
	tipo_flor
	where grupo_flor.id_grupo_flor = grupo_flor_variedad_flor.id_grupo_flor
	and variedad_flor.id_variedad_flor = grupo_flor_variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and grupo_flor.id_grupo_flor = @id_grupo_flor
end