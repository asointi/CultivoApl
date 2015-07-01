set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_produccion_por_fecha]

@fecha_inicial datetime,
@fecha_final datetime

as

select persona.idc_persona,
ltrim(rtrim(persona.nombre)) as nombre_persona,
ltrim(rtrim(persona.apellido)) as nombre_apellido,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
bloque.idc_bloque,
punto_corte.idc_punto_corte,
convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) as fecha,
sum(pieza_postcosecha.unidades_por_pieza) as unidades,
count(pieza_postcosecha.id_pieza_postcosecha) as piezas,
entrada.usuario_cobol,
entrada.computador,
entrada.sesion
from pieza_postcosecha left join entrada on pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha,
variedad_flor,
tipo_flor,
bloque,
persona,
punto_corte
where variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza_postcosecha.id_bloque = bloque.id_bloque
and pieza_postcosecha.id_persona = persona.id_persona
and pieza_postcosecha.id_punto_corte = punto_corte.id_punto_corte
and convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) > = @fecha_inicial
and convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)) < = @fecha_final
group by persona.idc_persona,
persona.nombre,
persona.apellido,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
bloque.idc_bloque,
punto_corte.idc_punto_corte,
convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)),
entrada.usuario_cobol,
entrada.computador,
entrada.sesion
order by convert(datetime,convert(nvarchar, pieza_postcosecha.fecha_entrada, 101)),
persona.idc_persona,
persona.nombre,
persona.apellido,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
bloque.idc_bloque
