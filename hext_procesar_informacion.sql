set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[hext_procesar_informacion]

@id_salida_general int,
@id_cuenta_interna int,
@id_grupo int,
@accion nvarchar(255)

AS
if(@accion = 'procesar_salidas')
begin
	insert into salida_general_procesada (id_salida_general, nombre_cuenta_interna, id_cuenta_interna, fecha_proceso, id_tipo_proceso, id_grupo)
	select @id_salida_general, ci.nombre, @id_cuenta_interna, getdate(), tipo_proceso.id_tipo_proceso, 0
	from bd_cultivo.dbo.cuenta_interna as ci, tipo_proceso
	where ci.id_cuenta_interna = @id_cuenta_interna
	and tipo_proceso.nombre_tipo_proceso = 'asignar_salidas'
end
else
if(@accion = 'procesar_horas')
begin
	insert into salida_general_procesada (id_salida_general, nombre_cuenta_interna, id_cuenta_interna, fecha_proceso, id_tipo_proceso, id_grupo)
	select @id_salida_general, ci.nombre, @id_cuenta_interna, getdate(), tipo_proceso.id_tipo_proceso, @id_grupo
	from bd_cultivo.dbo.cuenta_interna as ci, tipo_proceso
	where ci.id_cuenta_interna = @id_cuenta_interna
	and tipo_proceso.nombre_tipo_proceso = 'modificar_horas'
end
else
if(@accion = 'procesar_dia')
begin
	insert into salida_general_procesada (id_salida_general, nombre_cuenta_interna, id_cuenta_interna, fecha_proceso, id_tipo_proceso, id_grupo)
	select @id_salida_general, ci.nombre, @id_cuenta_interna, getdate(), tipo_proceso.id_tipo_proceso, 0
	from bd_cultivo.dbo.cuenta_interna as ci, tipo_proceso
	where ci.id_cuenta_interna = @id_cuenta_interna
	and tipo_proceso.nombre_tipo_proceso = 'procesar_dia'

	declare @fecha_salida nvarchar(255)
	select @fecha_salida = fecha_hora from salida_general where id_salida_general = @id_salida_general
	set @fecha_salida = convert(nvarchar, @fecha_salida, 101)

	insert into salida_general_historico_reporte_horas_laboradas(id_grupo, nombre_grupo, id_empleado, nombre_empleado, identificacion, hora_entrada, hora_salida, horas_laboradas, id_salida_general)
	EXEC [dbo].[hext_generar_reportes]
	@accion = N'generar_datos',
	@fecha = @fecha_salida,
	@@control = null
end
