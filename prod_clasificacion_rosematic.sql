set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_clasificacion_rosematic]

as

select grado_flor.id_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)) + '/' + datename(day, tallo_clasificado.fecha_transaccion) as periodo,
datepart(dy, tallo_clasificado.fecha_transaccion) as dia_año,
datepart(year,tallo_clasificado.fecha_transaccion) as año,
count(tallo_clasificado.id_tallo_clasificado) as tallos_clasificados into #temp
from tallo_clasificado,
tiempo_ejecucion_detalle_condicion,
tiempo_ejecucion_regla,
regla,
detalle_condicion,
condicion,
variedad_flor,
grado_flor
where regla.id_regla = condicion.id_regla
and regla.id_regla = tiempo_ejecucion_regla.id_regla
and condicion.id_condicion = detalle_condicion.id_condicion
and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
and regla.id_variedad_flor = variedad_flor.id_variedad_flor
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) > = convert(datetime,convert(nvarchar, '2011/03/17',101))
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) < = convert(datetime,convert(nvarchar, '2011/04/21',101))
and variedad_flor.id_variedad_flor = 851
and regla.id_regla in (12, 21, 30)
and condicion.id_grado_flor = grado_flor.id_grado_flor
and tallo_clasificado.apertura > = 60
and tallo_clasificado.apertura < = 129.3
group by grado_flor.id_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)),
datename(day, tallo_clasificado.fecha_transaccion),
datepart(dy, tallo_clasificado.fecha_transaccion),
datepart(year,tallo_clasificado.fecha_transaccion)
union all
select grado_flor.id_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)) + '/' + datename(day, tallo_clasificado.fecha_transaccion) as periodo,
datepart(dy, tallo_clasificado.fecha_transaccion) as dia_año,
datepart(year,tallo_clasificado.fecha_transaccion) as año,
count(tallo_clasificado.id_tallo_clasificado) as tallos_clasificados
from tallo_clasificado,
tiempo_ejecucion_detalle_condicion,
tiempo_ejecucion_regla,
regla,
detalle_condicion,
condicion,
variedad_flor,
grado_flor
where regla.id_regla = condicion.id_regla
and regla.id_regla = tiempo_ejecucion_regla.id_regla
and condicion.id_condicion = detalle_condicion.id_condicion
and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
and regla.id_variedad_flor = variedad_flor.id_variedad_flor
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) > = convert(datetime,convert(nvarchar, '2011/04/22',101))
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) < = convert(datetime,convert(nvarchar, '2011/05/26',101))
and variedad_flor.id_variedad_flor = 851
and regla.id_regla in (12, 21, 30)
and condicion.id_grado_flor = grado_flor.id_grado_flor
and tallo_clasificado.apertura > = 50
and tallo_clasificado.apertura < = 129.3
group by grado_flor.id_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)),
datename(day, tallo_clasificado.fecha_transaccion),
datepart(dy, tallo_clasificado.fecha_transaccion),
datepart(year,tallo_clasificado.fecha_transaccion)

alter table #temp
add total_tallos_clasificados int

select convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)) + '/' + datename(day, tallo_clasificado.fecha_transaccion) as periodo,
datepart(dy, tallo_clasificado.fecha_transaccion) as dia_año,
count(tallo_clasificado.id_tallo_clasificado) as total_tallos_clasificados into #temp2
from tallo_clasificado,
tiempo_ejecucion_detalle_condicion,
tiempo_ejecucion_regla,
regla,
detalle_condicion,
condicion,
variedad_flor,
grado_flor
where regla.id_regla = condicion.id_regla
and regla.id_regla = tiempo_ejecucion_regla.id_regla
and condicion.id_condicion = detalle_condicion.id_condicion
and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
and regla.id_variedad_flor = variedad_flor.id_variedad_flor
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) > = convert(datetime,convert(nvarchar, '2011/03/17',101))
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) < = convert(datetime,convert(nvarchar, '2011/04/21',101))
and variedad_flor.id_variedad_flor = 851
and regla.id_regla in (12, 21, 30)
and condicion.id_grado_flor = grado_flor.id_grado_flor
and tallo_clasificado.apertura > = 60
and tallo_clasificado.apertura < = 129.3
group by convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)),
datename(day, tallo_clasificado.fecha_transaccion),
datepart(dy, tallo_clasificado.fecha_transaccion)
union all
select convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)) + '/' + datename(day, tallo_clasificado.fecha_transaccion) as periodo,
datepart(dy, tallo_clasificado.fecha_transaccion) as dia_año,
count(tallo_clasificado.id_tallo_clasificado) as total_tallos_clasificados
from tallo_clasificado,
tiempo_ejecucion_detalle_condicion,
tiempo_ejecucion_regla,
regla,
detalle_condicion,
condicion,
variedad_flor,
grado_flor
where regla.id_regla = condicion.id_regla
and regla.id_regla = tiempo_ejecucion_regla.id_regla
and condicion.id_condicion = detalle_condicion.id_condicion
and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
and regla.id_variedad_flor = variedad_flor.id_variedad_flor
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) > = convert(datetime,convert(nvarchar, '2011/04/22',101))
and convert(datetime,convert(nvarchar, tallo_clasificado.fecha_transaccion,101)) < = convert(datetime,convert(nvarchar, '2011/05/26',101))
and variedad_flor.id_variedad_flor = 851
and regla.id_regla in (12, 21, 30)
and condicion.id_grado_flor = grado_flor.id_grado_flor
and tallo_clasificado.apertura > = 50
and tallo_clasificado.apertura < = 129.3
group by convert(nvarchar,datepart(month, tallo_clasificado.fecha_transaccion)),
datename(day, tallo_clasificado.fecha_transaccion),
datepart(dy, tallo_clasificado.fecha_transaccion)

update #temp
set total_tallos_clasificados = #temp2.total_tallos_clasificados
from #temp2
where #temp.periodo = #temp2.periodo
and #temp.dia_año = #temp2.dia_año

select * from #temp

drop table #temp
drop table #temp2
