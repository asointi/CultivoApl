SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[prod_hallar_curva_produccion]
	
@fecha datetime,
@idc_bloque nvarchar(20),
@idc_variedad_flor nvarchar(20)

as 

declare @dias_ciclo int,
@dias_ciclo_completo int,
@fecha_inicial datetime,
@fecha_final datetime,
@unidades_ciclo_anterior int,
@unidades_primer_ciclo int,
@unidades_segundo_ciclo int,
@unidades_tercer_ciclo int,
@id_bloque int,
@id_variedad_flor int,
@conteo int

select @id_bloque = bloque.id_bloque
from bloque
where bloque.idc_bloque = @idc_bloque

select @dias_ciclo = tipo_flor.dias_ciclo,
@id_variedad_flor = variedad_flor.id_variedad_flor
from tipo_flor,
variedad_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor = @idc_variedad_flor

select @dias_ciclo_completo = @dias_ciclo * 3
set @fecha_inicial = dateadd(dd, @dias_ciclo*-1, @fecha)
set @fecha_final = dateadd(dd, @dias_ciclo_completo, @fecha)

select convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) as fecha,
datediff(dd, @fecha, convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101))) as dias_diferencia,
case
	when datediff(dd, @fecha, convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101))) = 0 then 1
	else sum(pieza_postcosecha.unidades_por_Pieza)
end as unidades into #temp
from bloque,
variedad_flor,
tipo_flor,
pieza_postcosecha
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
and bloque.id_bloque = pieza_postcosecha.id_bloque
and bloque.id_bloque = @id_bloque
and variedad_flor.id_variedad_flor = @id_variedad_flor
and pieza_postcosecha.fecha_entrada between
@fecha_inicial and @fecha_final
group by convert(datetime, convert(nvarchar, pieza_postcosecha.fecha_entrada, 101))
order by fecha

--update #temp
--set unidades = 1
--where dias_diferencia = 0

select @unidades_ciclo_anterior = sum(unidades)
from #temp
where fecha < @fecha

select @unidades_primer_ciclo = sum(unidades)
from #temp
where dias_diferencia < = (@dias_ciclo * 1.5)
and fecha > = @fecha

select @unidades_segundo_ciclo = sum(unidades)
from #temp
where dias_diferencia > (@dias_ciclo * 1.5)
and dias_diferencia < = (@dias_ciclo * 2.5)

select @unidades_tercer_ciclo = sum(unidades)
from #temp
where dias_diferencia > (@dias_ciclo * 2.5)

--select 
--case
--	when fecha < @fecha then (unidades / convert(decimal(20,4), @unidades_ciclo_anterior)) * 100
--	when dias_diferencia < = (@dias_ciclo * 1.5) and fecha > = @fecha then (unidades / convert(decimal(20,4), @unidades_primer_ciclo)) * 100
--	when dias_diferencia > (@dias_ciclo * 1.5)  and dias_diferencia < = (@dias_ciclo * 2.5) then ((unidades / convert(decimal(20,4), @unidades_segundo_ciclo)) * 100) * (@unidades_segundo_ciclo/convert(decimal(20,4), @unidades_primer_ciclo))
--	when dias_diferencia > (@dias_ciclo * 2.5) then ((unidades / convert(decimal(20,4), @unidades_tercer_ciclo)) * 100) * (@unidades_tercer_ciclo/convert(decimal(20,4), @unidades_segundo_ciclo))
--end as porcentaje,
--* into #temp2
--from #temp

select 
case
	when dias_diferencia < = (@dias_ciclo) then (unidades / convert(decimal(20,4), @unidades_ciclo_anterior)) * 100
	when dias_diferencia > (@dias_ciclo) and dias_diferencia < = (@dias_ciclo * 1.5) and fecha > = @fecha then ((unidades / convert(decimal(20,4), @unidades_primer_ciclo)) * 100) --* (@unidades_primer_ciclo/convert(decimal(20,4), @unidades_ciclo_anterior))
	when dias_diferencia > (@dias_ciclo * 1.5)  and dias_diferencia < = (@dias_ciclo * 2.5) then ((unidades / convert(decimal(20,4), @unidades_segundo_ciclo)) * 100) * (@unidades_segundo_ciclo/convert(decimal(20,4), @unidades_primer_ciclo))
	when dias_diferencia > (@dias_ciclo * 2.5) then ((unidades / convert(decimal(20,4), @unidades_tercer_ciclo)) * 100) * (@unidades_tercer_ciclo/convert(decimal(20,4), @unidades_segundo_ciclo))
end as porcentaje,
* into #temp2
from #temp

select 
case
	when #temp2.dias_diferencia > (@dias_ciclo * -1.5) then 
	(
		select t.unidades
		from #temp2 as t
		where t.dias_diferencia = #temp2.dias_diferencia - @dias_ciclo
	) * #temp2.porcentaje /
	(
		select t.porcentaje
		from #temp2 as t
		where t.dias_diferencia = #temp2.dias_diferencia - @dias_ciclo
	) 
end as proyeccion,
dias_diferencia/7 as semana,
* INTO #TEMP3
from #temp2

update #temp3
set proyeccion = 0
where proyeccion is null

select 
(
	SELECT MAX(T.DIAS_DIFERENCIA)
	FROM #TEMP3 AS T
	WHERE T.DIAS_DIFERENCIA < = #TEMP3.DIAS_DIFERENCIA - @dias_ciclo
) AS DIA_CICLO_ANTERIOR,
* INTO #TEMP4
from #temp3
where proyeccion is null

ALTER TABLE #TEMP4
ADD UNIDADES_ATRAS INT,
PORCENTAJE_ATRAS DECIMAL(20,4)

UPDATE #TEMP4
SET UNIDADES_ATRAS = #TEMP2.UNIDADES,
PORCENTAJE_ATRAS = #TEMP2.PORCENTAJE
FROM #TEMP2
WHERE #TEMP4.DIA_CICLO_ANTERIOR = #TEMP2.DIAS_DIFERENCIA 

update #temp3
set proyeccion = #temp4.unidades_atras * #temp4.porcentaje / #temp4.porcentaje_atras
from #temp4
where #temp3.dias_diferencia = #temp4.dias_diferencia
and #temp3.proyeccion is null
and #temp3.dias_diferencia > (@dias_ciclo * 1.5)


SELECT convert(int,ROUND(sum(proyeccion), 0)) as proyeccion,
semana,
sum(porcentaje) as porcentaje,
sum(unidades) as unidades into #resultado
FROM #TEMP3
group by semana
order by semana

set @conteo = 6

while(@conteo > 0)
begin
	update #resultado
	set proyeccion = r.proyeccion
	from #resultado as r,
	#resultado
	where #resultado.semana = (@dias_ciclo/7) + @conteo
	and r.semana = (@dias_ciclo/7) - @conteo + 1

	set @conteo = @conteo - 1
end

select * from #resultado

drop table #temp
drop table #temp2
DROP TABLE #TEMP3
DROP TABLE #TEMP4
drop table #resultado