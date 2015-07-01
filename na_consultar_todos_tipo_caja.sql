set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_consultar_todos_tipo_caja]

@orden nvarchar(255)

AS

SELECT tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) + space(1) + '['+tipo_caja.idc_tipo_caja+']' as nombre_tipo_caja,
tipo_caja.factor_a_full,
tipo_caja.descripcion,
tipo_caja.disponible,
tipo_caja.id_cuenta_interna
FROM tipo_caja
WHERE disponible = 1
ORDER BY 
CASE @orden WHEN 'id_tipo_caja' THEN id_tipo_caja ELSE NULL END,
CASE @orden	WHEN 'idc_tipo_caja' THEN idc_tipo_caja ELSE NULL END,
CASE @orden	WHEN 'nombre_tipo_caja' THEN nombre_tipo_caja ELSE NULL END,
CASE @orden	WHEN '' THEN nombre_tipo_caja ELSE NULL END

