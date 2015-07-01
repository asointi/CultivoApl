set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[proglab_consultar_persona]

@fecha datetime

as

select historia_ingreso.id_historia_ingreso,
historia_ingreso.fecha_ingreso,
case
when 
	(
	select historia_retiro.fecha_retiro
	from historia_retiro
	where historia_retiro.id_historia_ingreso = historia_ingreso.id_historia_ingreso
	) is null then convert(datetime, '2100/01/01')
	else 
	(
	select historia_retiro.fecha_retiro
	from historia_retiro
	where historia_retiro.id_historia_ingreso = historia_ingreso.id_historia_ingreso
	)
end as fecha_retiro,
persona.id_persona,
persona.idc_persona,
ltrim(rtrim(persona.nombre)) as nombre_persona,
ltrim(rtrim(persona.apellido)) as apellido_persona,
persona.identificacion,
supervisor.id_supervisor,
idc_supervisor,
ltrim(rtrim(nombre_supervisor)) as nombre_supervisor into #temp
from persona,
supervisor,
historia_ingreso
where historia_ingreso.id_persona = persona.id_persona
and historia_ingreso.fecha_ingreso < = @fecha
and supervisor.id_supervisor = persona.id_supervisor

select idc_persona,
nombre_persona,
apellido_persona,
fecha_ingreso,
identificacion,
idc_supervisor,
nombre_supervisor
from #temp
where @fecha between
fecha_ingreso and fecha_retiro
order by nombre_persona,
apellido_persona

drop table #temp

