/****** Object:  StoredProcedure [dbo].[gce_editar_cuenta_externa_farm]    Script Date: 10/06/2007 11:52:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[gce_editar_cuenta_externa_farm]

@accion nvarchar(50),
@id_cuenta_externa_farm int,
@id_farm int,
@id_cuenta_externa int,
@id_impresora int

AS

IF @accion = 'registrar'
BEGIN
	INSERT INTO cuenta_externa_farm
	(
	id_farm,
	id_cuenta_externa,
	id_impresora
	)
	VALUES(
	@id_farm,
	@id_cuenta_externa,
	@id_impresora
	)
END

ELSE IF @accion = 'modificar'
BEGIN    
	UPDATE cuenta_externa_farm
	SET id_impresora = @id_impresora
	WHERE id_cuenta_externa_farm= @id_cuenta_externa_farm
END

ELSE IF @accion = 'eliminar'
BEGIN    
	DELETE cuenta_externa_farm
	WHERE id_cuenta_externa_farm= @id_cuenta_externa_farm
END