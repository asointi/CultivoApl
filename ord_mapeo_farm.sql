set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[ord_mapeo_farm]

@id_cliente_pedido int,
@id_mapeo_farm int,
@nombre_mapeo_farm nvarchar(255),
@es_valido bit,
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	if(@nombre_mapeo_farm = 'NAT')
	begin
		select 1 as es_valido
	end
	else
	begin
		select 0 as es_valido
	end
end
else
if(@accion = 'insertar')
begin
	if(@nombre_mapeo_farm = 'NAT')
	begin
		declare @conteo int

		select count(*)
		from mapeo_farm
		where mapeo_farm.id_cliente_pedido = @id_cliente_pedido
		and isnull(mapeo_farm.nombre_mapeo_farm,'') = isnull(@nombre_mapeo_farm,'')
	
		if(@conteo = 0)
		begin
			insert into mapeo_farm (id_cliente_pedido, nombre_mapeo_farm, es_valido)
			values (@id_cliente_pedido, @nombre_mapeo_farm, @es_valido)
		
			return scope_identity()
		end
		else
		begin
			return -1
		end
	end
	else
	begin
		return -1
	end
end