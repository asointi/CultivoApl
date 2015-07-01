set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 19-04-11
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[Crear_Oficina]
@area int,
@persona int

AS
INSERT INTO Oficina (fecha_creacion, id_area, id_persona)
VALUES(Getdate(), @area, @persona) 

UPDATE Persona SET id_estado = 1
WHERE id_persona = @persona