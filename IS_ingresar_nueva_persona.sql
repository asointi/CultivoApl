set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		John Rodriguez
-- Create date: 19-04-11
-- Description:	Ingresar una persona nueva en la tabla dbo.Persona
-- =============================================
ALTER PROCEDURE [dbo].[ingresar_nueva_persona] 
	@numero_identificacion int,
	@nombres nvarchar(50),
	@apellidos nvarchar(50),
	@id_estado int,
	@id_identificacion int,
	@accion nvarchar(30)
AS   
	INSERT INTO Persona (numero_identificacion, nombres, apellidos, id_estado, id_identificacion)
	VALUES (@numero_identificacion, @nombres, @apellidos, @id_estado, @id_identificacion)