set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/11/08
-- Description:	edita la informacion de los sticker en la comercializadora
-- =============================================

create PROCEDURE [dbo].[bouquet_editar_sticker_cultivo] 

@accion nvarchar(255),
@nombre_sticker nvarchar(255), 
@id_sticker int

as

declare @conteo int

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
if(@accion = 'eliminar')
begin
	begin try
		delete from sticker
		where id_sticker = @id_sticker
		
		select 1 as resultado
	end try 
	begin catch
		select -1 as resultado
	end catch
end
else
if(@accion = 'consultar')
begin
	select id_sticker,
	nombre_sticker
	from sticker
	where disponible = 1
	order by nombre_sticker
end