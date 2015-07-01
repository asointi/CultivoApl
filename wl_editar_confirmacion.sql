/****** Object:  StoredProcedure [dbo].[wl_editar_confirmacion]    Script Date: 10/06/2007 13:00:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wl_editar_confirmacion]

@accion nvarchar(50),
@id_confirmacion int,
@id_item_wishlist int,
@id_solicitud_item int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tapa int,
@id_tipo_caja int,
@piezas_conf int,
@unidades_por_pieza_conf int,
@precio_conf decimal(20,4),
@notas_conf nvarchar(512),
@id_cuenta_interna int

AS

DECLARE @sum_piezas_conf int, @piezas int

IF @accion = 'registrar'
BEGIN	
	SELECT @piezas = piezas FROM wl_item_wishlist WHERE id_item_wishlist = @id_item_wishlist
   	SELECT @sum_piezas_conf = SUM(piezas_conf) FROM wl_confirmacion WHERE id_item_wishlist = @id_item_wishlist
   	
	IF @sum_piezas_conf IS NOT NULL
		BEGIN
			SET @sum_piezas_conf = @sum_piezas_conf + @piezas_conf

		IF @sum_piezas_conf <= @piezas
			BEGIN
			INSERT INTO wl_confirmacion
					(
	  	   			id_item_wishlist,
		   			id_solicitud_item,
		   			id_variedad_flor,
		   			id_grado_flor,
		   			id_tapa,
		   			id_tipo_caja,
		   			piezas_conf,
		   			unidades_por_pieza_conf,
		   			precio_conf,
		   			notas_conf,
		   			id_cuenta_interna,
		   			fecha_transaccion
					)
				VALUES
					(
	  	   			@id_item_wishlist,
		   			@id_solicitud_item,
		   			@id_variedad_flor,
		   			@id_grado_flor,
		   			@id_tapa,
		   			@id_tipo_caja,
		   			@piezas_conf,
		   			@unidades_por_pieza_conf,
		   			@precio_conf,
		   			@notas_conf,
		   			@id_cuenta_interna,
		   			getdate()
					)
				RETURN SCOPE_IDENTITY()
			END

		ELSE
			RETURN -2
		END

	ELSE
		BEGIN
			IF @piezas_conf <= @piezas
			BEGIN
				INSERT INTO wl_confirmacion
					(
	  	   			id_item_wishlist,
		   			id_solicitud_item,
		   			id_variedad_flor,
		   			id_grado_flor,
		   			id_tapa,
		   			id_tipo_caja,
		   			piezas_conf,
		   			unidades_por_pieza_conf,
		   			precio_conf,
		   			notas_conf,
		   			id_cuenta_interna,
		   			fecha_transaccion
					)
				VALUES
					(
	  	   			@id_item_wishlist,
		   			@id_solicitud_item,
		   			@id_variedad_flor,
		   			@id_grado_flor,
		   			@id_tapa,
		   			@id_tipo_caja,
		   			@piezas_conf,
		   			@unidades_por_pieza_conf,
		   			@precio_conf,
		   			@notas_conf,
		   			@id_cuenta_interna,
		   			getdate()
					)
				RETURN SCOPE_IDENTITY()
			END
		
		ELSE
			RETURN -2
		END
END

ELSE IF @accion = 'modificar'
BEGIN
	DECLARE @piezas_conf_ant int, @id_item_wishlist_c int
	SELECT @id_item_wishlist_c = id_item_wishlist, @piezas_conf_ant = piezas_conf FROM wl_confirmacion WHERE  id_confirmacion = @id_confirmacion
	SELECT @piezas = piezas FROM wl_item_wishlist WHERE id_item_wishlist = @id_item_wishlist_c
	SELECT @sum_piezas_conf = SUM(piezas_conf) FROM wl_confirmacion WHERE id_item_wishlist = @id_item_wishlist_c
   	
	IF @sum_piezas_conf IS NOT NULL
		BEGIN
			SET @sum_piezas_conf = @sum_piezas_conf - @piezas_conf_ant + @piezas_conf

			IF @sum_piezas_conf <= @piezas
				BEGIN
					UPDATE wl_confirmacion
					SET
					id_variedad_flor = @id_variedad_flor,
					id_grado_flor =	@id_grado_flor,
					id_tapa = @id_tapa,
					id_tipo_caja =	@id_tipo_caja,
					piezas_conf = @piezas_conf,
					unidades_por_pieza_conf =  @unidades_por_pieza_conf,
					precio_conf = @precio_conf,
					notas_conf = @notas_conf,
					id_cuenta_interna = @id_cuenta_interna
					WHERE id_confirmacion = @id_confirmacion
					RETURN @id_confirmacion
				END
			ELSE
				RETURN -2
		END
END

ELSE IF @accion = 'eliminar'
BEGIN
	DELETE wl_confirmacion
	WHERE id_confirmacion = @id_confirmacion
	RETURN
END

