set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_funcion_detalle_labor]

@nombre_funcion nvarchar(255),
@idc_detalle_labor nvarchar(255),
@accion nvarchar(255),
@id_funcion_detalle_labor int,
@idc_persona nvarchar(255)

as

declare @conteo int

if(@accion = 'insertar_funcion_detalle_labor')
begin
	select @conteo = count(*)
	from funcion_detalle_labor,
	detalle_labor
	where detalle_labor.idc_detalle_labor = @idc_detalle_labor
	and detalle_labor.id_detalle_labor = funcion_detalle_labor.id_detalle_labor
	and funcion_detalle_labor.nombre_funcion = ltrim(rtrim(@nombre_funcion))

	if(@conteo = 0)
	begin
		insert into funcion_detalle_labor (id_detalle_labor, nombre_funcion)
		select detalle_labor.id_detalle_labor,
		@nombre_funcion 
		from detalle_labor
		where detalle_labor.idc_detalle_labor = @idc_detalle_labor
	end
end
else
if(@accion = 'consultar_funcion_detalle_labor')
begin
	select labor.idc_labor,
	labor.nombre_labor,
	detalle_labor.idc_detalle_labor,
	detalle_labor.nombre_detalle_labor,
	funcion_detalle_labor.id_funcion_detalle_labor,	
	funcion_detalle_labor.nombre_funcion 
	from funcion_detalle_labor,
	detalle_labor,
	labor
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = funcion_detalle_labor.id_detalle_labor
	and ltrim(rtrim(detalle_labor.idc_detalle_labor)) like
	case
		when ltrim(rtrim(@idc_detalle_labor)) = '' then '%%'
		else ltrim(rtrim(@idc_detalle_labor))
	end
	order by labor.idc_labor,
	detalle_labor.idc_detalle_labor,
	funcion_detalle_labor.nombre_funcion
end
else
if(@accion = 'asignar_persona')
begin
	insert into asignacion_funcion (id_persona, id_funcion_detalle_labor)
	select persona.id_persona,
	@id_funcion_detalle_labor
	from persona
	where persona.idc_persona = @idc_persona
end
else
if(@accion = 'consultar_asignaciones')
begin

	select max(id_asignacion_funcion) as id_asignacion_funcion into #asignacion_funcion
	from asignacion_funcion
	group by id_persona

	select labor.idc_labor,
	labor.nombre_labor,
	detalle_labor.idc_detalle_labor,
	detalle_labor.nombre_detalle_labor,
	funcion_detalle_labor.id_funcion_detalle_labor,	
	funcion_detalle_labor.nombre_funcion,
	persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	persona.identificacion,
	asignacion_funcion.fecha_asignacion
	from funcion_detalle_labor,
	detalle_labor,
	labor,
	asignacion_funcion,
	persona
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = funcion_detalle_labor.id_detalle_labor
	and funcion_detalle_labor.id_funcion_detalle_labor = asignacion_funcion.id_funcion_detalle_labor
	and persona.id_persona = asignacion_funcion.id_persona
	and detalle_labor.idc_detalle_labor like
	case
		when @idc_detalle_labor = '' then '%%'
		else @idc_detalle_labor
	end
	and asignacion_funcion.id_asignacion_funcion in
	(
		select *
		from #asignacion_funcion
		where asignacion_funcion.id_asignacion_funcion = #asignacion_funcion.id_asignacion_funcion
	)
	and persona.disponible = 1
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
	order by labor.idc_labor,
	detalle_labor.idc_detalle_labor,
	funcion_detalle_labor.nombre_funcion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido))

	drop table #asignacion_funcion
end
else
if(@accion = 'desasignar_persona')
begin
	delete from asignacion_funcion 
	where id_persona = (select id_persona from persona where idc_persona = @idc_persona)
end