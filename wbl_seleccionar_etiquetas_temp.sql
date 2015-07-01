/****** Object:  StoredProcedure [dbo].[wbl_seleccionar_etiquetas_temp]    Script Date: 10/06/2007 12:52:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_seleccionar_etiquetas_temp]

@usuario NVARCHAR(255), 
@farm NVARCHAR(255)

AS
BEGIN
	SELECT idTemp, usuario, farm, tipo, variedad, grado, 
	tapa, tipo_caja, marca, unidades_por_caja, fecha, cantidad, 
    unidades_por_caja * cantidad AS TotalUnds_Pieza
	FROM ETIQUETA_TEMP_USER
	WHERE usuario = @usuario AND farm = @farm AND
	unidades_por_caja*cantidad > 0
	ORDER BY Fecha asc
END
