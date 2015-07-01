set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_ramo_despatado_consulta_por_rangos]

@fecha_inicial datetime,
@fecha_final datetime,
@idc_persona_inicial nvarchar(50),
@idc_persona_final nvarchar(50)

AS

select persona.idc_persona,
persona.nombre,
persona.apellido,
persona.identificacion,
ramo_despatado.idc_ramo_despatado,
convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101)) as fecha_lectura,
convert(nvarchar,datepart(hh, ramo_despatado.fecha_lectura)) as hora,
convert(nvarchar,datepart(mi, ramo_despatado.fecha_lectura)) as minuto,
convert(nvarchar,datepart(ss, ramo_despatado.fecha_lectura)) as segundos,
ramo_despatado.tallos_por_ramo into #temp
from ramo_despatado,
persona
where not exists
(
	select *
	from ramo_devuelto
	where ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado
)
and convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101)) between
@fecha_inicial and @fecha_final
and persona.id_persona = ramo_despatado.id_persona
and persona.idc_persona > =
case
	when @idc_persona_inicial = '' then '      '
	else @idc_persona_inicial
end
and persona.idc_persona < =
case
	when @idc_persona_final = '' then 'ZZZZZZ'
	else @idc_persona_final
end

update #temp
set hora = '0' + convert(nvarchar,hora)
where len(convert(nvarchar,hora)) = 1

update #temp
set minuto = '0' + convert(nvarchar,minuto)
where len(convert(nvarchar,minuto)) = 1

update #temp
set segundos = '0' + convert(nvarchar,segundos)
where len(convert(nvarchar,segundos)) = 1

select idc_persona,
nombre,
apellido,
identificacion,
idc_ramo_despatado,
fecha_lectura,
hora + minuto + segundos + '00' as hora_lectura,
tallos_por_ramo
from #temp

drop table #temp