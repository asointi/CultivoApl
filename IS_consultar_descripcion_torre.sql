set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 02/08/2011
-- Description:	Consultar descripcion torre
-- =============================================
ALTER PROCEDURE [dbo].[consultar_descripcion_torre] 
	-- Add the parameters for the stored procedure here
	@accion nvarchar(10),
	@id_torre int
AS
IF(@accion = 'consultar')
SELECT comp.vel_procesador, comp.cap_memoria, comp.tam_disco 
FROM Compone_CPU as comp
WHERE comp.id_periferico = @id_torre