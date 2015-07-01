/****** Object:  StoredProcedure [dbo].[wl_editar_wishlist]    Script Date: 10/06/2007 13:08:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wl_editar_wishlist]

@accion nvarchar(50),
@id_wishlist int,
@id_despacho int,
@fecha_despacho datetime,
@id_cuenta_interna int

AS

IF @accion = 'registrar'
BEGIN
	INSERT INTO wl_wishlist 
		(
		id_despacho, 
		fecha_despacho,
		id_cuenta_interna,
		fecha_transaccion
		)
	VALUES
		(
		@id_despacho,
	   	@fecha_despacho,
	   	@id_cuenta_interna,
		getdate()
		)
	RETURN SCOPE_IDENTITY()
END

ELSE IF @accion = 'modificar'
BEGIN
	UPDATE wl_wishlist
	SET
		id_despacho = @id_despacho,
		fecha_despacho = @fecha_despacho,
		fecha_transaccion = getDate(),
		id_cuenta_interna = @id_cuenta_interna
	WHERE id_wishlist = @id_wishlist
	RETURN
END

ELSE IF @accion = 'eliminar'
BEGIN
   	DELETE wl_wishlist
	WHERE id_wishlist = @id_wishlist
	RETURN
END
