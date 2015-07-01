/****** Object:  StoredProcedure [dbo].[gc_editar_permiso_perfil]    Script Date: 10/06/2007 11:36:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_editar_permiso_perfil]

@accion nvarchar(50),
@id_permiso_perfil int,
@id_perfil int,
@id_funcion int,
@id_usuario int

AS

DECLARE @id_perfil_c int, @id_funcion_c int, @nombre_funcion nvarchar(255), @nombre_perfil nvarchar(255), @mensaje nvarchar(255)

IF @accion = 'registrar'
BEGIN
	DECLARE @id_ap_p int, @id_ap_f int
	SELECT @nombre_funcion = nombre_funcion, @id_ap_f = id_ap FROM funcion WHERE id_funcion = @id_funcion
	SELECT @nombre_perfil = nombre_perfil, @id_ap_p = id_ap FROM perfil WHERE id_perfil = @id_perfil
	
	IF (@id_ap_f = @id_ap_p)
		BEGIN
			INSERT INTO permiso_perfil
			(
			id_perfil,
			id_funcion
			)
			VALUES(
			@id_perfil,
			@id_funcion
			)
		END
	ELSE
	RETURN -1
END

ELSE IF @accion = 'eliminar'
BEGIN
	SELECT @id_funcion_c = id_funcion, @id_perfil_c = id_perfil FROM permiso_perfil WHERE id_permiso_perfil = @id_permiso_perfil
	SELECT @nombre_funcion = nombre_funcion FROM funcion WHERE id_funcion = @id_funcion_c
	SELECT @nombre_perfil = nombre_perfil FROM perfil WHERE id_perfil = @id_perfil_c
           
	DELETE permiso_perfil
	WHERE id_permiso_perfil= @id_permiso_perfil
END

