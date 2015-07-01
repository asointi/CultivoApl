/****** Object:  StoredProcedure [dbo].[pbinv_consultar_saldos_factura]    Script Date: 05/14/2008 11:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_consultar_saldos_factura]

@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime

AS

BEGIN

SELECT     
farm.id_farm, 
farm.idc_farm,
farm.nombre_farm,
tapa.id_tapa, 
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor, 
tipo_flor.idc_tipo_flor, 
tipo_flor.nombre_tipo_flor, 
variedad_flor.id_variedad_flor, 
variedad_flor.idc_variedad_flor, 
variedad_flor.nombre_variedad_flor, 
Color.id_color,
color.idc_color,
color.nombre_color,
color.prioridad_color,
grado_flor.id_grado_flor, 
grado_flor.idc_grado_flor, 
grado_flor.nombre_grado_flor, 
grado_flor.medidas, 
tipo_caja.id_tipo_caja, 
tipo_caja.idc_tipo_caja, 
tipo_caja.nombre_tipo_caja, 
Item_Inventario_Preventa.unidades_por_pieza, 
Detalle_Item_Inventario_Preventa.cantidad_piezas AS cantidad_piezas_inventario,
0 AS cantidad_piezas_prebook,
Item_Inventario_Preventa.marca, 
Item_Inventario_Preventa.precio_minimo, 
Detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora,
null as id_vendedor, 
null as idc_vendedor, 
null as nombre_vendedor, 
null as id_cliente_factura,
null as idc_cliente_factura,
null as id_despacho, 
null as idc_cliente_despacho, 
null as nombre_cliente, 
null as id_transportador,
null as idc_transportador,
null as nombre_transportador,
'1' as tipo_orden,
null as id_orden_pedido,
null as idc_orden_pedido,
Item_Inventario_Preventa.id_item_inventario_preventa,
null as fecha_para_aprobar,
controla_saldos into #temp
FROM         
Grado_Flor, 
Inventario_Preventa,
Item_Inventario_Preventa,     
Detalle_Item_Inventario_Preventa,     
Variedad_Flor,      
Tipo_Flor,               
Tipo_Caja,                
Farm,
Tapa,
Color
WHERE     
Inventario_Preventa.id_farm = Farm.id_farm
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Grado_Flor.id_grado_flor = Item_Inventario_Preventa.id_grado_flor
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor 
and variedad_flor.id_color = color.id_color
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and Item_Inventario_Preventa.id_item_inventario_preventa = Detalle_Item_Inventario_Preventa.id_item_inventario_preventa
and convert(datetime, detalle_item_inventario_preventa.fecha_disponible_distribuidora, 101) between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
AND Detalle_Item_Inventario_Preventa.id_detalle_item_inventario_preventa IN
(SELECT MAX(id_detalle_item_inventario_preventa) 
FROM Detalle_Item_Inventario_Preventa 
where convert(datetime, detalle_item_inventario_preventa.fecha_disponible_distribuidora, 101) between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
GROUP BY id_detalle_item_inventario_preventa_padre)

UNION

SELECT     
farm.id_farm, 
farm.idc_farm, 
farm.nombre_farm,	
tapa.id_tapa, 
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.id_variedad_flor, 
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
Color.id_color,
color.idc_color,
color.nombre_color,
color.prioridad_color,
grado_flor.id_grado_flor, 
grado_flor.idc_grado_flor, 
grado_flor.nombre_grado_flor, 
grado_flor.medidas, 
tipo_caja.id_tipo_caja, 
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
Orden_Pedido.unidades_por_pieza, 
0 AS cantidad_piezas_inventario,
orden_pedido.cantidad_piezas as cantidad_piezas_prebook, 
orden_pedido.marca, 
orden_pedido.valor_unitario,
Orden_Pedido.fecha_inicial  as fecha_disponible_distribuidora,
vendedor.id_vendedor, 
vendedor.idc_vendedor, 
vendedor.nombre as nombre_vendedor, 
cliente_factura.id_cliente_factura,
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho, 
cliente_despacho.idc_cliente_despacho, 
cliente_despacho.nombre_cliente, 
transportador.id_transportador, 
transportador.idc_transportador,
transportador.nombre_transportador,
'2' as tipo_orden,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
null as id_item_inventario_preventa,
orden_pedido.fecha_para_aprobar,
null as controla_saldos
FROM         
Orden_Pedido, 
Variedad_Flor, 
Tipo_Flor, 
Grado_Flor, 
Tipo_Caja, 
Cliente_Despacho, 
Cliente_Factura, 
Vendedor,
Transportador,
Farm,
Tapa,
color
WHERE
(convert(datetime, orden_pedido.fecha_inicial, 101) between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
or
convert(datetime, orden_pedido.fecha_para_aprobar, 101) between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101))
and Orden_Pedido.id_tapa = Tapa.id_tapa
and Orden_Pedido.id_farm = Farm.id_farm
and Orden_Pedido.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Orden_Pedido.id_transportador = Transportador.id_transportador
and Cliente_Factura.id_vendedor = Vendedor.id_vendedor
and Cliente_Despacho.id_cliente_factura = Cliente_Factura.id_cliente_factura
and Orden_Pedido.id_despacho = Cliente_Despacho.id_despacho
and Orden_Pedido.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Orden_Pedido.id_grado_flor = Grado_Flor.id_grado_flor 
and Tipo_Flor.id_tipo_flor = Grado_Flor.id_tipo_flor
and Orden_Pedido.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and variedad_flor.id_color = color.id_color
and Orden_Pedido.id_tipo_factura = 2 
and Orden_Pedido.disponible = 1 
and Orden_Pedido.id_orden_pedido IN
(SELECT MAX(id_orden_pedido) FROM Orden_Pedido GROUP BY id_orden_pedido_padre)
order by 
tipo_flor.idc_tipo_flor,
color.prioridad_color,
variedad_flor.idc_variedad_flor,
grado_flor.idc_grado_flor,
tipo_orden,
fecha_disponible_distribuidora

update #temp
set fecha_disponible_distribuidora = fecha_para_aprobar,
tipo_orden = '3'
where fecha_disponible_distribuidora = convert(datetime, '1999/01/01')

select * from #temp
order by
idc_tipo_flor,
prioridad_color,
idc_variedad_flor,
idc_grado_flor,
tipo_orden,
fecha_disponible_distribuidora

drop table #temp

END





