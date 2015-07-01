SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pbinv_insertar_inventario]

	@id_item_inventario_preventa int,
	@cantidad_piezas int

AS

declare @empaque_principal bit

select @empaque_principal  = item_inventario_preventa.empaque_principal
from item_inventario_preventa
where item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

if(@empaque_principal = 1)
begin
	update detalle_item_inventario_preventa
	set cantidad_piezas = @cantidad_piezas
	where detalle_item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

	select 1 as actualizado 
end
else
begin
	select 0 as actualizado
end