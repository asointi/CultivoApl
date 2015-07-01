set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/07/06
-- Description:	Se utiliza para generar el reporte de precios minimos de las comercializadoras
-- =============================================

alter PROCEDURE [dbo].[ventas_miami_reporte_precios_minimos] 

as

declare @id_estado_pieza_open_market int,
@id_estado_pieza_hold int,
@cantidad_dias_atras_inventario int,
@fresca nvarchar(50),
@natural nvarchar(50)

set @fresca = 'FRESCA FARMS'
set @natural = 'NATURAL FLOWERS'

select @id_estado_pieza_open_market = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Open Market'
select @id_estado_pieza_hold = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Hold'
select @cantidad_dias_atras_inventario = cantidad_dias_atras_inventario from configuracion_bd

Select tipo_flor.id_tipo_flor,
idc_tipo_flor,
ltrim(rtrim(nombre_tipo_flor)) as nombre_tipo_flor,
id_grado_flor,
'[' + idc_grado_flor + ']' as idc_grado_flor,
ltrim(rtrim(nombre_grado_flor)) as nombre_grado_flor into #grado_flor
from bd_cultivo.bd_cultivo.dbo.tipo_flor,
bd_cultivo.bd_cultivo.dbo.grado_flor
where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor

Select tipo_flor.id_tipo_flor,
idc_tipo_flor,
ltrim(rtrim(nombre_tipo_flor)) as nombre_tipo_flor,
id_variedad_flor,
'[' + idc_variedad_flor + ']' as idc_variedad_flor,
ltrim(rtrim(nombre_variedad_flor)) as nombre_variedad_flor into #variedad_flor
from bd_cultivo.bd_cultivo.dbo.tipo_flor,
bd_cultivo.bd_cultivo.dbo.variedad_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor

/*extractar inventario superior a 1 pieza*/
select variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_flor.idc_tipo_flor,
Mapeo_Variedad_Flor_Natuflora.id_variedad_flor_natuflora as id_variedad_flor_mapeo,
Mapeo_Grado_Flor_Natuflora.id_grado_flor_natuflora as id_grado_flor_mapeo,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
'[' + variedad_flor.idc_variedad_flor + ']**' as idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
'[' + grado_flor.idc_grado_flor + ']**' as idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor))as nombre_grado_flor,
sum(pieza.unidades_por_pieza) as unidades into #inventario
from pieza, 
tipo_flor,
variedad_flor left join Mapeo_Variedad_Flor_Natuflora on variedad_flor.id_variedad_flor = Mapeo_Variedad_Flor_Natuflora.id_variedad_flor,
grado_flor left join Mapeo_Grado_Flor_Natuflora on grado_flor.id_grado_flor = Mapeo_Grado_Flor_Natuflora.id_grado_flor,
estado_pieza
where pieza.id_estado_pieza = estado_pieza.id_estado_pieza
and estado_pieza.id_estado_pieza in (@id_estado_pieza_open_market, @id_estado_pieza_hold)
and pieza.disponible = 1
and pieza.tiene_marca = 0
and pieza.direccion_pieza <> 0
and pieza.direccion_pieza <> 6
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and not exists
(
	select * 
	from detalle_item_factura
	where pieza.id_pieza = detalle_item_factura.id_pieza
)
group by variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
Mapeo_Variedad_Flor_Natuflora.id_variedad_flor_natuflora,
Mapeo_Grado_Flor_Natuflora.id_grado_flor_natuflora

select id_variedad_flor,
id_grado_flor, 
max(id_valor_producto) as id_valor_producto into #valor_producto
from valor_producto 
where convert(datetime,convert(nvarchar,valor_producto.fecha_disponible_precio,103)) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,103))
and code = ''
group by id_variedad_flor,
id_grado_flor

alter table #valor_producto
add precio decimal(20,4)

update #valor_producto
set precio = valor_producto.precio_minimo
from valor_producto
where valor_producto.id_valor_producto = #valor_producto.id_valor_producto

alter table #inventario
add precio decimal(20,4)

update #inventario
set precio = #valor_producto.precio
from #valor_producto
where #inventario.id_variedad_flor = #valor_producto.id_variedad_flor
and #inventario.id_grado_flor = #valor_producto.id_grado_flor

drop table #valor_producto

--==========================================================
--==========================================================
--Traer los datos desde Natural Flowers
--==========================================================
--==========================================================

select @id_estado_pieza_open_market = id_estado_pieza from bd_nf.bd_nf.dbo.estado_pieza where nombre_estado_pieza = 'Open Market'
select @id_estado_pieza_hold = id_estado_pieza from bd_nf.bd_nf.dbo.estado_pieza where nombre_estado_pieza = 'Hold'
select @cantidad_dias_atras_inventario = cantidad_dias_atras_inventario from bd_nf.bd_nf.dbo.configuracion_bd

/*extractar inventario superior a 1 pieza*/
select variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
color.idc_color,
tipo_flor.idc_tipo_flor,
Mapeo_Variedad_Flor_Natuflora.id_variedad_flor_natuflora as id_variedad_flor_mapeo,
Mapeo_Grado_Flor_Natuflora.id_grado_flor_natuflora as id_grado_flor_mapeo,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
'[' + variedad_flor.idc_variedad_flor + ']**' as idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
'[' + grado_flor.idc_grado_flor + ']**' as idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
sum(pieza.unidades_por_pieza) as unidades into #inventario_natural
from bd_nf.bd_nf.dbo.pieza, 
bd_nf.bd_nf.dbo.color, 
bd_nf.bd_nf.dbo.tipo_flor,
bd_nf.bd_nf.dbo.variedad_flor left join bd_nf.bd_nf.dbo.Mapeo_Variedad_Flor_Natuflora on variedad_flor.id_variedad_flor = Mapeo_Variedad_Flor_Natuflora.id_variedad_flor,
bd_nf.bd_nf.dbo.grado_flor left join bd_nf.bd_nf.dbo.Mapeo_Grado_Flor_Natuflora on grado_flor.id_grado_flor = Mapeo_Grado_Flor_Natuflora.id_grado_flor,
bd_nf.bd_nf.dbo.estado_pieza
where pieza.id_estado_pieza = estado_pieza.id_estado_pieza
and color.id_color = variedad_flor.id_color
and estado_pieza.id_estado_pieza in (@id_estado_pieza_open_market, @id_estado_pieza_hold)
and pieza.disponible = 1
and pieza.tiene_marca = 0
and pieza.direccion_pieza <> 0
and pieza.direccion_pieza <> 6
and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and not exists
(
	select * 
	from bd_nf.bd_nf.dbo.detalle_item_factura
	where pieza.id_pieza = detalle_item_factura.id_pieza
)
group by variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
color.idc_color,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
Mapeo_Variedad_Flor_Natuflora.id_variedad_flor_natuflora,
Mapeo_Grado_Flor_Natuflora.id_grado_flor_natuflora

select id_variedad_flor,
id_grado_flor, 
max(id_valor_producto) as id_valor_producto into #valor_producto_natural
from bd_nf.bd_nf.dbo.valor_producto 
where convert(datetime,convert(nvarchar,valor_producto.fecha_disponible_precio,103)) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,103))
and code = ''
group by id_variedad_flor,
id_grado_flor

alter table #valor_producto_natural
add precio decimal(20,4)

update #valor_producto_natural
set precio = valor_producto.precio_minimo
from bd_nf.bd_nf.dbo.valor_producto
where valor_producto.id_valor_producto = #valor_producto_natural.id_valor_producto

alter table #inventario_natural
add precio decimal(20,4)

update #inventario_natural
set precio = #valor_producto_natural.precio
from #valor_producto_natural
where #inventario_natural.id_variedad_flor = #valor_producto_natural.id_variedad_flor
and #inventario_natural.id_grado_flor = #valor_producto_natural.id_grado_flor

drop table #valor_producto_natural

update #inventario
set idc_tipo_flor = #grado_flor.idc_tipo_flor,
nombre_tipo_flor = #grado_flor.nombre_tipo_flor,
idc_grado_flor = #grado_flor.idc_grado_flor,
nombre_grado_flor = #grado_flor.nombre_grado_flor
from #grado_flor
where #inventario.id_grado_flor_mapeo = #grado_flor.id_grado_flor

update #inventario
set idc_tipo_flor = #variedad_flor.idc_tipo_flor,
nombre_tipo_flor = #variedad_flor.nombre_tipo_flor,
idc_variedad_flor = #variedad_flor.idc_variedad_flor,
nombre_variedad_flor = #variedad_flor.nombre_variedad_flor
from #variedad_flor
where #inventario.id_variedad_flor_mapeo = #variedad_flor.id_variedad_flor

update #inventario_natural
set idc_tipo_flor = #grado_flor.idc_tipo_flor,
nombre_tipo_flor = #grado_flor.nombre_tipo_flor,
idc_grado_flor = #grado_flor.idc_grado_flor,
nombre_grado_flor = #grado_flor.nombre_grado_flor
from #grado_flor
where #inventario_natural.id_grado_flor_mapeo = #grado_flor.id_grado_flor

update #inventario_natural
set idc_tipo_flor = #variedad_flor.idc_tipo_flor,
nombre_tipo_flor = #variedad_flor.nombre_tipo_flor,
idc_variedad_flor = #variedad_flor.idc_variedad_flor,
nombre_variedad_flor = #variedad_flor.nombre_variedad_flor
from #variedad_flor
where #inventario_natural.id_variedad_flor_mapeo = #variedad_flor.id_variedad_flor

select @fresca as comercializadora,
id_variedad_flor,
id_grado_flor,
idc_tipo_flor,
'' as idc_color,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
precio,
sum(unidades) as unidades into #resultado
from #inventario
where precio is not null
group by id_variedad_flor,
id_grado_flor,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
precio
union all
select @natural as comercializadora,
id_variedad_flor,
id_grado_flor,
idc_tipo_flor,
idc_color,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
precio,
sum(unidades) as unidades
from #inventario_natural
where precio is not null
group by id_variedad_flor,
id_grado_flor,
idc_tipo_flor,
idc_color,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
precio

select idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor into #repetidos
from #resultado
group by idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor
having count(*) = 2

alter table #repetidos
add precio_natural decimal(20,4),
precio_fresca decimal(20,4),
porcentaje decimal(20,4)

update #repetidos
set precio_natural = precio
from #resultado
where #repetidos.idc_tipo_flor = #resultado.idc_tipo_flor
and #repetidos.nombre_tipo_flor  = #resultado.nombre_tipo_flor
and #repetidos.idc_variedad_flor  = #resultado.idc_variedad_flor
and #repetidos.nombre_variedad_flor  = #resultado.nombre_variedad_flor
and #repetidos.idc_grado_flor  = #resultado.idc_grado_flor
and #repetidos.nombre_grado_flor  = #resultado.nombre_grado_flor
and #resultado.comercializadora = @natural

update #repetidos
set porcentaje = ((precio_natural - precio) / precio) * 100,
precio_fresca = precio
from #resultado
where #repetidos.idc_tipo_flor = #resultado.idc_tipo_flor
and #repetidos.nombre_tipo_flor  = #resultado.nombre_tipo_flor
and #repetidos.idc_variedad_flor  = #resultado.idc_variedad_flor
and #repetidos.nombre_variedad_flor  = #resultado.nombre_variedad_flor
and #repetidos.idc_grado_flor  = #resultado.idc_grado_flor
and #repetidos.nombre_grado_flor  = #resultado.nombre_grado_flor
and #resultado.comercializadora = @fresca 

select #resultado.comercializadora,
#resultado.id_variedad_flor,
#resultado.id_grado_flor,
#resultado.idc_tipo_flor,
#resultado.nombre_tipo_flor,
#resultado.idc_variedad_flor,
#resultado.idc_color,
#resultado.nombre_variedad_flor,
#resultado.idc_grado_flor,
#resultado.nombre_grado_flor,
#resultado.precio,
(
	select convert(decimal(20,2), porcentaje)
	from #repetidos
	where #repetidos.idc_tipo_flor = #resultado.idc_tipo_flor
	and #repetidos.nombre_tipo_flor  = #resultado.nombre_tipo_flor
	and #repetidos.idc_variedad_flor  = #resultado.idc_variedad_flor
	and #repetidos.nombre_variedad_flor  = #resultado.nombre_variedad_flor
	and #repetidos.idc_grado_flor  = #resultado.idc_grado_flor
	and #repetidos.nombre_grado_flor  = #resultado.nombre_grado_flor
) as porcentaje,
#resultado.unidades
from #resultado
where precio > 0

drop table #inventario
drop table #inventario_natural
drop table #grado_flor
drop table #variedad_flor
drop table #resultado
drop table #repetidos