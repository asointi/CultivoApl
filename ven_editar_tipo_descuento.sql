/****** Object:  StoredProcedure [dbo].[na_editar_color]    Script Date: 11/15/2007 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ven_editar_tipo_descuento]

@accion nvarchar(50),
@id_tipo_descuento int,
@nombre_tipo_descuento nvarchar(255)

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO tipo_descuento
	(
	id_tipo_descuento,
	nombre_tipo_descuento
	)
	VALUES(
	@id_tipo_descuento,
	@nombre_tipo_descuento
	)
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE tipo_descuento
	SET	nombre_tipo_descuento= @nombre_tipo_descuento
	WHERE id_tipo_descuento = @id_tipo_descuento
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE tipo_descuento
	WHERE id_tipo_descuento = @id_tipo_descuento
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT * FROM tipo_descuento
	order by nombre_tipo_descuento
END
