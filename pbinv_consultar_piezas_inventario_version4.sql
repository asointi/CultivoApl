SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_consultar_piezas_inventario_version4]

@id_item_inventario_preventa int,
@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime 

AS

declare @id_variedad_flor int,
@id_grado_flor int,
@id_farm int,
@id_tapa int,
@unidades_por_pieza int,
@controla_saldos bit

select top 1 @controla_saldos = item_inventario_preventa.controla_saldos,
@id_variedad_flor = item_inventario_preventa.id_variedad_flor,
@id_grado_flor = item_inventario_preventa.id_grado_flor,
@id_farm = inventario_preventa.id_farm,
@id_tapa = item_inventario_preventa.id_tapa
from inventario_preventa,
item_inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

select max(id_orden_pedido) as id_orden_pedido into #ordenes
from orden_pedido
group by id_orden_pedido_padre

select 0 as unidades_inventario,
(Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as unidades_prevendidas,
0 as id_item_inventario_preventa,
Tapa.id_tapa,
Tapa.idc_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.idc_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_Flor.idc_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.idc_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
orden_pedido.unidades_por_pieza, 
orden_pedido.marca,
orden_pedido.valor_unitario as precio_minimo, 
orden_pedido.fecha_inicial as fecha_disponible_distribuidora,
@controla_saldos as controla_saldos,
orden_pedido.cantidad_piezas,
0 as cantidad_piezas_ofertadas_finca
from orden_pedido,
tapa, 
variedad_flor, 
grado_flor, 
farm, 
tipo_factura,
tipo_caja,
tipo_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and orden_pedido.disponible = 1
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.fecha_inicial > = @fecha_disponible_distribuidora_inicial 
and orden_pedido.fecha_inicial < = @fecha_disponible_distribuidora_final
and farm.id_farm = @id_farm
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa = @id_tapa
and variedad_flor.id_variedad_flor = @id_variedad_flor
and exists
(
	select *
	from #ordenes
	where orden_pedido.id_orden_pedido = #ordenes.id_orden_pedido
)

union all

select (item_inventario_preventa.unidades_por_pieza * detalle_item_inventario_preventa.cantidad_piezas) as unidades_inventario,
0 as unidades_prevendidas,
item_inventario_preventa.id_item_inventario_preventa,
Tapa.id_tapa,
Tapa.idc_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.idc_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_Flor.idc_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.idc_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
item_inventario_preventa.unidades_por_pieza, 
marca,
item_inventario_preventa.precio_minimo, 
detalle_item_inventario_preventa.fecha_disponible_distribuidora,
item_inventario_preventa.controla_saldos, 
detalle_item_inventario_preventa.cantidad_piezas,
Detalle_Item_Inventario_Preventa.cantidad_piezas_ofertadas_finca
from detalle_item_inventario_preventa, 
item_inventario_preventa, 
Inventario_Preventa, 
Tapa, 
Variedad_Flor, 
Grado_Flor, 
Tipo_Flor, 
Farm, 
Tipo_Caja
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and detalle_item_inventario_preventa.fecha_disponible_distribuidora > = @fecha_disponible_distribuidora_inicial 
and detalle_item_inventario_preventa.fecha_disponible_distribuidora < = @fecha_disponible_distribuidora_final
and farm.id_farm = @id_farm
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa = @id_tapa
and variedad_flor.id_variedad_flor = @id_variedad_flor

drop table #ordenes