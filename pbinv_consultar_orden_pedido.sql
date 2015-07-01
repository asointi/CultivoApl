set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[pbinv_consultar_orden_pedido]

@fecha_inicial datetime,
@idc_cliente nvarchar(20),
@idc_tipo_factura nvarchar(2)

AS

select orden_pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.idc_tapa,
ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
orden_pedido.marca,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
tipo_factura.idc_tipo_factura,
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
orden_pedido.disponible,
orden_pedido.fecha_inicial,
orden_pedido.fecha_final,
orden_pedido.unidades_por_pieza,
orden_pedido.cantidad_piezas,
ltrim(rtrim(orden_pedido.comentario)) as comentario,
orden_pedido.valor_unitario
from orden_pedido,
cliente_despacho,
tipo_flor,
variedad_flor,
grado_flor,
farm,
tapa,
tipo_caja,
tipo_factura,
transportador
where orden_pedido.id_despacho = cliente_despacho.id_despacho
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.disponible = 1
and
(
	@fecha_inicial between
	Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final
	or 
	@fecha_inicial + 6 between
	Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final
)
and cliente_despacho.idc_cliente_despacho > = 
case 
	when @idc_cliente = '' then '%%'
	else @idc_cliente
end
and cliente_despacho.idc_cliente_despacho < = 
case 
	when @idc_cliente = '' then 'ZZZZZZZZZZ'
	else @idc_cliente
end
and tipo_factura.idc_tipo_factura > = 
case 
	when @idc_tipo_factura = '' then '%%'
	else @idc_tipo_factura
end
and tipo_factura.idc_tipo_factura < = 
case 
	when @idc_tipo_factura = '' then 'ZZ'
	else @idc_tipo_factura
end