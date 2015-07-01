set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

ALTER PROCEDURE [dbo].[ord_mapeo_comida_bouquet]

@id_cliente_pedido int,
@id_mapeo_comida_bouquet int,
@nombre_mapeo_bouquet nvarchar(255),
@tiene_comida bit,
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select tiene_comida 
	from mapeo_comida_bouquet
	where isnull(nombre_mapeo_bouquet,'') = isnull(@nombre_mapeo_bouquet,'')
	and id_cliente_pedido = @id_cliente_pedido
end
else
if(@accion = 'insertar')
begin
	declare @conteo int
	
	select count(*)
	from mapeo_comida_bouquet
	where mapeo_comida_bouquet.id_cliente_pedido = @id_cliente_pedido
	and isnull(mapeo_comida_bouquet.nombre_mapeo_bouquet,'') = isnull(@nombre_mapeo_bouquet,'')

	if(@conteo = 0)
	begin
		insert into mapeo_comida_bouquet (id_cliente_pedido, nombre_mapeo_bouquet, tiene_comida)
		values (@id_cliente_pedido, @nombre_mapeo_bouquet, @tiene_comida)

		return scope_identity()
	end
	else
		return -1
end