/****** Object:  StoredProcedure [dbo].[na_editar_color]    Script Date: 11/15/2007 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ven_editar_tipo_descuento_cliente_factura]

@accion nvarchar(50),
@id_tipo_descuento_cliente_factura int,
@id_tipo_descuento int,
@id_cliente_factura int

AS
        
IF @accion = 'registrar'
BEGIN
	INSERT INTO tipo_descuento_cliente_factura
	(
	id_tipo_descuento,
	id_cliente_factura
	)
	VALUES(
	@id_tipo_descuento,
	@id_cliente_factura
	)
END

ELSE IF @accion = 'modificar'
BEGIN
   	UPDATE tipo_descuento_cliente_factura
	SET	id_tipo_descuento= @id_tipo_descuento,
	id_cliente_factura=@id_cliente_factura
	WHERE id_tipo_descuento_cliente_factura = @id_tipo_descuento_cliente_factura
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE tipo_descuento_cliente_factura
	WHERE id_tipo_descuento_cliente_factura = @id_tipo_descuento_cliente_factura
END

ELSE IF @accion = 'seleccionar'
BEGIN
	SELECT tc.*, d.nombre_cliente + ' [' + d.idc_cliente_despacho + ']' as nombre_cliente, 
	t.nombre_tipo_descuento
	FROM tipo_descuento_cliente_factura as tc, 
	tipo_descuento as t,
	cliente_factura as c, 
	cliente_despacho as d
	WHERE tc.id_tipo_descuento = t.id_tipo_descuento
	and tc.id_cliente_factura = c.id_cliente_factura
	and c.id_cliente_factura = d.id_cliente_factura
	order by t.nombre_tipo_descuento,
	nombre_cliente
END