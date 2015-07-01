set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_mapeo_numero_surtido]

@id_mapeo_caja int,
@id_mapeo_numero_surtido int,
@nombre_mapeo_mark nvarchar(255),
@id_surtido_flor int,
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select top 1 surtido_flor.numero_surtido, 
	sum(item_surtido_flor.cantidad_ramos) as unidades_por_pieza
	from surtido_flor,
	mapeo_numero_surtido,
	mapeo_caja,
	mapeo_flor,
	version_surtido_flor,
	item_surtido_flor,
	cliente_pedido
	where surtido_flor.id_surtido_flor = mapeo_numero_surtido.id_surtido_flor
	and mapeo_numero_surtido.id_mapeo_caja = mapeo_caja.id_mapeo_caja
	and mapeo_caja.id_mapeo_flor = mapeo_flor.id_mapeo_flor
	and mapeo_flor.id_flor = surtido_flor.id_flor
	and mapeo_flor.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and cliente_pedido.id_cliente_despacho = surtido_flor.id_cliente_despacho
	and mapeo_caja.id_mapeo_caja = @id_mapeo_caja
	and mapeo_numero_surtido.nombre_mapeo_mark = @nombre_mapeo_mark
	and surtido_flor.disponible = 1
	and surtido_flor.id_surtido_flor = version_surtido_flor.id_surtido_flor
	and version_surtido_flor.id_surtido_flor = item_surtido_flor.id_surtido_flor
	and version_surtido_flor.id_version_surtido_flor = item_surtido_flor.id_version_surtido_flor
	group by surtido_flor.numero_surtido, 
	version_surtido_flor.id_version_surtido_flor
	order by version_surtido_flor.id_version_surtido_flor desc
end
else
if(@accion = 'insertar')
begin
	insert into mapeo_numero_surtido (id_surtido_flor,id_mapeo_caja,nombre_mapeo_mark)
	values (@id_surtido_flor, @id_mapeo_caja, @nombre_mapeo_mark)

	return scope_identity()
end
else
if(@accion = 'modificar')
begin
	update mapeo_numero_surtido
	set id_surtido_flor = @id_surtido_flor
	where id_mapeo_numero_surtido = @id_mapeo_numero_surtido
end
else
if(@accion = 'eliminar')
begin
	delete mapeo_numero_surtido
	where id_mapeo_numero_surtido = @id_mapeo_numero_surtido
end





