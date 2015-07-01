/****** Object:  StoredProcedure [dbo].[gc_editar_grupo]    Script Date: 10/06/2007 11:32:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_editar_grupo]

@accion nvarchar(50),
@id_grupo int,
@nombre_grupo nvarchar(255),
@descripcion ntext,
@id_usuario int

AS
DECLARE @mensaje nvarchar(255)

IF @accion = 'registrar'
BEGIN
	INSERT INTO grupo
	(
	nombre_grupo,
	descripcion
	)
	VALUES(
	@nombre_grupo,
	@descripcion
	)
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE grupo
	SET nombre_grupo = @nombre_grupo,
		descripcion = @descripcion
	WHERE id_grupo = @id_grupo
END

ELSE IF @accion = 'eliminar'
BEGIN
	DECLARE @nombre_grupo_c nvarchar(255)
	SELECT @nombre_grupo_c = nombre_grupo FROM grupo WHERE id_grupo = @id_grupo
           
	DELETE grupo
	WHERE id_grupo = @id_grupo
END

