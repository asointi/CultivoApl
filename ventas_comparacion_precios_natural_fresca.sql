set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/09/28
-- Description:	Se utiliza para comparacion de precios entre Natural y Fresca
-- =============================================

alter PROCEDURE [dbo].[ventas_comparacion_precios_natural_fresca] 

as

declare @cantidad_dias_atras_inventario int,
@id_estado_pieza_open_market int,
@conteo int,
@fresca nvarchar(50),
@natural nvarchar(50)

select @cantidad_dias_atras_inventario = cantidad_dias_atras_inventario from bd_nf.bd_nf.dbo.configuracion_bd
select @id_estado_pieza_open_market = id_estado_pieza from bd_nf.bd_nf.dbo.estado_pieza where nombre_estado_pieza = 'Open Market'
set @fresca = 'FRESCA FARMS'
set @natural = 'NATURAL FLOWERS'

select tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
0 as unidades,
mapeo_variedad_flor_natuflora.id_variedad_flor_natuflora,
mapeo_grado_flor_natuflora.id_grado_flor_natuflora into #inventario
from bd_nf.bd_nf.dbo.pieza, 
bd_nf.bd_nf.dbo.tipo_flor,
bd_nf.bd_nf.dbo.farm,
bd_nf.bd_nf.dbo.variedad_flor left join bd_nf.bd_nf.dbo.mapeo_variedad_flor_natuflora on variedad_flor.id_variedad_flor = mapeo_variedad_flor_natuflora.id_variedad_flor,
bd_nf.bd_nf.dbo.grado_flor left join bd_nf.bd_nf.dbo.mapeo_grado_flor_natuflora on grado_flor.id_grado_flor = mapeo_grado_flor_natuflora.id_grado_flor,
bd_nf.bd_nf.dbo.estado_pieza
where pieza.id_estado_pieza = estado_pieza.id_estado_pieza
and estado_pieza.id_estado_pieza in (@id_estado_pieza_open_market)
and pieza.disponible = 1
and pieza.tiene_marca = 0
and pieza.direccion_pieza <> 0
and pieza.direccion_pieza <> 6
and not exists
(
	select * 
	from bd_nf.bd_nf.dbo.detalle_item_factura
	where pieza.id_pieza = detalle_item_factura.id_pieza
)
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and farm.id_farm = pieza.id_farm
and farm.finca_propia = 1
group by tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
mapeo_variedad_flor_natuflora.id_variedad_flor_natuflora,
mapeo_grado_flor_natuflora.id_grado_flor_natuflora
having 
count(pieza.id_pieza) > 0

alter table #inventario
add precio decimal(20,4)

select id_variedad_flor,
id_grado_flor, 
max(id_valor_producto) as id_valor_producto into #precio
from bd_nf.bd_nf.dbo.valor_producto 
where convert(datetime,convert(nvarchar,valor_producto.fecha_disponible_precio,103)) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,101))
group by id_variedad_flor,
id_grado_flor

alter table #precio
add precio decimal(20,4)

update #precio
set precio = valor_producto.precio
from bd_nf.bd_nf.dbo.valor_producto
where valor_producto.id_valor_producto = #precio.id_valor_producto

/*actualizar el precio de cada pieza*/
update #inventario
set precio = #precio.precio
from #precio
where #inventario.id_variedad_flor = #precio.id_variedad_flor
and #inventario.id_grado_flor = #precio.id_grado_flor

/*borrar items del inventario que no tengan precio vigente*/
delete from #inventario where precio is null

select @natural as comercializadora,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
detalle_facturacion_dia.unidades_vendidas,
detalle_facturacion_dia.valor,
mapeo_variedad_flor_natuflora.id_variedad_flor_natuflora,
mapeo_grado_flor_natuflora.id_grado_flor_natuflora,
(
	select max(d.fecha_transaccion)
	from bd_nf.bd_nf.dbo.detalle_facturacion_dia as d
) as fecha_transaccion into #resultado
from bd_nf.bd_nf.dbo.facturacion_dia,
bd_nf.bd_nf.dbo.detalle_facturacion_dia,
bd_nf.bd_nf.dbo.tipo_flor,
bd_nf.bd_nf.dbo.farm,
bd_nf.bd_nf.dbo.variedad_flor left join bd_nf.bd_nf.dbo.mapeo_variedad_flor_natuflora on variedad_flor.id_variedad_flor = mapeo_variedad_flor_natuflora.id_variedad_flor,
bd_nf.bd_nf.dbo.grado_flor left join bd_nf.bd_nf.dbo.mapeo_grado_flor_natuflora on grado_flor.id_grado_flor = mapeo_grado_flor_natuflora.id_grado_flor
where facturacion_dia.id_facturacion_dia = detalle_facturacion_dia.id_facturacion_dia
and farm.id_farm = detalle_facturacion_dia.id_farm
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = detalle_facturacion_dia.id_variedad_flor
and grado_flor.id_grado_flor = detalle_facturacion_dia.id_grado_flor
and facturacion_dia.fecha_facturacion_dia = convert(datetime, convert(nvarchar, getdate(), 101))
and farm.finca_propia = 1
union all 
select @natural as comercializadora,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
idc_grado_flor,
nombre_grado_flor,
idc_farm,
nombre_farm,
unidades,
0 as valor,
id_variedad_flor_natuflora,
id_grado_flor_natuflora,
null
from #inventario
UNION ALL
select @fresca as comercializadora,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
detalle_facturacion_dia.unidades_vendidas,
detalle_facturacion_dia.valor,
mapeo_variedad_flor_natuflora.id_variedad_flor_natuflora,
mapeo_grado_flor_natuflora.id_grado_flor_natuflora,
(
	select max(d.fecha_transaccion)
	from bd_fresca.bd_fresca.dbo.detalle_facturacion_dia as d
) as fecha_transaccion
from bd_fresca.bd_fresca.dbo.facturacion_dia,
bd_fresca.bd_fresca.dbo.detalle_facturacion_dia,
bd_fresca.bd_fresca.dbo.tipo_flor,
bd_fresca.bd_fresca.dbo.farm,
bd_fresca.bd_fresca.dbo.variedad_flor left join bd_fresca.bd_fresca.dbo.mapeo_variedad_flor_natuflora on variedad_flor.id_variedad_flor = mapeo_variedad_flor_natuflora.id_variedad_flor,
bd_fresca.bd_fresca.dbo.grado_flor left join bd_fresca.bd_fresca.dbo.mapeo_grado_flor_natuflora on grado_flor.id_grado_flor = mapeo_grado_flor_natuflora.id_grado_flor
where facturacion_dia.id_facturacion_dia = detalle_facturacion_dia.id_facturacion_dia
and farm.id_farm = detalle_facturacion_dia.id_farm
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = detalle_facturacion_dia.id_variedad_flor
and grado_flor.id_grado_flor = detalle_facturacion_dia.id_grado_flor
and facturacion_dia.fecha_facturacion_dia = convert(datetime, convert(nvarchar, getdate(), 101))
and farm.finca_propia = 1

alter table #resultado
add idc_tipo_flor_natuflora nvarchar(5),
nombre_tipo_flor_natuflora nvarchar(50),
idc_variedad_flor_natuflora nvarchar(5),
nombre_variedad_flor_natuflora nvarchar(50),
idc_grado_flor_natuflora nvarchar(5),
nombre_grado_flor_natuflora nvarchar(50)

update #resultado
set idc_tipo_flor_natuflora = tipo_flor.idc_tipo_flor,
nombre_tipo_flor_natuflora = ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
idc_variedad_flor_natuflora = variedad_flor.idc_variedad_flor,
nombre_variedad_flor_natuflora = ltrim(rtrim(variedad_flor.nombre_variedad_flor))
from tipo_flor,
variedad_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = #resultado.id_variedad_flor_natuflora

update #resultado
set idc_tipo_flor_natuflora = tipo_flor.idc_tipo_flor,
nombre_tipo_flor_natuflora = ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
idc_grado_flor_natuflora = grado_flor.idc_grado_flor,
nombre_grado_flor_natuflora = ltrim(rtrim(grado_flor.nombre_grado_flor))
from tipo_flor,
grado_flor
where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.id_grado_flor = #resultado.id_grado_flor_natuflora

update #resultado
set idc_tipo_flor_natuflora = '**' + idc_tipo_flor,
nombre_tipo_flor_natuflora = '**' + nombre_tipo_flor
where idc_tipo_flor_natuflora is null

update #resultado
set idc_variedad_flor_natuflora = '**' + idc_variedad_flor,
nombre_variedad_flor_natuflora = '**' + nombre_variedad_flor
where idc_variedad_flor_natuflora is null

update #resultado
set idc_grado_flor_natuflora = '**' + idc_grado_flor,
nombre_grado_flor_natuflora = '**' + nombre_grado_flor
where idc_grado_flor_natuflora is null

select identity(int, 1,1) as id,
* into #resultado1
from #resultado 
where 
(
	left(idc_tipo_flor_natuflora, 2) <> '**'
	and left(idc_grado_flor_natuflora, 2) <> '**'
	and left(idc_variedad_flor_natuflora, 2) <> '**'
)
order by nombre_tipo_flor_natuflora,
nombre_grado_flor_natuflora,
nombre_variedad_flor_natuflora

select identity(int, 10000,1) as id,
* into #resultado2
from #resultado
where 
(
	left(idc_tipo_flor_natuflora, 2) = '**'
	or left(idc_grado_flor_natuflora, 2) = '**'
	or left(idc_variedad_flor_natuflora, 2) = '**'
)
order by nombre_tipo_flor_natuflora,
nombre_grado_flor_natuflora,
nombre_variedad_flor_natuflora

select *
from #resultado1
union all
select *
from #resultado2
order by id

drop table #inventario
drop table #precio
drop table #resultado
drop table #resultado1
drop table #resultado2