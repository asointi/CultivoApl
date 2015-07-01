set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ven_editar_tipo_farm]

@accion nvarchar(255)

AS

IF @accion = 'seleccionar'
BEGIN
	SELECT * FROM tipo_farm
	order by nombre_tipo_farm
END