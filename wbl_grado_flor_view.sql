SELECT     TOP (100) PERCENT id_tipo_flor AS id_tipo, idc_grado_flor AS LlaveTafTaf, RTRIM(LTRIM(nombre_grado_flor)) AS NombreTaf
FROM         dbo.Grado_Flor
WHERE     (disponible = 1)
ORDER BY NombreTaf