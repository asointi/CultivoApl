set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_facturacion_automatica_reportes]

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

select orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
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
isnull(orden_pedido.comentario, '') as comentario,
tipo_factura.idc_tipo_factura,
orden_pedido.fecha_creacion_orden,
orden_pedido.disponible,
color.idc_color,
color.nombre_color,
color.prioridad_color as orden_color,
(
	select o.idc_orden_pedido
	from orden_pedido as o,
	orden_pedido as op
	where o.id_orden_pedido = op.id_orden_pedido_padre
	and op.id_orden_pedido = orden_pedido.id_orden_pedido 
) as idc_orden_pedido_padre,
(
	SELECT tipo_venta.id_tipo_venta
	from tipo_venta,
	temporada_cubo,
	temporada_año
	where temporada_cubo.id_año = temporada_año.id_año
	and temporada_cubo.id_temporada = temporada_año.id_temporada
	and temporada_año.id_tipo_venta = tipo_venta.id_tipo_venta
	and orden_pedido.fecha_inicial between
	temporada_cubo.fecha_inicial and temporada_cubo.fecha_final
) as id_tipo_venta,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
isnull(orden_pedido.numero_po, '') as numero_po,
case
	when orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido_padre then 0
	else 1
end as con_version into #temp
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
and variedad_flor.id_color = color.id_color
and orden_pedido.disponible > = @disponible
and
(
	convert(datetime,@fecha_inicial) between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or 
	convert(datetime,@fecha_inicial) + 6 between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or 
	orden_pedido.fecha_inicial between
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
)
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
	when @idc_farm_final = '' then 'ZZ'
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
and tipo_factura.idc_tipo_factura > = 
case 
	when @idc_tipo_factura_inicial = '' then '%%'
	else @idc_tipo_factura_inicial
end
and tipo_factura.idc_tipo_factura < = 
case 
	when @idc_tipo_factura_final = '' then 'ZZ'
	else @idc_tipo_factura_final
end

select * 
from #temp
where #temp.id_tipo_venta > = 
case 
	when @id_tipo_venta_inicial = '' then 0
	else convert(int, @id_tipo_venta_inicial)
end
and #temp.id_tipo_venta < = 
case 
	when @id_tipo_venta_final = '' then 99999
	else convert(int, @id_tipo_venta_final)
end

drop table #temp
