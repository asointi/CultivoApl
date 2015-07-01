set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[pbinv_eliminar_item]

@id_item_inventario_preventa int

AS

declare @cantidad_piezas_facturadas int,
@fecha_inicial datetime,
@fecha_final datetime

/*seleccionar la fecha inicial de la temporada actual*/
select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final
from temporada_año, temporada_cubo
where temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_año = temporada_cubo.id_año
and temporada_año.fecha_inicial = 
(
select top 1 detalle_item_inventario_preventa.fecha_disponible_distribuidora 
from item_inventario_preventa, detalle_item_inventario_preventa
where item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
order by detalle_item_inventario_preventa.fecha_disponible_distribuidora desc
)

/*verificar si el ítem ingresado tiene preventas facturadas en la tabla orden_pedido*/
select @cantidad_piezas_facturadas = isnull(sum(Orden_pedido.cantidad_piezas),0)
from Inventario_Preventa,
Item_Inventario_Preventa,
Detalle_Item_Inventario_Preventa,
Orden_pedido,
tipo_factura
where Detalle_item_inventario_preventa.id_item_inventario_preventa = Item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and Orden_pedido.id_farm = Inventario_Preventa.id_farm
and Orden_pedido.id_variedad_flor = Item_Inventario_Preventa.id_variedad_flor
and Orden_pedido.id_grado_flor = Item_Inventario_Preventa.id_grado_flor
and Orden_pedido.id_tipo_caja = Item_Inventario_Preventa.id_tipo_caja
and Orden_pedido.id_tapa = Item_Inventario_Preventa.id_tapa
and Orden_pedido.unidades_por_pieza = Item_Inventario_Preventa.unidades_por_pieza
and Orden_pedido.id_orden_pedido in
(select max(id_orden_pedido) from orden_pedido group by id_orden_pedido_padre)
and orden_pedido.disponible = 1
and Item_Inventario_Preventa.id_Item_Inventario_Preventa = @id_item_inventario_preventa
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'

/*realizar los borrados del inventario únicamente si el ítem no tiene piezas facturadas*/
if @cantidad_piezas_facturadas = 0
BEGIN
	begin transaction;
		delete from detalle_item_inventario_preventa 
		where id_item_inventario_preventa = @id_item_inventario_preventa
		and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
		@fecha_inicial and @fecha_final
	commit transaction;
	delete from item_inventario_preventa where not exists
	(
	select * from detalle_item_inventario_preventa 
	where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
	) 
	and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
END