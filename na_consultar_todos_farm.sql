/****** Object:  StoredProcedure [dbo].[na_consultar_todos_farm]    Script Date: 10/06/2007 12:04:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_todos_farm]

@orden nvarchar(255)

AS

SELECT id_farm,
idc_farm, 
id_tipo_farm,
id_ciudad,
idc_farm + space(1) + '['+ ltrim(rtrim(nombre_farm)) + ']'as nombre_farm, 
ltrim(rtrim(nombre_farm)) + space(1) + '['+ idc_farm + ']'as nombre_farm_invertido, 
observacion, 
disponible,
tiene_variedad_flor_exclusiva,
comision_farm,
dias_restados_despacho_distribuidora,
id_cuenta_interna,
bloqueada,
case
	when len(correo) > 7 then 1
	else 0
end as tiene_correo
FROM farm
WHERE disponible = 1
ORDER BY 
CASE @orden WHEN 'id_farm' THEN id_farm ELSE NULL END,
CASE @orden	WHEN 'idc_farm' THEN idc_farm ELSE NULL END,
CASE @orden	WHEN 'nombre_farm' THEN nombre_farm ELSE NULL END,
CASE @orden	WHEN '' THEN idc_farm ELSE NULL END