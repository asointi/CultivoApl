set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_pedido_bouquetera] 

@numero_pedido int,
@id_tipo_compra int,
@accion nvarchar(255)

as
if(@accion = 'consultar_pedido')
begin
	select orden_pedido_cultivo.usuario_cobol as usuario_pedido,
	orden_pedido_cultivo.descripcion as descripcion_pedido,
	orden_pedido_cultivo.fecha_transaccion,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.unidades,
	detalle_orden_pedido_cultivo.comentario 
	from orden_pedido_cultivo,
	tipo_compra,
	detalle_orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and tipo_compra.id_tipo_compra = @id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and orden_pedido_cultivo.numero_consecutivo = @numero_pedido
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor
end
else
if(@accion = 'consultar_tipo_compra')
begin
	select id_tipo_compra,
	nombre_tipo_compra 
	from tipo_compra
	order by nombre_tipo_compra
end