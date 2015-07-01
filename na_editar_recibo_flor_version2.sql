set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/06/07
-- Description:	Maneja informacion de la recepcion de las ordenes de pedido del cultivo
-- =============================================

create PROCEDURE [dbo].[na_editar_recibo_flor_version2] 

@accion nvarchar(50),
@numero_remision nvarchar(10), 
@usuario_cobol nvarchar(50),
@id_recibo_flor int,
@id_despacho_orden_pedido_cultivo int,
@id_verifica_detalle_orden_pedido_cultivo int,
@unidades int

as

if(@accion = 'insertar_recibo_flor')
begin
	insert into recibo_flor (numero_remision, usuario_cobol)
	values (@numero_remision, @usuario_cobol)

	select scope_identity() as id_recibo_flor
end
else
if(@accion = 'insertar_detalle_recibo_flor')
begin
	if(@id_despacho_orden_pedido_cultivo = 0)
	begin
		insert into despacho_orden_pedido_cultivo (id_verifica_detalle_orden_pedido_cultivo, id_estado_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, unidades, usuario_cobol)
		select verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo, 
		estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo, 
		detalle_orden_pedido_cultivo.id_variedad_flor, 
		detalle_orden_pedido_cultivo.id_grado_flor, 
		[dbo].[concatenar_fecha_hora_COBOL] (replace(convert(nvarchar, verifica_detalle_orden_pedido_cultivo.fecha_aprobada, 111), '/', ''), '23500000'),
		verifica_detalle_orden_pedido_cultivo.unidades -
		isnull((
			SELECT sum(d.unidades)
			from despacho_orden_pedido_cultivo as d
			where verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = d.id_verifica_detalle_orden_pedido_cultivo
		),0), 
		@usuario_cobol
		from estado_orden_pedido_cultivo,
		verifica_detalle_orden_pedido_cultivo,
		detalle_orden_pedido_cultivo
		where estado_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'
		and verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo = @id_verifica_detalle_orden_pedido_cultivo
		and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo

		set @id_despacho_orden_pedido_cultivo = scope_identity()

		update despacho_orden_pedido_cultivo
		set id_despacho_orden_pedido_cultivo_padre = @id_despacho_orden_pedido_cultivo
		where id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo

		insert into detalle_recibo_flor (id_recibo_flor, id_despacho_orden_pedido_cultivo, unidades)
		values (@id_recibo_flor, @id_despacho_orden_pedido_cultivo, @unidades)
	
		select scope_identity() as id_detalle_recibo_flor
	end
	else
	begin
		insert into detalle_recibo_flor (id_recibo_flor, id_despacho_orden_pedido_cultivo, unidades)
		values (@id_recibo_flor, @id_despacho_orden_pedido_cultivo, @unidades)
		
		select scope_identity() as id_detalle_recibo_flor
	end
end
else
if(@accion = 'consultar_numero_remision')
begin
	select count(*) as cantidad
	from recibo_flor
	where numero_remision = @numero_remision
end