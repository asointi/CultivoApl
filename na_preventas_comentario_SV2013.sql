set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_preventas_comentario_SV2013] 

as

declare @idc_vendedor nvarchar(5)

set @idc_vendedor = '40'

select max(id_orden_pedido) as id_orden_pedido into #orden_pedido
from orden_pedido
group by id_orden_pedido_padre

select ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
vendedor.idc_vendedor,
cliente_despacho.idc_cliente_despacho,
orden_pedido.valor_unitario,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
farm.idc_farm,
orden_pedido.marca,
isnull(orden_pedido.numero_po, '') as numero_po,
orden_pedido.unidades_por_pieza,
sum(orden_pedido.cantidad_piezas) as cantidad_piezas,
ltrim(rtrim(isnull(orden_pedido.comentario, ''))) as comentario,
orden_pedido.fecha_inicial
from orden_pedido,
tipo_flor,
variedad_flor,
grado_flor,
cliente_despacho,
cliente_factura,
vendedor,
tipo_caja,
farm,
tipo_factura
where orden_pedido.disponible = 1
and orden_pedido.fecha_inicial between
convert(datetime, '20130425') and convert(datetime, '20130510')
and exists
(
	select * 
	from #orden_pedido
	where #orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido
)
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and farm.id_farm = orden_pedido.id_farm
--and vendedor.idc_vendedor = @idc_vendedor
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
group by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
ltrim(rtrim(grado_flor.nombre_grado_flor)),
vendedor.idc_vendedor,
cliente_despacho.idc_cliente_despacho,
orden_pedido.valor_unitario,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
farm.idc_farm,
orden_pedido.marca,
orden_pedido.numero_po,
orden_pedido.unidades_por_pieza,
ltrim(rtrim(isnull(orden_pedido.comentario, ''))),
orden_pedido.fecha_inicial
order by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
ltrim(rtrim(grado_flor.nombre_grado_flor))

drop table #orden_pedido