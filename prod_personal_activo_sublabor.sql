set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_personal_activo_sublabor]

@idc_detalle_labor nvarchar(255)

as

declare @fecha_consulta datetime

set @fecha_consulta = convert(datetime,convert(nvarchar, getdate(), 101))

select detalle_labor_persona.id_persona,
max(detalle_labor_persona.id_detalle_labor_persona) as id_detalle_labor_persona into #temp
from detalle_labor_persona
where convert(datetime,convert(nvarchar,detalle_labor_persona.fecha,101)) = @fecha_consulta
group by detalle_labor_persona.id_persona

select count(*) as cantidad_personas
from detalle_labor_persona,
detalle_labor,
#temp
where detalle_labor_persona.id_detalle_labor_persona = #temp.id_detalle_labor_persona
and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
and detalle_labor.idc_detalle_labor = @idc_detalle_labor

drop table #temp