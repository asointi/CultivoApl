SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[hext_editar_salida_especifica_empleado]

@accion nvarchar(255),
@id_salida_general int,
@id_empleado int, 
@id_grupo nvarchar(255), 
@fecha_hora datetime, 
@descripcion nvarchar(512),
@@control int output

AS

set language us_english

if(@id_grupo is null)
	set @id_grupo = '%%'

if(@accion = 'consultar')
begin
	select empleado.id as id_empleado, 
	salida_general.id_salida_general, 
	empleado.nombre as nombre_empleado, 
	empleado.cc as identificacion, 
	salida_especifica.fecha_hora, 
	left(convert(nvarchar,salida_especifica.fecha_hora,108),5) as hora,
	grupo.nombre as nombre_grupo, 
	salida_especifica.descripcion
	from salida_especifica, 
	empleado, 
	salida_general, 
	grupo
	where empleado.id_grupo = grupo.id
	and salida_general.id_salida_general = salida_especifica.id_salida_general
	and salida_especifica.id_empleado = empleado.id
	and salida_general.id_salida_general = @id_salida_general
	order by empleado.nombre
end
else
if(@accion = 'insertar')
begin
	declare @conteo int 

	select @conteo = count(*) 
	from salida_especifica_salida_general_area, salida_general_area
	where salida_especifica_salida_general_area.id_empleado = @id_empleado 
	and convert(nvarchar,salida_general_area.fecha_hora,101) = convert(nvarchar,@fecha_hora,101)
	and salida_general_area.id_salida_general_area = salida_especifica_salida_general_area.id_salida_general_area

	if(@conteo < 1)
	begin
		insert into salida_especifica (id_empleado, id_salida_general, fecha_hora, descripcion)
		values (@id_empleado, @id_salida_general, @fecha_hora, @descripcion)
	end
	else
	begin
		set @@control = -3
		return @@control
	end
end
else
if(@accion = 'eliminar_asignado')
begin
	declare @id_salida_general_area int

	select @id_salida_general_area = salida_general_area.id_salida_general_area 
	from salida_general,
	salida_general_area,
	salida_especifica_salida_general_area
	where salida_general.id_salida_general = salida_general_area.id_salida_general
	and salida_general_area.id_salida_general_area = salida_especifica_salida_general_area.id_salida_general_area
	and salida_especifica_salida_general_area.id_empleado = @id_empleado
	and salida_general.id_salida_general = @id_salida_general
	
	delete from salida_especifica_salida_general_area 
	where salida_especifica_salida_general_area.id_empleado = @id_empleado
	and salida_especifica_salida_general_area.id_salida_general_area = @id_salida_general_area
end
else
if(@accion = 'eliminar')
begin
	delete from salida_especifica
	where id_salida_general = @id_salida_general
	and id_empleado = @id_empleado
end
else
if(@accion = 'modificar')
begin
	update salida_especifica
	set fecha_hora = @fecha_hora,
	descripcion = @descripcion
	where id_empleado = @id_empleado
	and id_salida_general = @id_salida_general
end
else
if(@accion = 'consultar_empleado')
begin
	select empleado.id as id_empleado, 
	empleado.Nombre as nombre_empleado, 
	empleado.cc as identificacion, 
	grupo.nombre as nombre_grupo
	from empleado, 
	grupo
	where grupo.id = empleado.id_grupo
	and grupo.id like @id_grupo
	and not exists
	(
	select * 
	from salida_especifica, 
	salida_general
	where salida_general.id_salida_general = salida_especifica.id_salida_general
	and salida_general.id_salida_general = @id_salida_general
	and empleado.id = salida_especifica.id_empleado
	)
	and not exists
	(
	select * from grupo as g1
	where g1.nombre = 'Coltrack'
	and g1.id = grupo.id
	)
	order by nombre_empleado
end