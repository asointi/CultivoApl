set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_consultar_fechas_carga_despacho]

@idc_orden_pedido nvarchar(255)

as

select archivo_orden_pedido.fecha_transaccion as fecha_carga_archivo,
archivo_orden_pedido.numero_consecutivo,
item_orden_pedido_pendiente.fecha_miami as fecha_despacho
from archivo_orden_pedido,
orden_pedido_pendiente,
item_orden_pedido_pendiente
where archivo_orden_pedido.id_archivo_orden_pedido = orden_pedido_pendiente.id_archivo_orden_pedido
and orden_pedido_pendiente.id_orden_pedido_pendiente = item_orden_pedido_pendiente.id_orden_pedido_pendiente
and convert(int,item_orden_pedido_pendiente.idc_orden_pedido) = convert(int,@idc_orden_pedido)