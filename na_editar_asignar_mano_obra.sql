set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_asignar_mano_obra]

@accion nvarchar(255),
@id_solicitud_mano_obra int,
@fecha nvarchar(20),
@hora_inicial nvarchar(20), 
@hora_final nvarchar(20), 
@usuario_cobol nvarchar(50)

AS

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
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = solicitud_mano_obra.id_detalle_labor
	and detalle_labor.disponible = 1
	and solicitud_mano_obra.id_solicitud_mano_obra < = smo.id_solicitud_mano_obra
	and solicitud_mano_obra.id_solicitud_mano_obra_padre = smo.id_solicitud_mano_obra_padre
	and not exists
	(
		select *
		from finalizar_solicitud_mano_obra
		where solicitud_mano_obra.id_solicitud_mano_obra = finalizar_solicitud_mano_obra.id_solicitud_mano_obra
	)
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
if(@accion = 'asignar_solicitud')
begin
	begin transaction
		insert into asignar_mano_obra (id_solicitud_mano_obra, hora_inicial, hora_final, usuario_cobol)
		values (@id_solicitud_mano_obra, dbo.concatenar_fecha_hora_COBOL (@fecha, @hora_inicial), dbo.concatenar_fecha_hora_COBOL (@fecha, @hora_final), @usuario_cobol)
	commit transaction

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
