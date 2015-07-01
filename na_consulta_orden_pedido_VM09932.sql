set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_VM09932]

@idc_cliente_despacho nvarchar(20)

as

select orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
transportador.idc_transportador,
transportador.nombre_transportador,
orden_pedido.fecha_inicial,
orden_pedido.fecha_final,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.cantidad_piezas,
orden_pedido.valor_unitario,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
tipo_factura.idc_tipo_factura,
orden_pedido.disponible,
color.idc_color,
color.nombre_color,
color.prioridad_color as orden_color,
isnull(orden_pedido.comentario, '') as comentario,
0 as confirmacion_pendiente,
case
	when orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido_padre then 0
	else 1
end as tiene_padre into #ordenes
from orden_pedido, 
tipo_factura, 
tipo_flor, 
variedad_flor, 
color,
grado_flor, 
farm, 
tapa, 
transportador, 
tipo_caja, 
cliente_despacho
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and variedad_flor.id_color = color.id_color
and LTRIM(RTRIM(cliente_despacho.idc_cliente_despacho)) = LTRIM(RTRIM(@idc_cliente_despacho))

/*Extraigo los últimos id del proceso de aprobación, de las órdenes consultadas en el paso inmediatamente anterior*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
orden_pedido.id_orden_pedido, 
(
	SELECT max(iosa.id_item_orden_sin_aprobar)
	from item_orden_sin_aprobar as iosa
	where iosa.id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre
) as id_item_orden_sin_aprobar INTO #items_pendientes
from orden_sin_aprobar,
item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden,
confirmacion_orden_cultivo,
orden_confirmada,
orden_pedido,
#ordenes
where orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
and confirmacion_orden_cultivo.id_confirmacion_orden_cultivo = orden_confirmada.id_confirmacion_orden_cultivo
and orden_pedido.id_orden_pedido = orden_confirmada.id_orden_pedido
and #ordenes.id_orden_pedido = orden_pedido.id_orden_pedido

/*verifico que los id consultados en el paso anterior no tengan alguna confirmación pendiente*/
/*lo anterior se debe realizar para cada estado del proceso*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar into #orden_con_modificacion
from #items_pendientes,
item_orden_sin_aprobar
where #items_pendientes.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
and not exists
(
	select *
	from aprobacion_orden
	where aprobacion_orden.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)

union all

select item_orden_sin_aprobar.id_item_orden_sin_aprobar
from #items_pendientes,
item_orden_sin_aprobar,
aprobacion_orden
where #items_pendientes.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.aceptada = 1
and not exists
(
	select *
	from solicitud_confirmacion_orden
	where aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
)

union all 

select item_orden_sin_aprobar.id_item_orden_sin_aprobar
from #items_pendientes,
item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden
where #items_pendientes.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and aprobacion_orden.aceptada = 1
and solicitud_confirmacion_orden.aceptada = 1
and not exists
(
	select *
	from confirmacion_orden_cultivo
	where solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
)

/*se marca en la tabla de las órdenes (el primer query realizado en este SP)*/
/*aquellas que tengan items pendientes de confirmación*/
update #ordenes
set confirmacion_pendiente = 1
from #items_pendientes,
#orden_con_modificacion
where #items_pendientes.id_item_orden_sin_aprobar = #orden_con_modificacion.id_item_orden_sin_aprobar
and #ordenes.id_orden_pedido = #items_pendientes.id_orden_pedido

/*se retornan los datos a pantalla con todos los cálculos realizados*/
select * 
from #ordenes

/*se eliminan las tablas temporales*/
drop table #items_pendientes
drop table #orden_con_modificacion
drop table #ordenes