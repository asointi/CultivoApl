/****** Object:  StoredProcedure [dbo].[pbinv_consultar_inventario_cobol]    Script Date: 05/14/2008 11:35:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_consultar_inventario_cobol]

@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime 

AS

BEGIN

select 
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
Color.idc_color,
Color.nombre_color,
Color.prioridad_color,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Grado_Flor.medidas,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
item_inventario_preventa.unidades_por_pieza, 
marca,
item_inventario_preventa.precio_minimo, 
detalle_item_inventario_preventa.fecha_disponible_distribuidora,
item_inventario_preventa.controla_saldos, 
sum(detalle_item_inventario_preventa.cantidad_piezas) as cantidad_piezas into #temp_preventas
from detalle_item_inventario_preventa, item_inventario_preventa, Inventario_Preventa, Tapa, Variedad_Flor, Grado_Flor, Tipo_Flor, Farm, Tipo_Caja,Color
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and convert(datetime, detalle_item_inventario_preventa.fecha_disponible_distribuidora, 101) between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and variedad_flor.id_color = color.id_color
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa in 
(select max(id_detalle_item_inventario_preventa) 
from detalle_item_inventario_preventa 
where convert(datetime, detalle_item_inventario_preventa.fecha_disponible_distribuidora, 101) between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
group by id_detalle_item_inventario_preventa_padre)
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
Color.idc_color,
Color.nombre_color,
Color.prioridad_color,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Grado_Flor.medidas,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
item_inventario_preventa.unidades_por_pieza, 
marca,
item_inventario_preventa.precio_minimo, 
detalle_item_inventario_preventa.fecha_disponible_distribuidora,
item_inventario_preventa.controla_saldos,
item_inventario_preventa.fecha_transaccion


select 
id_tapa,
id_tipo_caja,
id_variedad_flor,
id_grado_flor,
id_farm,
unidades_por_pieza,
fecha_inicial,
sum(cantidad_piezas) as cantidad_piezas into #temp_orden_pedido
from orden_pedido
where id_tipo_factura = 2
and fecha_inicial between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
and disponible = 1
group by 
id_tapa,
id_tipo_caja,
id_variedad_flor,
id_grado_flor,
id_farm,
unidades_por_pieza,
fecha_inicial

alter table #temp_preventas
add saldo integer

update #temp_preventas
set saldo = #temp_preventas.cantidad_piezas - isnull(#temp_orden_pedido.cantidad_piezas, 0)
from #temp_preventas, #temp_orden_pedido
where #temp_preventas.id_tapa = #temp_orden_pedido.id_tapa
and #temp_preventas.id_tipo_caja = #temp_orden_pedido.id_tipo_caja
and #temp_preventas.id_variedad_flor = #temp_orden_pedido.id_variedad_flor
and #temp_preventas.id_grado_flor = #temp_orden_pedido.id_grado_flor
and #temp_preventas.id_farm = #temp_orden_pedido.id_farm
and #temp_preventas.unidades_por_pieza = #temp_orden_pedido.unidades_por_pieza
and convert(nvarchar,#temp_preventas.fecha_disponible_distribuidora,101) = convert(nvarchar,#temp_orden_pedido.fecha_inicial,101)

update #temp_preventas
set saldo = cantidad_piezas
where saldo is null

select 
id_item_inventario_preventa,
id_tapa,
idc_tapa,
nombre_tapa,
id_tipo_caja,
idc_tipo_caja,
nombre_tipo_caja,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_color,
nombre_color,
prioridad_color,
id_grado_flor,
idc_grado_flor,
nombre_grado_flor,
medidas,
id_farm,
idc_farm,
nombre_farm,
unidades_por_pieza, 
marca,
precio_minimo, 
fecha_disponible_distribuidora,
controla_saldos, 
cantidad_piezas,
saldo 
from #temp_preventas
order by 
fecha_disponible_distribuidora

drop table #temp_preventas
drop table #temp_orden_pedido

END



