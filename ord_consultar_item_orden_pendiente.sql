set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


alter PROCEDURE [dbo].[ord_consultar_item_orden_pendiente]

@id_orden_pedido_pendiente int

as

select 
item_orden_pedido_pendiente.id_item_orden_pedido_pendiente,
tipo_pedido.nombre_tipo_pedido,
item_orden_pedido_pendiente.fecha_despacho,
flor.idc_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor))+space(1)+
ltrim(rtrim(variedad_flor.nombre_variedad_flor))+space(1)+
ltrim(rtrim(grado_flor.nombre_grado_flor))+space(1)+
ltrim(rtrim(grado_flor.medidas)) as nombre_flor,
item_orden_pedido_pendiente.code,
caja.nombre_caja,
item_orden_pedido_pendiente.unidades_por_pieza,
item_orden_pedido_pendiente.cantidad_piezas,
item_orden_pedido_pendiente.numero_surtido,
item_orden_pedido_pendiente.upc,
item_orden_pedido_pendiente.precio_upc,
item_orden_pedido_pendiente.fecha_vencimiento_flor,
item_orden_pedido_pendiente.precio_distribuidora,
item_orden_pedido_pendiente.capuchon_decorado,
item_orden_pedido_pendiente.comida,
tapa.nombre_tapa
from orden_pedido_pendiente, 
item_orden_pedido_pendiente,
tapa,
flor,
caja,
tipo_flor,
variedad_flor,
grado_flor,
tipo_pedido
where orden_pedido_pendiente.id_orden_pedido_pendiente = item_orden_pedido_pendiente.id_orden_pedido_pendiente
and orden_pedido_pendiente.id_orden_pedido_pendiente = @id_orden_pedido_pendiente
and tapa.id_tapa = item_orden_pedido_pendiente.id_tapa
and flor.id_flor = item_orden_pedido_pendiente.id_flor
and caja.id_caja = item_orden_pedido_pendiente.id_caja
and flor.id_variedad_flor = variedad_flor.id_variedad_flor
and flor.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and item_orden_pedido_pendiente.id_tipo_pedido = tipo_pedido.id_tipo_pedido