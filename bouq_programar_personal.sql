set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/06/13
-- Description:	Maneja informacion de programacion de personal en la bouquetera
-- =============================================

alter PROCEDURE [dbo].[bouq_programar_personal] 

@accion nvarchar(50),
@id_detalle_labor int,
@id_programacion_personal_bouquetera int,
@id_persona int

as

if(@accion = 'consultar_programacion')
begin
	select programacion_personal_bouquetera.id_programacion_personal_bouquetera,
	programacion_personal_bouquetera.fecha,
	horario_apoyo_personal_bouquetera.hora_llegada
	from programacion_personal_bouquetera,
	horario_apoyo_personal_bouquetera
	where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	and programacion_personal_bouquetera.fecha > = convert(datetime, convert(nvarchar, getdate(), 101))
	group by programacion_personal_bouquetera.id_programacion_personal_bouquetera,
	programacion_personal_bouquetera.fecha,
	horario_apoyo_personal_bouquetera.hora_llegada
	order by programacion_personal_bouquetera.fecha,
	horario_apoyo_personal_bouquetera.hora_llegada
end
else
if(@accion = 'consultar_sublabores')
begin
	select detalle_labor.id_detalle_labor,
	detalle_labor.idc_detalle_labor + ' [' + detalle_labor.nombre_detalle_labor + ']' as nombre_detalle_labor,
	horario_apoyo_personal_bouquetera.cantidad_personas as cantidad_personas_solicitadas
	from programacion_personal_bouquetera,
	horario_apoyo_personal_bouquetera,
	detalle_labor
	where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
	and programacion_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	order by nombre_detalle_labor
end
else
if(@accion = 'consultar_personal_asignado')
begin
	select supervisor.id_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) + ' [' + supervisor.idc_supervisor + ']' as nombre_supervisor, 
	persona.id_persona,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.identificacion + ']' as nombre_persona
	from programacion_personal_bouquetera,
	detalle_programacion_personal_bouquetera,
	horario_apoyo_personal_bouquetera,
	detalle_labor,
	persona,
	supervisor
	where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	and supervisor.id_supervisor = detalle_programacion_personal_bouquetera.id_supervisor
	and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
	and persona.id_persona = detalle_programacion_personal_bouquetera.id_persona
	and horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = detalle_programacion_personal_bouquetera.id_programacion_personal_bouquetera
	and horario_apoyo_personal_bouquetera.id_detalle_labor = detalle_programacion_personal_bouquetera.id_detalle_labor
	and programacion_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = @id_detalle_labor
	order by nombre_supervisor,
	nombre_persona
end
else
if(@accion = 'consultar_personal_disponible')
begin
	select supervisor.id_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) + ' [' + supervisor.idc_supervisor + ']' as nombre_supervisor, 
	persona.id_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '[' + persona.identificacion + ']' as nombre_persona into #persona_disponible
	from persona,
	supervisor
	where persona.disponible = 1
	and supervisor.id_supervisor = persona.id_supervisor
	and exists
	(
		select * from historia_ingreso
		where historia_ingreso.id_persona = persona.id_persona
		and not exists
		(
			select * from historia_retiro
			where historia_ingreso.id_historia_ingreso = historia_retiro.id_historia_ingreso
		)
	)
	and not exists
	(
		select *
		from detalle_programacion_personal_bouquetera
		where detalle_programacion_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
		and detalle_programacion_personal_bouquetera.id_detalle_labor = @id_detalle_labor
		and persona.id_persona = detalle_programacion_personal_bouquetera.id_persona
	)

	select detalle_labor_persona.id_persona into #persona_registrada
	from detalle_labor_persona
	where convert(datetime,convert(nvarchar,detalle_labor_persona.fecha, 101)) = convert(datetime,convert(nvarchar, getdate()-401, 101))
	group by detalle_labor_persona.id_persona

	update #persona_disponible
	set nombre_persona = nombre_persona + ' *'
	from #persona_registrada
	where #persona_disponible.id_persona = #persona_registrada.id_persona

	select * 
	from #persona_disponible
	order by nombre_supervisor,
	nombre_persona

	drop table #persona_disponible
	drop table #persona_registrada
end
else
if(@accion = 'insertar_asignacion')
begin
	declare @personas_solicitadas int,
	@personas_asignadas int,
	@conteo int

	select @personas_solicitadas = horario_apoyo_personal_bouquetera.cantidad_personas
	from programacion_personal_bouquetera,
	horario_apoyo_personal_bouquetera,
	detalle_labor
	where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
	and programacion_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = @id_detalle_labor

	select @personas_asignadas = count(persona.id_persona)
	from programacion_personal_bouquetera,
	horario_apoyo_personal_bouquetera,
	detalle_labor,
	detalle_programacion_personal_bouquetera,
	persona
	where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
	and programacion_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = @id_detalle_labor
	and persona.id_persona = detalle_programacion_personal_bouquetera.id_persona
	and horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = detalle_programacion_personal_bouquetera.id_programacion_personal_bouquetera
	and horario_apoyo_personal_bouquetera.id_detalle_labor = detalle_programacion_personal_bouquetera.id_detalle_labor
	
	select @conteo = count(*)
	from detalle_programacion_personal_bouquetera
	where id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	and id_persona = @id_persona
	and id_detalle_labor = @id_detalle_labor
	
	if(@conteo > 0)
	begin
		select -1 as id_detalle_programacion_personal_bouquetera
	end
	else
	if(@conteo = 0)
	begin
		insert into detalle_programacion_personal_bouquetera (id_programacion_personal_bouquetera, id_persona, id_detalle_labor, id_supervisor)
		select @id_programacion_personal_bouquetera, 
		persona.id_persona, 
		@id_detalle_labor, 
		supervisor.id_supervisor
		from persona,
		supervisor
		where supervisor.id_supervisor = persona.id_supervisor
		and persona.id_persona = @id_persona

		if(@personas_solicitadas < @personas_asignadas)
		begin
			select -2 as id_detalle_programacion_personal_bouquetera
		end
		else
		begin
			select scope_identity() as id_detalle_programacion_personal_bouquetera
		end
	end
end
else
if(@accion = 'eliminar_asignacion')
begin
	delete from supervisor_actual
	where id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	and id_persona = @id_persona
	and id_detalle_labor = @id_detalle_labor
end