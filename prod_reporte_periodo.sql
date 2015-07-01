set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_reporte_periodo]

@id_finca_propia int,
@fecha_inicial datetime,
@fecha_final datetime,
@tipo_periodo int,
@tipo_agrupamiento nvarchar(255)

AS

declare @conteo int

create table #fechas 
(
	fecha_inicial datetime,
	fecha_final datetime
)

set @conteo = 0

/*
1. Año
2. Semana
*/
if(@tipo_periodo = 1)
begin
	while (@conteo < 9)
	begin
		insert into #fechas (fecha_inicial, fecha_final)
		select @fecha_inicial - (364 * @conteo), @fecha_final - (364 * @conteo)

		set @conteo = @conteo + 1
	end
end
else
if(@tipo_periodo = 2)
begin
	while (@conteo < 9)
	begin
		insert into #fechas (fecha_inicial, fecha_final)
		select @fecha_inicial - (7 * @conteo), @fecha_final - (7 * @conteo)

		set @conteo = @conteo + 1
	end
end

select tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
bloque.id_bloque,
bloque.idc_bloque,
sum(pieza_postcosecha.unidades_por_pieza) as unidades,
#fechas.fecha_inicial,
#fechas.fecha_final,
datediff(dd, #fechas.fecha_inicial, #fechas.fecha_final) + 1 as dias
from pieza_postcosecha,
bloque,
variedad_flor,
tipo_flor,
finca_bloque,
finca_propia,
#fechas
where pieza_postcosecha.id_bloque = bloque.id_bloque
and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and bloque.id_bloque = finca_bloque.id_bloque
and finca_bloque.id_finca_propia = finca_propia.id_finca_propia
and finca_propia.id_finca_propia > = 
case
	when @id_finca_propia = -1 then 1
	else @id_finca_propia
end
and finca_propia.id_finca_propia < = 
case
	when @id_finca_propia = -1 then 99999
	else @id_finca_propia
end
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
#fechas.fecha_inicial and #fechas.fecha_final
group by tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
bloque.id_bloque,
bloque.idc_bloque,
#fechas.fecha_inicial,
#fechas.fecha_final
order by 
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
bloque.id_bloque,
bloque.idc_bloque,
#fechas.fecha_inicial,
#fechas.fecha_final

drop table #fechas