/****** Object:  StoredProcedure [dbo].[pbinv_actualizar_item]    Script Date: 01/05/2008 09:34:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_actualizar_item_version3]

@id_item_inventario_preventa int, 
@precio_minimo decimal(20,4)

AS

declare @id_item_inventario_preventa_aux int

select inventario_preventa.id_farm,
item_inventario_preventa.id_tapa,
item_inventario_preventa.id_variedad_flor,
item_inventario_preventa.id_grado_flor,
detalle_item_inventario_preventa.fecha_disponible_distribuidora into #inventario
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa 
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa =  @id_item_inventario_preventa

select @id_item_inventario_preventa_aux =  max(item_inventario_preventa.id_item_inventario_preventa) 
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa,
#inventario
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and #inventario.id_farm = inventario_preventa.id_farm
and #inventario.id_tapa = item_inventario_preventa.id_tapa
and #inventario.id_variedad_flor = item_inventario_preventa.id_variedad_flor
and #inventario.id_grado_flor = item_inventario_preventa.id_grado_flor
and #inventario.fecha_disponible_distribuidora = detalle_item_inventario_preventa.fecha_disponible_distribuidora
and item_inventario_preventa.empaque_principal = 1

update Item_Inventario_Preventa 
set precio_minimo = @precio_minimo
where id_item_inventario_preventa = @id_item_inventario_preventa_aux
