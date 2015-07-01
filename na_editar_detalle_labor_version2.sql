set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_detalle_labor_version2]

@accion nvarchar(255),
@idc_detalle_labor nvarchar(20),
@id_unidad_medida int,
@id_detalle_labor int,
@rendimiento int

AS

if(@accion = 'consultar')
begin
	select labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)) as nombre_labor,
	detalle_labor.id_detalle_labor,
	detalle_labor.idc_detalle_labor,
	detalle_labor.rendimiento,
	ltrim(rtrim(detalle_labor.nombre_detalle_labor)) as nombre_detalle_labor,
	unidad_medida.id_unidad_medida,
	unidad_medida.nombre_unidad_medida
	from labor,
	detalle_labor left join unidad_medida on unidad_medida.id_unidad_medida = detalle_labor.id_unidad_medida
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.idc_detalle_labor = @idc_detalle_labor
	order by nombre_labor,
	nombre_detalle_labor 
end
else
if(@accion = 'asignar_unidad_medida')
begin
	update detalle_labor
	set id_unidad_medida = @id_unidad_medida,
	rendimiento = @rendimiento
	where detalle_labor.id_detalle_labor = @id_detalle_labor
end