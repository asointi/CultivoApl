set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_VM05078]

@fecha_inicial nvarchar(15),
@fecha_final nvarchar(15),
@idc_cliente_inicial nvarchar(20),
@idc_cliente_final nvarchar(20),
@idc_orden_pedido nvarchar(20),
@idc_farm_inicial nvarchar(3),
@idc_farm_final nvarchar(3),
@idc_tipo_factura_inicial nvarchar(2),
@idc_tipo_factura_final nvarchar(2),
@id_tipo_venta_inicial nvarchar(2),
@id_tipo_venta_final nvarchar(2),
@disponible bit

as

select tipo_factura.idc_tipo_factura,
orden_pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
transportador.idc_transportador,
farm.idc_farm,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
tapa.idc_tapa,
orden_pedido.marca,
tipo_caja.idc_tipo_caja,
orden_pedido.unidades_por_pieza,
orden_pedido.cantidad_piezas,
orden_pedido.fecha_inicial,
orden_pedido.valor_unitario,
farm.nombre_farm,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
isnull(orden_pedido.comentario, '') as comentario,
orden_pedido.fecha_creacion_orden,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
isnull(orden_pedido.numero_po, '') as po_number
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
where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and cliente_factura.id_vendedor = vendedor.id_vendedor
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and orden_pedido.disponible = 1
and orden_pedido.fecha_inicial
between	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
and LTRIM(RTRIM(cliente_despacho.idc_cliente_despacho)) > = 
case 
	when LTRIM(RTRIM(@idc_cliente_inicial)) = '' then '%%'
	else LTRIM(RTRIM(@idc_cliente_inicial))
end
and LTRIM(RTRIM(cliente_despacho.idc_cliente_despacho)) < = 
case 
	when LTRIM(RTRIM(@idc_cliente_final)) = '' then 'ZZZZZZZZZZ'
	else LTRIM(RTRIM(@idc_cliente_final))
end
and farm.idc_farm > = 
case 
	when @idc_farm_inicial = '' then '%%'
	else @idc_farm_inicial
end
and farm.idc_farm < = 
case 
	when @idc_farm_final = '' then 'ZZZZZZZZZZ'
	else @idc_farm_final
end
and CONVERT(INT,orden_pedido.idc_orden_pedido) > = 
case 
	when @idc_orden_pedido = '' then 0
	else CONVERT(INT,@idc_orden_pedido)
end
and CONVERT(INT,orden_pedido.idc_orden_pedido) < = 
case 
	when @idc_orden_pedido = '' then 999999999999
	else CONVERT(INT,@idc_orden_pedido)
end
and tipo_factura.idc_tipo_factura = '4'