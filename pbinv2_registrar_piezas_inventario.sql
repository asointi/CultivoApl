set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv2_registrar_piezas_inventario]

@accion nvarchar(255),
@id_item_inventario_preventa int,
@id_fecha_inventario int,
@id_temporada_año int,
@cantidad_piezas int

AS
declare @id_detalle_item_inventario_preventa int

if(@accion = 'insertar_piezas')
begin
	select @id_detalle_item_inventario_preventa = detalle_item_inventario_preventa.id_detalle_item_inventario_preventa
	from fecha_inventario,
	detalle_item_inventario_preventa
	where fecha_inventario.id_fecha_inventario = @id_fecha_inventario
	and fecha_inventario.id_temporada_año = @id_temporada_año
	and fecha_inventario.fecha = detalle_item_inventario_preventa.fecha_disponible_distribuidora
	and detalle_item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

	if(@id_detalle_item_inventario_preventa is null)
	begin
		insert into detalle_item_inventario_preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, cantidad_piezas_adicionales_finca, cantidad_piezas_ofertadas_finca)
		select @id_item_inventario_preventa,
		fecha_inventario.fecha,
		@cantidad_piezas,
		0,
		0
		from fecha_inventario
		where fecha_inventario.id_fecha_inventario = @id_fecha_inventario
		and fecha_inventario.id_temporada_año = @id_temporada_año

		set @id_detalle_item_inventario_preventa = scope_identity()

		update detalle_item_inventario_preventa
		set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
		where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa

		select @id_detalle_item_inventario_preventa as id_detalle_item_inventario_preventa
	end
	else
	begin
		update detalle_item_inventario_preventa
		set cantidad_piezas = @cantidad_piezas
		where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa

		select @id_detalle_item_inventario_preventa as id_detalle_item_inventario_preventa
	end
end