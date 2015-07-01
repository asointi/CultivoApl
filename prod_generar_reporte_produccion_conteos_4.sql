set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/04/01
-- Description:	Generar Datos de Producción y Conteos a partir de 04 de Febrero de 2011 (DESCUENTA EL CONTEO DE LA SEMANA 04 - 10 ABRIL 2011)
-- =============================================

alter PROCEDURE [dbo].[prod_generar_reporte_produccion_conteos_4] 

as

declare @fecha datetime

set  @fecha = '2011/02/04'

declare @conteo int

create table #temp
(
	id int identity(1,1),
	fecha_inicial datetime,
	fecha_final datetime
)

set @conteo = 1

while(@conteo < = 3)
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
	and conteo_propietario_cama.id_conteo_propietario_cama = 151
	and variedad_flor.id_variedad_flor =  detalle_conteo_propietario_cama.id_variedad_flor
) as conteo,
(
	select sum(unidades_estimadas)
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = 152
	and variedad_flor.id_variedad_flor =  detalle_conteo_propietario_cama.id_variedad_flor
) as conteo_semana_entrante,
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 1
) as "2/04-2/10",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 2
) as "1/28-2/03",
(
	select sum(pieza_postcosecha.unidades_por_pieza)
	from pieza_postcosecha,
	#temp
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) > = #temp.fecha_inicial
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) < = #temp.fecha_final
	and #temp.id = 3
) as "1/21-1/27" into #resultado
from variedad_flor
group by variedad_flor.id_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))

delete from #resultado
where conteo is null
and "2/04-2/10" is null
and "1/28-2/03" is null
and "1/21-1/27" is null

select nombre_variedad_flor, 
isnull(conteo, 0) as conteo,
isnull(conteo_semana_entrante, 0) as conteo_semana_entrante,
isnull(conteo, 0) - isnull(conteo_semana_entrante, 0) as diferencia_conteos,
isnull("2/04-2/10", 0) as "2/04-2/10",
isnull("1/28-2/03", 0) as "1/28-2/03",
isnull("1/21-1/27", 0) as "1/21-1/27"
from #resultado
order by nombre_variedad_flor

drop table #temp
drop table #resultado