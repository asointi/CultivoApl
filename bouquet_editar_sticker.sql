set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/22
-- Description:	Maneja informacion de los stickers de las versiones de los Bouquets
-- =============================================

alter PROCEDURE [dbo].[bouquet_editar_sticker] 

@accion nvarchar(255),
@id_sticker int,
@id_detalle_version_bouquet int,
@id_sticker_bouquet int

as

if(@accion = 'consultar')
begin
	select id_sticker,
	nombre_sticker 
	from sticker
	where disponible = 1
	order by nombre_sticker
end
else
if(@accion = 'insertar_asignacion')
begin
	declare @conteo int

	select @conteo = count(*)
	from sticker_bouquet
	where id_sticker = @id_sticker
	and id_detalle_version_bouquet = @id_detalle_version_bouquet
	
	if(@conteo = 0)
	begin
		insert into sticker_bouquet (id_sticker, id_detalle_version_bouquet)
		values (@id_sticker, @id_detalle_version_bouquet)

		select scope_identity() as id_sticker_bouquet
	end
	else
	begin
		select -1 as id_sticker_bouquet
	end
end
else
if(@accion = 'consultar_asignacion')
begin
	select detalle_version_bouquet.id_detalle_version_bouquet,
	sticker.id_sticker,
	sticker.nombre_sticker,
	sticker_bouquet.id_sticker_bouquet 
	from detalle_version_bouquet,
	sticker_bouquet,
	sticker
	where detalle_version_bouquet.id_detalle_version_bouquet = sticker_bouquet.id_detalle_version_bouquet
	and sticker.id_sticker = sticker_bouquet.id_sticker
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by sticker.nombre_sticker
end
else
if(@accion = 'eliminar_asignacion')
begin
	select @id_sticker_bouquet = sticker_bouquet.id_sticker_bouquet
	from detalle_version_bouquet,
	sticker_bouquet
	where detalle_version_bouquet.id_detalle_version_bouquet = sticker_bouquet.id_detalle_version_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	and sticker_bouquet.id_sticker = @id_sticker

	delete from sticker_bouquet
	where id_sticker_bouquet = @id_sticker_bouquet
end