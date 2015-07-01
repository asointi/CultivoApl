set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/23
-- Description:	maneja todo lo relacionado con los mail a los cuales se les enviará notificaciones en los diferentes estados
-- =============================================

create PROCEDURE [dbo].[wbl_editar_notifica_proceso_instalacion] 

@id_estado_finca int, 
@accion nvarchar(255),
@id_notifica_proceso_instalacion int,
@direccion_correo nvarchar(1024),
@id_distribuidora int,
@cuerpo_mensaje nvarchar(4000)

as

declare @conteo int

if (@accion = 'insertar')
begin
	insert into notifica_proceso_instalacion (id_estado_finca, direccion_correo, id_distribuidora, cuerpo_mensaje)
	values (@id_estado_finca, @direccion_correo, @id_distribuidora, @cuerpo_mensaje)
end
else
if(@accion = 'eliminar')
begin
	delete from notifica_proceso_instalacion
	where id_notifica_proceso_instalacion = @id_notifica_proceso_instalacion
end
else
if(@accion = 'modificar')
begin
	select @conteo = count(*)
	from notifica_proceso_instalacion
	where notifica_proceso_instalacion.id_notifica_proceso_instalacion = @id_notifica_proceso_instalacion
	and notifica_proceso_instalacion.direccion_correo = @direccion_correo
	and notifica_proceso_instalacion.cuerpo_mensaje = @cuerpo_mensaje

	if(@conteo = 0)
	begin
		update notifica_proceso_instalacion
		set direccion_correo = @direccion_correo,
		cuerpo_mensaje = @cuerpo_mensaje
		where notifica_proceso_instalacion.id_notifica_proceso_instalacion = @id_notifica_proceso_instalacion
	end
end
else
if(@accion = 'consultar')
begin
	select estado_finca.id_estado_finca,
	estado_finca.nombre_estado_finca,
	notifica_proceso_instalacion.id_notifica_proceso_instalacion,
	notifica_proceso_instalacion.direccion_correo,
	notifica_proceso_instalacion.cuerpo_mensaje
	from estado_finca,
	notifica_proceso_instalacion,
	distribuidora
	where estado_finca.id_estado_finca = notifica_proceso_instalacion.id_estado_finca
	and distribuidora.id_distribuidora = notifica_proceso_instalacion.id_distribuidora
	and estado_finca.id_estado_finca = @id_estado_finca
	and distribuidora.id_distribuidora = @id_distribuidora
end