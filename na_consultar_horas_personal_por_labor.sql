set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_horas_personal_por_labor]

@fecha datetime

as

select ltrim(rtrim(persona.identificacion)) as identificacion,
ltrim(rtrim(persona.nombre)) as nombre,
ltrim(rtrim(persona.apellido)) as apellido,
labor.idc_labor,
ltrim(rtrim(labor.nombre_labor)) as nombre_labor,
detalle_labor.idc_detalle_labor,
ltrim(rtrim(detalle_labor.nombre_detalle_labor)) as nombre_detalle_labor,
case
	when left(cast(detalle_labor_persona.fecha as time), 5) <> '06:30' then detalle_labor_persona.fecha
	else
	(
		select top 1 fecha_lectura
		from detalle_labor_persona as dlp (NOLOCK)
		where persona.id_persona = dlp.id_persona
		and cast(dlp.fecha_lectura as date) = cast(Detalle_Labor_Persona.fecha_lectura as date)
	)
end as hora_inicio
from detalle_labor_persona (NOLOCK),
persona (NOLOCK),
detalle_labor (NOLOCK),
labor (NOLOCK)
where labor.id_labor = detalle_labor.id_labor
and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
and persona.id_persona = detalle_labor_persona.id_persona
and Detalle_Labor_Persona.fecha_lectura is not null
and convert(datetime, cast(detalle_labor_persona.fecha as date)) = @fecha
order by identificacion,
hora_inicio