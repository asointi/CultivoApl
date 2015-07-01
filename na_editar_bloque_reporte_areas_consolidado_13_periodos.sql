set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_bloque_reporte_areas_consolidado_13_periodos]

@fecha_inicial_siembra datetime,
@fecha_final_siembra datetime,
@id_variedad_flor nvarchar(255),
@fecha_inicial1 datetime,
@fecha_final1 datetime,
@fecha_inicial2 datetime,
@fecha_final2 datetime,
@fecha_inicial3 datetime,
@fecha_final3 datetime,
@fecha_inicial4 datetime,
@fecha_final4 datetime,
@fecha_inicial5 datetime,
@fecha_final5 datetime,
@fecha_inicial6 datetime,
@fecha_final6 datetime,
@fecha_inicial7 datetime,
@fecha_final7 datetime,
@fecha_inicial8 datetime,
@fecha_final8 datetime,
@fecha_inicial9 datetime,
@fecha_final9 datetime,
@fecha_inicial10 datetime,
@fecha_final10 datetime,
@fecha_inicial11 datetime,
@fecha_final11 datetime,
@fecha_inicial12 datetime,
@fecha_final12 datetime,
@fecha_inicial13 datetime,
@fecha_final13 datetime,
@idc_farm nvarchar(2) = null

as

set @idc_farm = 'ER'

declare @conteo int,
@promedio_maximo decimal(20,4),
@meses_sin_produccion int

SET DATEFIRST 1;

select @meses_sin_produccion = meses_sin_produccion from configuracion_bd

/*verificar la ultima cama sembrada de cada bloque en el rango de fechas dado y para la variedad seleccionada*/
/*sin incluir una cantidad de meses desde la fecha actual hacia atras con el fin de que los bloques que han sido*/
/*sembrados últimamente no sean tenidos en cuenta ya que en las primeras fases de la siembra no producen*/
select bloque.id_bloque,
max(sembrar_cama_bloque.fecha) as fecha_siembra,
count(cama.id_cama) as cantidad_camas into #siembra
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor,
tipo_flor,
cama
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and variedad_flor.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and cama.id_cama = cama_bloque.id_cama
and sembrar_cama_bloque.fecha between
@fecha_inicial_siembra and @fecha_final_siembra
and sembrar_cama_bloque.fecha < = dateadd(mm, -@meses_sin_produccion, getdate())
group by bloque.id_bloque

/*produccion calculada para el periodo solicitado por el usuario - se incluyen únicamente bloques*/
/*que tengan fecha de siembra dentro del rango solicitado por el usuario y de la misma manera no se*/
/*incluye la producción del día actual*/
create table #temp
(
id_bloque int,
idc_bloque nvarchar(255),
area decimal(20,4),
nombre_tipo_bloque nvarchar(255),
id_tipo_flor int,
idc_tipo_flor nvarchar(255),
nombre_tipo_flor nvarchar(255),
id_variedad_flor int,
idc_variedad_flor nvarchar(255),
nombre_variedad_flor nvarchar(255),
periodo int,
fecha_maxima datetime,
cantidad_tallos int,
ano int,
rango_fechas nvarchar(255),
fecha_inicial datetime,
fecha_final datetime
)

/*produccion calculada para el periodo solicitado por el usuario - se incluyen únicamente bloques*/
/*que tengan fecha de siembra dentro del rango solicitado por el usuario y de la misma manera no se*/
/*incluye la producción del día actual*/
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
1 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial1) as ano,
convert(nvarchar, @fecha_inicial1, 101) + ' - ' + convert(nvarchar, @fecha_final1, 101),
@fecha_inicial1,
@fecha_final1
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial1 and @fecha_final1
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
	select #siembra.id_bloque 
	from #siembra 
	where bloque.id_bloque = #siembra.id_bloque 
	group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

---------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
2 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial2) as ano,
convert(nvarchar, @fecha_inicial2, 101) + ' - ' + convert(nvarchar, @fecha_final2, 101),
@fecha_inicial2,
@fecha_final2
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial2 and @fecha_final2
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------

insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
3 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial3) as ano,
convert(nvarchar, @fecha_inicial3, 101) + ' - ' + convert(nvarchar, @fecha_final3, 101),
@fecha_inicial3,
@fecha_final3
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial3 and @fecha_final3
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null
----------------------------------------------------

insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
4 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial4) as ano,
convert(nvarchar, @fecha_inicial4, 101) + ' - ' + convert(nvarchar, @fecha_final4, 101),
@fecha_inicial4,
@fecha_final4
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial4 and @fecha_final4
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
	select #siembra.id_bloque 
	from #siembra 
	where bloque.id_bloque = #siembra.id_bloque 
	group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null
----------------------------------------------------

insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
5 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial5) as ano,
convert(nvarchar, @fecha_inicial5, 101) + ' - ' + convert(nvarchar, @fecha_final5, 101),
@fecha_inicial5,
@fecha_final5
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial5 and @fecha_final5
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null
----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
6 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial6) as ano,
convert(nvarchar, @fecha_inicial6, 101) + ' - ' + convert(nvarchar, @fecha_final6, 101),
@fecha_inicial6,
@fecha_final6
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial6 and @fecha_final6
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
7 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial7) as ano,
convert(nvarchar, @fecha_inicial7, 101) + ' - ' + convert(nvarchar, @fecha_final7, 101),
@fecha_inicial7,
@fecha_final7
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial7 and @fecha_final7
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
8 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial8) as ano,
convert(nvarchar, @fecha_inicial8, 101) + ' - ' + convert(nvarchar, @fecha_final8, 101),
@fecha_inicial8,
@fecha_final8
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial8 and @fecha_final8
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
9 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial9) as ano,
convert(nvarchar, @fecha_inicial9, 101) + ' - ' + convert(nvarchar, @fecha_final9, 101),
@fecha_inicial9,
@fecha_final9
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial9 and @fecha_final9
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
10 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial10) as ano,
convert(nvarchar, @fecha_inicial10, 101) + ' - ' + convert(nvarchar, @fecha_final10, 101),
@fecha_inicial10,
@fecha_final10
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial10 and @fecha_final10
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
11 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial11) as ano,
convert(nvarchar, @fecha_inicial11, 101) + ' - ' + convert(nvarchar, @fecha_final11, 101),
@fecha_inicial11,
@fecha_final11
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial11 and @fecha_final11
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
12 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial12) as ano,
convert(nvarchar, @fecha_inicial12, 101) + ' - ' + convert(nvarchar, @fecha_final12, 101),
@fecha_inicial12,
@fecha_final12
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial12 and @fecha_final12
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

----------------------------------------------------
insert into #temp
(
id_bloque,
idc_bloque,
area,
nombre_tipo_bloque,
id_tipo_flor,
idc_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor,
nombre_variedad_flor,
periodo,
fecha_maxima,
cantidad_tallos,
ano,
rango_fechas,
fecha_inicial,
fecha_final
)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
13 as periodo,
max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
datepart(yy, @fecha_inicial13) as ano,
convert(nvarchar, @fecha_inicial13, 101) + ' - ' + convert(nvarchar, @fecha_final13, 101),
@fecha_inicial13,
@fecha_final13
from bloque left join tipo_bloque on bloque.id_tipo_bloque = tipo_bloque.id_tipo_bloque,
pieza_postcosecha,
tipo_flor,
variedad_flor,
finca_propia,
finca_bloque
where bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
@fecha_inicial13 and @fecha_final13
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
and exists 
(
select #siembra.id_bloque 
from #siembra 
where bloque.id_bloque = #siembra.id_bloque 
group by #siembra.id_bloque
)
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_propia.idc_finca_propia > =
case
	when @idc_farm is null then '  '
	else @idc_farm
end
and finca_propia.idc_finca_propia < =
case
	when @idc_farm is null then 'ZZ'
	else @idc_farm
end
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
tipo_bloque.nombre_tipo_bloque,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
having bloque.area is not null

alter table #temp
add fecha_siembra datetime, 
promedio_maximo decimal(20,4),
promedio decimal(20,4),
area_por_cama decimal(20,4),
area_por_cama_unitaria decimal(20,4),
camas_sembradas int,
camas_totales int,
promedio_aux decimal(20,4)

/*se coloca la fecha máxima de siembra de cada bloque*/
update #temp
set fecha_siembra = #siembra.fecha_siembra
from #siembra
where #temp.id_bloque = #siembra.id_bloque

select id_bloque, 
idc_bloque into #bloques 
from #temp 
group by id_bloque,
idc_bloque 
order by id_bloque

select #bloques.id_bloque,
#temp.periodo, 
#temp.rango_fechas,
#bloques.idc_bloque,
max(#temp.id_tipo_flor) as id_tipo_flor,
max(#temp.idc_tipo_flor) as idc_tipo_flor,
max(#temp.nombre_tipo_flor) as nombre_tipo_flor,
max(#temp.id_variedad_flor) as id_variedad_flor,
max(#temp.idc_variedad_flor) as idc_variedad_flor,
max(#temp.nombre_variedad_flor) as nombre_variedad_flor,
max(#temp.fecha_maxima) as fecha_maxima,
max(#temp.fecha_siembra) as fecha_siembra,
ano into #faltante
from #temp, 
#bloques
group by #bloques.id_bloque,
#temp.periodo, 
#temp.rango_fechas,
ano,
#bloques.idc_bloque

/*conocer la cantidad de camas que se han sembrado por cada bloque según la variedad, sin incluir*/
/*la cantidad de meses en las cuales los bloques no dan producción*/
select bloque.id_bloque,
#temp.fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor,
#temp
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_variedad_flor = #temp.id_variedad_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= #temp.fecha_final
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < #temp.fecha_inicial
)
and bloque.id_bloque = #temp.id_bloque
group by bloque.id_bloque,
#temp.fecha_final

/*conocer la cantidad de camas totales por bloque, sin incluir*/
/*la cantidad de meses en las cuales los bloques no dan producción*/
select bloque.id_bloque,
#temp.fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales into #camas_totales_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
#temp
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < #temp.fecha_inicial
)
and construir_cama_bloque.fecha <= #temp.fecha_final
and bloque.id_bloque = #temp.id_bloque
group by bloque.id_bloque,
#temp.fecha_final

update #temp
set camas_totales = #camas_totales_definitivas.camas_totales
from #camas_totales_definitivas
where #camas_totales_definitivas.id_bloque = #temp.id_bloque
and #camas_totales_definitivas.fecha_final = #temp.fecha_final

update #temp
set camas_sembradas = #camas_sembradas_definitivas.camas_sembradas
from #camas_sembradas_definitivas
where #camas_sembradas_definitivas.id_bloque = #temp.id_bloque
and #camas_sembradas_definitivas.fecha_final = #temp.fecha_final

/*calcular el área que cada cama utiliza del bloque en total*/
update #temp
set area_por_cama = 
case
	when camas_totales = 0 then 0
	else (area/camas_totales) * camas_sembradas
end,
area_por_cama_unitaria = 
case
	when camas_totales = 0 then 0
	else (area/camas_totales)
end

/*calcular el promedio de cada bloque en los diferentes periodos de tiempo*/
update #temp
set promedio = 
case
	when area_por_cama = 0 then 0 
	else cantidad_tallos/area_por_cama
end

/*colocar el promedio máximo para que todas las gráficas del reporte vayan hasta el mismo valor en el eje X*/
select @promedio_maximo = max(promedio) from #temp

update #temp
set promedio_maximo = @promedio_maximo

/*incluir en la consulta los bloques que no tienen información para algunos periodos específicos*/
/*lo anterior se realiza con el fin de que en el reporte no aparezcan los gráficos con series diferentes*/
/*y a su vez con colores diferentes*/
insert into #temp (id_bloque, idc_bloque, area, id_tipo_flor, idc_tipo_flor, nombre_tipo_flor, id_variedad_flor, idc_variedad_flor, nombre_variedad_flor, periodo, fecha_maxima, cantidad_tallos, ano, rango_fechas, fecha_siembra, promedio_maximo, promedio, area_por_cama)
select id_bloque, 
idc_bloque,
0, 
id_tipo_flor, 
idc_tipo_flor, 
nombre_tipo_flor, 
id_variedad_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
periodo, 
fecha_maxima, 
0, 
ano, 
rango_fechas, 
fecha_siembra, 
0, 
0, 
0 
from #faltante
where not exists 
(
	select * from #temp
	where #temp.periodo = #faltante.periodo
	and #temp.rango_fechas = #faltante.rango_fechas
	and #temp.id_bloque = #faltante.id_bloque
)

select id_bloque,
ano,
periodo,
max(fecha_final) as fecha_final,
datediff(dd, max(fecha_inicial), max(fecha_final)) as dias_totales,
datediff(dd, max(fecha_inicial), getdate()) as dias_parciales
into #completar_periodo
from #temp
where periodo = 1
group by id_bloque,
ano,
periodo

update #temp
set promedio_aux = 
case
	when #completar_periodo.dias_parciales = 0 then 0
	when #temp.area_por_cama = 0 then 0
	else ((#completar_periodo.dias_totales * #temp.cantidad_tallos) / #completar_periodo.dias_parciales) / #temp.area_por_cama
end
from #completar_periodo	
where #temp.ano = #completar_periodo.ano
and #temp.periodo = #completar_periodo.periodo
and #temp.id_bloque = #completar_periodo.id_bloque
and #completar_periodo.dias_parciales <> 0
and #completar_periodo.fecha_final > convert(datetime,convert(nvarchar, getdate(),101))

update #temp
set promedio_aux = 
case
	when #temp.area_por_cama = 0 then 0
	else (#completar_periodo.dias_totales * #temp.cantidad_tallos) / #temp.area_por_cama
end
from #completar_periodo	
where #temp.ano = #completar_periodo.ano
and #temp.periodo = #completar_periodo.periodo
and #temp.id_bloque = #completar_periodo.id_bloque
and #completar_periodo.dias_parciales = 0
and #completar_periodo.fecha_final > convert(datetime,convert(nvarchar, getdate(),101))

update #temp
set promedio_aux = 0
where promedio_aux is null

select sum(cantidad_tallos) as cantidad_tallos,
sum(area_por_cama) as area,
sum(cantidad_tallos) / 
case
	when sum(area_por_cama) > 0 then sum(area_por_cama)
	else null
end as tallos_por_metro,
periodo,
(
	select round(((max(datediff(dd, fecha_inicial, fecha_final)) * 120) / 365),-1)
	from #temp
) as eje,
(
	select convert(int,round(((max(datediff(dd, fecha_inicial, fecha_final)) * 120) / 365),-1) * convert(decimal(20,2), 1.40))
	from #temp
) as limite_eje
from #temp
group by periodo
order by periodo

drop table #temp
drop table #siembra
drop table #faltante
drop table #bloques
drop table #camas_sembradas_definitivas
drop table #camas_totales_definitivas
drop table #completar_periodo