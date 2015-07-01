set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 06/06/07
-- =============================================
ALTER PROCEDURE [dbo].[inv_insertar_ramo_idc_cobol] 

@idc_grado_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_ramo nvarchar(255),
@tallos_por_ramo int,
@fecha nvarchar(255),
@hora nvarchar(255),
@idc_punto_corte nvarchar(255)

AS

INSERT INTO Ramo
(id_grado_flor, id_variedad_flor, idc_ramo, tallos_por_ramo, fecha_entrada, id_punto_corte)
select gf.id_grado_flor, vf.id_variedad_flor, @idc_ramo, @tallos_por_ramo, (CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) 
+':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)), punto_corte.id_punto_corte
from Grado_Flor as gf, Variedad_Flor as vf, Tipo_Flor as tf, punto_corte
where @idc_tipo_flor+@idc_variedad_flor = tf.idc_tipo_flor+vf.idc_variedad_flor
and tf.id_tipo_flor=vf.id_tipo_flor
and @idc_tipo_flor+@idc_grado_flor = tf.idc_tipo_flor+gf.idc_grado_flor
and tf.id_tipo_flor=gf.id_tipo_flor
and punto_corte.idc_punto_corte = @idc_punto_corte