set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_sin_verificar_aprobaciones]

@fecha_inicial datetime,
@fecha_final datetime

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
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor into #temp
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
and orden_pedido.disponible = 1
and
(
	@fecha_inicial
	between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or @fecha_inicial + 6
	between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or 
	orden_pedido.fecha_inicial between
	@fecha_inicial and @fecha_final
)

alter table #temp
add idc_caja nvarchar(2),
precio_finca decimal(20, 4)

update #temp
set idc_caja = tipo_caja.idc_tipo_caja + caja.idc_caja,
precio_finca = 
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol 
end
from caja,
tipo_caja,
item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden,
confirmacion_orden_cultivo,
orden_confirmada,
orden_pedido
where item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
and confirmacion_orden_cultivo.id_confirmacion_orden_cultivo = orden_confirmada.id_confirmacion_orden_cultivo
and orden_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
and orden_pedido.id_orden_pedido = #temp.id_orden_pedido

update #temp
set idc_caja = tipo_caja.idc_tipo_caja + caja.idc_caja,
precio_finca = 
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol 
end
from caja,
tipo_caja,
item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
confirmacion_orden_especial_cultivo,
orden_especial_confirmada,
orden_pedido
where item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo = orden_especial_confirmada.id_confirmacion_orden_especial_cultivo
and orden_especial_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
and orden_pedido.id_orden_pedido = #temp.id_orden_pedido

update #temp
set idc_caja = ''
where idc_caja is null

select * 
from #temp

drop table #temp
