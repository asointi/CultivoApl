set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ped_consultar_farms_actuales]

@idc_tipo_factura nvarchar(255)

AS
BEGIN

declare @idc_tipo_factura_doble nvarchar(255)

set @idc_tipo_factura_doble = '7'

if(@idc_tipo_factura = '9')
begin
	select 
	farm.nombre_farm,
	farm.idc_farm,
	farm.id_farm into #temp_so
	from 
	item_reporte_cambio_orden_pedido,
	reporte_cambio_orden_pedido,
	farm,
	tipo_factura
	where 
	(getdate() between
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final
	or 
	getdate()+6 between
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final)
	and item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and item_reporte_cambio_orden_pedido.disponible = 1
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido in 
	(select max(id_item_reporte_cambio_orden_pedido) 
	from item_reporte_cambio_orden_pedido,reporte_cambio_orden_pedido, tipo_factura
	where item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido=reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido 
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	group by id_orden_pedido_padre,id_farm)

	select 
	id_farm, 
	idc_farm,
	'[' + idc_farm + ']' +space(2)+ rtrim(ltrim(nombre_farm)) as nombre_farm
	from #temp_so 
	group by id_farm, idc_farm, nombre_farm
	order by idc_farm

	drop table #temp_so
end

if(@idc_tipo_factura = '4')
begin
	select 
	farm.nombre_farm,
	farm.idc_farm,
	farm.id_farm into #temp_pb
	from 
	item_reporte_cambio_orden_pedido,
	reporte_cambio_orden_pedido,
	farm,
	tipo_factura
	where 
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial between
	getdate() and getdate()+60
	and item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and item_reporte_cambio_orden_pedido.disponible = 1
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
	and item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido in 
	(select max(id_item_reporte_cambio_orden_pedido) 
	from item_reporte_cambio_orden_pedido,reporte_cambio_orden_pedido, tipo_factura
	where item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido=reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido 
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
	group by id_orden_pedido_padre,id_farm)

	select 
	id_farm, 
	idc_farm,
	'[' + idc_farm + ']' +space(2)+ rtrim(ltrim(nombre_farm)) as nombre_farm
	from #temp_pb
	group by id_farm, idc_farm, nombre_farm
	order by idc_farm

	drop table #temp_pb
end

END

