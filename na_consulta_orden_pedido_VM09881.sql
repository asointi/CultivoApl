set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_consulta_orden_pedido_VM09881]

@idc_cliente_despacho nvarchar(20)

as

select orden_pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
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
tipo_factura.idc_tipo_factura,
orden_pedido.disponible,
color.idc_color,
color.nombre_color,
color.prioridad_color as orden_color,
isnull(orden_pedido.comentario, '') as comentario
from orden_pedido, 
tipo_factura, 
tipo_flor, 
variedad_flor, 
color,
grado_flor, 
farm, 
tapa, 
transportador, 
tipo_caja, 
cliente_despacho
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and variedad_flor.id_color = color.id_color
and LTRIM(RTRIM(cliente_despacho.idc_cliente_despacho)) = LTRIM(RTRIM(@idc_cliente_despacho))

