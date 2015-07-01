/****** Object:  StoredProcedure [dbo].[gc_editar_cuenta_interna_grupo]    Script Date: 10/06/2007 11:25:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[gc_editar_cuenta_interna_grupo]

@accion nvarchar(50),
@id_cuenta_interna_grupo int,
@id_cuenta_interna int,
@id_grupo int,
@id_usuario int

AS

DECLARE @nombre nvarchar(255), @nombre_grupo nvarchar(255), @mensaje nvarchar(255), @id_grupo_c int,@id_cuenta_c int

IF @accion = 'registrar'
BEGIN
	SELECT @nombre = nombre FROM cuenta_interna WHERE id_cuenta_interna = @id_cuenta_interna
	SELECT @nombre_grupo = nombre_grupo FROM grupo WHERE id_grupo = @id_grupo

	INSERT INTO cuenta_interna_grupo
	(
	id_cuenta_interna,
	id_grupo
	)
	VALUES(
	@id_cuenta_interna,
	@id_grupo
	)
END

ELSE IF @accion = 'eliminar'
BEGIN
	SELECT @id_cuenta_c = id_cuenta_interna, @id_grupo_c = id_grupo 
	FROM cuenta_interna_grupo 
	WHERE id_cuenta_interna_grupo = @id_cuenta_interna_grupo
	
	SELECT @nombre = nombre FROM cuenta_interna WHERE id_cuenta_interna = @id_cuenta_c
	SELECT @nombre_grupo = nombre_grupo FROM grupo WHERE id_grupo = @id_grupo_c
	
	DELETE cuenta_interna_grupo
	WHERE id_cuenta_interna_grupo = @id_cuenta_interna_grupo
END
