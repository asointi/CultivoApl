/****** Object:  StoredProcedure [dbo].[na_editar_color]    Script Date: 11/15/2007 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_editar_color]

@accion nvarchar(50),
@id_color int,
@nombre_color nvarchar(255)

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO color
	(
	nombre_color
	)
	VALUES(
	@nombre_color
	)
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE color
	SET	nombre_color= @nombre_color
	WHERE id_color = @id_color
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE color
	WHERE id_color = @id_color
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT * FROM color
END
