/****** Object:  StoredProcedure [dbo].[pbinv_consultar_piezas_inventario]    Script Date: 05/14/2008 11:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pbinv_consultar_piezas_inventario_version2]

@id_item_inventario_preventa int,
@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime 

AS

declare @id_variedad_flor int,
@id_grado_flor int,
@id_farm int,
@id_tapa int,
@unidades_por_pieza int,
@unidades_inventario int,
@unidades_prevendidas int

select @id_variedad_flor = item_inventario_preventa.id_variedad_flor,
@id_grado_flor = item_inventario_preventa.id_grado_flor,
@id_farm = inventario_preventa.id_farm,
@id_tapa = item_inventario_preventa.id_tapa,
@unidades_por_pieza = item_inventario_preventa.unidades_por_pieza
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

select @unidades_inventario = sum(Item_Inventario_Preventa.unidades_por_pieza * Detalle_Item_Inventario_Preventa.cantidad_piezas)
from detalle_item_inventario_preventa, 
item_inventario_preventa, 
Inventario_Preventa, 
Tapa, 
Variedad_Flor, 
Grado_Flor, 
Farm
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and farm.id_farm = @id_farm
and variedad_flor.id_variedad_flor = @id_variedad_flor
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa = @id_tapa
and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Item_Inventario_Preventa.empaque_principal = 1

select sum(Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as prevendido into #prevendido
from orden_pedido,
orden_pedido as op, 
tapa, 
variedad_flor, 
grado_flor, 
farm, 
tipo_factura
where orden_pedido.id_orden_pedido < = op.id_orden_pedido
and orden_pedido.id_orden_pedido_padre = op.id_orden_pedido_padre
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.fecha_inicial between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and orden_pedido.disponible = 1
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and orden_pedido.id_farm = farm.id_farm
and farm.id_farm = @id_farm
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa = @id_tapa
and variedad_flor.id_variedad_flor = @id_variedad_flor
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
group by 
orden_pedido.id_orden_pedido
having
orden_pedido.id_orden_pedido = max(op.id_orden_pedido)

select @unidades_prevendidas = sum(prevendido)
from #prevendido

select 
((isnull(@unidades_inventario, 0) - isnull(@unidades_prevendidas, 0)) / @unidades_por_pieza) as saldo,
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
sum(detalle_item_inventario_preventa.cantidad_piezas) as cantidad_piezas,
sum(Detalle_Item_Inventario_Preventa.cantidad_piezas_ofertadas_finca) as cantidad_piezas_ofertadas_finca
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
and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
group by 
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
item_inventario_preventa.fecha_transaccion
order by 
detalle_item_inventario_preventa.fecha_disponible_distribuidora

drop table #prevendido