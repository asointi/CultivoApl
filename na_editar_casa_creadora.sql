/****** Object:  StoredProcedure [dbo].[na_editar_color]    Script Date: 11/15/2007 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_editar_casa_creadora]

@accion nvarchar(50),
@id_casa_creadora int,
@nombre_casa_creadora nvarchar(255)

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO casa_creadora
	(
	nombre_casa_creadora
	)
	VALUES(
	@nombre_casa_creadora
	)
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE casa_creadora
	SET	nombre_casa_creadora= @nombre_casa_creadora
	WHERE id_casa_creadora = @id_casa_creadora
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE casa_creadora
	WHERE id_casa_creadora = @id_casa_creadora
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT * FROM casa_creadora
END
