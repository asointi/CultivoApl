set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_generar_reporte_ordenes_fijas_vigentes] 

as

declare @orden_pedido table
(
  id_orden_pedido int
)

insert into @orden_pedido (id_orden_pedido)
select max(orden_pedido.id_orden_pedido)
from orden_pedido,
tipo_factura
where convert(datetime, cast(getdate() as date)) between
orden_pedido.fecha_inicial and orden_pedido.fecha_final
and orden_pedido.disponible = 1
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
group by orden_pedido.id_orden_pedido_padre

select orden_pedido.idc_orden_pedido as numero_orden,
farm.idc_farm + ' [' + ltrim(rtrim(farm.nombre_farm)) as farm,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as flower_type,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as variety,
ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as grade,
ltrim(rtrim(tapa.nombre_tapa)) + ' [' + tapa.idc_tapa + ']' as lid,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) + ' [' + tipo_caja.idc_tipo_caja + ']' as box,
cliente_despacho.idc_cliente_despacho + ' [' + ltrim(rtrim(cliente_despacho.nombre_cliente)) + ']' as customer,
orden_pedido.marca as code,
orden_pedido.fecha_inicial as initial_date,
orden_pedido.fecha_final as final_date,
orden_pedido.unidades_por_pieza as pack,
orden_pedido.cantidad_piezas as pieces, 
orden_pedido.comentario as observation
from orden_pedido,
farm,
tipo_flor,
variedad_flor,
grado_flor,
tapa,
tipo_caja,
cliente_despacho
where exists
(
  select *
  from @orden_pedido as op
  where op.id_orden_pedido = orden_pedido.id_orden_pedido
)
and farm.id_farm = orden_pedido.id_farm
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and cliente_despacho.id_despacho = orden_pedido.id_despacho