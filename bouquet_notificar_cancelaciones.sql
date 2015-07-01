set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/10/28
-- Description:	Trae informacion de solicitudes de Bouquets canceladas desde las comercializadoras
-- =============================================

create PROCEDURE [dbo].[bouquet_notificar_cancelaciones] 

@accion nvarchar(255),
@usuario_cobol nvarchar(25),
@id_solicitud_confirmacion_cultivo int,
@idc_farm nvarchar(25)

as

if(@accion = 'consultar_cancelaciones')
begin
	select solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	isnull((
		select upc_detalle_po.valor
		from bd_fresca.bd_fresca.dbo.informacion_upc,
		bd_fresca.bd_fresca.dbo.upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and upc_detalle_po.id_detalle_po = detalle_po.id_detalle_po
		and informacion_upc.nombre_informacion_upc = 'UPC'
	), '') as upc,
	isnull((
		select upc_detalle_po.valor
		from bd_fresca.bd_fresca.dbo.informacion_upc,
		bd_fresca.bd_fresca.dbo.upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and upc_detalle_po.id_detalle_po = detalle_po.id_detalle_po
		and informacion_upc.nombre_informacion_upc = 'Precio'
	), '') as precio_retail,
	isnull((
		select upc_detalle_po.valor
		from bd_fresca.bd_fresca.dbo.informacion_upc,
		bd_fresca.bd_fresca.dbo.upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and upc_detalle_po.id_detalle_po = detalle_po.id_detalle_po
		and informacion_upc.nombre_informacion_upc = 'Descripcion'
	), '') as descripcion_upc,
	isnull((
		select upc_detalle_po.valor
		from bd_fresca.bd_fresca.dbo.informacion_upc,
		bd_fresca.bd_fresca.dbo.upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and upc_detalle_po.id_detalle_po = detalle_po.id_detalle_po
		and informacion_upc.nombre_informacion_upc = 'Fecha'
	), '') as fecha_upc,
	isnull(formula_bouquet.especificacion_bouquet, '') as especificacion_bouquet,
	isnull(formula_bouquet.construccion_bouquet, '') as construccion_bouquet,
	isnull(caja.idc_caja_cultivo, '') as idc_caja,
	isnull((
		select sum(detalle_version_bouquet.unidades)
		from bd_fresca.bd_fresca.dbo.detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	), 0) as unidades,
	solicitud_confirmacion_cultivo.farm_price,
	comida_bouquet.id_comida_bouquet,
	comida_bouquet.nombre_comida as nombre_comida_bouquet,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente_despacho,
	po.po_number,
	farm_detalle_po.fecha_vuelo,	
	farm_detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	[dbo].[concatenar_numero_orden_bouquet] (solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo) as numero_solicitud,
	solicitud_confirmacion_cultivo.fecha_transaccion as fecha_envio_solicitud,
	cancela_detalle_po.fecha_transaccion as fecha_cancelacion,
	cuenta_interna.nombre as nombre_cuenta_cancela_orden,
	tapa.idc_tapa_cultivo as idc_tapa,
	detalle_po.precio_miami_pieza
	from bd_fresca.bd_fresca.dbo.detalle_po,
	bd_fresca.bd_fresca.dbo.farm_detalle_po,
	bd_fresca.bd_fresca.dbo.cancela_detalle_po,
	bd_fresca.bd_fresca.dbo.solicitud_confirmacion_cultivo,
	bd_fresca.bd_fresca.dbo.confirmacion_bouquet_cultivo,
	bd_fresca.bd_fresca.dbo.orden_pedido_bouquet,
	bd_fresca.bd_fresca.dbo.orden_pedido,
	bd_fresca.bd_fresca.dbo.bouquet,
	bd_fresca.bd_fresca.dbo.version_bouquet,
	bd_fresca.bd_fresca.dbo.tipo_flor,
	bd_fresca.bd_fresca.dbo.variedad_flor,
	bd_fresca.bd_fresca.dbo.grado_flor,
	bd_fresca.bd_fresca.dbo.tapa,
	bd_fresca.bd_fresca.dbo.caja,
	bd_fresca.bd_fresca.dbo.detalle_version_bouquet,
	bd_fresca.bd_fresca.dbo.formula_bouquet,
	bd_fresca.bd_fresca.dbo.comida_bouquet,
	bd_fresca.bd_fresca.dbo.po,
	bd_fresca.bd_fresca.dbo.cliente_despacho,
	bd_fresca.bd_fresca.dbo.farm,
	bd_fresca.bd_fresca.dbo.cuenta_interna
	where solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
	and confirmacion_bouquet_cultivo.id_confirmacion_bouquet_cultivo = orden_pedido_bouquet.id_confirmacion_bouquet_cultivo
	and orden_pedido.id_orden_pedido = orden_pedido_bouquet.id_orden_pedido
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_Po
	and detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and tapa.id_tapa = detalle_po.id_tapa
	and caja.id_caja = version_bouquet.id_caja
	and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and comida_bouquet.id_comida_bouquet = version_bouquet.id_comida_bouquet
	and po.id_po = detalle_po.id_po
	and cliente_despacho.id_despacho = po.id_despacho
	and farm.id_farm = farm_detalle_po.id_farm
	and cuenta_interna.id_cuenta_interna = cancela_detalle_po.id_cuenta_interna
	and farm.idc_farm > = 
	case
		when @idc_farm = '' then '  '
		else @idc_farm
	end
	and farm.idc_farm < = 
	case
		when @idc_farm = '' then 'ZZ'
		else @idc_farm
	end
	and not exists
	(
		select *
		from notificacion_cancela_pedido_bouquet
		where notificacion_cancela_pedido_bouquet.id_solicitud_confirmacion_cultivo = solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo
	)
end
else
if(@accion = 'insertar_notificacion_cancelacion')
begin
	begin try

		insert into Notificacion_Cancela_Pedido_Bouquet (usuario_cobol,id_solicitud_confirmacion_cultivo) 
		values (@usuario_cobol, @id_solicitud_confirmacion_cultivo)

		select scope_identity() as id_Notificacion_Cancela_Pedido_Bouquet
	end try
	begin catch
		select -1 as id_Notificacion_Cancela_Pedido_Bouquet
	end catch
end