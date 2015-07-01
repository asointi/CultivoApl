set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_mapeo_capuchon_decorado]

@id_cliente_pedido int,
@id_mapeo_capuchon_decorado int,
@nombre_mapeo_capuchon_decorado nvarchar(255),
@tiene_capuchon_decorado bit,
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select tiene_capuchon_decorado 
	from mapeo_capuchon_decorado
	where isnull(nombre_mapeo_capuchon_decorado,'') = isnull(@nombre_mapeo_capuchon_decorado,'')
	and id_cliente_pedido = @id_cliente_pedido
end
else
if(@accion = 'insertar')
begin
	declare @conteo int

	select @conteo = count(*)
	from mapeo_capuchon_decorado
	where mapeo_capuchon_decorado.id_cliente_pedido = @id_cliente_pedido
	and isnull(mapeo_capuchon_decorado.nombre_mapeo_capuchon_decorado,'') = isnull(@nombre_mapeo_capuchon_decorado,'')
	and mapeo_capuchon_decorado.tiene_capuchon_decorado = @tiene_capuchon_decorado

	if(@conteo = 0)
	begin
		insert into mapeo_capuchon_decorado (id_cliente_pedido, nombre_mapeo_capuchon_decorado, tiene_capuchon_decorado)
		values (@id_cliente_pedido, @nombre_mapeo_capuchon_decorado, @tiene_capuchon_decorado)

		return scope_identity()
	end
	else
		return -1
end