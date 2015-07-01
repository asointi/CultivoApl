set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_etiqueta_web] 

@codigo_etiqueta nvarchar(20),
@idc_pieza nvarchar(20)

as

declare @codigo nvarchar(20)

select @codigo = etiqueta_creci.etiqueta 
from etiqueta_creci
where etiqueta_creci.creci = @idc_pieza

select etiqueta.codigo as codigo_etiqueta,
isnull(etiqueta_creci.creci, '') as idc_pieza,
farm.idc_farm,
farm.nombre_farm,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
caja.nombre_caja,
etiqueta.marca,
etiqueta.unidades_por_caja,
etiqueta.usuario,
convert(datetime,convert(nvarchar,etiqueta.fecha, 103)) as fecha
from etiqueta LEFT JOIN etiqueta_creci on etiqueta.codigo = etiqueta_creci.etiqueta,
farm,
tipo_flor,
variedad_flor,
grado_flor,
tapa,
tipo_caja,
caja
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and farm.idc_farm = etiqueta.farm
and tipo_flor.idc_tipo_flor = etiqueta.tipo
and variedad_flor.idc_variedad_flor = etiqueta.variedad
and grado_flor.idc_grado_flor = etiqueta.grado
and tapa.idc_tapa = etiqueta.tapa
and tipo_caja.idc_tipo_caja + caja.idc_caja = etiqueta.tipo_caja
and etiqueta.codigo > =
case
	when @codigo_etiqueta = '' then @codigo
	else @codigo_etiqueta
end
and etiqueta.codigo < =
case
	when @codigo_etiqueta = '' then @codigo
	else @codigo_etiqueta
end