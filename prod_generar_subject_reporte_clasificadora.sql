set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER PROCEDURE [dbo].[prod_generar_subject_reporte_clasificadora]

as

declare @tolerancia_largo decimal(20,4),
@tolerancia_ancho_tallo decimal(20,4),
@tolerancia_alto decimal(20,4),
@cantidad_items int,
@fecha datetime,
@conteo int

set @fecha = convert(datetime,convert(nvarchar, getdate(), 101))

/*consultar las condiciones de tolerancia globales*/
select @tolerancia_largo = tolerancia_largo,
@tolerancia_ancho_tallo = tolerancia_ancho_tallo,
@tolerancia_alto = tolerancia_alto
from globales_sql

/*consultar los diferentes tallos clasificados de la fecha seleccionada*/
select regla.id_regla,
regla.nombre_regla,
tipo_flor.id_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
condicion.id_condicion,
condicion.nombre_condicion,
grado_flor.id_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '(' + grado_flor.idc_grado_flor + ')' as nombre_grado_flor,
tallo_clasificado.id_tallo_clasificado,
tallo_clasificado.largo,
tallo_clasificado.ancho,
tallo_clasificado.alto_cabeza,
tallo_clasificado.apertura,
punto_corte.id_punto_corte,
punto_corte.nombre_punto_corte,
apertura.id_apertura,
apertura.nombre_apertura,
apertura.apertura_minima,
apertura.apertura_maxima into #temp
from tipo_flor,
variedad_flor,
grado_flor,
condicion,
detalle_condicion,
tiempo_ejecucion_detalle_condicion,
tallo_clasificado,
regla,
punto_corte,
tiempo_ejecucion_regla,
apertura
where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.id_grado_flor = condicion.id_grado_flor
and condicion.id_condicion = detalle_condicion.id_condicion
and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
and regla.id_regla = condicion.id_regla
and regla.id_regla = tiempo_ejecucion_regla.id_regla
and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla = tiempo_ejecucion_regla.id_tiempo_ejecucion_regla
and variedad_flor.id_variedad_flor = regla.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and convert(datetime,convert(nvarchar,tallo_clasificado.fecha_transaccion,101)) = @fecha
and regla.id_punto_corte = punto_corte.id_punto_corte
and regla.id_apertura = apertura.id_apertura

/*Eliminar tallos de la regla Freedom EEUU que sobrepasan los limites estipulados*/
select IDENTITY(int, 1,1) AS id,
id_regla,
apertura_minima,
apertura_maxima into #apertura
from #temp
group by id_regla,
apertura_minima,
apertura_maxima

set @conteo = 1
select @cantidad_items = count(*) from #apertura

while (@conteo < = @cantidad_items)
begin
	delete from #temp
	where id_regla = (select id_regla from #apertura where id = @conteo)
	and (
		apertura < (select apertura_minima from #apertura where id = @conteo)
		or apertura > (select apertura_maxima from #apertura where id = @conteo)
	)

	set @conteo = @conteo + 1
end

alter table #temp
add id_grado_flor_alterado int, 
nombre_grado_flor_alterado nvarchar(255)

/*flores que debieron ser clasificadas en un grado menor*/
update #temp
set id_grado_flor_alterado = 
(
	select max(g1.id_grado_flor)
	from grado_flor as g1
	where g1.id_tipo_flor = tipo_flor.id_tipo_flor
	and g1.id_grado_flor < grado_flor.id_grado_flor
	and exists 
	(
		select * 
		from condicion_clasificacion 
		where condicion_clasificacion.id_grado_flor = g1.id_grado_flor
	)
),
nombre_grado_flor_alterado =
(
	select max(ltrim(rtrim(nombre_grado_flor))) + space(1) + '(' + max(idc_grado_flor) + ')'
	from grado_flor as g1
	where g1.id_tipo_flor = tipo_flor.id_tipo_flor
	and g1.id_grado_flor < grado_flor.id_grado_flor
	and exists 
	(
		select * 
		from condicion_clasificacion 
		where condicion_clasificacion.id_grado_flor = g1.id_grado_flor
	)
)
from condicion_clasificacion,
grupo_clasificacion,
grupo_variedad_clasificacion,
variedad_flor,
grado_flor,
tipo_flor
where #temp.id_grado_flor = condicion_clasificacion.id_grado_flor
and (#temp.largo + @tolerancia_largo < condicion_clasificacion.longitud_minima 
or #temp.ancho + @tolerancia_ancho_tallo < condicion_clasificacion.ancho_tallo_minimo
or #temp.alto_cabeza + @tolerancia_alto < condicion_clasificacion.alto_cabeza_minimo)
and condicion_clasificacion.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = grupo_variedad_clasificacion.id_variedad_flor
and grupo_clasificacion.id_grupo_clasificacion = grupo_variedad_clasificacion.id_grupo_clasificacion
and grupo_clasificacion.id_grupo_clasificacion = condicion_clasificacion.id_grupo_clasificacion
and #temp.id_variedad_flor = variedad_flor.id_variedad_flor
and #temp.id_punto_corte = grupo_clasificacion.id_punto_corte

/*flores que pudieron ser clasificadas en grado mayor*/
select #temp.id_tallo_clasificado,
grado_flor.id_grado_flor as id_grado_flor_alterado,
ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '(' + grado_flor.idc_grado_flor + ')' as nombre_grado_flor_alterado into #modificaciones
from condicion_clasificacion,
grado_flor,
tipo_flor,
variedad_flor,
grupo_variedad_clasificacion,
grupo_clasificacion,
punto_corte,
#temp
where #temp.id_grado_flor < condicion_clasificacion.id_grado_flor
and #temp.largo > condicion_clasificacion.longitud_minima + @tolerancia_largo
and #temp.ancho > condicion_clasificacion.ancho_tallo_minimo + @tolerancia_ancho_tallo
and #temp.alto_cabeza > condicion_clasificacion.alto_cabeza_minimo + @tolerancia_alto
and condicion_clasificacion.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = grupo_variedad_clasificacion.id_variedad_flor
and grupo_clasificacion.id_grupo_clasificacion = grupo_variedad_clasificacion.id_grupo_clasificacion
and grupo_clasificacion.id_grupo_clasificacion = condicion_clasificacion.id_grupo_clasificacion
and variedad_flor.id_variedad_flor = #temp.id_variedad_flor
and #temp.id_punto_corte = punto_corte.id_punto_corte
and punto_corte.id_punto_corte = grupo_clasificacion.id_punto_corte

update #temp
set id_grado_flor_alterado = #modificaciones.id_grado_flor_alterado,
nombre_grado_flor_alterado = #modificaciones.nombre_grado_flor_alterado
from #modificaciones
where #modificaciones.id_tallo_clasificado = #temp.id_tallo_clasificado

create table #temp2 
(	
	id_regla int,
	nombre_regla nvarchar(255),
	id_tipo_flor int,
	nombre_tipo_flor nvarchar(255),
	id_variedad_flor int,
	nombre_variedad_flor nvarchar(255),
	id_grado_flor int,
	nombre_grado_flor nvarchar(255),
	porcentaje decimal(20,4),
	cantidad_tallos int,
	cantidad_tallos_total int,
	grado_alterado nvarchar(255),
	tipo nvarchar(255),
	orden int,
	condiciones nvarchar(255),
	id_punto_corte int,
	nombre_punto_corte nvarchar(255)
)

/*promedios de clasificacion por regla y grado generales*/
insert into #temp2 
(
	id_regla,
	nombre_regla,
	id_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	nombre_grado_flor,
	porcentaje,
	cantidad_tallos,
	cantidad_tallos_total,
	grado_alterado,
	tipo,
	orden,
	id_punto_corte,
	nombre_punto_corte
)
select id_regla,
nombre_regla,
id_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
nombre_grado_flor,
convert(decimal(20,4),
convert(decimal(20,4),count(id_tallo_clasificado)) /
convert(decimal(20,4),	(
							select count(*) from #temp as t1
							where #temp.id_regla = t1.id_regla)) * 100
						) as porcentaje,
count(#temp.id_tallo_clasificado) as cantidad_tallos,
(
	select count(*) from #temp as t1
	where #temp.id_regla = t1.id_regla
) as cantidad_tallos_total,
null as grado_alterado,
'general' as tipo,
1 as orden,
id_punto_corte,
nombre_punto_corte
from #temp
group by id_regla,
nombre_regla,
id_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
nombre_grado_flor,
id_punto_corte,
nombre_punto_corte

/*promedios de flores que debieron ser clasificadas en grado menor*/
insert into #temp2 
(
	id_regla,
	nombre_regla,
	id_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	nombre_grado_flor,
	porcentaje,
	cantidad_tallos,
	cantidad_tallos_total,
	grado_alterado,
	tipo,
	orden
)
select id_regla,
nombre_regla,
id_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
nombre_grado_flor,
((convert(decimal(20,4),(
							select count(id_grado_flor_alterado) from #temp as t2
							where #temp.id_regla = t2.id_regla
							and #temp.id_grado_flor = t2.id_grado_flor
							and #temp.id_grado_flor > t2.id_grado_flor_alterado
						))/
convert(decimal(20,4),	(
						select count(*) from #temp as t1
						where #temp.id_regla = t1.id_regla
						))) * convert(decimal(20,4),100)) as porcentaje,
(
	select count(id_grado_flor_alterado) 
	from #temp as t2
	where #temp.id_regla = t2.id_regla
	and #temp.id_grado_flor = t2.id_grado_flor
	and #temp.id_grado_flor > t2.id_grado_flor_alterado
) as cantidad_tallos,
(
	select count(*) from #temp as t1
	where #temp.id_regla = t1.id_regla
) as cantidad_tallos_total,
(
	select nombre_grado_flor_alterado from #temp as t2
	where #temp.id_regla = t2.id_regla
	and #temp.id_grado_flor = t2.id_grado_flor
	and #temp.id_grado_flor > t2.id_grado_flor_alterado
	group by nombre_grado_flor_alterado
) as grado_alterado,
'bajados' as tipo,
2 as orden
from #temp
group by id_regla,
nombre_regla,
id_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
nombre_grado_flor
having 
(
	select nombre_grado_flor_alterado from #temp as t2
	where #temp.id_regla = t2.id_regla
	and #temp.id_grado_flor = t2.id_grado_flor
	and #temp.id_grado_flor > t2.id_grado_flor_alterado
	group by nombre_grado_flor_alterado
) is not null

/*promedios de flores que pudieron ser clasificadas en grado superior*/
insert into #temp2 
(
	id_regla,
	nombre_regla,
	id_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	nombre_grado_flor,
	porcentaje,
	cantidad_tallos,
	cantidad_tallos_total,
	grado_alterado,
	tipo,
	orden
)
select id_regla,
nombre_regla,
id_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
nombre_grado_flor,
convert(decimal(20,4),((convert(decimal(20,4), count(*))/convert(decimal(20,4), 
(
	select count(*) from #temp as t1
	where #temp.id_regla = t1.id_regla
))) * 100)) as porcentaje,
count(*) as cantidad_tallos,
(
	select count(*) from #temp as t1
	where #temp.id_regla = t1.id_regla
) as cantidad_tallos_total,
(
	select top 1 nombre_grado_flor_alterado
	from #temp as t2
	where #temp.id_regla = t2.id_regla
	and #temp.id_grado_flor = t2.id_grado_flor
	and #temp.id_grado_flor < t2.id_grado_flor_alterado
	and #temp.id_grado_flor_alterado = t2.id_grado_flor_alterado
) as grado_alterado,
'subidos' as tipo,
3 as orden
from #temp
where #temp.id_grado_flor < #temp.id_grado_flor_alterado
group by id_regla,
nombre_regla,
id_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
nombre_grado_flor,
id_grado_flor_alterado

update #temp2
set condiciones = 'Largo:' + space(1) + convert(nvarchar,convert(decimal(20,1),condicion_clasificacion.longitud_minima)) + space(1) + 
'- Ancho:' + space(1) + convert(nvarchar,convert(decimal(20,1),condicion_clasificacion.ancho_tallo_minimo)) +space(1) +
'- Alto:' + space(1) + convert(nvarchar,convert(decimal(20,1),condicion_clasificacion.alto_cabeza_minimo))
from variedad_flor,
grupo_variedad_clasificacion,
grupo_clasificacion,
condicion_clasificacion,
grado_flor,
#temp2
where variedad_flor.id_variedad_flor = grupo_variedad_clasificacion.id_variedad_flor
and grado_flor.id_grado_flor = condicion_clasificacion.id_grado_flor
and grupo_clasificacion.id_grupo_clasificacion = grupo_variedad_clasificacion.id_grupo_clasificacion
and grupo_clasificacion.id_grupo_clasificacion = condicion_clasificacion.id_grupo_clasificacion
and variedad_flor.id_variedad_flor = #temp2.id_variedad_flor
and grado_flor.id_grado_flor = #temp2.id_grado_flor
and #temp2.id_punto_corte = grupo_clasificacion.id_punto_corte
and #temp2.grado_alterado is null

select id_regla into #temp3
from #temp2
group by condiciones, id_regla, grado_alterado

update #temp2
set condiciones = 'Sin parámetros asignados'
where grado_alterado is null
and condiciones is null
and id_regla in 
(select id_regla from #temp3 group by id_regla having count(*) < = 1)

update #temp2
set condiciones = 'Largo:' + space(1) + convert(nvarchar,convert(decimal(20,1),'0.0')) + space(1) + 
'- Ancho:' + space(1) + convert(nvarchar,convert(decimal(20,1),'0.0')) +space(1) +
'- Alto:' + space(1) + convert(nvarchar,convert(decimal(20,1),'0.0'))
where grado_alterado is null
and condiciones is null

delete from #temp2
where grado_alterado = '60BAJADOS (6J)'

delete from #temp2
where grado_alterado = '50BAJADOS (5J)'

set @conteo = null

select @conteo = count(*)
from #temp

if(@conteo > 0)
begin
	declare @cantidad_tallos int,
	@porcentaje decimal(20,1),
	@nombre_regla nvarchar(255)

	select top 1 @cantidad_tallos = isnull(cantidad_tallos, 0),
	@porcentaje = porcentaje,
	@nombre_regla = nombre_regla
	from #temp2
	where condiciones is null
	order by porcentaje desc

	if(@cantidad_tallos < 25)
	begin
		select top 1 @cantidad_tallos = isnull(cantidad_tallos, 0),
		@porcentaje = porcentaje,
		@nombre_regla = nombre_regla
		from #temp2
		where condiciones is null
		order by cantidad_tallos desc
	end

	if(@cantidad_tallos is null)
		set @cantidad_tallos = 0

	update configuracion_bd
	set subject_clasificadora = 
	'[TO]
	carlos@natuflora.net
	ricardo@natuflora.net
	dpineros@natuflora.net
	sisandres@natuflora.net
	[CC]
	[BCC]
	copiaoculta@natuflora.net
	[SUBJECT]' + '
	' +
	CASE
		when @cantidad_tallos < 25 then 'Reporte Clasificacion Consolidado - ROSEMATIC'
		else 'Max. tallos mal clasificados' + space(1) + '(' +  convert(nvarchar,@porcentaje) + '%' + ' - ' + 'Cant. tallos ' + convert(nvarchar,@cantidad_tallos) + ')' + ' - ' + @nombre_regla
	end	+ '
	' +
	'[MESSAGE]
	[ATTACH]
	\E-MAIL\ATTACH\Cultivo_Reporte_Clasificacion_Consolidado.pdf'
end
else
begin
	update configuracion_bd
	set subject_clasificadora = 
	'[TO]
	carlos@natuflora.net
	ricardo@natuflora.net
	dpineros@natuflora.net
	sisandres@natuflora.net
	[CC]
	[BCC]
	copiaoculta@natuflora.net
	[SUBJECT]' + '
	' +
	'No existe informacion de clasificación para el dia de hoy'
	+ '
	' +
	'[MESSAGE]
	[ATTACH]'
end

declare @query nvarchar(4000),
@file varchar(250),
@fileunique varchar(100),
@Dir varchar (200)

set @fileunique = replace(replace(convert(nvarchar, getdate(),120), ' ', '_'),':','-')
set @Dir = '\\Dbcobol\Datos\E-mail\PRE-SALIDA\'
Set @file = @Dir + 'Clasificadora_'+ @fileunique +'.txt'
select @query = 'bcp "select subject_clasificadora from bd_cultivo.dbo.configuracion_bd" queryout '+ @file +' -c -t; -T -S' + @@servername

exec master..xp_cmdshell @query

WAITFOR DELAY '00:00:10'

EXEC master..xp_cmdshell 'MOVE \\Dbcobol\Datos\E-mail\PRE-SALIDA\*.txt \\Dbcobol\Datos\E-mail\SALIDA\'

drop table #temp
drop table #temp2
drop table #temp3
drop table #modificaciones
drop table #apertura

