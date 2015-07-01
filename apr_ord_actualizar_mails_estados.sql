set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/08/02
-- Description:	Crea los mails a los que se enviara notificacion en cada proceso de la confirmacion de las ordenes
-- =============================================

create PROCEDURE [dbo].[apr_ord_actualizar_mails_estados] 

@correo nvarchar(1024),
@id_correo_estado int,
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select id_correo_estado,
	nombre_estado,
	correo 
	from correo_estado
	order by id_correo_estado
end
else
if(@accion = 'actualizar')
begin
	update correo_estado
	set correo = @correo
	where correo_estado.id_correo_estado = @id_correo_estado
end