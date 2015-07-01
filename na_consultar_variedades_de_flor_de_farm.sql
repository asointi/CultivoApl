/****** Object:  StoredProcedure [dbo].[na_consultar_variedades_de_flor_de_farm]    Script Date: 10/06/2007 12:10:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_variedades_de_flor_de_farm]

@id_farm int

AS
	
SELECT fvf.id_farm_variedad_flor, 
vf.*,
tf.idc_tipo_flor + ' '+ vf.idc_variedad_flor as idc_tipo_variedad_flor,
tf.nombre_tipo_flor,
c.nombre_color, 
f.nombre_farm
FROM farm_variedad_flor as fvf, 
tipo_flor as tf, 
variedad_flor as vf, 
color as c, 
farm as f
where fvf.id_farm = @id_farm
and f.id_farm = fvf.id_farm
and fvf.id_variedad_flor = vf.id_variedad_flor
and vf.id_tipo_flor = tf.id_tipo_flor
and vf.id_color = c.id_color
and vf.disponible = 1
ORDER BY tf.nombre_tipo_flor, 
vf.nombre_variedad_flor
