SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[ord_consultar_archivos_pendientes_mapeo]

AS

select cliente_despacho.idc_cliente_despacho,
cliente_pedido.nombre_cliente_pedido,
archivo_orden_pedido.numero_consecutivo,
archivo_orden_pedido.fecha_transaccion,
convert(nvarchar,archivo_orden_pedido.fecha_transaccion, 103) as fecha,
convert(nvarchar,archivo_orden_pedido.fecha_transaccion, 108) as hora
from archivo_orden_pedido,
cliente_pedido,
cliente_despacho
where not exists
(
	select *
	from orden_pedido_pendiente
	where archivo_orden_pedido.id_archivo_orden_pedido = orden_pedido_pendiente.id_archivo_orden_pedido
)
and fecha_transaccion > = convert(datetime, '20120101')
and cliente_pedido.id_cliente_pedido = archivo_orden_pedido.id_cliente_pedido
and cliente_despacho.id_cliente_despacho = cliente_pedido.id_cliente_despacho
order by archivo_orden_pedido.fecha_transaccion