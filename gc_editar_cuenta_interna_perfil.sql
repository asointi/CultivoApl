/****** Object:  StoredProcedure [dbo].[gc_editar_cuenta_interna_perfil]    Script Date: 10/06/2007 11:30:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gc_editar_cuenta_interna_perfil]

@accion nvarchar(50),
@id_cuenta_interna_perfil int,
@id_cuenta_interna int,
@id_perfil int,
@id_usuario int

AS

DECLARE @nombre nvarchar(255), @nombre_perfil nvarchar(255), @mensaje nvarchar(255),@id_cuenta_c int, @id_perfil_c int

IF @accion = 'registrar'
BEGIN
	SELECT @nombre = nombre FROM cuenta_interna WHERE id_cuenta_interna = @id_cuenta_interna
	SELECT @nombre_perfil = nombre_perfil FROM perfil WHERE id_perfil = @id_perfil
    
	INSERT INTO cuenta_interna_perfil
	(
	id_cuenta_interna,
	id_perfil
	)
	VALUES(
	@id_cuenta_interna,
	@id_perfil
	)
END

ELSE IF @accion = 'eliminar'
BEGIN
	SELECT @id_cuenta_c = id_cuenta_interna, @id_perfil_c = id_perfil 
	FROM cuenta_interna_perfil 
	WHERE id_cuenta_interna_perfil = @id_cuenta_interna_perfil
	
	SELECT @nombre = nombre FROM cuenta_interna WHERE id_cuenta_interna = @id_cuenta_c
	SELECT @nombre_perfil = nombre_perfil FROM perfil WHERE id_perfil = @id_perfil_c
	
	DELETE cuenta_interna_perfil
	WHERE id_cuenta_interna_perfil = @id_cuenta_interna_perfil
END

