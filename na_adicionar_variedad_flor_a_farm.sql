/****** Object:  StoredProcedure [dbo].[na_adicionar_variedad_flor_a_farm]    Script Date: 10/06/2007 11:54:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_adicionar_variedad_flor_a_farm]

@id_farm int,
@id_variedad_flor int

AS

DECLARE @id_tipo_flor int

SELECT @id_tipo_flor = id_tipo_flor
FROM variedad_flor
WHERE id_variedad_flor = @id_variedad_flor

IF @id_tipo_flor in (SELECT id_tipo_flor FROM Producto_Farm WHERE id_farm = @id_farm)
BEGIN
	INSERT INTO Farm_Variedad_Flor
	(
	id_farm, 
	id_variedad_flor
	)
	VALUES
	(
	@id_farm,
	@id_variedad_flor
	)
END
