set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_consultar_todos_tapa]

@orden nvarchar(255)

AS

SELECT tapa.id_tapa,
tapa.idc_tapa,
tapa.idc_tapa + space(1) + '[' + ltrim(rtrim(tapa.nombre_tapa)) + ']' as nombre_tapa,
tapa.disponible,
tapa.id_cuenta_interna,
tapa.idc_tapa_cultivo
FROM tapa
where disponible = 1
ORDER BY 
CASE @orden WHEN 'id_tapa' THEN id_tapa ELSE NULL END,
CASE @orden	WHEN 'idc_tapa' THEN idc_tapa ELSE NULL END,
CASE @orden	WHEN 'nombre_tapa' THEN nombre_tapa ELSE NULL END,
CASE @orden	WHEN '' THEN nombre_tapa ELSE NULL END
