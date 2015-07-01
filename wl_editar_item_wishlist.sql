/****** Object:  StoredProcedure [dbo].[wl_editar_item_wishlist]    Script Date: 10/06/2007 13:05:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wl_editar_item_wishlist]

@accion nvarchar(50),
@id_item_wishlist int,
@id_wishlist int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tapa int,
@id_tipo_caja int,
@piezas int,
@unidades_por_pieza int,
@precio_max decimal(20,4),
@notas nvarchar(512)

AS

IF @accion = 'registrar'
BEGIN
INSERT INTO wl_item_wishlist
		(
	   	id_wishlist,
		id_variedad_flor,
		id_grado_flor,
		id_tapa,
		id_tipo_caja,
		piezas,
		unidades_por_pieza,
		precio_max,
		notas
		)
	VALUES
		(
	   	@id_wishlist,
		@id_variedad_flor,
		@id_grado_flor,
		@id_tapa,
		@id_tipo_caja,
		@piezas,
		@unidades_por_pieza,
		@precio_max,
		@notas
		)
	RETURN SCOPE_IDENTITY()
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE wl_item_wishlist
	SET
	id_variedad_flor = @id_variedad_flor,
	id_grado_flor = @id_grado_flor,
	id_tapa = @id_tapa,
	id_tipo_caja = @id_tipo_caja,
	piezas = @piezas,
	unidades_por_pieza = @unidades_por_pieza,
	precio_max = @precio_max,
	notas  = @notas 
	WHERE id_item_wishlist = @id_item_wishlist
	RETURN
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE wl_item_wishlist
	WHERE id_item_wishlist = @id_item_wishlist
	RETURN
END
