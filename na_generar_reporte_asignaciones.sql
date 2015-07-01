set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_generar_reporte_asignaciones]

@fecha_inicial datetime,
@fecha_final datetime

as

declare @conteo int,
@id int,
@id_area int,
@id_area_aux int

create table #temp
(
	id int identity(1,1),
	id_bloque nvarchar(255), 
	idc_bloque nvarchar(255), 
	id_variedad_flor int, 
	nombre_variedad_flor nvarchar(255), 
	id_area int, 
	area decimal(20,4), 
	idc_persona nvarchar(255), 
	id_persona int,
	identificacion nvarchar(255), 
	nombre nvarchar(255), 
	apellido nvarchar(255), 
	cantidad_tallos int, 
	camas_creadas int, 
	camas_sembradas int,
	camas_asignadas int,
	fecha_asignacion_area datetime
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
	id_persona,
	identificacion, 
	nombre, 
	apellido, 
	cantidad_tallos, 
	camas_creadas, 
	camas_sembradas,
	camas_asignadas,
	fecha_asignacion_area
)
select bloque.id_bloque,
bloque.idc_bloque,
variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
area.id_area,
bloque.area,
persona.idc_persona,
persona.id_persona,
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
		and destruir_cama_bloque.fecha < @fecha_inicial
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
		and erradicar_cama_bloque.fecha < @fecha_inicial 
	)
) as camas_sembradas,
(
	select count(detalle_area.id_sembrar_cama_bloque)
	from detalle_area,
	sembrar_cama_bloque
	where detalle_area.id_area = area.id_area
	and detalle_area.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
) as camas_asignadas,
(
	select max(area_asignada.fecha_asignacion)
	from area_asignada
	where area.id_area = area_asignada.id_area
	and area_asignada.id_persona = persona.id_persona
	and area_asignada.fecha_asignacion < = @fecha_final
) as fecha_asignacion_area
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
and area_asignada.fecha_asignacion < = @fecha_final
group by bloque.idc_bloque,
bloque.id_bloque,
variedad_flor.id_variedad_flor,
area.id_area,
bloque.area,
persona.idc_persona,
persona.identificacion,
persona.id_persona,
cama_bloque.id_bloque,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
rtrim(ltrim(persona.nombre)),
ltrim(rtrim(persona.apellido))
order by area.id_area,
fecha_asignacion_area

alter table #temp
add fecha_final datetime,
cantidad_tallos_asignacion int

select @conteo = count(id) from #temp
set @id = 1

while(@id < = @conteo)
begin
	select @id_area = id_area from #temp where id = @id
	select @id_area_aux = id_area from #temp where id = @id + 1

	if(@id_area = @id_area_aux)
	begin
		update #temp
		set fecha_final = (select fecha_asignacion_area from #temp where id = @id + 1)
		where id = @id
	end

	set @id = @id + 1
end

update #temp
set cantidad_tallos = 0,
camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_variedad_flor,
	id_persona,
	cantidad_tallos
	having count(*) > 1
)

update #temp
set cantidad_tallos = 0,
camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_variedad_flor,
	id_persona,
	cantidad_tallos
	having count(*) > 1
)

update #temp
set cantidad_tallos = 0,
camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_variedad_flor,
	id_persona,
	cantidad_tallos
	having count(*) > 1
)

update #temp
set camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_area,
	id_variedad_flor,
	camas_asignadas
	having count(*) > 1
)

update #temp
set camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_area,
	id_variedad_flor,
	camas_asignadas
	having count(*) > 1
)

update #temp
set camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_area,
	id_variedad_flor,
	camas_asignadas
	having count(*) > 1
)

update #temp
set camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_area,
	id_variedad_flor,
	camas_asignadas
	having count(*) > 1
)

update #temp
set camas_asignadas = 0
where id 
in
(
	select min(id)
	from #temp
	group by id_bloque,
	id_area,
	id_variedad_flor,
	camas_asignadas
	having count(*) > 1
)

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

select #temp.id,
sum(unidades_por_pieza) as cantidad_tallos into #tallos_asignacion
from pieza_postcosecha,
variedad_flor,
bloque,
persona,
#temp
where convert(nvarchar,pieza_postcosecha.fecha_entrada, 101) between
case
	when #temp.fecha_asignacion_area < @fecha_inicial then @fecha_inicial
	else #temp.fecha_asignacion_area
end and #temp.fecha_final
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and pieza_postcosecha.id_bloque = bloque.id_bloque
and pieza_postcosecha.id_persona = persona.id_persona
and pieza_postcosecha.id_variedad_flor = #temp.id_variedad_flor
and pieza_postcosecha.id_bloque = #temp.id_bloque
and pieza_postcosecha.id_persona = #temp.id_persona
group by 
#temp.id

update #temp
set cantidad_tallos_asignacion = #tallos_asignacion.cantidad_tallos
from #tallos_asignacion
where #temp.id = #tallos_asignacion.id

insert into #temp 
(
	id_bloque, 
	idc_bloque, 
	id_variedad_flor, 
	nombre_variedad_flor, 
	id_area, 
	area, 
	idc_persona, 
	id_persona,
	identificacion, 
	nombre, 
	apellido, 
	cantidad_tallos, 
	camas_creadas, 
	camas_sembradas,
	camas_asignadas,
	fecha_asignacion_area
)
select bloque.id_bloque,
bloque.idc_bloque,
variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
9999,
null,
'',
null,
'',
'',
'',
#reales.cantidad_tallos - isnull(#calculados.cantidad_tallos, 0),
null,
null,
null,
null
from #reales left join #calculados on (#reales.id_bloque = #calculados.id_bloque and #reales.id_variedad_flor = #calculados.id_variedad_flor),
bloque,
variedad_flor
where #reales.id_bloque = bloque.id_bloque
and #reales.id_variedad_flor = variedad_flor.id_variedad_flor
and #reales.cantidad_tallos > = isnull(#calculados.cantidad_tallos, 0)
order by #reales.id_bloque,
#reales.id_variedad_flor

update #temp
set area = null
where area = 0

update #temp
set fecha_final = @fecha_final
where fecha_final is null
and fecha_asignacion_area is not null
and fecha_asignacion_area < = @fecha_final

update #temp
set fecha_final = null
where fecha_asignacion_area is null

--update #temp
--set camas_asignadas = 0
--from estado_area,
--area
--where area.id_estado_area = estado_area.id_estado_area
--and estado_area.nombre_estado_area = 'Anulada'
--and #temp.id_area = area.id_area

select *,
datediff(dd, fecha_asignacion_area, fecha_final) as dias_totales_asignacion,
case
	when datediff(dd, @fecha_inicial, fecha_final) < 0 then 0
	else datediff(dd, @fecha_inicial, fecha_final)
end as dias_periodo_asignacion 
from #temp
order by convert(int,id_bloque),
id_variedad_flor,
id_area,
nombre,
apellido

drop table #temp
drop table #reales
drop table #calculados
drop table #tallos_asignacion