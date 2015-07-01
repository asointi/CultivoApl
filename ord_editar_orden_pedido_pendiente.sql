set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_editar_orden_pedido_pendiente]

@accion nvarchar(255),
@id_cliente_pedido int,
@id_temporada_año int

AS

declare @fresca nvarchar(255),
@natural nvarchar(255),
@nombre_cliente_pedido nvarchar(255),
@conteo int,
@numero int,
@control int

set @fresca = 'NAUSFFR'
set @natural = 'NAUSNF'
set @nombre_cliente_pedido = 'Preventas'

if(@accion = 'consultar_consecutivo')
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
		select @numero = max(numero_consecutivo) + 1
		from orden_pedido_pendiente,
		cliente_pedido
		where orden_pedido_pendiente.id_cliente_pedido = cliente_pedido.id_cliente_pedido
		and cliente_pedido.id_cliente_pedido = @id_cliente_pedido

		select @conteo = count(*)
		from archivo_orden_pedido,
		cliente_pedido
		where archivo_orden_pedido.id_cliente_pedido = cliente_pedido.id_cliente_pedido
		and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
		and archivo_orden_pedido.numero_consecutivo = @numero

		if(@conteo = 0)
		begin
			set @control = -2
			select @control as control, 
			@numero as numero_consecutivo
		end
		else
		begin
			set @control = 0
			select @control as control, 
			@numero as numero_consecutivo
		end
	end
	else
	begin
		select max(numero_consecutivo) + 1 as numero_consecutivo
		from orden_pedido_pendiente,
		cliente_pedido,
		temporada_año
		where orden_pedido_pendiente.id_cliente_pedido = cliente_pedido.id_cliente_pedido
		and orden_pedido_pendiente.id_temporada_año = temporada_año.id_temporada_año
		and temporada_año.id_cliente_pedido = @id_cliente_pedido
		and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
		and temporada_año.id_temporada_año = @id_temporada_año
	end
end