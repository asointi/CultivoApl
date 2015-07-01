set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_persona_asignada]

@accion nvarchar(255),
@id_solicitud_mano_obra int,
@id_persona int,
@id_asignar_mano_obra int

AS

if(@accion = 'consultar_asignacion')
begin
	select labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)) as nombre_labor,
	detalle_labor.idc_detalle_labor,
	ltrim(rtrim(detalle_labor.nombre_detalle_labor)) as nombre_detalle_labor,
	unidad_medida.nombre_unidad_medida,
	solicitud_mano_obra.id_solicitud_mano_obra,
	solicitud_mano_obra.fecha_transaccion as fecha_transaccion_solicitud,
	solicitud_mano_obra.fecha_programada,
	solicitud_mano_obra.unidades_totales,
	solicitud_mano_obra.descripcion as descripcion_solicitud,
	asignar_mano_obra.id_asignar_mano_obra,
	convert(nvarchar, asignar_mano_obra.hora_inicial, 101) as fecha_inicial_asignacion,	
	convert(nvarchar, asignar_mano_obra.hora_inicial, 108) as hora_inicial_asignacion,	
	convert(nvarchar, asignar_mano_obra.hora_final, 101) as fecha_final_asignacion,	
	convert(nvarchar, asignar_mano_obra.hora_final, 108) as hora_final_asignacion,	
	asignar_mano_obra.fecha_transaccion as fecha_transaccion_asignacion,
	asignar_mano_obra.usuario_cobol as usuario_cobol_asignacion
	from solicitud_mano_obra,
	asignar_mano_obra,
	labor,
	detalle_labor left join unidad_medida on unidad_medida.id_unidad_medida = detalle_labor.id_unidad_medida
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = solicitud_mano_obra.id_detalle_labor
	and detalle_labor.disponible = 1
	and solicitud_mano_obra.id_solicitud_mano_obra = asignar_mano_obra.id_solicitud_mano_obra
	and solicitud_mano_obra.id_solicitud_mano_obra = @id_solicitud_mano_obra
end
else
if(@accion = 'insertar_persona_asignada')
begin
	begin try
		insert into persona_asignada (id_asignar_mano_obra, id_persona)
		values (@id_asignar_mano_obra, @id_persona)

		select 1 as resultado
	end try
	begin catch
		select -1 as resultado
	end catch
end
else
if(@accion = 'eliminar_persona_asignada')
begin
	delete from persona_asignada 
	where id_asignar_mano_obra = @id_asignar_mano_obra
	and id_persona = @id_persona
end
else
if(@accion = 'consultar_persona_asignada')
begin
	select asignar_mano_obra.id_asignar_mano_obra,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	persona.idc_persona,
	persona.identificacion
	from persona, 
	persona_asignada,
	asignar_mano_obra,
	solicitud_mano_obra
	where persona.id_persona = persona_asignada.id_persona
	and solicitud_mano_obra.id_solicitud_mano_obra = asignar_mano_obra.id_solicitud_mano_obra
	and asignar_mano_obra.id_asignar_mano_obra = persona_asignada.id_asignar_mano_obra
	and asignar_mano_obra.id_asignar_mano_obra = @id_asignar_mano_obra
	order by nombre_persona,
	apellido_persona
end
else
if(@accion = 'consultar_personal_libre')
begin
	declare @hora_inicial_asignacion datetime, 
	@hora_final_asignacion datetime,
	@id int,
	@conteo int,
	@id_persona1 int,
	@id_persona_aux int,
	@fecha_aux datetime

	select @hora_inicial_asignacion = hora_inicial, 
	@hora_final_asignacion = hora_final
	from asignar_mano_obra
	where id_asignar_mano_obra = @id_asignar_mano_obra

	select identity(int, 1,1)as id,
	persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	@hora_inicial_asignacion as hora_inicial_asignacion,
	persona_asignada.hora_inicial as hora_inicial_persona,
	datediff(mi, @hora_inicial_asignacion, persona_asignada.hora_inicial) as diferencia_inicial,
	@hora_final_asignacion as hora_final_asignacion,
	persona_asignada.hora_final as hora_final_persona into #minutos_disponibles
	from asignar_mano_obra,
	persona_asignada,
	persona
	where asignar_mano_obra.id_asignar_mano_obra = persona_asignada.id_asignar_mano_obra
	and persona.id_persona = persona_asignada.id_persona
	and 
	(
		asignar_mano_obra.hora_inicial between
		@hora_inicial_asignacion and @hora_final_asignacion
		or
		asignar_mano_obra.hora_final between
		@hora_inicial_asignacion and @hora_final_asignacion
	)
	order by persona.id_persona,
	persona_asignada.hora_inicial

	alter table #minutos_disponibles
	add diferencia_final int

	update #minutos_disponibles
	set diferencia_inicial = null
	where id not in
	(
		select min(id)
		from #minutos_disponibles
		group by id_persona
	)

	select @id = max(id) from #minutos_disponibles
	set @conteo = 1

	while(@conteo < @id)
	begin
		select @id_persona1 = id_persona from #minutos_disponibles where id = @conteo
		select @id_persona_aux = id_persona from #minutos_disponibles where id = @conteo + 1

		select @fecha_aux = hora_inicial_persona 
		from #minutos_disponibles where id = @conteo + 1 
		and @id_persona1 = @id_persona_aux

		update #minutos_disponibles
		set diferencia_final = datediff(mi, hora_final_persona, @fecha_aux)
		where id = @conteo

		set @conteo = @conteo + 1
	end

	update #minutos_disponibles
	set diferencia_final = datediff(mi, hora_final_persona, hora_final_asignacion)
	where diferencia_final is null

	insert into #minutos_disponibles (id_persona, idc_persona, identificacion, nombre, apellido, hora_inicial_asignacion, hora_inicial_persona, diferencia_inicial, hora_final_asignacion, hora_final_persona, diferencia_final)
	select persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	@hora_inicial_asignacion,
	0,
	datediff(mi, @hora_inicial_asignacion, @hora_final_asignacion),
	@hora_final_asignacion,
	0,
	0
	from persona
	where disponible = 1
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
		from #minutos_disponibles
		where persona.id_persona = #minutos_disponibles.id_persona
	)

	select id_persona,
	idc_persona,
	identificacion,
	nombre,
	apellido,
	convert(nvarchar,hora_inicial_asignacion, 101) as fecha,
	convert(nvarchar,hora_inicial_asignacion, 108) as hora_inicial,
	convert(nvarchar,dateadd(mi, diferencia_inicial, hora_inicial_asignacion), 108) as hora_final
	from #minutos_disponibles
	where diferencia_inicial > 0

	union all

	select id_persona,
	idc_persona,
	identificacion,
	nombre,
	apellido,
	convert(nvarchar,hora_final_persona, 101),
	convert(nvarchar,hora_final_persona, 108),
	convert(nvarchar,dateadd(mi, diferencia_final, hora_final_persona), 108)
	from #minutos_disponibles
	where diferencia_final > 0
	order by nombre,
	apellido,
	hora_inicial

	drop table #minutos_disponibles
end