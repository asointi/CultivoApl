SELECT     TOP (100) PERCENT idc_variedad_flor AS LlaveVfVf, nombre_variedad_flor AS NombreVf, id_tipo_flor AS id_tipo
FROM         dbo.Variedad_Flor
WHERE     (disponible = 1)
ORDER BY NombreVf