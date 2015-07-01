/****** Object:  StoredProcedure [dbo].[prov_editar_precio_oferta]    Script Date: 10/24/2007 11:24:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	ALTER PROCEDURE [dbo].[prov_editar_precio_oferta]
	@accion nvarchar(20),
	@id_precio_oferta int,
	@id_variedad_flor int,
	@id_grado_flor int,
	@id_cliente_factura int,
	@precio decimal(20,4)
	
	AS
	IF @accion = 'insertar'
		BEGIN
			INSERT INTO precio_oferta
			(
			id_variedad_flor,
			id_grado_flor,
			id_cliente_factura,
			precio,
			fecha_transaccion
			)
			VALUES
			(
			@id_variedad_flor,
			@id_grado_flor,
			@id_cliente_factura,
			@precio,
			getdate()
			)
		END
	ELSE IF @accion = 'eliminar'
		BEGIN
			DELETE precio_oferta
   			WHERE id_precio_oferta = @id_precio_oferta
		END		
