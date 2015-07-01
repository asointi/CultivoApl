set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/29
-- Description:	cambia la finca y los precios de cultivo en las ordenes fijas de SUNBURST
-- =============================================

create PROCEDURE [dbo].[apr_ord_cambiar_finca_precio_finca_so] 

@idc_farm nvarchar(5),
@id_item_orden_sin_aprobar int,
@precio_finca decimal(20,4),
@accion nvarchar(255)

as

declare @id_farm int

if(@accion = 'consultar')
begin
	select orden_pedido.id_orden_pedido,
	orden_pedido.idc_orden_pedido,
	item_orden_sin_aprobar.id_item_orden_sin_aprobar,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	farm.idc_farm,
	farm.nombre_farm,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	transportador.idc_transportador,
	transportador.nombre_transportador,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	caja.idc_caja,
	caja.nombre_caja,
	vendedor.idc_vendedor,
	vendedor.nombre as nombre_vendedor,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente as nombre_cliente_despacho,
	orden_pedido.fecha_inicial,
	orden_pedido.fecha_final,
	orden_pedido.marca,
	orden_pedido.unidades_por_pieza,
	orden_pedido.cantidad_piezas,
	orden_pedido.comentario,
	case
		when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
		else item_orden_sin_aprobar.valor_pactado_cobol
	end as precio_finca
	from orden_pedido,
	orden_confirmada,
	confirmacion_orden_cultivo,
	solicitud_confirmacion_orden,
	aprobacion_orden,
	item_orden_sin_aprobar,
	orden_sin_aprobar,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	transportador,
	tipo_caja,
	vendedor,
	cliente_despacho,
	caja
	where orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
	and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
	and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
	and confirmacion_orden_cultivo.id_confirmacion_orden_cultivo = orden_confirmada.id_confirmacion_orden_cultivo
	and orden_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
	and item_orden_sin_aprobar.id_farm = farm.id_farm
	and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
	and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
	and item_orden_sin_aprobar.id_transportador = transportador.id_transportador
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = item_orden_sin_aprobar.id_caja
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and vendedor.id_vendedor = orden_pedido.id_vendedor
	and cliente_despacho.id_despacho = orden_pedido.id_despacho
	and farm.idc_farm = 'Z0'
	order by cliente_despacho.idc_cliente_despacho,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor	
end
else
if(@accion = 'modificar')
begin
	select @id_farm = id_farm
	from farm
	where idc_farm = @idc_farm

	update item_orden_sin_aprobar
	set valor_pactado_interno = @precio_finca,
	id_farm = @id_farm
	where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
end