set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_editar_temporada_cultivo]

@accion nvarchar(50),
@id_temporada int,
@nombre_temporada nvarchar(255),
@descripcion nvarchar(510)

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO temporada
	(
	nombre_temporada,
	descripcion
	)
	VALUES(
	@nombre_temporada,
	@descripcion
	)
	return scope_identity()
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE temporada SET	
	nombre_temporada = @nombre_temporada,
	descripcion = @descripcion
	WHERE id_temporada = @id_temporada
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE temporada
	WHERE id_temporada = @id_temporada
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT *
	FROM temporada
	ORDER BY nombre_temporada
END

ELSE IF @accion = 'seleccionar_por_id'
BEGIN
	SELECT *
	FROM temporada
	WHERE id_temporada = @id_temporada
	ORDER BY nombre_temporada
END