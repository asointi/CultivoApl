set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[ord_consultar_orden_pendiente]

@idc_cliente_despacho nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'pendientes')
begin
	select item_orden_pedido_pendiente.id_item_orden_pedido_pendiente,
	cliente_despacho.idc_cliente_despacho,
	flor.idc_flor,	
	item_orden_pedido_pendiente.numero_surtido,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja, 
	item_orden_pedido_pendiente.code,
	item_orden_pedido_pendiente.cantidad_piezas,
	item_orden_pedido_pendiente.unidades_por_pieza,
	item_orden_pedido_pendiente.upc,
	item_orden_pedido_pendiente.precio_upc,
	item_orden_pedido_pendiente.fecha_vencimiento_flor,
	case
		when item_orden_pedido_pendiente.capuchon_decorado = 1 then 'X'
		else ''
	end as capuchon_decorado,
	case
		when item_orden_pedido_pendiente.comida = 1 then 'X'
		else ''
	end as comida,
	item_orden_pedido_pendiente.fecha_despacho,
	item_orden_pedido_pendiente.formato_especial_fecha_vencimiento,
	item_orden_pedido_pendiente.precio_distribuidora
	from orden_pedido_pendiente, 
	item_orden_pedido_pendiente,
	cliente_despacho,
	cliente_pedido,
	tapa,
	flor,
	tipo_caja,
	caja
	where orden_pedido_pendiente.id_orden_pedido_pendiente = item_orden_pedido_pendiente.id_orden_pedido_pendiente
	and orden_pedido_pendiente.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and cliente_pedido.id_cliente_despacho = cliente_despacho.id_cliente_despacho
	and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	and item_orden_pedido_pendiente.idc_orden_pedido is null
	and item_orden_pedido_pendiente.id_tapa = tapa.id_tapa
	and item_orden_pedido_pendiente.id_flor = flor.id_flor
	and item_orden_pedido_pendiente.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	order by
	flor.idc_flor,
	item_orden_pedido_pendiente.numero_surtido,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja,
	caja.idc_caja,
	item_orden_pedido_pendiente.cantidad_piezas,
	item_orden_pedido_pendiente.unidades_por_pieza
end

if(@accion = 'procesadas')
begin
	select 
	item_orden_pedido_pendiente.id_item_orden_pedido_pendiente,
	item_orden_pedido_pendiente.idc_orden_pedido,
	cliente_despacho.idc_cliente_despacho,
	flor.idc_flor,
	item_orden_pedido_pendiente.numero_surtido,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja, 
	item_orden_pedido_pendiente.code,
	item_orden_pedido_pendiente.cantidad_piezas,
	item_orden_pedido_pendiente.unidades_por_pieza,
	item_orden_pedido_pendiente.upc,
	item_orden_pedido_pendiente.precio_upc,
	item_orden_pedido_pendiente.fecha_vencimiento_flor,
	case
		when item_orden_pedido_pendiente.capuchon_decorado = 1 then 'X'
		else ''
	end as capuchon_decorado,
	case
		when item_orden_pedido_pendiente.comida = 1 then 'X'
		else ''
	end as comida,
	item_orden_pedido_pendiente.fecha_despacho,
	item_orden_pedido_pendiente.formato_especial_fecha_vencimiento,
	item_orden_pedido_pendiente.precio_distribuidora
	from orden_pedido_pendiente, 
	item_orden_pedido_pendiente,
	cliente_despacho,
	cliente_pedido,
	tapa,
	flor,
	tipo_caja,
	caja
	where orden_pedido_pendiente.id_orden_pedido_pendiente = item_orden_pedido_pendiente.id_orden_pedido_pendiente
	and orden_pedido_pendiente.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and cliente_pedido.id_cliente_despacho = cliente_despacho.id_cliente_despacho
	and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	and item_orden_pedido_pendiente.idc_orden_pedido is not null
	and item_orden_pedido_pendiente.id_tapa = tapa.id_tapa
	and item_orden_pedido_pendiente.id_flor = flor.id_flor
	and item_orden_pedido_pendiente.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	order by
	flor.idc_flor,
	item_orden_pedido_pendiente.numero_surtido,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja,
	caja.idc_caja,
	item_orden_pedido_pendiente.cantidad_piezas,
	item_orden_pedido_pendiente.unidades_por_pieza
end