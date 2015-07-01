/****** Object:  StoredProcedure [dbo].[na_consultar_variedad_por_tipo_flor]    Script Date: 10/06/2007 12:08:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_consultar_variedad_por_tipo_flor]

@id_tipo_flor int,
@orden nvarchar(255),
@idc_tipo_flor nvarchar(10) = null

AS

SELECT vf.*,
LTRIM(RTRIM(vf.nombre_variedad_flor)) + ' [' + tf.idc_tipo_flor + vf.idc_variedad_flor + ']' as nombre_variedad_color_idc
FROM variedad_flor as vf left join color as c on vf.id_color = c.id_color,
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
and vf.id_tipo_flor = tf.id_tipo_flor 
and vf.disponible = 1
ORDER BY 
CASE @orden WHEN 'id_variedad_flor' THEN id_variedad_flor ELSE NULL END,
CASE @orden	WHEN 'idc_variedad_flor' THEN idc_variedad_flor ELSE NULL END,
CASE @orden	WHEN 'nombre_variedad_flor' THEN nombre_variedad_flor ELSE NULL END,
CASE @orden	WHEN 'nombre_tipo_flor' THEN nombre_variedad_flor ELSE NULL END