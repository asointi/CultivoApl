SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[siembra_consultar_produccion_bloque_variedad]

@fecha_inicial datetime,
@fecha_final datetime

as

create table #fecha
(
	fecha datetime
)

/*seleccionar las entradas (produccion) por bloque y variedad en las fechas ingresadas*/
select bloque.idc_bloque,
bloque.id_bloque,
bloque.area,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) as fecha,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos into #temp
from bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor
where bloque.id_bloque = pieza_postcosecha.id_bloque
and bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = @fecha_inicial
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = @fecha_final
group by bloque.idc_bloque,
bloque.id_bloque,
bloque.area,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101))
having bloque.area is not null
and sum(pieza_postcosecha.unidades_por_pieza) > 0

while (@fecha_inicial < = @fecha_final)
begin
	insert into #fecha (fecha)
	values (@fecha_inicial)

	set @fecha_inicial = @fecha_inicial + 1
end

alter table #temp
add camas_totales int,
camas_sembradas int

/*camas totales creadas de cada bloque inferior a la fecha final ingresada*/
select bloque.idc_bloque,
bloque.id_bloque,
#fecha.fecha,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales into #camas_totales
from bloque,
cama_bloque,
construir_cama_bloque,
#fecha
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < #fecha.fecha
)
and construir_cama_bloque.fecha < = #fecha.fecha
group by bloque.idc_bloque,
bloque.id_bloque,
#fecha.fecha

/*camas sembradas x variedad de cada bloque, inferior a la fecha final ingresada*/
select b.idc_bloque,
b.id_bloque,
b.area,
#fecha.fecha,
tf.idc_tipo_flor,
ltrim(rtrim(tf.nombre_tipo_flor)) as nombre_tipo_flor,
vf.idc_variedad_flor,
tf.id_tipo_flor,
vf.id_variedad_flor,
ltrim(rtrim(vf.nombre_variedad_flor)) as nombre_variedad_flor,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas into #camas_sembradas
from cama,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
tipo_flor as tf,
variedad_flor as vf,
bloque as b,
#fecha
where b.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and vf.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
and tf.id_tipo_flor = vf.id_tipo_flor
and cama.id_cama = cama_bloque.id_cama
and sembrar_cama_bloque.fecha < = #fecha.fecha
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < #fecha.fecha
)
group by b.idc_bloque,
b.id_bloque,
b.area,
#fecha.fecha,
tf.idc_tipo_flor,
ltrim(rtrim(tf.nombre_tipo_flor)),
vf.idc_variedad_flor,
tf.id_tipo_flor,
vf.id_variedad_flor,
ltrim(rtrim(vf.nombre_variedad_flor))

alter table #camas_sembradas
add camas_totales int

update #camas_sembradas
set camas_totales = #camas_totales.camas_totales
from #camas_totales
where #camas_sembradas.id_bloque = #camas_totales.id_bloque
and #camas_sembradas.fecha = #camas_totales.fecha

update #temp
set camas_totales = #camas_sembradas.camas_totales,
camas_sembradas = #camas_sembradas.camas_sembradas
from #camas_sembradas
where #temp.id_bloque = #camas_sembradas.id_bloque
and #temp.id_tipo_flor = #camas_sembradas.id_tipo_flor
and #temp.id_variedad_flor = #camas_sembradas.id_variedad_flor
and #temp.fecha = #camas_sembradas.fecha

/*ingresar camas sembradas en variedad x bloque que no aparecen con produccion*/
insert into #temp (idc_bloque, id_bloque, id_tipo_flor, id_variedad_flor, area, idc_tipo_flor, nombre_tipo_flor, idc_variedad_flor, nombre_variedad_flor, cantidad_tallos, camas_totales, camas_sembradas, fecha)
select idc_bloque, 0, 0, 0, area, idc_tipo_flor, nombre_tipo_flor, idc_variedad_flor, nombre_variedad_flor, 0, camas_totales, camas_sembradas, fecha
from #camas_sembradas
where not exists
(
	select * 
	from #temp
	where #temp.id_bloque = #camas_sembradas.id_bloque
	and #temp.id_tipo_flor = #camas_sembradas.id_tipo_flor
	and #temp.id_variedad_flor = #camas_sembradas.id_variedad_flor
	and #temp.fecha = #camas_sembradas.fecha
)

select convert(nvarchar, #temp.fecha, 103) as fecha,
#temp.idc_bloque,
#temp.area,
sum(#temp.camas_totales) as camas_totales,
#temp.idc_tipo_flor,
#temp.nombre_tipo_flor,
#temp.idc_variedad_flor,
#temp.nombre_variedad_flor,
convert(decimal(20,2),(sum(#temp.area)/sum(#temp.camas_totales)) * sum(#temp.camas_sembradas)) as area_sembrada,
sum(#temp.camas_sembradas) as camas_sembradas,
sum(#temp.cantidad_tallos) as cantidad_tallos
from #temp 
group by convert(nvarchar, #temp.fecha, 103),
#temp.idc_bloque,
#temp.area,
#temp.idc_tipo_flor,
#temp.nombre_tipo_flor,
#temp.idc_variedad_flor,
#temp.nombre_variedad_flor
having sum(#temp.cantidad_tallos) > 0
order by #temp.idc_bloque,
#temp.idc_variedad_flor

drop table #camas_sembradas
drop table #camas_totales
drop table #temp
drop table #fecha