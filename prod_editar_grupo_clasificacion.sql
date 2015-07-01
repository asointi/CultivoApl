set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_grupo_clasificacion]

@accion nvarchar(255),
@id_grupo_clasificacion nvarchar(255),
@id_punto_corte int,
@id_variedad_flor nvarchar(255),
@nombre_grupo_clasificacion nvarchar(255),
@@control int output

as

declare @conteo int

if(@id_grupo_clasificacion is null)
	set @id_grupo_clasificacion = '%%'

if(@id_variedad_flor is null)
	set @id_variedad_flor = '%%'

if(@accion = 'consultar_grupo')
begin
	select id_grupo_clasificacion,
	grupo_clasificacion.nombre_grupo_clasificacion as nombre_grupo_clasificacion_simple,
	nombre_grupo_clasificacion + space(1) + '(' + punto_corte.nombre_punto_corte  + ')' as 	nombre_grupo_clasificacion,
	punto_corte.nombre_punto_corte,
	punto_corte.id_punto_corte
	from grupo_clasificacion,
	punto_corte
	where id_grupo_clasificacion like @id_grupo_clasificacion
	and grupo_clasificacion.id_punto_corte = punto_corte.id_punto_corte
	order by nombre_grupo_clasificacion 
end
else
if(@accion = 'consultar_variedad_grupo')
begin
	select grupo_clasificacion.id_grupo_clasificacion,
	grupo_clasificacion.nombre_grupo_clasificacion + space(1) + '(' + punto_corte.nombre_punto_corte  + ')' as 	nombre_grupo_clasificacion,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor
	from grupo_clasificacion,
	grupo_variedad_clasificacion,
	variedad_flor,
	tipo_flor,
	punto_corte
	where variedad_flor.id_variedad_flor = grupo_variedad_clasificacion.id_variedad_flor
	and grupo_clasificacion.id_grupo_clasificacion = grupo_variedad_clasificacion.id_grupo_clasificacion
	and grupo_clasificacion.id_punto_corte = punto_corte.id_punto_corte
	and grupo_clasificacion.id_grupo_clasificacion like @id_grupo_clasificacion
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	order by grupo_clasificacion.nombre_grupo_clasificacion,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor	
end
else
if(@accion = 'insertar_variedad_grupo')
begin
	select @conteo = count(*) 
	from grupo_clasificacion,
	grupo_variedad_clasificacion
	where grupo_clasificacion.id_grupo_clasificacion = grupo_variedad_clasificacion.id_grupo_clasificacion
	and grupo_variedad_clasificacion.id_variedad_flor = convert(int,@id_variedad_flor)
	and grupo_clasificacion.id_punto_corte = (select id_punto_corte from grupo_clasificacion where id_grupo_clasificacion = convert(int,@id_grupo_clasificacion))

	if(@conteo = 0)
	begin
		insert into grupo_variedad_clasificacion (id_variedad_flor, id_grupo_clasificacion)
		values (convert(int,@id_variedad_flor), convert(int,@id_grupo_clasificacion))
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'insertar_grupo')
begin
	select @conteo = count(*) from grupo_clasificacion where ltrim(rtrim(nombre_grupo_clasificacion)) = ltrim(rtrim(@nombre_grupo_clasificacion))
	if(@conteo = 0)
	begin
		insert into grupo_clasificacion (nombre_grupo_clasificacion,id_punto_corte)
		values (@nombre_grupo_clasificacion, @id_punto_corte)
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'editar_grupo')
begin
	select @conteo = count(*) 
	from grupo_clasificacion 
	where ltrim(rtrim(nombre_grupo_clasificacion)) = ltrim(rtrim(@nombre_grupo_clasificacion))
	and id_punto_corte = @id_punto_corte

	if(@conteo = 0)
	begin
		update grupo_clasificacion
		set nombre_grupo_clasificacion = @nombre_grupo_clasificacion,
		id_punto_corte = @id_punto_corte
		where id_grupo_clasificacion = convert(int,@id_grupo_clasificacion)
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end
else
if(@accion = 'eliminar_variedad_grupo')
begin
	delete from grupo_variedad_clasificacion where id_variedad_flor = convert(int,@id_variedad_flor)
	and id_grupo_clasificacion = convert(int,@id_grupo_clasificacion)
end