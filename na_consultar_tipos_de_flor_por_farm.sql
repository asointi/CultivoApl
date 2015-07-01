/****** Object:  StoredProcedure [dbo].[na_consultar_tipos_de_flor_por_farm]    Script Date: 10/06/2007 12:01:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_tipos_de_flor_por_farm]

@id_farm int

AS

SELECT *, nombre_tipo_flor + '(' + idc_tipo_flor + ')' as nombre_tipo_flor_idc
FROM tipo_flor
WHERE disponible = 1
AND id_tipo_flor in (SELECT id_tipo_flor FROM Producto_Farm WHERE id_farm = @id_farm)
ORDER BY nombre_tipo_flor

