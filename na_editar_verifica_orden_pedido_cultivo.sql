set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/05/31
-- Description:	Maneja informacion de la aprobacion de las ordenes de pedido del cultivo
-- =============================================

alter PROCEDURE [dbo].[na_editar_verifica_orden_pedido_cultivo] 

@accion nvarchar(255),
@id_tipo_compra int,
@id_detalle_orden_pedido_cultivo int, 
@id_estado_orden_pedido_cultivo int, 
@observacion nvarchar(255), 
@usuario_cobol nvarchar(50)

as

if(@accion = 'consultar_estado')
begin
	select estado_orden_pedido_cultivo.id_estado_orden_pedido_cultivo,
	estado_orden_pedido_cultivo.nombre_estado_orden_pedido 
	from estado_orden_pedido_cultivo
	where estado_orden_pedido_cultivo.nombre_estado_orden_pedido in ('Aprobada', 'Rechazada')
	order by estado_orden_pedido_cultivo.nombre_estado_orden_pedido
end
else
if(@accion = 'consultar_ingresados')
begin
	select verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	sum(verifica_detalle_orden_pedido_cultivo.unidades) as unidades into #verifica_detalle_orden_pedido_cultivo
	from verifica_detalle_orden_pedido_cultivo
	group by verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo

	select detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo into #faltantes
	from detalle_orden_pedido_cultivo
	where not exists
	(
		select *
		from #verifica_detalle_orden_pedido_cultivo
		where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
		and detalle_orden_pedido_cultivo.unidades = #verifica_detalle_orden_pedido_cultivo.unidades 
	)

	select tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.usuario_cobol,
	orden_pedido_cultivo.descripcion,
	orden_pedido_cultivo.numero_consecutivo,
	convert(datetime,convert(nvarchar, orden_pedido_cultivo.fecha_transaccion, 101)) as fecha_transaccion,
	convert(nvarchar, orden_pedido_cultivo.fecha_transaccion, 108) as hora_transaccion,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	detalle_orden_pedido_cultivo.fecha_inicial,
	detalle_orden_pedido_cultivo.fecha_final,
	detalle_orden_pedido_cultivo.unidades - 
	(
		select isnull(sum(unidades),0)
		from #verifica_detalle_orden_pedido_cultivo
		where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #verifica_detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	) as unidades,
	detalle_orden_pedido_cultivo.comentario
	from detalle_orden_pedido_cultivo,
	orden_pedido_cultivo,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_compra,
	#faltantes
	where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = #faltantes.id_detalle_orden_pedido_cultivo
	and tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and tipo_compra.id_tipo_compra > = 
	case
		when @id_tipo_compra = 0 then 1
		else @id_tipo_compra
	end
	and tipo_compra.id_tipo_compra < = 
	case
		when @id_tipo_compra = 0 then 999
		else @id_tipo_compra
	end
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = detalle_orden_pedido_cultivo.id_grado_flor

	drop table #verifica_detalle_orden_pedido_cultivo
	drop table #faltantes
end
