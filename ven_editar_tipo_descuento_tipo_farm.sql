/****** Object:  StoredProcedure [dbo].[na_editar_color]    Script Date: 11/15/2007 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ven_editar_tipo_descuento_tipo_farm]

@accion nvarchar(50),
@id_tipo_descuento_tipo_farm int,
@id_tipo_descuento int,
@id_tipo_farm int,
@porcentaje_descuento decimal(20,4)

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO tipo_descuento_tipo_farm
	(
	id_tipo_descuento,
	id_tipo_farm,
	porcentaje_descuento
	)
	VALUES(
	@id_tipo_descuento,
	@id_tipo_farm,
	@porcentaje_descuento
	)
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE tipo_descuento_tipo_farm
	SET	id_tipo_descuento= @id_tipo_descuento,
	id_tipo_farm=@id_tipo_farm,
	porcentaje_descuento = @porcentaje_descuento
	WHERE id_tipo_descuento_tipo_farm = @id_tipo_descuento_tipo_farm
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE tipo_descuento_tipo_farm
	WHERE id_tipo_descuento_tipo_farm = @id_tipo_descuento_tipo_farm
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT tc.*, tf.nombre_tipo_farm, t.nombre_tipo_descuento
	FROM tipo_descuento_tipo_farm as tc, 
	tipo_descuento as t,
	tipo_farm as tf
	WHERE tc.id_tipo_descuento = t.id_tipo_descuento
	and tc.id_tipo_farm = tf.id_tipo_farm
	order by t.nombre_tipo_descuento,
	nombre_tipo_farm
END
