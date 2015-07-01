set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ped_consultar_items_reporte_actual_automatico]

AS

set language spanish

select id_farm,
max(numero_reporte_farm) as numero_reporte_farm into #farm
from item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido, 
tipo_factura
where reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
group by id_farm


select max(id_item_reporte_cambio_orden_pedido) as id_item_reporte_cambio_orden_pedido into #reporte_cambio
from item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido, 
tipo_factura
where reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
group by id_orden_pedido_padre	

/*seleccionar las ordenes desde item_reporte_cambio_orden_pedido actuales*/
select item_reporte_cambio_orden_pedido.id_orden_pedido,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.nombre_tapa,
tipo_caja.nombre_tipo_caja,
item_reporte_cambio_orden_pedido.code, 
item_reporte_cambio_orden_pedido.unidades_por_pieza, 
item_reporte_cambio_orden_pedido.cantidad_piezas,
item_reporte_cambio_orden_pedido.comentario,
ciudad.id_ciudad,
datename(dw,dbo.calcular_dia_vuelo_orden_fija (item_reporte_cambio_orden_pedido.fecha_despacho_inicial, farm.idc_farm)) as nombre_dia_despacho,
datepart(dw,dbo.calcular_dia_vuelo_orden_fija (item_reporte_cambio_orden_pedido.fecha_despacho_inicial, farm.idc_farm)) as id_dia_despacho,
farm.nombre_farm,
farm.id_farm,
#farm.numero_reporte_farm into #temp
from 
item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido,
farm, 
tipo_flor,
variedad_flor, 
grado_flor,
tapa,
tipo_caja,
ciudad,
tipo_factura,
#farm
where #farm.id_farm = farm.id_farm
and (getdate() between
item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final
or 
getdate()+6 between
item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final)
and item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and farm.id_farm = reporte_cambio_orden_pedido.id_farm
and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
and farm.id_ciudad = ciudad.id_ciudad
and item_reporte_cambio_orden_pedido.disponible = 1
and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
and exists
(
	select *
	from #reporte_cambio
	where #reporte_cambio.id_item_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido
)

/**datos para ser visualizados por los usuarios**/
select 
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
nombre_tipo_caja,
id_dia_despacho,
nombre_dia_despacho,
code, 
unidades_por_pieza, 
sum(cantidad_piezas) as cantidad_piezas,
comentario,
nombre_farm,
numero_reporte_farm
from #temp 
group by
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
nombre_tapa,
nombre_tipo_caja,
nombre_dia_despacho,
id_dia_despacho,
code, 
unidades_por_pieza, 
comentario,
nombre_farm,
numero_reporte_farm
order by nombre_farm,
id_dia_despacho, 
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor

/*eliminación tablas temporales*/
drop table #temp
drop table #reporte_cambio
drop table #farm