/****** Object:  StoredProcedure [dbo].[wl_editar_farm_de_item]    Script Date: 10/06/2007 13:03:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wl_editar_farm_de_item]

@accion nvarchar(50),
@id_item_farm int,
@id_item_wishlist int,
@id_farm int,
@es_unica bit

AS

IF @accion = 'registrar'
BEGIN
INSERT INTO wl_item_wishlist_farm
		(
	   	id_item_wishlist,
	   	id_farm,
	   	es_unica
		)
	VALUES
		(
	   	@id_item_wishlist,
	   	@id_farm,
	   	@es_unica
		)
	RETURN SCOPE_IDENTITY()
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE wl_item_wishlist_farm
	WHERE id_item_farm = @id_item_farm
	RETURN
END
