set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_consultar_composicion_grado_flor]

@idc_tipo_flor nvarchar(255),
@idc_grado_flor nvarchar(255)

as

select tipo_flor.idc_tipo_flor,
grado_flor.idc_grado_flor 
from composicion_grado_flor, 
grado_flor,
tipo_flor
where composicion_grado_flor.id_grado_flor_grupo_grado_flor = 
(
select grupo_grado_flor.id_grado_flor 
from grado_flor,
tipo_flor,
grupo_grado_flor
where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.id_grado_flor = grupo_grado_flor.id_grado_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
)
and  composicion_grado_flor.id_grado_flor_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
order by tipo_flor.idc_tipo_flor,
grado_flor.idc_grado_flor 