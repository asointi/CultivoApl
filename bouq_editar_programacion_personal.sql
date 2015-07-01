set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/06/13
-- Description:	Maneja informacion de programacion de personal en la bouquetera
-- =============================================

alter PROCEDURE [dbo].[bouq_editar_programacion_personal] 

@accion nvarchar(50),
@fecha nvarchar(8),
@usuario_cobol nvarchar(50),
@unidades_despacho int,
@unidades_adicion int,
@unidades_adelantadas int,
@unidades_por_adelantar int,
@cantidad_personas_bonchando int,
@cantidad_personas_otras_labores int,
@rendimiento_por_hora int,
@cantidad_personas int,
@hora_llegada nvarchar(8),
@idc_detalle_labor nvarchar(15),
@hora_entrega_despacho nvarchar(8),
@cantidad_personas_plan_bouqueteras_base int,
@cantidad_personas_plan_bouqueteras_adicional int,
@cantidad_personas_plan_total_personas int 

as

declare @conteo int,
@id_programacion_personal_bouquetera int,
@id_detalle_labor int

select @id_programacion_personal_bouquetera = id_programacion_personal_bouquetera
from programacion_personal_bouquetera
where fecha = convert(datetime, @fecha)

select @id_detalle_labor = detalle_labor.id_detalle_labor
from detalle_labor
where detalle_labor.idc_detalle_labor = @idc_detalle_labor

if(@accion = 'insertar_programacion_personal')
begin
	declare @horario_asignado int

	select @conteo = count(*)
	from programacion_personal_bouquetera
	where programacion_personal_bouquetera.fecha = convert(datetime, @fecha)

	select @horario_asignado = count(*)
	from programacion_personal_bouquetera,
	horario_apoyo_personal_bouquetera,
	detalle_labor
	where programacion_personal_bouquetera.fecha = convert(datetime,@fecha)
	and programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor

	if(@conteo = 0)
	begin
		insert into programacion_personal_bouquetera (fecha, usuario_cobol, unidades_despacho, unidades_adicion, unidades_adelantadas, unidades_por_adelantar, cantidad_personas_bonchando, cantidad_personas_otras_labores, rendimiento_por_hora, hora_entrega_despacho, cantidad_personas_plan_bouqueteras_base, cantidad_personas_plan_bouqueteras_adicional, cantidad_personas_plan_total_personas)
		values (convert(datetime, @fecha), @usuario_cobol, @unidades_despacho, @unidades_adicion, @unidades_adelantadas, @unidades_por_adelantar, @cantidad_personas_bonchando, @cantidad_personas_otras_labores, @rendimiento_por_hora, dbo.concatenar_fecha_hora_COBOL(@fecha, @hora_entrega_despacho), @cantidad_personas_plan_bouqueteras_base, @cantidad_personas_plan_bouqueteras_adicional, @cantidad_personas_plan_total_personas)

		select scope_identity() as id_programacion_personal_bouquetera
	end
	else
	if(@conteo = 1 and @horario_asignado = 0)
	begin
		select @id_programacion_personal_bouquetera = programacion_personal_bouquetera.id_programacion_personal_bouquetera
		from programacion_personal_bouquetera
		where fecha = convert(datetime, @fecha)

		update programacion_personal_bouquetera
		set fecha_transaccion = getdate(),
		usuario_cobol = @usuario_cobol,
		unidades_despacho = @unidades_despacho,
		unidades_adicion = @unidades_adicion,
		unidades_adelantadas = @unidades_adelantadas,
		unidades_por_adelantar = @unidades_por_adelantar,
		cantidad_personas_bonchando = @cantidad_personas_bonchando,
		cantidad_personas_otras_labores = @cantidad_personas_otras_labores,
		rendimiento_por_hora = @rendimiento_por_hora,
		hora_entrega_despacho = dbo.concatenar_fecha_hora_COBOL(@fecha, @hora_entrega_despacho),
		cantidad_personas_plan_bouqueteras_base = @cantidad_personas_plan_bouqueteras_base,
		cantidad_personas_plan_bouqueteras_adicional = @cantidad_personas_plan_bouqueteras_adicional,
		cantidad_personas_plan_total_personas = @cantidad_personas_plan_total_personas
		where id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera

		select @id_programacion_personal_bouquetera as id_programacion_personal_bouquetera
	end
	else
	begin
		select -1 as id_programacion_personal_bouquetera
	end
end
else
if(@accion = 'insertar_horario_programacion_personal')
begin
	declare @personal_asignado int

	select @conteo = count(*)
	from horario_apoyo_personal_bouquetera,
	detalle_labor
	where horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
	and detalle_labor.id_detalle_labor = @id_detalle_labor

	select @personal_asignado = count(*)
	from horario_apoyo_personal_bouquetera,
	detalle_programacion_personal_bouquetera,
	detalle_labor
	where horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = detalle_programacion_personal_bouquetera.id_programacion_personal_bouquetera
	and horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
	and detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
	and detalle_labor.id_detalle_labor = @id_detalle_labor

	if(@conteo = 0)
	begin
		insert into horario_apoyo_personal_bouquetera (id_programacion_personal_bouquetera, cantidad_personas, hora_llegada, usuario_cobol, id_detalle_labor)
		values (@id_programacion_personal_bouquetera, @cantidad_personas, dbo.concatenar_fecha_hora_COBOL(@fecha, @hora_llegada), @usuario_cobol, @id_detalle_labor)

		select scope_identity() as id_horario_apoyo_personal_bouquetera
	end
	else
	if(@conteo = 1 and @personal_asignado = 0)
	begin
		update horario_apoyo_personal_bouquetera
		set cantidad_personas = @cantidad_personas,
		hora_llegada = dbo.concatenar_fecha_hora_COBOL(@fecha, @hora_llegada),
		fecha_transaccion = getdate(),
		usuario_cobol = @usuario_cobol
		where horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera = @id_programacion_personal_bouquetera
		and horario_apoyo_personal_bouquetera.id_detalle_labor = @id_detalle_labor

		select 1 as id_horario_apoyo_personal_bouquetera
	end
	else
	begin
		select -1 as id_horario_apoyo_personal_bouquetera
	end
end
else
if(@accion = 'consultar')
begin
	select programacion_personal_bouquetera.id_programacion_personal_bouquetera,
	programacion_personal_bouquetera.fecha,
	convert(datetime,convert(nvarchar, programacion_personal_bouquetera.fecha_transaccion, 101)) as fecha_transaccion,
	convert(nvarchar, programacion_personal_bouquetera.fecha_transaccion, 108) as hora_transaccion,
	programacion_personal_bouquetera.usuario_cobol,
	programacion_personal_bouquetera.unidades_despacho,
	programacion_personal_bouquetera.unidades_adicion,
	programacion_personal_bouquetera.unidades_adelantadas,
	programacion_personal_bouquetera.unidades_por_adelantar,
	programacion_personal_bouquetera.cantidad_personas_bonchando,
	programacion_personal_bouquetera.cantidad_personas_otras_labores,
	programacion_personal_bouquetera.cantidad_personas_plan_bouqueteras_base,
	programacion_personal_bouquetera.cantidad_personas_plan_bouqueteras_adicional,
	programacion_personal_bouquetera.cantidad_personas_plan_total_personas, 
	programacion_personal_bouquetera.rendimiento_por_hora,
	isnull(convert(nvarchar, programacion_personal_bouquetera.hora_entrega_despacho, 108), '') as hora_entrega_despacho,
	isnull(horario_apoyo_personal_bouquetera.id_horario_apoyo_personal_bouquetera, 0) as id_horario_apoyo_personal_bouquetera,
	isnull(horario_apoyo_personal_bouquetera.cantidad_personas, 0) as cantidad_personas,
	isnull(convert(nvarchar, horario_apoyo_personal_bouquetera.hora_llegada, 108), '') as hora_llegada,
	isnull(detalle_labor.idc_detalle_labor, '') as idc_detalle_labor,
	isnull(detalle_labor.nombre_detalle_labor, '') as nombre_detalle_labor
	from programacion_personal_bouquetera left join horario_apoyo_personal_bouquetera on programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	left join detalle_labor on detalle_labor.id_detalle_labor = horario_apoyo_personal_bouquetera.id_detalle_labor
	where programacion_personal_bouquetera.fecha = convert(datetime, @fecha)
	order by programacion_personal_bouquetera.fecha,
	horario_apoyo_personal_bouquetera.hora_llegada
end
else
if(@accion = 'consultar_programacion_personal_bouquetera')
begin
	select count(*) as cantidad
	from programacion_personal_bouquetera,
	horario_apoyo_personal_bouquetera
	where programacion_personal_bouquetera.id_programacion_personal_bouquetera = horario_apoyo_personal_bouquetera.id_programacion_personal_bouquetera
	and programacion_personal_bouquetera.fecha = convert(datetime, @fecha)
end