set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/03/11
-- Description:	Generar Datos de Producción y Conteos a partir de 18 de Febrero de 2011
-- =============================================

ALTER PROCEDURE [dbo].[prod_generar_reporte_produccion_conteos] 

as

declare @fecha datetime

set  @fecha = '2011/02/18'

declare @conteo int

create table #temp
(
	id int identity(1,1),
	fecha_inicial datetime,
	fecha_final datetime
)

set @conteo = 1

while(@conteo < = 8)
begin
	insert into #temp (fecha_inicial, fecha_final)
	select @fecha, @fecha + 6
	set @fecha = @fecha - 7

	set @conteo = @conteo  + 1
end

select variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
(
	select sum(unidades_estimadas)
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = 146
	and variedad_flor.id_variedad_flor =  detalle_conteo_propietario_cama.id_variedad_flor
) as conteo,
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 1
) as "2/18-2/24",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 2
) as "2/11-2/17",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 3
) as "2/04-2/10",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 4
) as "1/28-2/03",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 5
) as "1/21-1/27",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 6
) as "1/14-1/20",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 7
) as "1/07-1/13",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 8
) as "12/31-1/06" into #resultado
from variedad_flor
group by variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))

delete from #resultado
where conteo is null
and "2/18-2/24" is null
and "2/11-2/17" is null
and "2/04-2/10" is null
and "1/28-2/03" is null
and "1/21-1/27" is null
and "1/14-1/20" is null
and "1/07-1/13" is null
and "12/31-1/06" is null

select nombre_variedad_flor, 
isnull(conteo, 0) as conteo,
isnull("2/18-2/24", 0) as "2/18-2/24",
isnull("2/11-2/17", 0) as "2/11-2/17",
isnull("2/04-2/10", 0) as "2/04-2/10",
isnull("1/28-2/03", 0) as "1/28-2/03",
isnull("1/21-1/27", 0) as "1/21-1/27",
isnull("1/14-1/20", 0) as "1/14-1/20",
isnull("1/07-1/13", 0) as "1/07-1/13",
isnull("12/31-1/06", 0) as "12/31-1/06"
from #resultado
order by nombre_variedad_flor

drop table #temp
drop table #resultado