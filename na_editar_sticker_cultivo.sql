set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/25
-- Description:	Maneja informacion de los stickres de los Bouquets en el Cultivo
-- =============================================

alter PROCEDURE [dbo].[na_editar_sticker_cultivo] 

@accion nvarchar(255),
@nombre_sticker nvarchar(255),
@id_sticker int,
@disponible bit

as

declare @conteo int

if(@accion = 'consultar')
begin
	select id_sticker,
	nombre_sticker,
	disponible
	from sticker
	order by nombre_sticker
end
else
if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from sticker
	where nombre_sticker = @nombre_sticker

	if(@conteo = 0)
	begin
		insert into sticker (nombre_sticker)
		values (@nombre_sticker)

		select scope_identity() as id_sticker
	end
	else
	begin
		select -1 as id_sticker
	end
end
else
if(@accion = 'actualizar')
begin
	select @conteo = count(*)
	from sticker
	where nombre_sticker = @nombre_sticker
	and id_sticker <> @id_sticker 

	if(@conteo = 0)
	begin
		update sticker
		set nombre_sticker = @nombre_sticker,
		disponible = @disponible
		where id_sticker = @id_sticker

		select @id_sticker as id_sticker
	end
	else
	begin
		select -1 as id_sticker
	end
end