set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[pyg_generar_reportes] 

@fecha_inicial datetime, 
@fecha_final datetime,
@id_grupo_flor int

as

declare @idc_farm nvarchar(5)

set @idc_farm = 'N5'

select sum(pieza.unidades_por_pieza * costo_por_unidad) as costo
from guia,
pieza,
variedad_flor,
farm
--grupo_flor,
--grupo_flor_variedad_flor
where guia.id_guia = pieza.id_guia
and guia.fecha_guia between
@fecha_inicial and @fecha_final
and pieza.costo_por_unidad <> 99999.9999
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
--and variedad_flor.id_variedad_flor = grupo_flor_variedad_flor.id_variedad_flor
--and grupo_flor.id_grupo_flor = grupo_flor_variedad_flor.id_grupo_flor
--and grupo_flor.id_grupo_flor = @id_grupo_flor
and farm.id_farm = pieza.id_farm
and farm.idc_farm = @idc_farm