set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_variedades_exclusivas] 

as

select max(id_orden_pedido) as id_orden_pedido into #ordenes
from orden_pedido
group by id_orden_pedido_padre

select farm.id_farm,
variedad_flor.id_variedad_flor into #variedad_exclusiva
from farm,
farm_variedad_flor,
variedad_flor
where farm.tiene_variedad_flor_exclusiva = 1
and farm.id_farm = farm_variedad_flor.id_farm
and variedad_flor.id_variedad_flor = farm_variedad_flor.id_variedad_flor
group by farm.id_farm,
variedad_flor.id_variedad_flor

select id_farm,
id_tapa,
id_tipo_flor,
id_caja into #producto_farm
from producto_farm
group by id_farm,
id_tapa,
id_tipo_flor,
id_caja

select tipo_factura.idc_tipo_factura,
orden_pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.idc_farm,
farm.nombre_farm,
farm.tiene_variedad_flor_exclusiva,
tapa.idc_tapa,
orden_pedido.marca,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
orden_pedido.unidades_por_pieza,
orden_pedido.cantidad_piezas,
orden_pedido.fecha_inicial,
orden_pedido.fecha_final,
orden_pedido.valor_unitario,
orden_pedido.comentario,
orden_pedido.numero_po,
(
	select 1
	from #variedad_exclusiva
	where farm.id_farm = #variedad_exclusiva.id_farm
	and variedad_flor.id_variedad_flor = #variedad_exclusiva.id_variedad_flor
) as variedad_exclusiva,
(
	select top 1 1
	from #producto_farm,
	caja
	where #producto_farm.id_farm = farm.id_farm
	and #producto_farm.id_tapa = tapa.id_tapa
	and #producto_farm.id_tipo_flor = tipo_flor.id_tipo_flor
	and #producto_farm.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
) as producto_farm into #resultado
from orden_pedido,
tipo_factura,
cliente_despacho,
tipo_flor,
variedad_flor,
grado_flor,
farm,
tapa,
tipo_caja,
transportador
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and farm.id_farm = orden_pedido.id_farm
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and transportador.id_transportador = orden_pedido.id_transportador
and orden_pedido.disponible = 1
and exists
(
	select *
	from #ordenes
	where #ordenes.id_orden_pedido = orden_pedido.id_orden_pedido
)
and 
(
	orden_pedido.fecha_inicial > = convert(datetime,convert(nvarchar,getdate(),103))
	or orden_pedido.fecha_final > = convert(datetime,convert(nvarchar,getdate(),103))
)

select idc_tipo_factura,
idc_orden_pedido,
idc_cliente_despacho,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
idc_farm,
nombre_farm,
idc_tapa,
idc_tipo_caja,
nombre_tipo_caja,
marca,
idc_transportador,
nombre_transportador,
unidades_por_pieza,
cantidad_piezas,
fecha_inicial,
fecha_final,
valor_unitario,
isnull(comentario, '') as comentario,
numero_po
from #resultado
where producto_farm is null 
and variedad_exclusiva is null

drop table #ordenes
drop table #variedad_exclusiva
drop table #resultado
drop table #producto_farm