set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_version3]

@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255),
@idc_cliente_inicial nvarchar(255),
@idc_cliente_final nvarchar(255),
@idc_orden_pedido nvarchar(255)

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
orden_pedido.comentario,
0 as con_version,
tipo_factura.idc_tipo_factura,
orden_pedido.fecha_creacion_orden,
orden_pedido.disponible into #temp
from orden_pedido, 
tipo_factura, 
tipo_flor, 
variedad_flor, 
grado_flor, 
farm, 
tapa, 
transportador, 
tipo_caja, 
cliente_despacho
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
and  ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) > =
case
	when ltrim(rtrim(@idc_cliente_inicial)) = '' then '          '
	else ltrim(rtrim(@idc_cliente_inicial))
end
and ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) < =
case
	when ltrim(rtrim(@idc_cliente_final)) = '' then 'ZZZZZZZZZZ'
	else ltrim(rtrim(@idc_cliente_final))
end
and convert(int, orden_pedido.idc_orden_pedido) > =
case
	when convert(int, @idc_orden_pedido) = 0 then 0
	else convert(int, @idc_orden_pedido)
end 
and convert(int, orden_pedido.idc_orden_pedido) < =
case
	when convert(int, @idc_orden_pedido) = 0 then 99999999
	else convert(int, @idc_orden_pedido)
end 
and
(
	convert(datetime,@fecha_inicial) between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or 
	convert(datetime,@fecha_inicial) + 6 between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or orden_pedido.fecha_inicial between
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
)

select id_orden_pedido_padre, 
max(id_orden_pedido) as id_orden_pedido, 
count(*) as cantidad into #temp2
from orden_pedido, 
tipo_factura
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
group by id_orden_pedido_padre

update #temp
set con_version = 1
from #temp, 
#temp2
where #temp.id_orden_pedido = #temp2.id_orden_pedido
and #temp2.cantidad > 1

select * 
from #temp

drop table #temp
drop table #temp2