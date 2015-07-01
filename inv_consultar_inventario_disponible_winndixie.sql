SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[inv_consultar_inventario_disponible_winndixie]

AS

declare @id_estado_pieza_open_market int,
@id_estado_pieza_hold int,
@cantidad_dias_atras_inventario int

select @id_estado_pieza_open_market = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Open Market'
select @id_estado_pieza_hold = id_estado_pieza from estado_pieza where nombre_estado_pieza = 'Hold'
select @cantidad_dias_atras_inventario = 360--cantidad_dias_atras_inventario from configuracion_bd

/*extractar inventario superior a 1 pieza*/
select tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor))  + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
sum(pieza.unidades_por_pieza) as unidades into #inventario
from pieza, 
tipo_flor,
variedad_flor,
grado_flor,
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
group by tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
tipo_flor.idc_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
variedad_flor.idc_variedad_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor))

select id_variedad_flor,
id_grado_flor, 
max(id_valor_producto) as id_valor_producto into #valor_producto
from valor_producto 
where convert(datetime,convert(nvarchar,valor_producto.fecha_disponible_precio,101)) >= convert(datetime,convert(nvarchar,getdate()-@cantidad_dias_atras_inventario,101))
group by id_variedad_flor,
id_grado_flor

alter table #valor_producto
add precio decimal(20,4)

update #valor_producto
set precio = valor_producto.precio
from valor_producto
where valor_producto.id_valor_producto = #valor_producto.id_valor_producto

alter table #inventario
add precio decimal(20,4),
imagen image

update #inventario
set precio = #valor_producto.precio
from #valor_producto
where #inventario.id_variedad_flor = #valor_producto.id_variedad_flor
and #inventario.id_grado_flor = #valor_producto.id_grado_flor

update #inventario
set imagen = variedad_flor.imagen
from variedad_flor
where #inventario.id_variedad_flor = variedad_flor.id_variedad_flor

select #inventario.id_tipo_flor,
#inventario.id_variedad_flor,
#inventario.id_grado_flor,
#inventario.idc_tipo_flor,
#inventario.idc_variedad_flor,
#inventario.idc_grado_flor,
#inventario.nombre_tipo_flor,
#inventario.nombre_variedad_flor,
(
	select top 1 i.imagen
	from #inventario as i
	where #inventario.id_variedad_flor = i.id_variedad_flor
) as imagen,
#inventario.nombre_grado_flor,
#inventario.precio,
sum(#inventario.unidades) as unidades
from #inventario
where #inventario.precio is not null
group by #inventario.id_tipo_flor,
#inventario.id_variedad_flor,
#inventario.id_grado_flor,
#inventario.idc_tipo_flor,
#inventario.idc_variedad_flor,
#inventario.idc_grado_flor,
#inventario.nombre_tipo_flor,
#inventario.nombre_variedad_flor,
#inventario.nombre_grado_flor,
#inventario.precio
order by #inventario.nombre_tipo_flor,
#inventario.nombre_variedad_flor,
#inventario.nombre_grado_flor

drop table #inventario
drop table #valor_producto