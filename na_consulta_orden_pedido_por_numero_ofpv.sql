set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_por_numero_ofpv]

@idc_orden_pedido nvarchar(15)

as

select orden_pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
vendedor.idc_vendedor,
vendedor.nombre as nombre_vendedor,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
transportador.idc_transportador,
transportador.nombre_transportador,
orden_pedido.fecha_inicial,
orden_pedido.fecha_final,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.cantidad_piezas,
orden_pedido.valor_unitario,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
orden_pedido.comentario,
tipo_factura.idc_tipo_factura,
orden_pedido.disponible,
orden_pedido.numero_po
from orden_pedido, 
tipo_factura, 
tipo_flor, 
variedad_flor, 
grado_flor, 
farm, 
tapa, 
transportador, 
tipo_caja, 
cliente_despacho,
cliente_factura,
vendedor
where 
tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and convert(int,idc_orden_pedido) = convert(int,@idc_orden_pedido)
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura 
and vendedor.id_vendedor = cliente_factura.id_vendedor