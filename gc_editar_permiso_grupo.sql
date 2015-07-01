/****** Object:  StoredProcedure [dbo].[gc_editar_permiso_grupo]    Script Date: 10/06/2007 11:35:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_editar_permiso_grupo]

@accion nvarchar(50),
@id_permiso_grupo int,
@id_grupo int,
@id_funcion int,
@id_usuario int

AS

DECLARE @mensaje nvarchar(255),@nombre_funcion nvarchar(255), @nombre_grupo nvarchar(255), @id_grupo_c int,@id_funcion_c int

IF @accion = 'registrar'
BEGIN
	SELECT @nombre_funcion = nombre_funcion FROM funcion WHERE id_funcion = @id_funcion
	SELECT @nombre_grupo = nombre_grupo FROM grupo WHERE id_grupo = @id_grupo
		
	INSERT INTO permiso_grupo
	(
	id_grupo,
	id_funcion
	)
	VALUES(
	@id_grupo,
	@id_funcion
	)
END

ELSE IF @accion = 'eliminar'
BEGIN
	SELECT @id_funcion_c = id_funcion, @id_grupo_c = id_grupo FROM permiso_grupo WHERE id_permiso_grupo = @id_permiso_grupo
	SELECT @nombre_funcion = nombre_funcion FROM funcion WHERE id_funcion = @id_funcion_c
	SELECT @nombre_grupo = nombre_grupo FROM grupo WHERE id_grupo = @id_grupo_c
           
	DELETE permiso_grupo
	WHERE id_permiso_grupo = @id_permiso_grupo
END
