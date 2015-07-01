set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_modificar_item_orden_pendiente]

@id_item_orden_pedido_pendiente int,
@idc_orden_pedido nvarchar(255)

as

update item_orden_pedido_pendiente
set idc_orden_pedido = @idc_orden_pedido
where id_item_orden_pedido_pendiente = @id_item_orden_pedido_pendiente
