set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/23
-- Description:	maneja todo lo relacionado con los archivos que seran enviados automaticamente por mail en cada estado de la instalacion
-- =============================================

create PROCEDURE [dbo].[wbl_editar_archivo_proceso_instalacion] 

@id_estado_finca int, 
@archivo image,
@accion nvarchar(255),
@id_archivo_proceso_instalacion int,
@nombre_archivo nvarchar(255),
@id_distribuidora int

as

declare @conteo int

if (@accion = 'insertar')
begin
	insert into archivo_proceso_instalacion (id_estado_finca, archivo, nombre_archivo, id_distribuidora)
	values (@id_estado_finca, @archivo, @nombre_archivo, @id_distribuidora)
end
else
if(@accion = 'eliminar')
begin
	delete from archivo_proceso_instalacion
	where id_archivo_proceso_instalacion = @id_archivo_proceso_instalacion
end
else
if(@accion = 'modificar')
begin
	if(dbo.compara_imagenes(@archivo, datalength(@archivo)) = dbo.compara_imagenes(convert(image, 0x01), datalength(convert(image, 0x01))))
	begin
		update archivo_proceso_instalacion
		set	nombre_archivo = @nombre_archivo
		where archivo_proceso_instalacion.id_archivo_proceso_instalacion = @id_archivo_proceso_instalacion
	end
	else
	begin
		select @conteo = count(*)
		from archivo_proceso_instalacion
		where dbo.compara_imagenes(archivo, datalength(archivo)) = dbo.compara_imagenes(@archivo, datalength(@archivo))
		and archivo_proceso_instalacion.id_archivo_proceso_instalacion = @id_archivo_proceso_instalacion
		and archivo_proceso_instalacion.nombre_archivo = @nombre_archivo

		if(@conteo = 0)
		begin
			update archivo_proceso_instalacion
			set archivo = @archivo,
			nombre_archivo = @nombre_archivo
			where archivo_proceso_instalacion.id_archivo_proceso_instalacion = @id_archivo_proceso_instalacion
		end
	end
end
else
if(@accion = 'consultar')
begin
	select estado_finca.id_estado_finca,
	estado_finca.nombre_estado_finca,
	archivo_proceso_instalacion.id_archivo_proceso_instalacion,
	archivo_proceso_instalacion.archivo,
	archivo_proceso_instalacion.nombre_archivo
	from estado_finca,
	archivo_proceso_instalacion,
	distribuidora
	where estado_finca.id_estado_finca = archivo_proceso_instalacion.id_estado_finca
	and distribuidora.id_distribuidora = archivo_proceso_instalacion.id_distribuidora
	and estado_finca.id_estado_finca = @id_estado_finca
	and distribuidora.id_distribuidora = @id_distribuidora
end