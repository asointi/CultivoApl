set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[apr_ord_consultar_detalle_comentarios]

@id_item_orden_sin_aprobar int,
@idc_tipo_orden nvarchar(1)

as

declare @id_item_orden_sin_aprobar_padre int

select @id_item_orden_sin_aprobar_padre = id_item_orden_sin_aprobar_padre 
from item_orden_sin_aprobar
where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

select ltrim(rtrim(transportador.idc_transportador)) as idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) as idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
ltrim(rtrim(tipo_flor.idc_tipo_flor)) as idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
ltrim(rtrim(variedad_flor.idc_variedad_flor)) as idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
ltrim(rtrim(grado_flor.idc_grado_flor)) as idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
ltrim(rtrim(farm.idc_farm)) as idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
ltrim(rtrim(tapa.idc_tapa)) as idc_tapa,
ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
ltrim(rtrim(item_orden_sin_aprobar.code)) as code,
ltrim(rtrim(item_orden_sin_aprobar.comentario)) as comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.valor_unitario,
ltrim(rtrim(item_orden_sin_aprobar.usuario_cobol)) as usuario_cobol,
item_orden_sin_aprobar.box_charges,
ltrim(rtrim(item_orden_sin_aprobar.observacion)) as observacion
from item_orden_sin_aprobar,
transportador,
orden_sin_aprobar,
cliente_despacho,
tipo_flor,
variedad_flor,
grado_flor,
farm,
tapa,
tipo_caja,
caja
where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
and item_orden_sin_aprobar.usuario_cobol <> 'USUARIO SQL'
and item_orden_sin_aprobar.id_transportador = transportador.id_transportador
and item_orden_sin_aprobar.id_orden_sin_aprobar = orden_sin_aprobar.id_orden_sin_aprobar
and orden_sin_aprobar.id_despacho = cliente_despacho.id_despacho
and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and item_orden_sin_aprobar.id_farm = farm.id_farm
and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
order by item_orden_sin_aprobar.id_item_orden_sin_aprobar