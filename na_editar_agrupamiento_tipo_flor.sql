set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/07/12
-- Description:	Se utiliza para agrupar los tipos de flor, con el fin de generar reportes con ventas acumuladas
-- =============================================

alter PROCEDURE [dbo].[na_editar_agrupamiento_tipo_flor] 

@accion nvarchar(255),
@nombre_grupo_tipo_flor nvarchar(255),
@id_grupo_tipo_flor int,
@id_tipo_flor int,
@idc_tipo_flor nvarchar(2)

as

declare @conteo int

if(@accion = 'ingresar_grupo')
begin
	select @conteo = count(*)
	from grupo_tipo_flor
	where ltrim(rtrim(nombre_grupo_tipo_flor)) = ltrim(rtrim(@nombre_grupo_tipo_flor))

	if(@conteo = 0)
	begin
		insert into grupo_tipo_flor (nombre_grupo_tipo_flor)
		values (ltrim(rtrim(@nombre_grupo_tipo_flor)))

		select 1 as ingresado
	end
	else
	begin
		select 0 as ingresado
	end
end
else
if(@accion = 'consultar_grupo')
begin
	select id_grupo_tipo_flor,
	ltrim(rtrim(nombre_grupo_tipo_flor)) as nombre_grupo_tipo_flor
	from grupo_tipo_flor
	order by nombre_grupo_tipo_flor
end
else
if(@accion = 'modificar_grupo')
begin
	select @conteo = count(*)
	from grupo_tipo_flor
	where ltrim(rtrim(nombre_grupo_tipo_flor)) = ltrim(rtrim(@nombre_grupo_tipo_flor))

	if(@conteo = 0)
	begin
		update grupo_tipo_flor
		set nombre_grupo_tipo_flor = @nombre_grupo_tipo_flor
		where id_grupo_tipo_flor = @id_grupo_tipo_flor

		select 1 as actualizado
	end
	else
	begin
		select 0 as actualizado
	end
end
else
if(@accion = 'eliminar_grupo')
begin
	select @conteo = count(*)
	from grupo_tipo_flor,
	tipo_flor_agrupado
	where grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor
	and grupo_tipo_flor.id_grupo_tipo_flor = @id_grupo_tipo_flor

	if(@conteo = 0)
	begin
		delete from grupo_tipo_flor
		where id_grupo_tipo_flor = @id_grupo_tipo_flor

		select 1 as eliminado
	end
	else
	begin

		select 0 as eliminado
	end
end
else
if(@accion = 'ingresar_tipo_flor_agrupado')
begin
	select @conteo = count(*)
	from tipo_flor_agrupado,
	tipo_flor
	where tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor

	if(@conteo = 0)	
	begin
		insert into tipo_flor_agrupado (id_tipo_flor, id_grupo_tipo_flor)
		select tipo_flor.id_tipo_flor,
		@id_grupo_tipo_flor
		from tipo_flor
		where tipo_flor.idc_tipo_flor = @idc_tipo_flor

		select 1 as ingresado
	end
	else
	begin
		select 0 as ingresado
	end
end 
else
if(@accion = 'consultar_tipo_flor_agrupado')
begin
	select grupo_tipo_flor.id_grupo_tipo_flor,
	ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor)) as nombre_grupo_tipo_flor,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor
	from tipo_flor_agrupado,
	grupo_tipo_flor,
	tipo_flor
	where tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor
	and grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor
	and grupo_tipo_flor.id_grupo_tipo_flor > =
	case
		when @id_grupo_tipo_flor = 0 then 1
		else @id_grupo_tipo_flor
	end
	and grupo_tipo_flor.id_grupo_tipo_flor < =
	case
		when @id_grupo_tipo_flor = 0 then 99999
		else @id_grupo_tipo_flor
	end
	order by nombre_grupo_tipo_flor,
	nombre_tipo_flor
end
else
if(@accion = 'eliminar_tipo_flor_agrupado')
begin
	delete from tipo_flor_agrupado
	where id_tipo_flor = @id_tipo_flor
end