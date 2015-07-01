set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER PROCEDURE [dbo].[pbinv_registrar_item]

@id_inventario_preventa integer, 
@id_cuenta_interna integer, 
@id_tapa integer, 
@id_tipo_caja integer, 
@id_variedad_flor integer,
@id_grado_flor integer, 
@unidades_por_pieza integer, 
@marca nvarchar(255), 
@fecha_disponible_distribuidora datetime,
@controla_saldos bit

AS

declare @id_item_inventario_preventa integer,
@id_detalle_item_inventario_preventa integer,
@id_farm integer

select @id_farm = id_farm from inventario_preventa where id_inventario_preventa = @id_inventario_preventa

BEGIN

if(convert(nvarchar,@id_farm)+convert(nvarchar,@id_tapa)+convert(nvarchar,@id_tipo_caja)+convert(nvarchar,@id_variedad_flor)+convert(nvarchar,@id_grado_flor)+convert(nvarchar,@unidades_por_pieza) not in 
(select convert(nvarchar,id_farm)+convert(nvarchar,id_tapa)+convert(nvarchar,id_tipo_caja)+convert(nvarchar,id_variedad_flor)+convert(nvarchar,id_grado_flor)+convert(nvarchar,unidades_por_pieza) from item_inventario_preventa, inventario_preventa where item_inventario_preventa.id_inventario_preventa = inventario_preventa.id_inventario_preventa))
begin
	insert into Item_Inventario_Preventa (id_inventario_preventa, id_cuenta_interna, 
			id_tapa, id_tipo_caja, id_variedad_flor, id_grado_flor, unidades_por_pieza, marca, controla_saldos)
	values (@id_inventario_preventa, @id_cuenta_interna, @id_tapa, @id_tipo_caja, @id_variedad_flor,
			@id_grado_flor, @unidades_por_pieza, @marca, @controla_saldos)

	set @id_item_inventario_preventa = scope_identity()

	insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas)
	values (@id_item_inventario_preventa, @fecha_disponible_distribuidora, 0)

	set @id_detalle_item_inventario_preventa = scope_identity()
	
	update detalle_item_inventario_preventa
	set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa

	select @id_item_inventario_preventa as id_item_inventario_preventa
	return 1
end
else
begin
	select id_item_inventario_preventa
	from Item_Inventario_Preventa, Inventario_Preventa
	where Item_Inventario_Preventa.id_inventario_preventa = Inventario_Preventa.id_inventario_preventa
	and Inventario_Preventa.id_farm = @id_farm
	and id_tapa = @id_tapa
	and id_tipo_caja = @id_tipo_caja
	and id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor
	and unidades_por_pieza =@unidades_por_pieza
	return 2
end
return -1
END

