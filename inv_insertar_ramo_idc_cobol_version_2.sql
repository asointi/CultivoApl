set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 06/06/07
-- =============================================
alter PROCEDURE [dbo].[inv_insertar_ramo_idc_cobol_version_2] 

@idc_grado_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_tipo_flor nvarchar(5),
@idc_ramo nvarchar(25),
@tallos_por_ramo int,
@fecha nvarchar(25),
@hora nvarchar(25),
@idc_punto_corte nvarchar(25),
@idc_persona nvarchar(25)

AS

INSERT INTO Ramo
(
	id_grado_flor, 
	id_variedad_flor, 
	idc_ramo, 
	tallos_por_ramo, 
	fecha_entrada, 
	id_punto_corte,
	id_persona
)
select gf.id_grado_flor, 
vf.id_variedad_flor, 
@idc_ramo, 
@tallos_por_ramo, 
[dbo].[concatenar_fecha_hora_COBOL] (@fecha, @hora),
punto_corte.id_punto_corte,
persona.id_persona
from Grado_Flor as gf, 
Variedad_Flor as vf, 
Tipo_Flor as tf, 
punto_corte,
persona
where tf.idc_tipo_flor = @idc_tipo_flor
and vf.idc_variedad_flor = @idc_variedad_flor
and tf.id_tipo_flor = vf.id_tipo_flor
and gf.idc_grado_flor = @idc_grado_flor
and tf.id_tipo_flor = gf.id_tipo_flor
and punto_corte.idc_punto_corte = @idc_punto_corte
and persona.idc_persona = @idc_persona