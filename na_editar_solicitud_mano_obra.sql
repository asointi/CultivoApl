set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_solicitud_mano_obra]

@accion nvarchar(255),
@id_cuenta_interna int,
@id_solicitud_mano_obra int,
@id_detalle_labor int, 
@fecha_programada datetime, 
@unidades_totales int, 
@descripcion nvarchar(512)

AS

declare @id_solicitud_mano_obra_aux int,
@id_solicitud_mano_obra_padre int

if(@accion = 'consultar')
begin
	select labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)) as nombre_labor,
	detalle_labor.idc_detalle_labor,
	ltrim(rtrim(detalle_labor.nombre_detalle_labor)) as nombre_detalle_labor,
	unidad_medida.nombre_unidad_medida,
	solicitud_mano_obra.id_solicitud_mano_obra,
	solicitud_mano_obra.fecha_transaccion,
	solicitud_mano_obra.fecha_programada,
	solicitud_mano_obra.unidades_totales,
	solicitud_mano_obra.descripcion as descripcion_solicitud
	from solicitud_mano_obra,
	solicitud_mano_obra as smo,
	labor,
	detalle_labor left join unidad_medida on unidad_medida.id_unidad_medida = detalle_labor.id_unidad_medida
	where solicitud_mano_obra.id_cuenta_interna = @id_cuenta_interna
	and labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = solicitud_mano_obra.id_detalle_labor
	and detalle_labor.disponible = 1
	and solicitud_mano_obra.id_solicitud_mano_obra < = smo.id_solicitud_mano_obra
	and solicitud_mano_obra.id_solicitud_mano_obra_padre = smo.id_solicitud_mano_obra_padre
	group by labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)),
	detalle_labor.idc_detalle_labor,
	ltrim(rtrim(detalle_labor.nombre_detalle_labor)),
	unidad_medida.nombre_unidad_medida,
	solicitud_mano_obra.id_solicitud_mano_obra,
	solicitud_mano_obra.fecha_transaccion,
	solicitud_mano_obra.fecha_programada,
	solicitud_mano_obra.unidades_totales,
	solicitud_mano_obra.descripcion
	having
	solicitud_mano_obra.id_solicitud_mano_obra = max(smo.id_solicitud_mano_obra)
	order by solicitud_mano_obra.fecha_transaccion desc
end
else
if(@accion = 'consultar_finalizacion')
begin
	select solicitud_mano_obra.fecha_programada,
	solicitud_mano_obra.unidades_totales,
	solicitud_mano_obra.descripcion as descripcion_solicitud,
	tipo_finalizacion.nombre_tipo_finalizacion,
	finalizar_solicitud_mano_obra.fecha_transaccion as fecha_transaccion_finalizacion,
	finalizar_solicitud_mano_obra.observacion as observacion_finalizacion,
	finalizar_solicitud_mano_obra.usuario_cobol as usuario_cobol_finalizacion
	from solicitud_mano_obra,
	finalizar_solicitud_mano_obra,
	tipo_finalizacion
	where solicitud_mano_obra.id_solicitud_mano_obra = @id_solicitud_mano_obra
	and solicitud_mano_obra.id_solicitud_mano_obra = finalizar_solicitud_mano_obra.id_solicitud_mano_obra
	and finalizar_solicitud_mano_obra.id_tipo_finalizacion = tipo_finalizacion.id_tipo_finalizacion
end
else
if(@accion = 'consultar_personal_asignado')
begin
	select asignar_mano_obra.hora_inicial,
	asignar_mano_obra.hora_final,
	asignar_mano_obra.usuario_cobol as usuario_cobol_asignacion,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona
	from solicitud_mano_obra, 
	asignar_mano_obra,
	persona_asignada,
	persona
	where solicitud_mano_obra.id_solicitud_mano_obra = asignar_mano_obra.id_solicitud_mano_obra
	and asignar_mano_obra.id_solicitud_mano_obra = persona_asignada.id_solicitud_mano_obra
	and persona.id_persona = persona_asignada.id_persona
	and solicitud_mano_obra.id_solicitud_mano_obra = @id_solicitud_mano_obra 
end
else
if(@accion = 'insertar_solicitud')
begin
	insert into solicitud_mano_obra (id_detalle_labor, id_cuenta_interna, fecha_programada, unidades_totales, descripcion)
	values (@id_detalle_labor, @id_cuenta_interna, @fecha_programada, @unidades_totales, @descripcion)

	set @id_solicitud_mano_obra_aux = scope_identity()

	update solicitud_mano_obra
	set id_solicitud_mano_obra_padre = @id_solicitud_mano_obra_aux
	where id_solicitud_mano_obra = @id_solicitud_mano_obra_aux
end
else
if(@accion = 'insertar_reapertura_solicitud')
begin
	select @id_solicitud_mano_obra_padre = id_solicitud_mano_obra_padre
	from solicitud_mano_obra
	where solicitud_mano_obra.id_solicitud_mano_obra = @id_solicitud_mano_obra

	insert into solicitud_mano_obra (id_detalle_labor, id_solicitud_mano_obra_padre, id_cuenta_interna, fecha_programada, unidades_totales, descripcion)
	values (@id_detalle_labor, @id_solicitud_mano_obra_padre, @id_cuenta_interna, @fecha_programada, @unidades_totales, @descripcion)
end