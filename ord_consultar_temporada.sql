set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_consultar_temporada]

@accion nvarchar(255),
@id_cliente_pedido int

AS

if(@accion = 'consultar')
begin
	select temporada_año.id_temporada_año,
	temporada.nombre_temporada,
	año.nombre_año,
	temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	temporada.nombre_temporada + space(1) + '(' + convert(nvarchar,temporada_año.fecha_inicial,101) + '-' + convert(nvarchar,temporada_cubo.fecha_final,101) + ')' as nombre
	from temporada_cubo,
	temporada_año, 
	año,
	temporada,
	cliente_pedido
	where temporada_año.id_temporada = temporada_cubo.id_temporada
	and temporada_año.id_año = temporada_cubo.id_año
	and temporada_año.id_año = año.id_año
	and temporada_año.id_temporada = temporada.id_temporada
	and temporada_año.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and temporada_año.id_cliente_pedido_año = cliente_pedido.id_cliente_pedido
	and temporada_año.id_cliente_pedido_temporada = cliente_pedido.id_cliente_pedido
	and temporada.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and año.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
	and temporada_año.disponible = 1
	order by año.nombre_año,temporada_cubo.fecha_inicial
end