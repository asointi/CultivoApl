set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ped_regenerar_reporte]

@accion nvarchar(255), 
@id_farm int, 
@id_temporada_año int,
@idc_tipo_factura nvarchar(255)

AS
BEGIN
if (@accion = 'farm')
begin
	select farm.id_farm, 
	farm.idc_farm, 
	'['+ farm.idc_farm +']' + space(2) + rtrim(ltrim(farm.nombre_farm)) as nombre_farm
	from farm, 
	reporte_cambio_orden_pedido, 
	tipo_factura
	where reporte_cambio_orden_pedido.id_farm = farm.id_farm
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	group by farm.id_farm, farm.idc_farm, farm.nombre_farm
	order by farm.idc_farm
end
else
if (@accion = 'farm_preventa')
begin
	select farm.id_farm, 
	farm.idc_farm, 
	'['+ farm.idc_farm +']' + space(2) + rtrim(ltrim(farm.nombre_farm)) as nombre_farm
	from farm, 
	reporte_cambio_orden_pedido, 
	tipo_factura
	where reporte_cambio_orden_pedido.id_farm = farm.id_farm
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año
	group by farm.id_farm, farm.idc_farm, farm.nombre_farm
	order by farm.idc_farm
end
else
if (@accion = 'numero_reporte')
begin
	if(@idc_tipo_factura = '9')
	begin
		select reporte_cambio_orden_pedido.numero_reporte_farm
		from reporte_cambio_orden_pedido, 
		farm, 
		tipo_factura
		where reporte_cambio_orden_pedido.id_farm = farm.id_farm
		and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and farm.id_farm = @id_farm
		order by reporte_cambio_orden_pedido.numero_reporte_farm desc
	end
	else
	if(@idc_tipo_factura = '4')
	begin
		select reporte_cambio_orden_pedido.numero_reporte_farm
		from reporte_cambio_orden_pedido, 
		farm, 
		tipo_factura
		where reporte_cambio_orden_pedido.id_farm = farm.id_farm
		and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año
		and farm.id_farm = @id_farm
		order by reporte_cambio_orden_pedido.numero_reporte_farm desc
	end
end
END

