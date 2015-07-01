set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/23
-- Description:	maneja todo lo relacionado con los mail a los cuales se les enviará notificaciones en los diferentes estados de reportes de novedades
-- =============================================

create PROCEDURE [dbo].[wbl_editar_notifica_reporte_finca] 

@id_estado_reporte_finca int, 
@accion nvarchar(255),
@id_notifica_reporte_finca int,
@direccion_correo nvarchar(1024),
@id_distribuidora int,
@cuerpo_mensaje nvarchar(4000)

as

declare @conteo int

if (@accion = 'insertar')
begin
	insert into notifica_reporte_finca (id_estado_reporte_finca, direccion_correo, id_distribuidora, cuerpo_mensaje)
	values (@id_estado_reporte_finca, @direccion_correo, @id_distribuidora, @cuerpo_mensaje)
end
else
if(@accion = 'eliminar')
begin
	delete from notifica_reporte_finca
	where id_notifica_reporte_finca = @id_notifica_reporte_finca
end
else
if(@accion = 'modificar')
begin
	select @conteo = count(*)
	from notifica_reporte_finca
	where notifica_reporte_finca.id_notifica_reporte_finca = @id_notifica_reporte_finca
	and notifica_reporte_finca.direccion_correo = @direccion_correo
	and notifica_reporte_finca.cuerpo_mensaje = @cuerpo_mensaje
	
	if(@conteo = 0)
	begin
		update notifica_reporte_finca
		set direccion_correo = @direccion_correo,
		cuerpo_mensaje = @cuerpo_mensaje
		where notifica_reporte_finca.id_notifica_reporte_finca = @id_notifica_reporte_finca
	end
end
else
if(@accion = 'consultar')
begin
	select estado_reporte_finca.id_estado_reporte_finca,
	estado_reporte_finca.nombre_estado_reporte_finca,
	notifica_reporte_finca.id_notifica_reporte_finca,
	notifica_reporte_finca.direccion_correo,
	notifica_reporte_finca.cuerpo_mensaje
	from estado_reporte_finca,
	notifica_reporte_finca,
	distribuidora
	where estado_reporte_finca.id_estado_reporte_finca = notifica_reporte_finca.id_estado_reporte_finca
	and distribuidora.id_distribuidora = notifica_reporte_finca.id_distribuidora
	and estado_reporte_finca.id_estado_reporte_finca = @id_estado_reporte_finca
	and distribuidora.id_distribuidora = @id_distribuidora
end