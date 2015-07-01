set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_consulta_orden_pedido_so]

@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255)

as

select max(id_orden_pedido) as id_orden_pedido,
orden_pedido.id_orden_pedido_padre, 
count(*) as cantidad into #ordenes
from orden_pedido, tipo_factura 
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
group by id_orden_pedido_padre

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
orden_pedido.comentario,
0 as con_version into #temp
from orden_pedido, tipo_factura, tipo_flor, variedad_flor, grado_flor, farm, tapa, transportador, tipo_caja, cliente_despacho
where 
tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
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
and orden_pedido.fecha_final between
convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
and exists
(
	select * 
	from #ordenes
	where #ordenes.id_orden_pedido = orden_pedido.id_orden_pedido
)

update #temp
set con_version = 1
from #ordenes
where #temp.id_orden_pedido = #ordenes.id_orden_pedido
and #ordenes.cantidad > 1

select * from #temp

drop table #temp
drop table #ordenes
