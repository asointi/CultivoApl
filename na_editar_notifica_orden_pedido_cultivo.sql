set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/06/28
-- Description:	Maneja informacion de notificaciones a los usuarios
-- =============================================

alter PROCEDURE [dbo].[na_editar_notifica_orden_pedido_cultivo] 

@accion nvarchar(255),
@id_detalle_orden_pedido_cultivo int, 
@usuario_cobol nvarchar(50),
@nombre_usuario_notificacion nvarchar(50),
@id_usuario_notificacion int

as

declare @conteo int

if(@accion = 'consultar_listado_notificaciones')
begin
	select tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.usuario_cobol as usuario_pedido,
	orden_pedido_cultivo.numero_consecutivo,
	convert(datetime,convert(nvarchar,orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_pedido,
	convert(nvarchar,orden_pedido_cultivo.fecha_transaccion, 108) as hora_pedido,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.unidades,
	detalle_orden_pedido_cultivo.comentario,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo,
	estado_orden_pedido_cultivo.nombre_estado_orden_pedido,
	verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo.observacion,
	verifica_detalle_orden_pedido_cultivo.usuario_cobol as usuario_aprobacion,
	convert(datetime,convert(nvarchar, verifica_detalle_orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_aprobacion,
	convert(nvarchar, verifica_detalle_orden_pedido_cultivo.fecha_transaccion, 108) as hora_aprobacion
	from tipo_compra,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo,
	estado_orden_pedido_cultivo,
	notifica_orden_pedido_cultivo,
	usuario_cobol,
	tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and usuario_cobol.id_usuario_cobol = notifica_orden_pedido_cultivo.id_usuario_cobol
	and verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = notifica_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and usuario_cobol.idc_usuario_cobol = @usuario_cobol
	and notifica_orden_pedido_cultivo.usuario_notificado = 0
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
	and estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo = verifica_detalle_orden_pedido_cultivo.id_estado_orden_pedido_cultivo
	order by nombre_estado_orden_pedido,
	fecha_inicial,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor
end
else
if(@accion = 'usuario_notificado')
begin
	update notifica_orden_pedido_cultivo
	set fecha_notificacion = getdate(),
	usuario_notificado = 1
	from usuario_cobol
	where usuario_cobol.id_usuario_cobol = notifica_orden_pedido_cultivo.id_usuario_cobol
	and usuario_cobol.idc_usuario_cobol = @usuario_cobol
	and notifica_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = @id_detalle_orden_pedido_cultivo
end
else
if(@accion = 'consultar_usuario_notificacion')
begin
	select usuario_notificacion.id_usuario_notificacion,
	usuario_notificacion.idc_usuario_notificacion,
	usuario_notificacion.nombre_usuario_notificacion
	from usuario_notificacion
	order by nombre_usuario_notificacion
end
else
if(@accion = 'insertar_usuario_notificacion')
begin
	select @conteo = count(*)
	from usuario_notificacion
	where idc_usuario_notificacion = @usuario_cobol

	if(@conteo = 0)
	begin
		insert into usuario_notificacion (idc_usuario_notificacion, nombre_usuario_notificacion)
		values (@usuario_cobol, @nombre_usuario_notificacion)
	end
	else
	begin
		update usuario_notificacion 
		set nombre_usuario_notificacion = @nombre_usuario_notificacion
		where idc_usuario_notificacion = @usuario_cobol
	end
end
else
if(@accion = 'eliminar_usuario_notificacion')
begin
	delete from usuario_notificacion
	where id_usuario_notificacion = @id_usuario_notificacion

	select 1 as id_usuario_notificacion
end