SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[proglab_editar_programacion_labores]

@idc_detalle_labor nvarchar(20),
@usuario_cobol nvarchar(20),
@descripcion nvarchar(512),
@fecha nvarchar(8),
@hora nvarchar(8),
@id_programacion_labor int,
@id_programacion_labor_persona int,
@idc_persona nvarchar(20),
@accion nvarchar(255)

AS

declare @id int,
@conteo int

if(@accion = 'consultar_programacion_labor')
begin
	select programacion_labor.id_programacion_labor,
	labor.idc_labor,
	detalle_labor.idc_detalle_labor,
	convert(nvarchar,programacion_labor.fecha,101) as fecha,
	convert(nvarchar,programacion_labor.fecha, 108) as hora,
	programacion_labor.descripcion,
	programacion_labor.usuario_cobol 
	from programacion_labor,
	labor,
	detalle_labor
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = programacion_labor.id_detalle_labor
	and convert(datetime, convert(nvarchar, programacion_labor.fecha, 101)) = convert(datetime, @fecha)
end
else
if(@accion = 'consultar_programacion_labor_persona')
begin
	select programacion_labor_persona.id_programacion_labor_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	persona.identificacion
	from programacion_labor,
	persona,
	programacion_labor_persona
	where programacion_labor.id_programacion_labor  = programacion_labor_persona.id_programacion_labor
	and programacion_labor_persona.id_persona = persona.id_persona
	and programacion_labor.id_programacion_labor = @id_programacion_labor
	order by nombre_persona,
	apellido_persona
end
else
if(@accion = 'insertar_programacion_labor')
begin
	insert into programacion_labor(id_detalle_labor, fecha, descripcion, se_pistolea, usuario_cobol)
	select detalle_labor.id_detalle_labor, (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)), @descripcion, 1, @usuario_cobol 
	from detalle_labor
	where ltrim(rtrim(detalle_labor.idc_detalle_labor)) = ltrim(rtrim(@idc_detalle_labor))

	set @id = scope_identity()

	select @id as id_programacion_labor
end
else
if(@accion = 'insertar_programacion_labor_persona')
begin
	insert into programacion_labor_persona (id_programacion_labor, id_persona)
	select @id_programacion_labor, persona.id_persona
	from persona
	where ltrim(rtrim(persona.idc_persona)) = ltrim(rtrim(@idc_persona))

	set @id = scope_identity()

	select @id as id_programacion_labor_persona
end
else
if(@accion = 'eliminar_programacion_labor_persona')
begin
	delete from programacion_labor_persona where id_programacion_labor_persona = @id_programacion_labor_persona
end
else
if(@accion = 'eliminar_programacion_labor')
begin
	select @conteo  = count(*)
	from programacion_labor_persona
	where programacion_labor_persona.id_programacion_labor = @id_programacion_labor

	if(@conteo = 0)
	begin
		delete from programacion_labor where id_programacion_labor = @id_programacion_labor

		select 1 as result
	end
	else
	begin
		select 0 as result
	end
end
else
if(@accion = 'actualizar_programacion_labor')
begin
	update programacion_labor
	set id_detalle_labor = detalle_labor.id_detalle_labor,
	fecha = (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)),
	descripcion = @descripcion,
	usuario_cobol = @usuario_cobol
	from detalle_labor
	where ltrim(rtrim(detalle_labor.idc_detalle_labor)) = ltrim(rtrim(@idc_detalle_labor))
	and programacion_labor.id_programacion_labor = @id_programacion_labor
end