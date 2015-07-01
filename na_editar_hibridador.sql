set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_hibridador]

@accion nvarchar(255),
@id_hibridador int,
@id_variedad_flor int,
@id_tipo_flor nvarchar(255),
@nombre_hibridador nvarchar(255),
@@control int output

AS

declare @conteo int

if(@id_tipo_flor is null)
	set @id_tipo_flor = '%%'

if(@accion = 'consultar')
begin
	select tipo_flor.id_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	hibridador.id_hibridador,
	isnull(hibridador.nombre_hibridador,'Sin Información') as nombre_hibridador
	from
	variedad_flor left join hibridador
	on variedad_flor.id_hibridador = hibridador.id_hibridador,
	tipo_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	order by nombre_tipo_flor,
	nombre_variedad_flor
end
else
if(@accion = 'actualizar')
begin
	update variedad_flor
	set id_hibridador = @id_hibridador
	where id_variedad_flor = @id_variedad_flor
end
else
if(@accion = 'consultar_hibridador')
begin
	select id_hibridador,
	nombre_hibridador
	from hibridador
	order by nombre_hibridador
end
else 
if(@accion = 'insertar_hibridador')
begin
	select @conteo = count(*)
	from hibridador
	where ltrim(rtrim(nombre_hibridador)) = ltrim(rtrim(@nombre_hibridador))

	if(@conteo = 0)
	begin
		insert into hibridador (nombre_hibridador)
		values (@nombre_hibridador)

		set @@control = 1
		return @@control
	end
	else
	begin
		set @@control = -1
		return @@control
	end
end
else 
if(@accion = 'actualizar_hibridador')
begin
	select @conteo = count(*)
	from hibridador
	where ltrim(rtrim(nombre_hibridador)) = ltrim(rtrim(@nombre_hibridador))

	if(@conteo = 0)
	begin
		update hibridador
		set nombre_hibridador = @nombre_hibridador
		where id_hibridador = @id_hibridador

		set @@control = 1
		return @@control
	end
	else
	begin
		set @@control = -1
		return @@control
	end
end
else
if(@accion = 'eliminar_hibridador')
begin
	select @conteo = count(*)
	from variedad_flor, hibridador
	where hibridador.id_hibridador = variedad_flor.id_hibridador
	and hibridador.id_hibridador = @id_hibridador

	if(@conteo = 0)
	begin
		delete from hibridador 
		where id_hibridador = @id_hibridador

		set @@control = 1
		return @@control
	end
	else
	begin
		set @@control = -1
		return @@control
	end
end