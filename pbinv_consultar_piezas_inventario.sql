/****** Object:  StoredProcedure [dbo].[pbinv_consultar_piezas_inventario]    Script Date: 05/14/2008 11:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_consultar_piezas_inventario]

@id_item_inventario_preventa int,
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
from detalle_item_inventario_preventa, item_inventario_preventa, Inventario_Preventa, Tapa, Variedad_Flor, Grado_Flor, Tipo_Flor, Farm, Tipo_Caja
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
and convert(datetime, detalle_item_inventario_preventa.fecha_disponible_distribuidora, 101) between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
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
END



