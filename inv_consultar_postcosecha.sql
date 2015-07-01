/****** Object:  StoredProcedure [dbo].[inv_consultar_postcosecha2]    Script Date: 02/11/2008 13:47:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[inv_consultar_postcosecha] 

@fecha_consulta datetime,
@dias_columna int,
@id_tipo_flor int,
@dias_semana_consulta nvarchar(13),
@periodo7 int,
@periodo6 int,
@periodo5 int,
@periodo4 int,
@periodo3 int,
@periodo2 int,
@periodo1 int,
@id_finca int

AS

set datefirst 1
declare @tbl_dias_semana TABLE (nstr nvarchar(1) NOT NULL)

INSERT INTO @tbl_dias_semana
SELECT nstr FROM na_charlist_to_tbl(@dias_semana_consulta, default)

select bloque.id_bloque into #bloques
from finca_propia, 
finca_bloque,  
bloque
where finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and finca_bloque.id_bloque = bloque.id_bloque
and finca_propia.id_finca_propia > = 
case 
	when @id_finca = -1 then 1
	else  @id_finca
end
and finca_propia.id_finca_propia < = 
case 
	when @id_finca = -1 then 9999999
	else  @id_finca
end
group by bloque.id_bloque

SELECT rango_fechas.date,
'unidades6' as periodo into #fechas
FROM na_rangeOfDates_to_tbl(DATEADD(day, -(@periodo7*@dias_columna-1),@fecha_consulta), DATEADD(day,-((@periodo7-1)*@dias_columna),@fecha_consulta)) as rango_fechas,
@tbl_dias_semana as dias_semana
WHERE rango_fechas.weekDayNumber = dias_semana.nstr
union all 
SELECT rango_fechas.date,
'unidades5' as periodo
FROM na_rangeOfDates_to_tbl(DATEADD(day, -(@periodo6*@dias_columna-1),@fecha_consulta), DATEADD(day,-((@periodo6-1)*@dias_columna),@fecha_consulta)) as rango_fechas,
@tbl_dias_semana as dias_semana
WHERE rango_fechas.weekDayNumber = dias_semana.nstr
union all
SELECT rango_fechas.date,
'unidades4' as periodo
FROM na_rangeOfDates_to_tbl(DATEADD(day, -(@periodo5*@dias_columna-1),@fecha_consulta), DATEADD(day,-((@periodo5-1)*@dias_columna),@fecha_consulta)) as rango_fechas,
@tbl_dias_semana as dias_semana
WHERE rango_fechas.weekDayNumber = dias_semana.nstr
union all
SELECT rango_fechas.date,
'unidades3' as periodo
FROM na_rangeOfDates_to_tbl(DATEADD(day, -(@periodo4*@dias_columna-1),@fecha_consulta), DATEADD(day,-((@periodo4-1)*@dias_columna),@fecha_consulta)) as rango_fechas,
@tbl_dias_semana as dias_semana
WHERE rango_fechas.weekDayNumber = dias_semana.nstr
union all
SELECT rango_fechas.date,
'unidades2' as periodo
FROM na_rangeOfDates_to_tbl(DATEADD(day, -(@periodo3*@dias_columna-1),@fecha_consulta), DATEADD(day,-((@periodo3-1)*@dias_columna),@fecha_consulta)) as rango_fechas,
@tbl_dias_semana as dias_semana
WHERE rango_fechas.weekDayNumber = dias_semana.nstr
union all
SELECT rango_fechas.date,
'unidades1' as periodo
FROM na_rangeOfDates_to_tbl(DATEADD(day, -(@periodo2*@dias_columna-1),@fecha_consulta), DATEADD(day,-((@periodo2-1)*@dias_columna),@fecha_consulta)) as rango_fechas,
@tbl_dias_semana as dias_semana
WHERE rango_fechas.weekDayNumber = dias_semana.nstr
union all
SELECT rango_fechas.date,
'unidades0' as periodo
FROM na_rangeOfDates_to_tbl(DATEADD(day, -(@periodo1*@dias_columna-1),@fecha_consulta), DATEADD(day,-((@periodo1-1)*@dias_columna),@fecha_consulta)) as rango_fechas,
@tbl_dias_semana as dias_semana
WHERE rango_fechas.weekDayNumber = dias_semana.nstr

select tipo_flor.id_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
#fechas.periodo,
isnull(sum(unidades_por_pieza), 0) as unidades into #temp
from pieza_postcosecha,
#fechas,
tipo_flor,
variedad_flor
where DATEADD(day, 0, DATEDIFF(day, 0, pieza_postcosecha.fecha_entrada)) = #fechas.date
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
and exists
(
	select *
	from #bloques
	where pieza_postcosecha.id_bloque = #bloques.id_bloque
)
group by tipo_flor.id_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
#fechas.periodo

select id_tipo_flor,
nombre_variedad_flor,
isnull([unidades6], 0) as [unidades6],
isnull([unidades5], 0) as [unidades5],
isnull([unidades4], 0) as [unidades4],
isnull([unidades3], 0) as [unidades3],
isnull([unidades2], 0) as [unidades2],
isnull([unidades1], 0) as [unidades1],
isnull([unidades0], 0) as [unidades0]
from #temp
pivot 
(
	sum(unidades) 
	for periodo in ([unidades6],[unidades5],[unidades4],[unidades3],[unidades2],[unidades1],[unidades0])
) as dias
where id_tipo_flor > = 
case
	when @id_tipo_flor = -1 then 1
	else @id_tipo_flor
end
and id_tipo_flor < = 
case
	when @id_tipo_flor = -1 then 99999999
	else @id_tipo_flor
end

select id_tipo_flor,
nombre_tipo_flor
from #temp
group by id_tipo_flor,
nombre_tipo_flor
order by nombre_tipo_flor

drop table #bloques
drop table #fechas
drop table #temp