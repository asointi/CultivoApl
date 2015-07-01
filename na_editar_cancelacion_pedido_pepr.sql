SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[na_editar_cancelacion_pedido_pepr] 

@numero_solicitud int, 
@usuario_cobol nvarchar(255), 
@comentario nvarchar(1024), 
@cantidad_piezas int, 
@id_comercializadora int,
@accion nvarchar(255)

as

if(@accion = 'insertar_cancelacion')
begin
	insert into Cancelacion_Pedido_PEPR
	(
		numero_solicitud,
		usuario_cobol,
		comentario,
		cantidad_piezas,
		id_distribuidora
	)
	values (@numero_solicitud, @usuario_cobol, @comentario, @cantidad_piezas, @id_comercializadora)

	select scope_identity() as id_cancelacion_pedido_pepr
end
else
if(@accion = 'consultar_comercializadora')
begin
	select id_distribuidora as id_comercializadora,
	nombre_distribuidora as nombre_comercializadora 
	from distribuidora
	order by nombre_comercializadora 
end