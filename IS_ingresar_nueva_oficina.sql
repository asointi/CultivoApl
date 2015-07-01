set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 19-04-11
-- Description:	Permite ingresar una nueva oficina
-- =============================================
ALTER PROCEDURE [dbo].[ingresar_nueva_oficina] 
	@nombre nvarchar(50),
	@id_area int,
	@id_persona int
AS

INSERT INTO Oficina (id_area, id_persona)
VALUES (@id_area, @id_persona)