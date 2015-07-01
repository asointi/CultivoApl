/****** Object:  StoredProcedure [dbo].[wl_editar_solicitud]    Script Date: 10/06/2007 13:06:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wl_editar_solicitud]

@accion nvarchar(50),
@id_solicitud_item int,
@id_item_wishlist int,
@id_farm int,
@precio_solicitud decimal(20,4),
@piezas_solicitud int,
@id_cuenta_interna int

AS

IF @accion = 'registrar'
BEGIN
INSERT INTO wl_solicitud_item
		(
	   	id_item_wishlist,
	   	id_farm,
	   	precio_solicitud,
	   	piezas_solicitud,
	   	id_cuenta_interna,
	   	fecha_transaccion
		)
	VALUES
		(
	   	@id_item_wishlist,
	   	@id_farm,
	   	@precio_solicitud,
	   	@piezas_solicitud,
	   	@id_cuenta_interna,
	   	getdate()
		)
	RETURN SCOPE_IDENTITY()
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE wl_solicitud_item
	SET
		id_farm = @id_farm,
		precio_solicitud = @precio_solicitud,
		piezas_solicitud = @piezas_solicitud,
		id_cuenta_interna = @id_cuenta_interna
	WHERE id_solicitud_item = @id_solicitud_item   
	RETURN
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE wl_solicitud_item
	WHERE id_solicitud_item = @id_solicitud_item
	RETURN
END
