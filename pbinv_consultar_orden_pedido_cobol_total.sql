/****** Object:  StoredProcedure [dbo].[pbinv_consultar_orden_pedido_cobol]    Script Date: 01/05/2008 09:39:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pbinv_consultar_orden_pedido_cobol_total]

@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime

AS

BEGIN

select 
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
transportador.id_transportador,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_factura.id_tipo_factura,
tipo_factura.idc_tipo_factura,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
Color.idc_color,
color.nombre_color,
Color.prioridad_color,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
grado_flor.medidas,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
orden_pedido.unidades_por_pieza,
orden_pedido.marca,
orden_pedido.valor_unitario,
orden_pedido.fecha_inicial,
orden_pedido.fecha_final,
orden_pedido.cantidad_piezas,
orden_pedido.comentario,
orden_pedido.id_orden_pedido_padre,
vendedor.id_vendedor,
vendedor.idc_vendedor,
vendedor.nombre,
orden_pedido.fecha_para_aprobar
from orden_pedido, 
tapa, 
tipo_caja, 
variedad_flor, 
Color,
grado_flor, 
farm, 
tipo_flor, 
cliente_despacho, 
transportador, 
tipo_factura, 
vendedor
where fecha_final between
convert(datetime, @fecha_disponible_distribuidora_inicial, 101) and convert(datetime, @fecha_disponible_distribuidora_final, 101)
and orden_pedido.disponible = 1
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_color = color.id_color
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and orden_pedido.id_vendedor = vendedor.id_vendedor
order by 
orden_pedido.fecha_final

END
