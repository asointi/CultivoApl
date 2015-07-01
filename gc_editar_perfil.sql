/****** Object:  StoredProcedure [dbo].[gc_editar_perfil]    Script Date: 10/06/2007 11:34:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_editar_perfil]

@accion nvarchar(50),
@id_perfil int,
@id_ap int,
@nombre_perfil nvarchar(255),
@descripcion ntext,
@id_usuario int

AS

DECLARE @mensaje nvarchar(255)

IF @accion = 'registrar'
BEGIN
	DECLARE @nombre_ap nvarchar(255)
	SELECT @nombre_ap = nombre_ap FROM aplicacion WHERE id_ap = @id_ap
	INSERT INTO perfil
	(
	id_ap,
	nombre_perfil,
	descripcion
	)
	VALUES(
	@id_ap,
	@nombre_perfil,
	@descripcion
	)
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE perfil
	SET	id_ap = @id_ap,
		nombre_perfil = @nombre_perfil,
		descripcion = @descripcion
	WHERE id_perfil = @id_perfil
END

ELSE IF @accion = 'eliminar'
BEGIN
	DECLARE @nombre_perfil_c nvarchar(255)
	SELECT @nombre_perfil_c = nombre_perfil FROM perfil WHERE id_perfil = @id_perfil
           
	DELETE perfil
	WHERE id_perfil = @id_perfil
END

