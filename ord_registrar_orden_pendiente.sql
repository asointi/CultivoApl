set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_registrar_orden_pendiente]

@id_cuenta_interna int,
@id_cliente_pedido int,
@id_temporada_año int,
@id_orden_pedido_pendiente int,
@accion nvarchar(255)

as

declare @fresca nvarchar(255),
@natural nvarchar(255),
@nombre_cliente_pedido nvarchar(255),
@conteo int,
@numero_consecutivo int, 
@id_orden_pedido int,
@id_archivo_orden_pedido int

set @fresca = 'NAUSFFR'
set @natural = 'NAUSNF'
set @nombre_cliente_pedido = 'Preventas'

if(@accion = 'insertar')
begin
	select @conteo = count(*) 
	from cliente_despacho,
	cliente_pedido
	where cliente_despacho.id_cliente_despacho = cliente_pedido.id_cliente_despacho
	and (cliente_despacho.idc_cliente_despacho = @fresca
	or cliente_despacho.idc_cliente_despacho = @natural)
	and cliente_pedido.nombre_cliente_pedido = @nombre_cliente_pedido
	and cliente_pedido.id_cliente_pedido = @id_cliente_pedido

	if(@conteo = 0)
	begin
		select @numero_consecutivo = max(numero_consecutivo) + 1
		from orden_pedido_pendiente,
		cliente_pedido
		where orden_pedido_pendiente.id_cliente_pedido = cliente_pedido.id_cliente_pedido
		and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
	end
	else
	begin
		select @numero_consecutivo = max(numero_consecutivo) + 1
		from orden_pedido_pendiente,
		cliente_pedido,
		temporada_año
		where orden_pedido_pendiente.id_cliente_pedido = cliente_pedido.id_cliente_pedido
		and orden_pedido_pendiente.id_temporada_año = temporada_año.id_temporada_año
		and temporada_año.id_cliente_pedido = @id_cliente_pedido
		and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
		and temporada_año.id_temporada_año = @id_temporada_año
	end

	if (@numero_consecutivo is null)
	begin
		set @numero_consecutivo = 1
	end

	select @id_archivo_orden_pedido = archivo_orden_pedido.id_archivo_orden_pedido
	from archivo_orden_pedido
	where archivo_orden_pedido.id_cliente_pedido = @id_cliente_pedido
	and archivo_orden_pedido.numero_consecutivo = @numero_consecutivo

	insert into orden_pedido_pendiente (id_cuenta_interna,id_cliente_pedido,fecha_transaccion, numero_consecutivo, id_temporada_año, id_archivo_orden_pedido)
	values (@id_cuenta_interna, @id_cliente_pedido, getdate(), @numero_consecutivo, @id_temporada_año, @id_archivo_orden_pedido)

	set @id_orden_pedido = scope_identity() 
	select @id_orden_pedido as id_orden_pedido_pendiente, 
	@numero_consecutivo as numero_consecutivo
end
else
if(@accion = 'consultar')
begin
	select sum(cantidad_piezas) as cantidad_piezas, 
	sum(tipo_caja.factor_a_full * cantidad_piezas) as cantidad_full
	from orden_pedido_pendiente, 
	item_orden_pedido_pendiente, 
	caja, 
	tipo_caja
	where orden_pedido_pendiente.id_orden_pedido_pendiente = item_orden_pedido_pendiente.id_orden_pedido_pendiente
	and orden_pedido_pendiente.id_orden_pedido_pendiente = @id_orden_pedido_pendiente
	and item_orden_pedido_pendiente.id_caja = caja.id_caja
	and caja.id_tipo_caja = tipo_caja.id_tipo_caja
end




