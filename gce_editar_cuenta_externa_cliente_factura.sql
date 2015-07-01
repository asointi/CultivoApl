/****** Object:  StoredProcedure [dbo].[gce_editar_cuenta_externa_cliente_factura]    Script Date: 10/06/2007 11:50:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[gce_editar_cuenta_externa_cliente_factura]

@accion nvarchar(50),
@id_cuenta_externa_cliente_factura int,
@id_cliente_factura int,
@id_cuenta_externa int

AS

IF @accion = 'registrar'
BEGIN

	INSERT INTO cuenta_externa_cliente_factura
	(
	id_cliente_factura,
	id_cuenta_externa
	)
	VALUES(
	@id_cliente_factura,
	@id_cuenta_externa
	)

END
ELSE IF @accion = 'eliminar'
BEGIN
    DELETE cuenta_externa_cliente_factura
	WHERE id_cuenta_externa_cliente_factura= @id_cuenta_externa_cliente_factura
END

