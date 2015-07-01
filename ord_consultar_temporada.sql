set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ord_consultar_temporada]

@accion nvarchar(255),
@id_cliente_pedido int

AS

if(@accion = 'consultar')
begin
	select temporada_a�o.id_temporada_a�o,
	temporada.nombre_temporada,
	a�o.nombre_a�o,
	temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final,
	temporada.nombre_temporada + space(1) + '(' + convert(nvarchar,temporada_a�o.fecha_inicial,101) + '-' + convert(nvarchar,temporada_cubo.fecha_final,101) + ')' as nombre
	from temporada_cubo,
	temporada_a�o, 
	a�o,
	temporada,
	cliente_pedido
	where temporada_a�o.id_temporada = temporada_cubo.id_temporada
	and temporada_a�o.id_a�o = temporada_cubo.id_a�o
	and temporada_a�o.id_a�o = a�o.id_a�o
	and temporada_a�o.id_temporada = temporada.id_temporada
	and temporada_a�o.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and temporada_a�o.id_cliente_pedido_a�o = cliente_pedido.id_cliente_pedido
	and temporada_a�o.id_cliente_pedido_temporada = cliente_pedido.id_cliente_pedido
	and temporada.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and a�o.id_cliente_pedido = cliente_pedido.id_cliente_pedido
	and cliente_pedido.id_cliente_pedido = @id_cliente_pedido
	and temporada_a�o.disponible = 1
	order by a�o.nombre_a�o,temporada_cubo.fecha_inicial
end