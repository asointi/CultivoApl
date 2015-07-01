SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_actualizar_detalle_item]

@id_detalle_item_inventario_preventa int, 
@id_item_inventario_preventa int,
@cantidad_piezas int,
@fecha_disponible_distribuidora datetime

AS

declare @id_detalle_item_inventario_preventa_padre int,
@id_detalle_item_inventario_preventa_aux int

if(@id_detalle_item_inventario_preventa is null and @cantidad_piezas <> 0)
begin
	insert into detalle_item_inventario_preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas)
	select @id_item_inventario_preventa, @fecha_disponible_distribuidora, @cantidad_piezas

	set @id_detalle_item_inventario_preventa_aux = scope_identity()

	update detalle_item_inventario_preventa
	set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa_aux
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa_aux
end
else
if(@id_detalle_item_inventario_preventa is not null)
begin
	declare @conteo int

	select @conteo = count(*)
	from detalle_item_inventario_preventa
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa
	and cantidad_piezas = @cantidad_piezas

	if(@conteo = 0)
	begin

		select @id_detalle_item_inventario_preventa_padre = id_detalle_item_inventario_preventa_padre
		from detalle_item_inventario_preventa 
		where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa

		insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, id_detalle_item_inventario_preventa_padre)
		values (@id_item_inventario_preventa, @fecha_disponible_distribuidora, @cantidad_piezas, @id_detalle_item_inventario_preventa_padre)
	end
	else
	begin 
		return -1
	end
end