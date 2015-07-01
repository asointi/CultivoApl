set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[editar_mantenimiento] 
	-- Add the parameters for the stored procedure here
	@accion nvarchar(255),
	@id_periferico int,
	@id_mantenimiento int,
	@ultimo_mantenimiento datetime,
	@proximo_mantenimiento datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if(@accion = 'consultar')
	begin
		select per.id_periferico, per.placa, mod.nombre_modelo, per.serial, tp.tipo, man.ultimo_mantenimiento, man.proximo_mantenimiento, man.id_mantenimiento 
		from Mantenimiento as man
		inner join Periferico as per on per.id_periferico = man.id_periferico
		inner join Tipo_Periferico as tp on per.id_tipo = tp.id_tipo
		inner join Modelo as mod on per.id_modelo = mod.id_modelo
	end
	if(@accion = 'insertar')
	begin
		insert into Mantenimiento (id_periferico, ultimo_mantenimiento) values(@id_periferico, @ultimo_mantenimiento)
	end
	if(@accion = 'actualizar')
	begin
		update Mantenimiento set proximo_mantenimiento = @proximo_mantenimiento
		where id_mantenimiento = @id_mantenimiento
	end
END