/****** Object:  StoredProcedure [dbo].[pbinv_consultar_piezas_inventario]    Script Date: 05/14/2008 11:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_consultar_saldo]

@id_item_inventario_preventa int,
@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime 

AS

declare @id_variedad_flor int,
@id_grado_flor int,
@id_farm int,
@id_tapa int,
@unidades_por_pieza int,
@base_datos nvarchar(50),
@preventas int,
@inventario int

set @base_datos = db_name()

select @id_variedad_flor = item_inventario_preventa.id_variedad_flor,
@id_grado_flor = item_inventario_preventa.id_grado_flor,
@id_farm = inventario_preventa.id_farm,
@id_tapa = item_inventario_preventa.id_tapa,
@unidades_por_pieza = item_inventario_preventa.unidades_por_pieza
from inventario_preventa,
item_inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

select max(id_orden_pedido) as id_orden_pedido into #ordenes
from orden_pedido
group by id_orden_pedido_padre

select @preventas = isnull(sum(Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas),0)
from orden_pedido,
tapa, 
variedad_flor, 
grado_flor, 
farm, 
tipo_factura
where tipo_factura.idc_tipo_factura = '4'
and orden_pedido.fecha_inicial between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and orden_pedido.disponible = 1
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and farm.id_farm = @id_farm
and variedad_flor.id_variedad_flor = @id_variedad_flor
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa > = 
case
	when @base_datos = 'BD_NF' then 0
	else @id_tapa
end
and tapa.id_tapa < = 
case
	when @base_datos = 'BD_NF' then 99999
	else @id_tapa
end
and exists
(
	select *
	from #ordenes
	where orden_pedido.id_orden_pedido = #ordenes.id_orden_pedido
)

select @inventario = isnull(sum(item_inventario_preventa.unidades_por_pieza * detalle_item_inventario_preventa.cantidad_piezas), 0)
from detalle_item_inventario_preventa, 
item_inventario_preventa, 
Inventario_Preventa, 
Tapa, 
Variedad_Flor, 
Grado_Flor, 
Farm
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and farm.id_farm = @id_farm
and variedad_flor.id_variedad_flor = @id_variedad_flor
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa > = 
case
	when @base_datos = 'BD_NF' then 0
	else @id_tapa
end
and tapa.id_tapa < = 
case
	when @base_datos = 'BD_NF' then 99999
	else @id_tapa
end
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor

select @inventario - @preventas as unidades_saldo,
(@inventario - @preventas)/@unidades_por_pieza as saldo,
precio_minimo,
controla_saldos
from item_inventario_preventa
where item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

drop table #ordenes