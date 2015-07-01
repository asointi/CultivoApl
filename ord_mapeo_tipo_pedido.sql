set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_mapeo_tipo_pedido]

@id_cliente_pedido int,
@id_mapeo_tipo_pedido int,
@id_tipo_pedido int,
@nombre_mapeo_order_type nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select tipo_pedido.id_tipo_pedido, 
	tipo_pedido.nombre_tipo_pedido + space(1) + '[' + tipo_pedido.idc_tipo_pedido + ']' as nombre_tipo_pedido
	from mapeo_tipo_pedido, 
	tipo_pedido
	where isnull(nombre_mapeo_order_type,'') = isnull(@nombre_mapeo_order_type,'')
	and id_cliente_pedido = @id_cliente_pedido
	and	mapeo_tipo_pedido.id_tipo_pedido = tipo_pedido.id_tipo_pedido	
	order by nombre_tipo_pedido
end
else
if(@accion = 'insertar')
begin
	declare @conteo int

	select @conteo = count(*)
	from mapeo_tipo_pedido 
	where mapeo_tipo_pedido.id_cliente_pedido = @id_cliente_pedido
	and mapeo_tipo_pedido.id_tipo_pedido = @id_tipo_pedido
	and isnull(mapeo_tipo_pedido.nombre_mapeo_order_type,'') = isnull(@nombre_mapeo_order_type,'')

	if(@conteo = 0)
	begin
		insert into mapeo_tipo_pedido (id_cliente_pedido, id_tipo_pedido, nombre_mapeo_order_type)
		values (@id_cliente_pedido, @id_tipo_pedido, @nombre_mapeo_order_type)

		return scope_identity()
	end
	else
		return -1
end