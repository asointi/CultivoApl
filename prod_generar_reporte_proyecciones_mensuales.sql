set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_proyecciones_mensuales]

as

declare @nombre_tipo_conteo_mes_entrante nvarchar(255),
@nombre_tipo_conteo_semana_entrante nvarchar(255),
@fecha_inicio_conteo datetime,
@fecha_inicial datetime,
@fecha_final datetime,
@conteo int

set @nombre_tipo_conteo_mes_entrante = 'Estimado Mes Entrante'
set @nombre_tipo_conteo_semana_entrante = 'Estimado semana entrante'
set @fecha_inicio_conteo = convert(datetime, '2011/10/02')

select tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama,
tipo_conteo_propietario_cama.nombre as nombre_tipo_conteo,
conteo_propietario_cama.id_conteo_propietario_cama,
conteo_propietario_cama.fecha_conteo,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
bloque.id_bloque,
bloque.idc_bloque,
persona.id_persona,
persona.idc_persona,
ltrim(rtrim(persona.nombre)) as nombre_persona,
ltrim(rtrim(persona.apellido)) as apellido_persona,
sum(detalle_conteo_propietario_cama.unidades_estimadas) as conteo_semana,
(
	select sum(d.unidades_estimadas)
	from tipo_conteo_propietario_cama as t,
	conteo_propietario_cama as c,
	detalle_conteo_propietario_cama as d
	where t.id_tipo_conteo_propietario_cama = c.id_tipo_conteo_propietario_cama
	and c.id_conteo_propietario_cama = d.id_conteo_propietario_cama
	and t.nombre = @nombre_tipo_conteo_mes_entrante
	and d.id_variedad_flor = variedad_flor.id_variedad_flor
	and d.id_bloque = bloque.id_bloque
	and d.id_persona = persona.id_persona
	and c.fecha_conteo = conteo_propietario_cama.fecha_conteo
) as conteo_mes INTO #TEMP
from conteo_propietario_cama,
tipo_conteo_propietario_cama,
detalle_conteo_propietario_cama,
bloque,
variedad_flor,
tipo_flor,
persona
where conteo_propietario_cama.fecha_conteo > = @fecha_inicio_conteo
and tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
and tipo_conteo_propietario_cama.nombre = @nombre_tipo_conteo_semana_entrante
and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = detalle_conteo_propietario_cama.id_variedad_flor
and bloque.id_bloque = detalle_conteo_propietario_cama.id_bloque
and persona.id_persona = detalle_conteo_propietario_cama.id_persona
group by tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama,
tipo_conteo_propietario_cama.nombre,
conteo_propietario_cama.id_conteo_propietario_cama,
conteo_propietario_cama.fecha_conteo,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
bloque.id_bloque,
bloque.idc_bloque,
persona.id_persona,
persona.idc_persona,
ltrim(rtrim(persona.nombre)),
ltrim(rtrim(persona.apellido))

select @fecha_inicial = min(fecha_conteo),
@fecha_final = max(fecha_conteo)
from #temp

create table #fecha
(
	fecha_inicio datetime,
	fecha_fin datetime
)

while (@fecha_inicial < dateadd(dd, 34, @fecha_final))
begin
	insert into #fecha (fecha_inicio, fecha_fin)
	values (@fecha_inicial, dateadd(dd, 6, @fecha_inicial))

	set @fecha_inicial = dateadd(dd, 7, @fecha_inicial)
end

select identity(int, 1,1) as id, 
(conteo_mes - conteo_semana) / 4 as unidades_estimadas_semanas_restantes,
* into #temp2
from #temp,
#fecha

update #temp2
set unidades_estimadas_semanas_restantes = conteo_semana
where id in
(
	select min(id)
	from #temp2
	group by id_conteo_propietario_cama,
	conteo_semana
)

select * 
from #temp2

drop table #temp
drop table #temp2
drop table #fecha