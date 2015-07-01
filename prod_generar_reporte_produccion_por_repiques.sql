set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/09/16
-- Description:	Generar Datos de Producción por Repiques (15 periodos)
-- =============================================

alter PROCEDURE [dbo].[prod_generar_reporte_produccion_por_repiques] 

as

declare @fecha datetime,
@fecha_proyectada datetime,
@fecha_inicial_primer_ciclo datetime,
@fecha_final_primer_ciclo datetime,
@conteo int,
@sql nvarchar(max)

set language spanish
select @fecha = convert(datetime, convert(nvarchar, getdate(), 103))

select @fecha_proyectada = @fecha + (7 - datepart(dw, @fecha)) + 8

select @fecha_inicial_primer_ciclo = dateadd(dd, -80, @fecha_proyectada)

create table #temp
(
	id int identity(1,1),
	fecha_inicial datetime,
	fecha_final datetime
)

set @conteo = 0

while (@conteo < 15)
begin
	set @fecha_final_primer_ciclo = @fecha_inicial_primer_ciclo + 6
	
	insert into #temp (fecha_inicial, fecha_final)
	select @fecha_inicial_primer_ciclo, @fecha_final_primer_ciclo

	set @fecha_inicial_primer_ciclo = @fecha_inicial_primer_ciclo + 7
	set @conteo = @conteo + 1
end

create table #datos
(
	id_variedad_flor int,
	nombre_variedad_flor nvarchar(255),
	produccion1 int,
	produccion2 int,
	produccion3 int,
	produccion4 int,
	produccion5 int,
	produccion6 int,
	produccion7 int,
	produccion8 int,
	produccion9 int,
	produccion10 int,
	produccion11 int,
	produccion12 int,
	produccion13 int,
	produccion14 int,
	produccion15 int
)

insert into #datos
(
	id_variedad_flor,
	nombre_variedad_flor,
	produccion1,
	produccion2,
	produccion3,
	produccion4,
	produccion5,
	produccion6,
	produccion7,
	produccion8,
	produccion9,
	produccion10,
	produccion11,
	produccion12,
	produccion13,
	produccion14,
	produccion15
)
select variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 1
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 2
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 3
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 4
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 5
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 6
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 7
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 8
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 9
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 10
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 11
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 12
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 13
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 14
	and pieza_postcosecha.id_bloque <> 191
),
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,103)) < = #temp.fecha_final
	and #temp.id = 15
	and pieza_postcosecha.id_bloque <> 191
)
from variedad_flor
group by variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))

delete from #datos
where produccion1 is null
and produccion2 is null
and produccion3 is null
and produccion4 is null
and produccion5 is null
and produccion6 is null
and produccion7 is null
and produccion8 is null
and produccion9 is null
and produccion10 is null
and produccion11 is null
and produccion12 is null
and produccion13 is null
and produccion14 is null
and produccion15 is null

set @sql = 'select nombre_variedad_flor,
produccion1 as ' + dbo.Nombre_Dinamico_Columna(0) + ',
produccion2 as ' + dbo.Nombre_Dinamico_Columna(7) + ',
produccion3 as ' + dbo.Nombre_Dinamico_Columna(14) + ',
produccion4 as ' + dbo.Nombre_Dinamico_Columna(21) + ',
produccion5 as ' + dbo.Nombre_Dinamico_Columna(28) + ',
produccion6 as ' + dbo.Nombre_Dinamico_Columna(35) + ',
produccion7 as ' + dbo.Nombre_Dinamico_Columna(42) + ',
produccion8 as ' + dbo.Nombre_Dinamico_Columna(49) + ',
produccion9 as ' + dbo.Nombre_Dinamico_Columna(56) + ',
produccion10 as ' + dbo.Nombre_Dinamico_Columna(63) + ',
produccion11 as ' + dbo.Nombre_Dinamico_Columna(70) + ',
produccion12 as ' + dbo.Nombre_Dinamico_Columna(77) + ',
produccion13 as ' + dbo.Nombre_Dinamico_Columna(84) + ',
produccion14 as ' + dbo.Nombre_Dinamico_Columna(91) + ',
produccion15 as ' + dbo.Nombre_Dinamico_Columna(98) + '
from #datos
order by produccion1'

exec (@sql)

drop table #datos
drop table #temp