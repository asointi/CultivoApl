/****** Object:  StoredProcedure [dbo].[na_editar_caracteristica_tipo_flor]    Script Date: 09/24/2009 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_editar_caracteristica_tipo_flor]

@accion nvarchar(50),
@id_caracteristica_tipo_flor int,
@id_tipo_flor int,
@nombre_caracteristica_tipo_flor nvarchar(255)

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO caracteristica_tipo_flor
	(
	id_tipo_flor,
	nombre_caracteristica_tipo_flor
	)
	VALUES(
	@id_tipo_flor,
	@nombre_caracteristica_tipo_flor
	)
	return scope_identity()
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE caracteristica_tipo_flor SET
	id_tipo_flor = @id_tipo_flor,
	nombre_caracteristica_tipo_flor = @nombre_caracteristica_tipo_flor
	WHERE id_caracteristica_tipo_flor = @id_caracteristica_tipo_flor
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE caracteristica_tipo_flor
	WHERE id_caracteristica_tipo_flor = @id_caracteristica_tipo_flor
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT caracteristica_tipo_flor.*, tipo_flor.nombre_tipo_flor
	FROM caracteristica_tipo_flor, tipo_flor
	WHERE caracteristica_tipo_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
	order by nombre_tipo_flor, nombre_caracteristica_tipo_flor
END

ELSE IF @accion = 'seleccionar_por_id'
BEGIN
	SELECT caracteristica_tipo_flor.*, tipo_flor.nombre_tipo_flor
	FROM caracteristica_tipo_flor, tipo_flor
	WHERE caracteristica_tipo_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
	and id_caracteristica_tipo_flor = @id_caracteristica_tipo_flor
END

ELSE IF @accion = 'seleccionar_por_tipo_flor'
BEGIN
	SELECT caracteristica_tipo_flor.*, tipo_flor.nombre_tipo_flor
	FROM caracteristica_tipo_flor, tipo_flor
	WHERE caracteristica_tipo_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
	and caracteristica_tipo_flor.id_tipo_flor = @id_tipo_flor
	order by nombre_tipo_flor, nombre_caracteristica_tipo_flor
END