/****** Object:  StoredProcedure [dbo].[na_consultar_caja_por_tipo_caja]    Script Date: 05/03/2008 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_consultar_caja_por_tipo_caja]

@id_tipo_caja int,
@orden nvarchar(255)

AS

SELECT caja.id_caja,
caja.id_tipo_caja,
caja.idc_caja,
ltrim(rtrim(caja.nombre_caja)) + ' [' + tipo_caja.idc_tipo_caja + caja.idc_caja + '] (' + ltrim(rtrim(caja.medida)) + ')' as nombre_caja,
caja.medida,
caja.disponible,
caja.medida_largo,
caja.medida_ancho,
caja.medida_alto,
caja.id_cuenta_interna,
caja.idc_caja_cultivo
FROM caja,
tipo_caja
WHERE caja.disponible = 1
and caja.id_tipo_caja = tipo_caja.id_tipo_caja
and tipo_caja.id_tipo_caja > = 
case
	when @id_tipo_caja = 0 then 1
	else @id_tipo_caja
end
and tipo_caja.id_tipo_caja < = 
case
	when @id_tipo_caja = 0 then 999999
	else @id_tipo_caja
end
ORDER BY 
CASE @orden WHEN 'id_caja' THEN caja.id_caja ELSE NULL END,
CASE @orden	WHEN 'idc_caja' THEN caja.idc_caja ELSE NULL END,
CASE @orden	WHEN 'nombre_caja' THEN caja.nombre_caja ELSE NULL END,
CASE @orden	WHEN '' THEN caja.nombre_caja ELSE NULL END