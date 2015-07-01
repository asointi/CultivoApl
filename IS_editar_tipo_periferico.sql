set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[editar_tipo_periferico] 
	-- Add the parameters for the stored procedure here
	@accion nvarchar(250),
	@tipo nvarchar(250),
	@id_tipo int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if(@accion = 'consultar')
	begin
		select * from Tipo_Periferico
		order by tipo
	end
	
	declare @contador int
	if(@accion = 'insertar')
	begin
		select @contador = count(*)
		from Tipo_Periferico
		where ltrim(rtrim(tipo)) = ltrim(rtrim(@tipo))
		if(@contador = 0)
		begin
			insert into Tipo_Periferico (tipo)
			values (@tipo)
			select 2 as asignado
		end
		else
		begin
			select -1 as existente
		end
	end

	if(@accion = 'eliminar')
	begin
		delete from Tipo_Periferico
		where id_tipo = @id_tipo
		select 2 as eliminado
	end

	declare @contadorUpdate int
	if(@accion = 'actualizar')
	begin
		select @contadorUpdate = count(*)
		from TIpo_Periferico
		where tipo = ltrim(rtrim(@tipo))
		if(@contadorUpdate = 0)
		begin
			update Tipo_Periferico set tipo = @tipo
		end
		else
		begin
			select -1 as existe
		end
	end
END