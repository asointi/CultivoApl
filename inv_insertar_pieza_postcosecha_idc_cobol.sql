set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 06/06/07
-- Description:	<Description,,>
-- =============================================

ALTER PROCEDURE [dbo].[inv_insertar_pieza_postcosecha_idc_cobol] 
@idc_grado_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_bloque nvarchar(255),
@idc_pieza_postcosecha nvarchar(255),
@idc_persona nvarchar(255),
@unidades_por_pieza int,
@fecha nvarchar(255),
@hora nvarchar(255),
@idc_punto_corte nvarchar(255)

AS

INSERT INTO Pieza_Postcosecha
(id_caracteristica_tipo_flor, id_variedad_flor, id_bloque, idc_pieza_postcosecha, id_persona, unidades_por_pieza, fecha_entrada, id_punto_corte)
select ctf.id_caracteristica_tipo_flor, 
vf.id_variedad_flor, 
b.id_bloque, 
@idc_pieza_postcosecha, 
p.id_persona, 
@unidades_por_pieza, 
(CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)), 
punto_corte.id_punto_corte
from caracteristica_tipo_flor as ctf, 
Variedad_Flor as vf, 
Tipo_Flor as tf, 
Bloque as b, 
Persona as p,
punto_corte
where @idc_tipo_flor+@idc_variedad_flor = tf.idc_tipo_flor+vf.idc_variedad_flor
and tf.id_tipo_flor=vf.id_tipo_flor
and ctf.id_tipo_flor = tf.id_tipo_flor
and ltrim(rtrim(ctf.nombre_caracteristica_tipo_flor)) = ltrim(rtrim(@idc_grado_flor))
and b.idc_bloque=@idc_bloque
and p.idc_persona = @idc_persona
and punto_corte.idc_punto_corte = @idc_punto_corte