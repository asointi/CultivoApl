set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/05/08
-- Description:	Maneja informacion de las causas de creditos en las fincas
-- =============================================

alter PROCEDURE [dbo].[na_editar_causa_credito_farm] 

@accion nvarchar(50),
@id_causa_credito_farm int,
@nombre_causa_credito_farm nvarchar(255)

as

declare @conteo int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from causa_credito_farm
	where causa_credito_farm.nombre_causa_credito_farm = @nombre_causa_credito_farm

	if(@conteo = 0)
	begin
		insert into causa_credito_farm (nombre_causa_credito_farm)
		values (@nombre_causa_credito_farm)

		select 1 as resultado
	end
	else
	begin
		select -1 as resultado
	end
end
else
if(@accion = 'consultar')
begin
	select causa_credito_farm.id_causa_credito_farm,
	causa_credito_farm.nombre_causa_credito_farm
	from causa_credito_farm
	order by causa_credito_farm.nombre_causa_credito_farm
end
else
if(@accion = 'actualizar')
begin
	select @conteo = count(*)
	from causa_credito_farm
	where causa_credito_farm.nombre_causa_credito_farm = @nombre_causa_credito_farm

	if(@conteo = 0)
	begin
		update causa_credito_farm
		set nombre_causa_credito_farm = @nombre_causa_credito_farm
		where id_causa_credito_farm = @id_causa_credito_farm

		select 1 as resultado
	end
	else
	begin
		select -2 as resultado
	end
end
else
if(@accion = 'eliminar')
begin
	select @conteo = count(*)
	from causa_credito_farm,
	credito_farm_flor
	where causa_credito_farm.id_causa_credito_farm = credito_farm_flor.id_causa_credito_farm
	and causa_credito_farm.id_causa_credito_farm = @id_causa_credito_farm

	if(@conteo = 0)
	begin
		delete from causa_credito_farm
		where id_causa_credito_farm = @id_causa_credito_farm

		select 1 as resultado
	end
	else
	begin
		select -3 as resultado
	end
end