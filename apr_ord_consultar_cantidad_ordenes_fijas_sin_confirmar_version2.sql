set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_consultar_cantidad_ordenes_fijas_sin_confirmar_version2]

@estado nvarchar(50)

as

select max(id_item_orden_sin_aprobar) as id_item_orden_sin_aprobar into #temp 
from item_orden_sin_aprobar
group by id_item_orden_sin_aprobar_padre

if(@estado = 'Without Approval')
begin
	select count(*) as conteo
	from orden_sin_aprobar,
	item_orden_sin_aprobar,
	tipo_factura
	where tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and tipo_factura.idc_tipo_factura = '9'
	and not exists
	(
		select *
		from aprobacion_orden
		where aprobacion_orden.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	)
	and exists
	(
		select *
		from #temp
		where #temp.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	)
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre is not null
end
else
if(@estado = 'Not Sent to Farm')
begin
	select count(*) as conteo
	from orden_sin_aprobar,
	item_orden_sin_aprobar,
	tipo_factura,
	aprobacion_orden
	where tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and tipo_factura.idc_tipo_factura = '9'
	and aprobacion_orden.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	and aprobacion_orden.aceptada = 1
	and not exists
	(
		select *
		from solicitud_confirmacion_orden
		where aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
	)
	and exists
	(
		select *
		from #temp
		where #temp.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	)
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre is not null
end
else
if(@estado = 'No Farm Confirmed')
begin
	select count(*) as conteo
	from orden_sin_aprobar,
	item_orden_sin_aprobar,
	tipo_factura,
	aprobacion_orden,
	solicitud_confirmacion_orden
	where tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and tipo_factura.idc_tipo_factura = '9'
	and aprobacion_orden.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	and aprobacion_orden.aceptada = 1
	and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
	and solicitud_confirmacion_orden.aceptada = 1
	and not exists
	(
		select *
		from confirmacion_orden_cultivo
		where solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden 
	)
	and exists
	(
		select *
		from #temp
		where #temp.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	)
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre is not null
end

drop table #temp