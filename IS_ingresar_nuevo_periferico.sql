set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 19-04-11
-- Description:	Ingresa un nuevo periferico a la tabla dbo.Perifericos
-- =============================================
ALTER PROCEDURE [dbo].[ingresar_nuevo_periferico] 
	@numero_placa nvarchar(5),
	@descripcion nvarchar(50),
	@id_marca int,
	@id_modelo int,
	@id_estado int,
	@id_tipo int,
	@id_periferico int,
	@serial nvarchar(50),
	@accion nvarchar(20),
	@velProc decimal(4,1),
	@capMem int,
	@tamDisc int
AS
declare @idPeriferico int
if (@accion = 'otro')
begin
	insert into Periferico (placa, descripcion, fecha_ingreso, id_marca, id_modelo, id_estado, id_tipo, serial)
	values (@numero_placa, @descripcion, Getdate(), @id_marca, @id_modelo, @id_estado, @id_tipo, @serial)
end

if (@accion = 'torre')
begin
	insert into Periferico (placa, descripcion, fecha_ingreso, id_marca, id_modelo, id_estado, id_tipo, serial)
	values (@numero_placa, @descripcion, Getdate(), @id_marca, @id_modelo, @id_estado, @id_tipo, @serial)
	select @idPeriferico = (select id_periferico from periferico where placa = @numero_placa)
	insert into Compone_CPU (id_periferico, vel_procesador, cap_memoria, tam_disco)
	values (@idPeriferico, @velProc, @capMem, @tamDisc)
end