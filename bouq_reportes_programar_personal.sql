set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/02
-- Description:	Maneja los reportes de programacion de personal en la bouquetera
-- =============================================

alter PROCEDURE [dbo].[bouq_reportes_programar_personal] 

@accion nvarchar(50)

as

select programacion_personal_bouquetera.id_programacion_personal_bouquetera,
programacion_personal_bouquetera.hora_entrega_despacho,
detalle_labor.id_detalle_labor,
detalle_labor.idc_detalle_labor,
horario_apoyo_personal_bouquetera.id_horario_apoyo_personal_bouquetera,
horario_apoyo_personal_bouquetera.cantidad_personas,
horario_apoyo_personal_bouquetera.hora_llegada,
supervisor.id_supervisor,
ltrim(rtrim(supervisor.nombre_supervisor)) + ' [' + supervisor.idc_supervisor + ']' as nombre_supervisor,
persona.id_persona,
ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + ltrim(rtrim(persona.identificacion)) + ']' as nombre_persona,
isnull((
	select top 1 
	case
		when detalle_labor_persona.id_persona is not null then 1
	end
	from detalle_labor_persona
	where detalle_labor_persona.fecha > = horario_apoyo_personal_bouquetera.hora_llegada
	and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
	and persona.id_persona = detalle_labor_persona.id_persona
), 0) as llegada_persona,
(
	select count(d.id_detalle_programacion_personal_bouquetera)
	from detalle_programacion_personal_bouquetera as d
	where programacion_personal_bouquetera.id_programacion_personal_bouquetera = d.id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = d.id_detalle_labor
) as cantidad_personas_programadas into #temp
from programacion_personal_bouquetera,
horario_apoyo_personal_bouquetera,
detalle_labor,
detalle_programacion_personal_bouquetera,
persona,
supervisor
where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
and horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = detalle_programacion_personal_bouquetera.id_programacion_personal_bouquetera
and supervisor.id_supervisor = detalle_programacion_personal_bouquetera.id_supervisor
and horario_apoyo_personal_bouquetera.id_detalle_labor = detalle_programacion_personal_bouquetera.id_detalle_labor
and persona.id_persona = detalle_programacion_personal_bouquetera.id_persona
and convert(datetime,convert(nvarchar, horario_apoyo_personal_bouquetera.hora_llegada, 101)) < = convert(datetime,convert(nvarchar, getdate(), 101))
and horario_apoyo_personal_bouquetera.hora_llegada < = getdate()
and programacion_personal_bouquetera.hora_entrega_despacho > = getdate()

union all

select programacion_personal_bouquetera.id_programacion_personal_bouquetera,
programacion_personal_bouquetera.hora_entrega_despacho,
detalle_labor.id_detalle_labor,
detalle_labor.idc_detalle_labor,
horario_apoyo_personal_bouquetera.id_horario_apoyo_personal_bouquetera,
horario_apoyo_personal_bouquetera.cantidad_personas,
horario_apoyo_personal_bouquetera.hora_llegada,
0,
'' as nombre_supervisor,
0,
'' as nombre_persona,
0 as llegada_persona,
0 as cantidad_personas_programadas
from programacion_personal_bouquetera,
horario_apoyo_personal_bouquetera,
detalle_labor
where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
and convert(datetime,convert(nvarchar, horario_apoyo_personal_bouquetera.hora_llegada, 101)) < = convert(datetime,convert(nvarchar, getdate(), 101))
and horario_apoyo_personal_bouquetera.hora_llegada < = getdate()
and programacion_personal_bouquetera.hora_entrega_despacho > = getdate()
and not exists
(
	select *
	from detalle_programacion_personal_bouquetera
	where horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = detalle_programacion_personal_bouquetera.id_programacion_personal_bouquetera
	and horario_apoyo_personal_bouquetera.id_detalle_labor = detalle_programacion_personal_bouquetera.id_detalle_labor
)

if(@accion = 'reporte_pendientes_por_llegar')
begin
	select *,
	(
		select sum(t.llegada_persona)
		from #temp as t
		where #temp.id_programacion_personal_bouquetera = t.id_programacion_personal_bouquetera
		and #temp.id_detalle_labor = t.id_detalle_labor
	) as cantidad_personas_pistoleadas 
	from #temp
	order by id_programacion_personal_bouquetera,
	id_detalle_labor
end
else
if(@accion = 'enviar_reporte')
begin
	declare @correo nvarchar(1024),
	@subject1 nvarchar(512),
	@personas_por_programar int,
	@personas_por_llegar int

	set @correo = 'carlos@natuflora.net; dpineros@natuflora.net'

	select id_programacion_personal_bouquetera,
	id_horario_apoyo_personal_bouquetera,
	cantidad_personas as cantidad_personas_solicitadas,
	cantidad_personas_programadas,
	(
		select sum(t.llegada_persona)
		from #temp as t
		where #temp.id_programacion_personal_bouquetera = t.id_programacion_personal_bouquetera
		and #temp.id_detalle_labor = t.id_detalle_labor
	) as cantidad_personas_pistoleadas into #temp2
	from #temp
	group by id_programacion_personal_bouquetera,
	id_horario_apoyo_personal_bouquetera,
	cantidad_personas,
	cantidad_personas_programadas,	
	id_detalle_labor

	select 
	case
		when cantidad_personas_programadas < cantidad_personas_solicitadas then cantidad_personas_solicitadas - cantidad_personas_programadas
		else 0
	end as personas_por_programar,
	cantidad_personas_programadas - cantidad_personas_pistoleadas as personas_por_llegar into #temp3
	from #temp2

	select @subject1 = 'ARN001 Falta Programar - Llegar [' + convert(nvarchar,isnull(sum(personas_por_programar), 0)) + ' - ' + convert(nvarchar,isnull(sum(personas_por_llegar), 0)) + ']'
	from #temp3

	select @personas_por_programar = isnull(sum(personas_por_programar), 0),
	@personas_por_llegar = isnull(sum(personas_por_llegar), 0)
	from #temp3
	
	if(@personas_por_programar = 0 and @personas_por_llegar = 0)
	begin
		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @correo,
		@subject = @subject1,
		@body = '',
		@body_format = 'html'
	end
	else
	begin
		exec ReportServer2.dbo.AddEvent @EventType='TimedSubscription', @EventData='1367ce00-c449-43aa-a560-ed6a26417d11'

		waitfor delay '00:00:20';

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @correo,
		@subject = @subject1,
		@body = '',
		@body_format = 'html',
		@file_attachments = '\\Db4\C$\Web\Reportes\Personal_Bouquetera\Programacion_Personal_Bouquetera.pdf';

		exec xp_cmdshell 'del \\Db4\C$\Web\Reportes\Personal_Bouquetera\Programacion_Personal_Bouquetera.pdf' 
	end

	drop table #temp2
	drop table #temp3
end

drop table #temp
