/****** Object:  StoredProcedure [dbo].[awb_consultar_piezas_de_guia]    Script Date: 10/06/2007 10:56:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[hext_editar_salida_general_area_empleado]

@accion nvarchar(255),
@id_empleado nvarchar (255), 
@id_salida_general_area int,
@id_grupo nvarchar (255),
@@control int output

AS

set language us_english

if(@id_empleado is null)
	set @id_empleado = '%%'
if(@id_grupo is null)
	set @id_grupo = '%%'

if(@accion = 'consultar')
begin
	select salida_especifica_salida_general_area.id_empleado, 
	salida_especifica_salida_general_area.id_salida_general_area,
	empleado.Nombre as nombre_empleado, 
	empleado.CC as identificacion, 
	grupo.Nombre as nombre_grupo
	from salida_especifica_salida_general_area, 
	empleado, 
	grupo
	where grupo.id = empleado.id_grupo
	and empleado.id = salida_especifica_salida_general_area.id_empleado
	and salida_especifica_salida_general_area.id_salida_general_area = @id_salida_general_area
	order by empleado.Nombre
end
else
if(@accion = 'insertar')
begin
	declare @conteo int 

	select @conteo = count(*) 
	from salida_especifica, 
	salida_general_area	
	where salida_especifica.id_empleado = convert(int, @id_empleado) 
	and convert(nvarchar,salida_especifica.fecha_hora,101) = convert(nvarchar,salida_general_area.fecha_hora,101)
	and salida_general_area.id_salida_general_area = @id_salida_general_area
	
	select @conteo = @conteo + count(*)
	from salida_general_area,
	salida_especifica_salida_general_area
	where salida_general_area.id_salida_general_area = salida_especifica_salida_general_area.id_salida_general_area
	and salida_especifica_salida_general_area.id_empleado = convert(int, @id_empleado) 
	and convert(nvarchar(255),salida_general_area.fecha_hora,101) = 
	(select convert(nvarchar(255),salida_general_area.fecha_hora,101) 
	from salida_general_area
	where salida_general_area.id_salida_general_area = @id_salida_general_area)

	if(@conteo < 1)
	begin
		insert into salida_especifica_salida_general_area (id_empleado, id_salida_general_area)
		values (convert(int, @id_empleado), @id_salida_general_area)
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
	declare @id_salida_general int

	select @id_salida_general = salida_general.id_salida_general
	from salida_general,
	salida_general_area 
	where salida_general.id_salida_general = salida_general_area.id_salida_general
	and salida_general_area.id_salida_general_area = @id_salida_general_area
	
	delete from salida_especifica 
	where salida_especifica.id_empleado = @id_empleado
	and salida_especifica.id_salida_general = @id_salida_general
end
else
if(@accion = 'eliminar')
begin
	delete from salida_especifica_salida_general_area 
	where id_salida_general_area = @id_salida_general_area
	and id_empleado = convert(int,@id_empleado)
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
	from salida_especifica_salida_general_area, 
	salida_general_area
	where salida_general_area.id_salida_general_area = salida_especifica_salida_general_area.id_salida_general_area
	and salida_general_area.id_salida_general_area = @id_salida_general_area
	and empleado.id = salida_especifica_salida_general_area.id_empleado
	)
	and not exists
	(
	select * from grupo as g1
	where g1.nombre = 'Coltrack'
	and g1.id = grupo.id
	)
	order by nombre_empleado
end
else
if(@accion = 'consultar_filtros_grupo')
begin
	select grupo.id as id_grupo, 
	grupo.nombre as nombre_grupo
	from grupo
	where not exists
	(select * from grupo as g1
	where g1.nombre = 'Coltrack'
	and g1.id = grupo.id)
	group by grupo.id, grupo.nombre
	order by nombre_grupo
end
