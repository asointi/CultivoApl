/****** Object:  StoredProcedure [dbo].[pbinv_registrar_item]    Script Date: 10/06/2007 13:36:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_registrar_detalle_item]

@id_item_inventario_preventa integer, 
@cantidad_piezas integer, 
@fecha_disponible_distribuidora nvarchar(255)

AS

if(convert(nvarchar, @id_item_inventario_preventa)+convert(nvarchar,convert(datetime,@fecha_disponible_distribuidora),111) in (select convert(nvarchar, id_item_inventario_preventa)+convert(nvarchar, fecha_disponible_distribuidora,111) from Detalle_Item_Inventario_Preventa))
	return -1
else
begin
	insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas)
	values (@id_item_inventario_preventa, @fecha_disponible_distribuidora, @cantidad_piezas)
	
	declare @id_detalle_item_inventario_preventa_padre integer

	set @id_detalle_item_inventario_preventa_padre = scope_identity()

	update detalle_item_inventario_preventa
	set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa_padre
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa_padre
end

