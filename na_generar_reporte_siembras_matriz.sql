set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-01-06
-- Description:	
-- =============================================

alter PROCEDURE [dbo].[na_generar_reporte_siembras_matriz]

as

declare @fecha_inicial1 datetime,
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
@meses_sin_produccion int

select @meses_sin_produccion = meses_sin_produccion from configuracion_bd
set @fecha_inicial1 = '1990/01/01'
set @fecha_final1 = '2000/10/31'
set @fecha_inicial2 = '2000/11/01'
set @fecha_final2 = '2001/10/31'
set @fecha_inicial3 = '2001/11/01'
set @fecha_final3 = '2002/10/31'
set @fecha_inicial4 = '2002/11/01'
set @fecha_final4 = '2003/10/31'
set @fecha_inicial5 = '2003/11/01'
set @fecha_final5 = '2004/10/31'
set @fecha_inicial6 = '2004/11/01'
set @fecha_final6 = '2005/10/31'
set @fecha_inicial7 = '2005/11/01'
set @fecha_final7 = '2006/10/31'
set @fecha_inicial8 = '2006/11/01'
set @fecha_final8 = '2007/10/31'
set @fecha_inicial9 = '2007/11/01'
set @fecha_final9 = '2008/10/31'
set @fecha_inicial10 = '2008/11/01'
set @fecha_final10 = '2009/10/31'


create table #sembradas
(
	id_bloque int,
	idc_bloque nvarchar(255),
	area decimal(20,4),
	id_variedad_flor int,
	idc_variedad_flor nvarchar(255),
	nombre_variedad_flor nvarchar(255),
	fecha_final datetime,
	camas_sembradas int
)
create table #totales
(
	id_bloque int,
	fecha_final datetime,
	camas_construidas int
)

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final1 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final1
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial1
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final1 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial1
)
and construir_cama_bloque.fecha <= @fecha_final1
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final2 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final2
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial2
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final2 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial2
)
and construir_cama_bloque.fecha <= @fecha_final2
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final3 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final3
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial3
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final3 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial3
)
and construir_cama_bloque.fecha <= @fecha_final3
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final4 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final4
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial4
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final4 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial4
)
and construir_cama_bloque.fecha <= @fecha_final4
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final5 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final5
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial5
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final5 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial5
)
and construir_cama_bloque.fecha <= @fecha_final5
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final6 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final6
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial6
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final6 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial6
)
and construir_cama_bloque.fecha <= @fecha_final6
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final7 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final7
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial7
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final7 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial7
)
and construir_cama_bloque.fecha <= @fecha_final7
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final8 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final8
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial8
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final8 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial8
)
and construir_cama_bloque.fecha <= @fecha_final8
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final9 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final9
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial9
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final9 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial9
)
and construir_cama_bloque.fecha <= @fecha_final9
group by bloque.id_bloque
order by bloque.id_bloque

------------------------------

insert into #sembradas (id_bloque, idc_bloque, area, id_variedad_flor, idc_variedad_flor,	nombre_variedad_flor, fecha_final, camas_sembradas)
select bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
@fecha_final10 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_sembradas --into #camas_sembradas_definitivas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and dateadd(mm, @meses_sin_produccion, sembrar_cama_bloque.fecha) <= @fecha_final10
and not exists
(
	select * 
	from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and erradicar_cama_bloque.fecha < @fecha_inicial10
)
group by bloque.id_bloque,
bloque.idc_bloque,
bloque.area,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))
order by bloque.id_bloque

insert into #totales (id_bloque, fecha_final, camas_construidas)
select bloque.id_bloque,
@fecha_final10 as fecha_final,
count(distinct construir_cama_bloque.id_construir_cama_bloque) as camas_totales
from bloque,
cama_bloque,
construir_cama_bloque
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and not exists
(
	select * 
	from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque
	and destruir_cama_bloque.fecha < @fecha_inicial10
)
and construir_cama_bloque.fecha <= @fecha_final10
group by bloque.id_bloque
order by bloque.id_bloque

alter table #sembradas
add camas_totales int,
area_por_cama decimal(20,4)

update #sembradas
set camas_totales = #totales.camas_construidas
from #totales
where #totales.fecha_final = #sembradas.fecha_final
and #totales.id_bloque = #sembradas.id_bloque

/*calcular el área que cada cama utiliza del bloque en total*/
update #sembradas
set area_por_cama = (area/camas_totales) * camas_sembradas

select * from #sembradas order by id_bloque, fecha_final,nombre_variedad_flor

drop table #totales
drop table #sembradas