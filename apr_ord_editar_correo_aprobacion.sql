set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[apr_ord_editar_correo_aprobacion]

@accion nvarchar(255),
@correo_aprobacion nvarchar(1024),
@id_farm int,
@id_item_orden_sin_aprobar int

AS

if(@accion = 'consultar')
begin
	select farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(nombre_farm)) as nombre_farm,
	'[' + farm.idc_farm + ']' + space(1) + ltrim(rtrim(farm.nombre_farm)) as nombre,
	correo as correo_aprobacion,
	1 as orden	
	from farm,
	item_orden_sin_aprobar
	where farm.disponible = 1
	and item_orden_sin_aprobar.id_farm = farm.id_farm
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
	union all
	select farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	'[' + farm.idc_farm + ']' + space(1) + ltrim(rtrim(farm.nombre_farm)) as nombre,
	correo as correo_aprobacion,
	2 as orden
	from farm
	where farm.disponible = 1
	order by orden,
	idc_farm
end
else
if(@accion = 'modificar_correo_aprobacion')
begin
	update farm
	set correo = @correo_aprobacion
	where id_farm = @id_farm
end
else
if(@accion = 'consultar_dropdown')
begin
	select farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(nombre_farm)) as nombre_farm,
	'[' + farm.idc_farm + ']' + space(1) + ltrim(rtrim(farm.nombre_farm)) as nombre,
	correo as correo_aprobacion,
	1 as orden	
	from farm,
	item_orden_sin_aprobar
	where farm.disponible = 1
	and item_orden_sin_aprobar.id_farm = farm.id_farm
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
	union all
	select farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	'[' + farm.idc_farm + ']' + space(1) + ltrim(rtrim(farm.nombre_farm)) as nombre,
	correo as correo_aprobacion,
	2 as orden
	from farm
	where farm.disponible = 1
	and farm.correo is not null
	and len(farm.correo) > 7
	order by orden,
	idc_farm
end
