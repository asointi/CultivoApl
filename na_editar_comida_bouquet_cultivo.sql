set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/23
-- Description:	Maneja informacion de la comida de los Bouquets en el Cultivo
-- =============================================

alter PROCEDURE [dbo].[na_editar_comida_bouquet_cultivo] 

@accion nvarchar(255),
@nombre_comida nvarchar(255),
@id_comida int,
@disponible bit

as

declare @conteo int

if(@accion = 'consultar')
begin
	select id_comida,
	nombre_comida,
	disponible
	from comida
	order by nombre_comida
end
else
if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from comida
	where nombre_comida = @nombre_comida

	if(@conteo = 0)
	begin
		insert into comida (nombre_comida)
		values (@nombre_comida)

		select scope_identity() as id_comida
	end
	else
	begin
		select -1 as id_comida
	end
end
else
if(@accion = 'actualizar')
begin
	select @conteo = count(*)
	from comida
	where nombre_comida = @nombre_comida
	and id_comida <> @id_comida 

	if(@conteo = 0)
	begin
		update comida
		set nombre_comida = @nombre_comida,
		disponible = @disponible
		where id_comida = @id_comida

		select @id_comida as id_comida
	end
	else
	begin
		select -1 as id_comida
	end
end