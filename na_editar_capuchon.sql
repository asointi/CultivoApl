set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_editar_capuchon]

@accion nvarchar(50),
@id_capuchon int,
@idc_capuchon nvarchar(255),
@descripcion nvarchar(255),
@ancho_superior int,
@ancho_inferior int,
@alto int,
@decorado bit

AS

IF @accion = 'registrar'
BEGIN
	INSERT INTO capuchon
	(
	idc_capuchon,
	descripcion,
	ancho_superior,
	ancho_inferior,
	alto,
	decorado
	)
	VALUES(
	@idc_capuchon,
	@descripcion,
	@ancho_superior,
	@ancho_inferior,
	@alto,
	@decorado
	)
	return scope_identity()
END
ELSE 
IF @accion = 'modificar'
BEGIN
   	UPDATE capuchon 
	SET	idc_capuchon = @idc_capuchon,
	descripcion = @descripcion,
	ancho_superior = @ancho_superior,
	ancho_inferior = @ancho_inferior,
	alto = @alto,
	decorado = @decorado
	WHERE id_capuchon = @id_capuchon
END
ELSE 
IF @accion = 'eliminar'
BEGIN
	DELETE capuchon
	WHERE id_capuchon = @id_capuchon
END
ELSE 
IF @accion = 'seleccionar'
BEGIN
	SELECT capuchon.id_capuchon,
	capuchon.idc_capuchon,
	capuchon.descripcion,
	capuchon.ancho_superior,
	capuchon.ancho_inferior,
	capuchon.alto,
	capuchon.decorado
	FROM capuchon 
	where disponible = 1
	ORDER BY capuchon.descripcion
END
ELSE 
IF @accion = 'seleccionar_por_id'
BEGIN
	SELECT capuchon.id_capuchon,
	capuchon.idc_capuchon,
	capuchon.descripcion,
	capuchon.ancho_superior,
	capuchon.ancho_inferior,
	capuchon.alto,
	capuchon.decorado
	FROM capuchon
	WHERE capuchon.id_capuchon = @id_capuchon
	and disponible = 1
	ORDER BY capuchon.descripcion
END