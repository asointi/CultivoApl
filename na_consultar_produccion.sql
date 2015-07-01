set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-01-13
-- Description:	extraer informacion de propietarios de camas
-- =============================================

alter PROCEDURE [dbo].[na_consultar_produccion]

@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255)

AS

select tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) as fecha,
bloque.idc_bloque,
sum(pieza_postcosecha.unidades_por_pieza) as unidades
from pieza_postcosecha, 
variedad_flor, 
bloque, 
tipo_flor
where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza_postcosecha.id_bloque = bloque.id_bloque
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101))
between convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
group by tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)),
bloque.idc_bloque
order by convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101))