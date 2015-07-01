set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/01/27
-- Description:	Consulta las preventas que han sido vendidas por debajo del precio minimo presente en el inventario
-- =============================================

alter PROCEDURE [dbo].[pbinv_consultar_preventas_superando_precio_minimo] 

as

declare @nombre_base_datos nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime

set @nombre_base_datos = DB_NAME()

if(@nombre_base_datos = 'BD_NF')
begin
	set @fecha_inicial = '25/01/2012'
	set @fecha_final = '10/02/2012'
end
else 
begin
	set @fecha_inicial = '26/01/2012'
	set @fecha_final = '16/02/2012'
end

select max(id_orden_pedido) as id_orden_pedido into #temp
from orden_pedido
group by id_orden_pedido_padre

select farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tapa.idc_tapa,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tapa.id_tapa,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
orden_pedido.unidades_por_pieza,
orden_pedido.marca,
orden_pedido.valor_unitario,

orden_Pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
vendedor.idc_vendedor,
vendedor.nombre as nombre_vendedor,
orden_pedido.fecha_inicial,
color.idc_color,
color.nombre_color into #preventa
from orden_pedido,
farm,
variedad_flor,
grado_flor,
tapa,
tipo_factura,
tipo_caja,
cliente_despacho,
cliente_factura,
vendedor,
tipo_flor,
color
where farm.id_farm = orden_pedido.id_farm
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and color.id_color = variedad_flor.id_color
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and vendedor.id_vendedor = cliente_factura.id_vendedor
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and exists
(
	select *
	from #temp
	where #temp.id_orden_pedido = orden_pedido.id_orden_pedido
)
--and cliente_despacho.idc_cliente_despacho not like 'BIDO%'
--and cliente_despacho.idc_cliente_despacho not like 'PEN%'

select farm.id_farm,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tapa.id_tapa,
tipo_caja.id_tipo_caja,
item_inventario_preventa.unidades_por_pieza,
item_inventario_preventa.marca,
item_inventario_preventa.precio_minimo,
item_inventario_preventa.empaque_principal into #inventario
from inventario_preventa,
farm,
tapa,
item_inventario_preventa,
detalle_item_inventario_preventa,
variedad_flor,
grado_flor,
tipo_caja
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and detalle_item_inventario_preventa.fecha_disponible_distribuidora = @fecha_inicial
and farm.id_farm = inventario_preventa.id_farm
and tapa.id_tapa = item_inventario_preventa.id_tapa
and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
and tipo_caja.id_tipo_caja = item_inventario_preventa.id_tipo_caja
and item_inventario_preventa.empaque_principal = 1

alter table #preventa
add precio_minimo decimal(20,4)

if(@nombre_base_datos = 'BD_NF')
begin
	update #preventa
	set precio_minimo = #inventario.precio_minimo
	from #inventario
	where #preventa.id_farm = #inventario.id_farm
	and #preventa.id_variedad_flor = #inventario.id_variedad_flor
	and #preventa.id_grado_flor = #inventario.id_grado_flor
end
else
begin
	update #preventa
	set precio_minimo = #inventario.precio_minimo
	from #inventario
	where #preventa.id_farm = #inventario.id_farm
	and #preventa.id_variedad_flor = #inventario.id_variedad_flor
	and #preventa.id_grado_flor = #inventario.id_grado_flor
	and #preventa.id_tapa = #inventario.id_tapa
end

select idc_orden_pedido,
fecha_inicial,
idc_farm,
nombre_farm,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor,
idc_color,
nombre_color,
idc_tapa,
idc_tipo_caja,
nombre_tipo_caja,
marca,
valor_unitario,
precio_minimo,
unidades_por_pieza,
idc_cliente_despacho,
idc_vendedor,
nombre_vendedor
from #preventa
where valor_unitario < precio_minimo
and precio_minimo is not null
order by fecha_inicial,
idc_vendedor,
idc_cliente_despacho

drop table #temp
drop table #preventa
drop table #inventario