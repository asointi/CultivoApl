SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[apr_ord_consultar_preventas_repetidas]

@idc_cliente_despacho nvarchar(20),
@idc_transportador nvarchar(20),
@idc_farm nvarchar(20),
@code nvarchar(20),
@idc_tipo_flor nvarchar(20),
@idc_variedad_flor nvarchar(20),
@idc_grado_flor nvarchar(20),
@idc_caja nvarchar(20),
@unidades_por_pieza int,
@fecha datetime,
@idc_orden_pedido nvarchar(20)

as

declare @conteo int

select @conteo = count(*) 
from tipo_factura,
orden_sin_aprobar,
item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
confirmacion_orden_especial_cultivo,
orden_especial_confirmada,
orden_pedido,
cliente_despacho,
transportador,
farm,
tipo_flor,
variedad_flor,
grado_flor,
tipo_caja,
caja
where tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo = orden_especial_confirmada.id_confirmacion_orden_especial_cultivo
and orden_especial_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
and tipo_factura.idc_tipo_factura = '4'
and orden_sin_aprobar.id_despacho = cliente_despacho.id_despacho
and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
and item_orden_sin_aprobar.id_transportador = transportador.id_transportador
and transportador.idc_transportador = @idc_transportador
and item_orden_sin_aprobar.id_farm = farm.id_farm
and farm.idc_farm = @idc_farm
and item_orden_sin_aprobar.code = @code
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.unidades_por_pieza = @unidades_por_pieza
and item_orden_sin_aprobar.fecha_inicial = @fecha
and convert(int, orden_pedido.idc_orden_pedido) <> convert(int, @idc_orden_pedido)

select @conteo as cantidad_preventas