set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_editar_archivo_orden_pedido]

@id_cuenta_interna int,
@id_cliente_pedido int,
@accion nvarchar(255),
@numero_consecutivo int

as

declare @numero int

if(@accion = 'insertar')
begin
	insert into archivo_orden_pedido (id_cliente_pedido, numero_consecutivo, id_cuenta_interna)
	values (@id_cliente_pedido, @numero_consecutivo, @id_cuenta_interna)
end
else
if(@accion = 'consultar_consecutivo')
begin
	select @numero = max(numero_consecutivo) + 1
	from archivo_orden_pedido,
	cliente_pedido
	where archivo_orden_pedido.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and cliente_pedido.id_cliente_pedido = @id_cliente_pedido

	if(@numero is null)
	begin
		select max(numero_consecutivo) + 1 as numero_consecutivo
		from orden_pedido_pendiente,
		cliente_pedido
		where orden_pedido_pendiente.id_cliente_pedido = cliente_pedido.id_cliente_pedido
		and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
	end
	else
	begin
		select @numero as numero_consecutivo
	end
end