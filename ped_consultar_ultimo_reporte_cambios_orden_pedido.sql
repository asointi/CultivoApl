set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ped_consultar_ultimo_reporte_cambios_orden_pedido]

@id_farm int, 
@idc_tipo_factura nvarchar(255), 
@numero_reporte_farm int, 
@id_temporada_año int,
@accion nvarchar(255)

AS

declare @id_tipo_factura int

select @id_tipo_factura = id_tipo_factura 
from tipo_factura 
where idc_tipo_factura = @idc_tipo_factura

if(@idc_tipo_factura = '4')
begin
	IF(@accion = 'ultimo_reporte')
	begin
		select reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido,
		reporte_cambio_orden_pedido.fecha_transaccion,
		reporte_cambio_orden_pedido.numero_reporte_farm,
		reporte_cambio_orden_pedido.fecha_despacho_inicial_consultada,
		reporte_cambio_orden_pedido.id_farm,
		reporte_cambio_orden_pedido.id_cuenta_interna,
		reporte_cambio_orden_pedido.comentario,
		reporte_cambio_orden_pedido.id_tipo_factura,
		reporte_cambio_orden_pedido.id_temporada_año, 
		cuenta_interna.nombre 
		from reporte_cambio_orden_pedido, 
		cuenta_interna
		where reporte_cambio_orden_pedido.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		and reporte_cambio_orden_pedido.numero_reporte_farm = 
		(
			select max(reporte_cambio_orden_pedido.numero_reporte_farm)
			from reporte_cambio_orden_pedido
			where reporte_cambio_orden_pedido.id_farm = @id_farm
			and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura
			and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año
		)
		and reporte_cambio_orden_pedido.id_farm = @id_farm
		and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura
		and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año
	end
	else
	IF(@accion = 'numero_reporte')
	begin
		select cuenta_interna.nombre,
		reporte_cambio_orden_pedido.numero_reporte_farm,
		convert(nvarchar, reporte_cambio_orden_pedido.fecha_transaccion,100) as fecha_transaccion,  
		convert(nvarchar, reporte_cambio_orden_pedido.fecha_despacho_inicial_consultada,107) as fecha_despacho_inicial_consultada
		from reporte_cambio_orden_pedido, 
		cuenta_interna
		where reporte_cambio_orden_pedido.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		and reporte_cambio_orden_pedido.numero_reporte_farm = @numero_reporte_farm
		and reporte_cambio_orden_pedido.id_farm = @id_farm
		and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura
		and reporte_cambio_orden_pedido.id_temporada_año = @id_temporada_año
	end
end
else
if(@idc_tipo_factura = '9')
begin
	IF(@accion = 'ultimo_reporte')
	begin
		select reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido,
		reporte_cambio_orden_pedido.fecha_transaccion,
		reporte_cambio_orden_pedido.numero_reporte_farm,
		reporte_cambio_orden_pedido.fecha_despacho_inicial_consultada,
		reporte_cambio_orden_pedido.id_farm,
		reporte_cambio_orden_pedido.id_cuenta_interna,
		reporte_cambio_orden_pedido.comentario,
		reporte_cambio_orden_pedido.id_tipo_factura,
		reporte_cambio_orden_pedido.id_temporada_año, 
		cuenta_interna.nombre 
		from reporte_cambio_orden_pedido, cuenta_interna
		where reporte_cambio_orden_pedido.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		and reporte_cambio_orden_pedido.numero_reporte_farm = 
		(
			select max(reporte_cambio_orden_pedido.numero_reporte_farm)
			from reporte_cambio_orden_pedido
			where reporte_cambio_orden_pedido.id_farm = @id_farm
			and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura
		)
		and reporte_cambio_orden_pedido.id_farm = @id_farm
		and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura
	end
	else
	IF(@accion = 'numero_reporte')
	begin
		select cuenta_interna.nombre,
		reporte_cambio_orden_pedido.numero_reporte_farm,
		convert(nvarchar, reporte_cambio_orden_pedido.fecha_transaccion,100) as fecha_transaccion,  
		convert(nvarchar, reporte_cambio_orden_pedido.fecha_despacho_inicial_consultada,107) as fecha_despacho_inicial_consultada
		from reporte_cambio_orden_pedido, 
		cuenta_interna
		where reporte_cambio_orden_pedido.id_cuenta_interna = cuenta_interna.id_cuenta_interna
		and reporte_cambio_orden_pedido.numero_reporte_farm = @numero_reporte_farm
		and reporte_cambio_orden_pedido.id_farm = @id_farm
		and reporte_cambio_orden_pedido.id_tipo_factura = @id_tipo_factura
	end
end