SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[prod_consultar_produccion_por_fecha]

@fecha_inicial datetime,
@fecha_final datetime

as

select pieza_postcosecha.idc_pieza_postcosecha,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
bloque.idc_bloque,
entrada.fecha_transaccion as fecha_entrada,
salida_pieza.fecha_salida,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
pieza_postcosecha.unidades_por_pieza
from pieza_postcosecha left join salida_pieza on pieza_postcosecha.id_pieza_postcosecha = salida_pieza.id_pieza_postcosecha
left join cliente_despacho on cliente_despacho.id_cliente_despacho = salida_pieza.id_cliente_despacho,
tipo_flor,
variedad_flor,
bloque,
entrada
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza_postcosecha.id_variedad_flor
and bloque.id_bloque = pieza_postcosecha.id_bloque
and pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) > = @fecha_inicial
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) < = @fecha_final
