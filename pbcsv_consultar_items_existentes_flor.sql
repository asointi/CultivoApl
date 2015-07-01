/****** Object:  StoredProcedure [dbo].[pbcsv_consultar_items_existentes_flor]    Script Date: 10/06/2007 13:07:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbcsv_consultar_items_existentes_flor]

@nombre_equivalencia_tipo_flor nvarchar(255), 
@nombre_equivalencia_variedad_flor nvarchar(255), 
@nombre_equivalencia_grado_flor nvarchar(255),
@id_grupo_cliente integer

AS

select gcf.id_variedad_flor, gcf.id_grado_flor, 
tf.nombre_tipo_flor, 
vf.nombre_variedad_flor, 
gf.nombre_grado_flor,
gcf.marca
from Grupo_Cliente_Flor as gcf, Grupo_Cliente as gc, Variedad_Flor as vf, Grado_Flor as gf, Tipo_Flor as tf
where gcf.id_grupo_cliente = gc.id_grupo_cliente
and gcf.id_variedad_flor = vf.id_variedad_flor
and gcf.id_grado_flor = gf.id_grado_flor
and vf.id_tipo_flor = tf.id_tipo_flor
and gf.id_tipo_flor = tf.id_tipo_flor
and vf.id_tipo_flor = gf.id_tipo_flor
and gcf.nombre_equivalencia_tipo_flor = @nombre_equivalencia_tipo_flor
and gcf.nombre_equivalencia_variedad_flor = @nombre_equivalencia_variedad_flor
and gcf.nombre_equivalencia_grado_flor = @nombre_equivalencia_grado_flor
and gc.id_grupo_cliente = @id_grupo_cliente	