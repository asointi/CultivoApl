/****** Object:  StoredProcedure [dbo].[na_consultar_grado_por_tipo_flor]    Script Date: 10/06/2007 12:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_grado_por_tipo_flor]

@id_tipo_flor int,
@orden nvarchar(255),
@idc_tipo_flor nvarchar(10) = null

AS

SELECT gf.*, 
LTRIM(RTRIM(gf.nombre_grado_flor)) + ' [' + tf.idc_tipo_flor + gf.idc_grado_flor + ']' as nombre_grado_idc
FROM grado_flor as gf, 
tipo_flor as tf
where tf.id_tipo_flor > = 
case
	when @id_tipo_flor = 0 then 0
	else @id_tipo_flor
end
and tf.id_tipo_flor < = 
case
	when @id_tipo_flor = 0 then 999999
	else @id_tipo_flor
end
and gf.id_tipo_flor = tf.id_tipo_flor
and gf.disponible = 1
and tf.idc_tipo_flor > = 
case
	when @idc_tipo_flor is null then '  '
	else @idc_tipo_flor
end
and tf.idc_tipo_flor < = 
case
	when @idc_tipo_flor is null then 'ZZ'
	else @idc_tipo_flor
end
ORDER BY 
CASE @orden WHEN 'id_grado_flor' THEN id_grado_flor ELSE NULL END,
CASE @orden	WHEN 'idc_grado_flor' THEN idc_grado_flor ELSE NULL END,
CASE @orden	WHEN 'nombre_grado_flor' THEN nombre_grado_flor ELSE NULL END