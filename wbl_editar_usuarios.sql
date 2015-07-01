/****** Object:  StoredProcedure [dbo].[wbl_editar_usuarios]    Script Date: 10/06/2007 12:37:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_editar_usuarios]

@accion nvarchar(20),
@id_usuarios int,
@usuario nvarchar(255),
@nombre nvarchar(255),
@id_impresora int

AS

IF @accion = 'modificar'
	BEGIN
		UPDATE usuarios
		SET	usuario = @usuario,
		nombre = @nombre,
		id_impresora = @id_impresora
		WHERE id_usuarios = @id_usuarios
	END

ELSE IF @accion = 'eliminar'
	BEGIN
		DELETE usuarios
		WHERE id_usuarios = @id_usuarios
	END
