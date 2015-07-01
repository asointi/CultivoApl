/****** Object:  StoredProcedure [dbo].[inv_consultar_postcosecha2]    Script Date: 02/11/2008 13:47:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_generar_pivote_pieza_postcosecha] 

AS

set language spanish

select bloque.idc_bloque as Bloque,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as Tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as Variedad_flor,
finca_propia.nombre_finca_propia as Finca,
cast(pieza_postcosecha.fecha_entrada as date) as fecha,
datename(dw,pieza_postcosecha.fecha_entrada) as dia_semana,
datepart(yyyy, pieza_postcosecha.fecha_entrada) as año,
datepart(m, pieza_postcosecha.fecha_entrada) as mes,
datepart(wk, pieza_postcosecha.fecha_entrada) as semana,
sum(pieza_postcosecha.unidades_por_pieza) as unidades
from pieza_postcosecha,
variedad_flor,
tipo_flor,
bloque,
finca_bloque,
finca_propia
where variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and bloque.id_bloque = pieza_postcosecha.id_bloque
and bloque.id_bloque = finca_bloque.id_bloque
and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
and pieza_postcosecha.fecha_entrada < = getdate()
and pieza_postcosecha.fecha_entrada > = convert(datetime, cast(dateadd(yyyy, -1, getdate()) as date))
group by bloque.idc_bloque,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
finca_propia.nombre_finca_propia,
cast(pieza_postcosecha.fecha_entrada as date),
datename(dw,pieza_postcosecha.fecha_entrada),
datepart(wk, pieza_postcosecha.fecha_entrada),
datepart(yyyy, pieza_postcosecha.fecha_entrada),
datepart(m, pieza_postcosecha.fecha_entrada)