/****** Object:  StoredProcedure [dbo].[na_editar_color]    Script Date: 11/15/2007 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_editar_variedad_flor]

@accion nvarchar(50),
@id_variedad_flor int,
@id_color int,
@id_tipo_flor int,
@id_casa_creadora int,
@nombre_variedad_flor nvarchar(255),
@descripcion nvarchar(510),
@id_cuenta_interna int

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO variedad_flor
	(
	id_color,
	id_tipo_flor,
	id_casa_creadora,
	nombre_variedad_flor,
	descripcion,
	id_cuenta_interna
	)
	VALUES(
	@id_color,
	@id_tipo_flor,
	@id_casa_creadora,
	@nombre_variedad_flor,
	@descripcion,
	@id_cuenta_interna
	)
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE variedad_flor
	SET		id_color = @id_color,
	id_tipo_flor = @id_tipo_flor,
	id_casa_creadora = @id_casa_creadora,
	nombre_variedad_flor = @nombre_variedad_flor,
	descripcion = @descripcion,
	id_cuenta_interna = @id_cuenta_interna
	WHERE id_variedad_flor = @id_variedad_flor
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE variedad_flor
	WHERE id_variedad_flor = @id_variedad_flor
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT vf.*,LTRIM(RTRIM(vf.nombre_variedad_flor)) + ' [' + tf.idc_tipo_flor + vf.idc_variedad_flor + ']' as nombre_variedad_color_idc
	FROM variedad_flor as vf,tipo_flor as tf, color as c
	where tf.id_tipo_flor = @id_tipo_flor
	and vf.id_tipo_flor = tf.id_tipo_flor 
	and vf.id_color = c.id_color
	and vf.disponible = 1
	ORDER BY vf.nombre_variedad_flor
END
