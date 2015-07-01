set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[rep_consultar_periferico_por_tipo] 

@id_tipo int,
@accion nvarchar(255)

AS

if(@accion = 'asignado')
begin
	declare @ultima_asignacion table
	(
		id_periferico int, 
		fecha_asignacion datetime
	)

	insert into @ultima_asignacion (id_periferico, fecha_asignacion)
	select periferico_asignado.id_periferico, 
	max(periferico_asignado.fecha_asignacion)
	from periferico_asignado
	where periferico_asignado.fecha_desasignado is null
	group by periferico_asignado.id_periferico

	select periferico.placa, 
	periferico.serial, 
	modelo.nombre_modelo, 
	marca_periferico.marca, 
	area.nombre, 
	persona.nombres + ' ' + persona.apellidos as oficina
	from periferico,
	modelo,
	marca_periferico,
	periferico_asignado,
	oficina,
	area,
	persona,
	tipo_periferico
	where tipo_periferico.id_tipo = periferico.id_tipo 
	and periferico.id_modelo = modelo.id_modelo
	and periferico.id_marca = marca_periferico.id_marca
	and periferico.id_periferico = periferico_asignado.id_periferico
	and periferico_asignado.id_oficina = oficina.id_oficina
	and oficina.id_area = area.id_area
	and oficina.id_persona = persona.id_persona
	and tipo_periferico.id_tipo = @id_tipo
	and exists
	(
		select *
		from @ultima_asignacion as ua
		where ua.id_periferico = periferico.id_periferico
		and ua.fecha_asignacion = periferico_asignado.fecha_asignacion
	)
end
else
if(@accion = 'todos')
begin
	select per.placa, per.serial, mod.nombre_modelo, mp.marca, tp.tipo
	from periferico as per
	inner join modelo as mod 
	on per.id_modelo = mod.id_modelo
	inner join marca_periferico as mp
	on per.id_marca = mp.id_marca
	inner join tipo_periferico as tp
	on per.id_tipo = tp.id_tipo
	and per.id_tipo = @id_tipo
end