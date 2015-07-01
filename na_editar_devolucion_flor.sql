set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/06/11
-- Description:	Maneja informacion de la devolucion de las recepciones de las ordenes de pedido del cultivo
-- =============================================

alter PROCEDURE [dbo].[na_editar_devolucion_flor] 

@accion nvarchar(50),
@id_tipo_compra int,
@usuario_cobol nvarchar(50),
@id_devolucion_flor int, 
@id_detalle_recibo_flor int, 
@unidades int

as

if(@accion = 'insertar_devolucion_flor')
begin
	declare @numero_consecutivo int

	select @numero_consecutivo = max(devolucion_flor.numero_consecutivo)
	from tipo_compra,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	detalle_recibo_flor,
	detalle_devolucion_flor,
	devolucion_flor
	where tipo_compra.id_tipo_compra = @id_tipo_compra
	and tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_Pedido_cultivo.id_orden_Pedido_cultivo = detalle_orden_Pedido_cultivo.id_orden_Pedido_cultivo
	and detalle_orden_Pedido_cultivo.id_detalle_orden_Pedido_cultivo = verifica_detalle_orden_Pedido_cultivo.id_detalle_orden_Pedido_cultivo
	and verifica_detalle_orden_Pedido_cultivo.id_verifica_detalle_orden_Pedido_cultivo = despacho_orden_pedido_cultivo.id_verifica_detalle_orden_Pedido_cultivo
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo
	and devolucion_flor.id_devolucion_flor = detalle_devolucion_flor.id_devolucion_flor
	and detalle_recibo_flor.id_detalle_recibo_flor = detalle_devolucion_flor.id_detalle_recibo_flor

	if(@numero_consecutivo is null)
	begin
		set @numero_consecutivo = 1
	end
	else
	begin
		set @numero_consecutivo = @numero_consecutivo + 1
	end

	insert into devolucion_flor (numero_consecutivo, usuario_cobol)
	values (@numero_consecutivo, @usuario_cobol)

	select scope_identity() as id_devolucion_flor,
	@numero_consecutivo as numero_consecutivo
end
else
if(@accion = 'insertar_detalle_devolucion_flor')
begin
	insert into detalle_devolucion_flor (id_devolucion_flor, id_detalle_recibo_flor, unidades)
	values (@id_devolucion_flor, @id_detalle_recibo_flor, @unidades)

	select scope_identity() as id_detalle_devolucion_flor
end
else
if(@accion = 'consultar')
begin
	select tipo_compra.id_tipo_compra,
	tipo_compra.nombre_tipo_compra,
	orden_pedido_cultivo.id_orden_pedido_cultivo,
	orden_pedido_cultivo.descripcion,
	detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo.id_verifica_detalle_orden_pedido_cultivo,
	detalle_orden_pedido_cultivo.comentario,
	despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
	despacho_orden_pedido_cultivo.usuario_cobol,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	recibo_flor.id_recibo_flor,
	recibo_flor.numero_remision,
	recibo_flor.fecha_transaccion as fecha_recibo_flor,
	detalle_recibo_flor.id_detalle_recibo_flor,
	detalle_recibo_flor.unidades - 
	isnull((
		select sum(d.unidades)
		from detalle_devolucion_flor as d
		where detalle_recibo_flor.id_detalle_recibo_flor = d.id_detalle_recibo_flor
	), 0) as unidades into #temp
	from tipo_compra,
	tipo_flor,
	variedad_flor,
	grado_flor,
	orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	verifica_detalle_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	detalle_recibo_flor,
	recibo_flor
	where recibo_flor.id_recibo_flor = detalle_recibo_flor.id_recibo_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
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
	and tipo_compra.id_tipo_compra = orden_pedido_cultivo.id_tipo_compra
	and orden_Pedido_cultivo.id_orden_Pedido_cultivo = detalle_orden_Pedido_cultivo.id_orden_Pedido_cultivo
	and detalle_orden_Pedido_cultivo.id_detalle_orden_Pedido_cultivo = verifica_detalle_orden_Pedido_cultivo.id_detalle_orden_Pedido_cultivo
	and verifica_detalle_orden_Pedido_cultivo.id_verifica_detalle_orden_Pedido_cultivo = despacho_orden_pedido_cultivo.id_verifica_detalle_orden_Pedido_cultivo
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = detalle_recibo_flor.id_despacho_orden_pedido_cultivo

	select id_tipo_compra,
	nombre_tipo_compra,
	id_orden_pedido_cultivo,
	descripcion,
	id_detalle_orden_pedido_cultivo,
	id_verifica_detalle_orden_pedido_cultivo,
	comentario,
	id_despacho_orden_pedido_cultivo,
	fecha_estimada_recibo_flor,
	unidades,
	usuario_cobol,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	id_recibo_flor,
	numero_remision,
	fecha_recibo_flor,
	id_detalle_recibo_flor
	from #temp
	where unidades > 0

	drop table #temp
end
