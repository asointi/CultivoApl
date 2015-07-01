set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_comparativo_semanas] 

@fecha datetime

as

declare @conteo int

set @conteo = 1

create table #temp
(
	id int,
	fecha_inicial datetime,
	fecha_final datetime
)

while (@conteo < = 42)
begin
	insert into #temp (id, fecha_inicial, fecha_final)
	values (@conteo, @fecha, @fecha + 6)

	set @fecha = @fecha + 7

	set @conteo = @conteo + 1
end

select bloque.idc_bloque,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
convert(nvarchar,#temp.fecha_inicial, 101) + ' - ' + convert(nvarchar,#temp.fecha_inicial, 101) as rango_fechas,
convert(nvarchar,#temp.fecha_inicial, 101) as fecha_inicial,
convert(nvarchar,#temp.fecha_final, 101) as fecha_final,
#temp.id,
sum(pieza_postcosecha.unidades_por_pieza) as total_unidades into #resultado
from pieza_postcosecha,
variedad_flor,
tipo_flor,
bloque,
#temp
where pieza_postcosecha.id_bloque = bloque.id_bloque
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
and convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) between
#temp.fecha_inicial and #temp.fecha_final
group by bloque.idc_bloque,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
convert(nvarchar,#temp.fecha_inicial, 101),
convert(nvarchar,#temp.fecha_final, 101),
#temp.id
order by bloque.idc_bloque,
fecha_inicial,
fecha_final

alter table #resultado
add unidades_primer_ciclo int,
unidades_segundo_ciclo int,
unidades_tercer_ciclo int,
ciclo int

update #resultado
set unidades_primer_ciclo = total_unidades
where id < = 14

update #resultado
set unidades_segundo_ciclo = total_unidades
where id > 14 and id < 29

update #resultado
set unidades_tercer_ciclo = total_unidades
where id > = 29

update #resultado
set id = id - 14
where id > 14 and id < 29

select id, 
min(convert(datetime,fecha_inicial)) as inicio, 
max(convert(datetime,fecha_inicial)) as intermedia into #dias
from #resultado
where id < 29
group by id

alter table #dias
add final datetime

select id, 
min(convert(datetime,fecha_inicial)) as final into #dias_tercer_ciclo
from #resultado
where id > = 29
group by id

update #dias_tercer_ciclo
set id = id - 28

update #dias
set final = #dias_tercer_ciclo.final
from #dias_tercer_ciclo
where #dias_tercer_ciclo.id = #dias.id

update #resultado
set id = id - 28
where id > = 29

update #resultado
set rango_fechas = 
case
	when len(convert(nvarchar, #dias.id)) = 1 then '0' + convert(nvarchar, #dias.id)
	else convert(nvarchar, #dias.id)
end 
+ ' (1C: ' + isnull(convert(nvarchar,#dias.inicio, 101), '') + ' - 2C: ' + isnull(convert(nvarchar,#dias.intermedia, 101), '') + ')'  + ' - 3C: ' + isnull(convert(nvarchar,#dias.final, 101), '') + ')'
from #dias
where #dias.id = #resultado.id

update #resultado
set ciclo = 0

select * 
from #resultado

drop table #temp
drop table #resultado
drop table #dias
drop table #dias_tercer_ciclo


