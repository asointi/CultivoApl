set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[editar_modelo] 
@accion nvarchar(255),
@nombre_modelo nvarchar(255)

AS
declare @registros int
BEGIN
	if(@accion = 'consultar')
	begin
		select * from Modelo
		order by nombre_modelo
	end

	if(@accion = 'insertar')
	begin
		select @registros = count(*)
		from Modelo
		where ltrim(rtrim(nombre_modelo)) = ltrim(rtrim(@nombre_modelo))

		if(@registros = 0)
		begin
			insert into Modelo (nombre_modelo) values(@nombre_modelo)
			select 1 as ins
		end
		else
		begin
			select -2 as modelo_existe
		end
	end 
END