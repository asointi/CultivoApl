set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ord_mapeo_tapa]

@id_cliente_pedido int,
@id_tapa int,
@id_mapeo_tapa int,
@nombre_mapeo_tapa nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select tapa.id_tapa, 
	tapa.nombre_tapa + space(1) + '[' + tapa.idc_tapa + ']' as nombre_tapa
	from mapeo_tapa, 
	tapa
	where isnull(nombre_mapeo_tapa,'') = isnull(@nombre_mapeo_tapa,'')
	and mapeo_tapa.id_cliente_pedido = @id_cliente_pedido
	and	mapeo_tapa.id_tapa = tapa.id_tapa	
	and tapa.disponible = 1
	order by tapa.nombre_tapa
end
else
if(@accion = 'insertar')
begin
	declare @conteo int

	select count(*)
	from mapeo_tapa
	where mapeo_tapa.id_cliente_pedido = @id_cliente_pedido
	and mapeo_tapa.id_tapa = @id_tapa
	and isnull(mapeo_tapa.nombre_mapeo_tapa,'') = @nombre_mapeo_tapa

	if(@conteo = 0)
	begin
		insert into mapeo_tapa (id_cliente_pedido, id_tapa, nombre_mapeo_tapa)
		values (@id_cliente_pedido, @id_tapa, @nombre_mapeo_tapa)

		return scope_identity()
	end
	else
		return -1
end





