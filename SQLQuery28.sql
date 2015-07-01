set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_generar_reporte_asignaciones]

@fecha_inicial datetime,
@fecha_final datetime

as

create table #temp
(
	id_bloque nvarchar(255), 
	idc_bloque nvarchar(255), 
	id_variedad_flor int, 
	nombre_variedad_flor nvarchar(255), 
	id_area int, 
	area decimal(20,4), 
	idc_persona nvarchar(255), 
	identificacion nvarchar(255), 
	nombre nvarchar(255), 
	apellido nvarchar(255), 
	cantidad_tallos int, 
	camas_creadas int, 
	camas_sembradas int
)


insert into #temp
(
	id_bloque, 
	idc_bloque, 
	id_variedad_flor, 
	nombre_variedad_flor, 
	id_area, 
	area, 
	idc_persona, 
	identificacion, 
	nombre, 
	apellido, 
	cantidad_tallos, 
	camas_creadas, 
	camas_sembradas
)
select distinct bloque.id_bloque,
bloque.idc_bloque,
variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
max(area.id_area) as id_area,
bloque.area,
persona.idc_persona,
persona.identificacion,
rtrim(ltrim(persona.nombre)) as nombre,
ltrim(rtrim(persona.apellido)) as apellido,
isnull((
	select sum(unidades_por_pieza)
	from pieza_postcosecha
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza_postcosecha.id_bloque = bloque.id_bloque
	and pieza_postcosecha.id_persona = persona.id_persona
	and convert(nvarchar,pieza_postcosecha.fecha_entrada, 101) between
	@fecha_inicial and @fecha_final
), 0) as cantidad_tallos,
(
	select count(construir_cama_bloque.id_construir_cama_bloque)
	from construir_cama_bloque
	where cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and construir_cama_bloque.fecha < = @fecha_final
	and not exists
	(
		select *
		from destruir_cama_bloque
		where construir_cama_bloque.id_construir_cama_bloque = destruir_cama_bloque.id_construir_cama_bloque
	)
) as camas_creadas,
(
	select count(sembrar_cama_bloque.id_sembrar_cama_bloque)
	from construir_cama_bloque,
	sembrar_cama_bloque
	where cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and sembrar_cama_bloque.fecha < = @fecha_final
	and not exists
	(
		select *
		from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
) as camas_sembradas
from bloque,
nave,
cama,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
detalle_area,
area,
area_asignada,
persona,
estado_area,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and nave.id_nave = cama_bloque.id_nave
and cama.id_cama = cama_bloque.id_cama
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
and persona.id_persona = area_asignada.id_persona
and area.id_area = area_asignada.id_area
and area.id_estado_area = estado_area.id_estado_area
and area.id_area = detalle_area.id_area
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and sembrar_cama_bloque.fecha < = @fecha_final
group by bloque.idc_bloque,
bloque.id_bloque,
variedad_flor.id_variedad_flor,
bloque.area,
persona.idc_persona,
persona.identificacion,
persona.id_persona,
cama_bloque.id_bloque,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
rtrim(ltrim(persona.nombre)),
ltrim(rtrim(persona.apellido))
order by bloque.idc_bloque,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
id_area,
rtrim(ltrim(persona.nombre)),
ltrim(rtrim(persona.apellido))

select id_bloque,
id_variedad_flor,
sum(cantidad_tallos) as cantidad_tallos into #calculados
from #temp
group by id_bloque,
id_variedad_flor
order by id_bloque,
id_variedad_flor


select bloque.id_bloque,
variedad_flor.id_variedad_flor,
sum(unidades_por_pieza) as cantidad_tallos into #reales
from pieza_postcosecha,
variedad_flor,
bloque
where convert(nvarchar,pieza_postcosecha.fecha_entrada, 101) between
@fecha_inicial and @fecha_final
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and pieza_postcosecha.id_bloque = bloque.id_bloque
group by bloque.id_bloque,
variedad_flor.id_variedad_flor
order by bloque.id_bloque,
variedad_flor.id_variedad_flor

insert into #temp 
(
	id_bloque, 
	idc_bloque, 
	id_variedad_flor, 
	nombre_variedad_flor, 
	id_area, 
	area, 
	idc_persona, 
	identificacion, 
	nombre, 
	apellido, 
	cantidad_tallos, 
	camas_creadas, 
	camas_sembradas
)
select bloque.id_bloque,
bloque.idc_bloque,
variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
999,
null,
'',
'',
'',
'',
#reales.cantidad_tallos - isnull(#calculados.cantidad_tallos, 0),
null,
null
from #reales left join #calculados on (#reales.id_bloque = #calculados.id_bloque and #reales.id_variedad_flor = #calculados.id_variedad_flor),
bloque,
variedad_flor
where #reales.id_bloque = bloque.id_bloque
and #reales.id_variedad_flor = variedad_flor.id_variedad_flor
order by #reales.id_bloque,
#reales.id_variedad_flor

select * from #temp

drop table #temp
drop table #reales
drop table #calculados