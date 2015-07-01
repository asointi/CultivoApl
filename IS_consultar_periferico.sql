set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[consultar_periferico] 
	@id_oficina int,
	@accion nvarchar(50)

AS
IF (@accion = 'consultar')
SELECT per.id_tipo, per.id_periferico, per.placa, mod.id_modelo, mod.nombre_modelo, tip.tipo, mar.marca, per.serial, per.descripcion
FROM Periferico AS per, Tipo_Periferico AS tip, Marca_Periferico AS mar, Estado_Periferico AS est, Modelo as mod
WHERE tip.id_tipo = per.id_tipo
AND per.id_modelo = mod.id_modelo
AND mar.id_marca = per.id_marca
AND est.id_estado = per.id_estado

IF (@accion = 'tipo_placa')
begin
SELECT per.id_periferico, per.placa + ' - ' + tip.tipo + ' - ' + mar.marca AS Periferico
FROM Periferico AS per, Tipo_Periferico AS tip, Marca_Periferico AS mar
WHERE tip.id_tipo = per.id_tipo
AND mar.id_marca = per.id_marca
AND per.id_estado = 2
end

if (@accion = 'consultar_asignados')
begin
	select per.placa, per.id_periferico, per.id_tipo, per.fecha_ingreso, per.serial, mar.marca, ofi.id_area, ofi.id_persona,
	ar.nombre + ' - ' + pers.nombres + ' ' + pers.apellidos as oficina, perAs.id_asignacion
	from Periferico as per, Marca_Periferico as mar, Oficina as ofi, Area as ar, Persona as pers,
	Periferico_Asignado as perAs, Tipo_Periferico as tipPer, Estado_Periferico as estPer 
	where per.id_periferico = perAs.id_periferico
	and per.id_tipo = tipPer.id_tipo
	and per.id_marca = mar.id_marca
	and per.id_estado = estPer.id_estado
	and ofi.id_persona = pers.id_persona
	and ofi.id_area = ar.id_area
	and ofi.id_oficina = perAs.id_oficina 
end

if (@accion = 'consultar_asignados_oficina')
begin
	insert into log_info (mensaje)
	select '@id_oficina: ' + isnull(convert(nvarchar, @id_oficina), '-1')

	select per.placa, per.id_periferico, per.id_tipo, per.fecha_ingreso, per.serial, mar.marca, ofi.id_area, ofi.id_persona,
	ar.nombre + ' - ' + pers.nombres + ' ' + pers.apellidos as oficina, perAs.id_asignacion, perAs.fecha_asignacion, ofi.id_oficina, mod.id_modelo, mod.nombre_modelo,
	tp.id_tipo, tp.tipo
	from Periferico as per, Marca_Periferico as mar, Oficina as ofi, Area as ar, Persona as pers, Tipo_Periferico as tp,
	Periferico_Asignado as perAs, Tipo_Periferico as tipPer, Estado_Periferico as estPer, Modelo as mod 
	where per.id_periferico = perAs.id_periferico
	and per.id_tipo = tipPer.id_tipo
	and per.id_marca = mar.id_marca
	and per.id_estado = estPer.id_estado
	and per.id_modelo = mod.id_modelo
	and per.id_tipo = tp.id_tipo
	and ofi.id_persona = pers.id_persona
	and ofi.id_area = ar.id_area
	and ofi.id_oficina = perAs.id_oficina 
	and perAs.estado = 1
	and ofi.id_oficina = 
	case when @id_oficina = 0 then ofi.id_oficina 
	else @id_oficina
	end
	order by per.placa
end