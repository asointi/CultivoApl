set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_horas_personal]

@fecha datetime

as

select ltrim(rtrim(persona.identificacion)) as identificacion,
ltrim(rtrim(persona.nombre)) as nombre,
ltrim(rtrim(persona.apellido)) as apellido,
min(detalle_labor_persona.fecha_lectura) as hora_ingreso,
max(detalle_labor_persona.fecha) as hora_salida 
from persona,
detalle_labor_persona
where persona.id_persona = detalle_labor_persona.id_persona
and convert(datetime,convert(nvarchar,detalle_labor_persona.fecha, 101)) = @fecha
group by ltrim(rtrim(persona.identificacion)),
ltrim(rtrim(persona.nombre)),
ltrim(rtrim(persona.apellido))