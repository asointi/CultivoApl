set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_detalle_labor]

@accion nvarchar(255),
@id_labor int

AS

if(@accion = 'consultar')
begin
	select labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)) as nombre_labor,
	detalle_labor.id_detalle_labor,
	detalle_labor.idc_detalle_labor,
	ltrim(rtrim(detalle_labor.nombre_detalle_labor)) as nombre_detalle_labor,
	unidad_medida.id_unidad_medida,
	unidad_medida.nombre_unidad_medida
	from labor,
	detalle_labor left join unidad_medida on unidad_medida.id_unidad_medida = detalle_labor.id_unidad_medida
	where labor.id_labor = detalle_labor.id_labor
	and labor.id_labor > = 
	case
		when @id_labor = 0 then 1
		else @id_labor
	end
	and labor.id_labor < = 
	case
		when @id_labor = 0 then 99999999
		else @id_labor
	end
	and detalle_labor.disponible = 1
	order by nombre_labor,
	nombre_detalle_labor 
end