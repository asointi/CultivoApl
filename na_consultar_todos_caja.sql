set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_todos_caja]

@orden nvarchar(255)

AS

SELECT tipo_caja.id_tipo_caja,
caja.id_caja,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
ltrim(rtrim(caja.nombre_caja)) + space(1) + '['+tipo_caja.idc_tipo_caja + caja.idc_caja+']' as nombre_caja,
caja.medida
FROM tipo_caja,
caja
WHERE caja.disponible = 1
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
ORDER BY 
CASE @orden WHEN 'id_caja' THEN id_caja ELSE NULL END,
CASE @orden	WHEN 'idc_caja' THEN idc_caja ELSE NULL END,
CASE @orden	WHEN 'nombre_caja' THEN nombre_caja ELSE NULL END,
CASE @orden	WHEN '' THEN nombre_caja ELSE NULL END