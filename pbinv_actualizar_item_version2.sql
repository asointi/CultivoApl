/****** Object:  StoredProcedure [dbo].[pbinv_actualizar_item]    Script Date: 01/05/2008 09:34:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_actualizar_item_version2]

@id_item_inventario_preventa integer, 
@id_cuenta_interna integer, 
@precio_minimo decimal(20,4),
@controla_saldos bit,
@precio_finca decimal(20,4)

AS

set @controla_saldos = convert(bit, @controla_saldos)
set @id_cuenta_interna = convert(int, @id_cuenta_interna)

if(@id_cuenta_interna <> 0)
begin
	update Item_Inventario_Preventa 
	set precio_minimo = @precio_minimo,
	precio_finca = @precio_finca,
	id_cuenta_interna = @id_cuenta_interna, 
	controla_saldos = @controla_saldos,
	fecha_transaccion = getdate()
	where id_item_inventario_preventa = @id_item_inventario_preventa
end
else 
begin
	update Item_Inventario_Preventa 
	set precio_minimo = @precio_minimo,
	precio_finca = @precio_finca,
	fecha_transaccion = getdate()
	where id_item_inventario_preventa = @id_item_inventario_preventa
end