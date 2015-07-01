USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_editar_confirmacion_bouquet_cultivo]    Script Date: 11/25/2013 5:07:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/09/17
-- Description:	maneja la informacion para confirmar los pedidos que ya se han enviado a los cultivos
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_editar_confirmacion_bouquet_cultivo] 

@accion nvarchar(255),
@id_solicitud_confirmacion_cultivo int, 
@id_cuenta_interna int, 
@cantidad_piezas int,
@aceptada bit, 
@observacion nvarchar(1024)

as

if(@accion = 'consultar')
begin
	select id_solicitud_confirmacion_cultivo,
	sum(cantidad_piezas) as cantidad_piezas into #confirmacion_bouquet_cultivo
	from confirmacion_bouquet_cultivo
	group by id_solicitud_confirmacion_cultivo

	select solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
	detalle_po.id_detalle_po,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	po.id_po,
	po.po_number,
	po.fecha_despacho_miami,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas -
	isnull((
		select cantidad_piezas
		from #confirmacion_bouquet_cultivo
		where solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = #confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
	), 0) as cantidad_piezas,
	detalle_po.marca,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	caja.nombre_caja,
	caja.medida as medida_caja,
	farm_detalle_po.fecha_vuelo,
	farm.id_farm,
	farm.idc_farm,
	farm.nombre_farm,
	null as especificacion_bouquet,
	null as construccion_bouquet,
	isnull((
		select sum(unidades)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	), 0) as unidades,
	cuenta_interna.nombre as nombre_cuenta_interna,
	solicitud_confirmacion_cultivo.fecha_transaccion,
	po.numero_solicitud into #temp
	from farm_detalle_po,
	cuenta_interna,
	farm,
	detalle_po,
	po,
	version_bouquet,
	tipo_flor,
	variedad_flor,
	grado_flor,
	caja,
	tipo_caja,
	tapa,
	bouquet,
	cliente_despacho,
	solicitud_confirmacion_cultivo
	where cuenta_interna.id_cuenta_interna = solicitud_confirmacion_cultivo.id_cuenta_interna
	and solicitud_confirmacion_cultivo.id_farm_detalle_po = farm_detalle_po.id_farm_detalle_po
	and solicitud_confirmacion_cultivo.aceptada = 1
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm.id_farm = farm_detalle_po.id_farm
	and caja.id_caja = version_bouquet.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and tapa.id_tapa = detalle_po.id_tapa
	and cliente_despacho.id_despacho = po.id_despacho
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and po.id_po = detalle_po.id_po
	and not exists
	(
		select *
		from #confirmacion_bouquet_cultivo
		where solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = #confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
		and detalle_po.cantidad_piezas = #confirmacion_bouquet_cultivo.cantidad_piezas
	)
	
	select *
	from #temp
	where cantidad_piezas > 0
	order by fecha_transaccion

	select id_farm,
	'[' + idc_farm + '] ' + ltrim(rtrim(nombre_farm)) as nombre_farm
	from #temp
	where cantidad_piezas > 0
	GROUP BY id_farm,
	idc_farm,
	ltrim(rtrim(nombre_farm))
	order by idc_farm

	select id_despacho,
	idc_cliente_despacho + ' [' + nombre_cliente + ']' as idc_cliente_despacho
	from #temp
	group by id_despacho,
	nombre_cliente,
	idc_cliente_despacho
	order by idc_cliente_despacho
	
	drop table #temp
	drop table #confirmacion_bouquet_cultivo
end
else
if(@accion = 'insertar')
begin
	declare @id_confirmacion_bouquet_cultivo int 

	insert into confirmacion_bouquet_cultivo (id_solicitud_confirmacion_cultivo, id_cuenta_interna, aceptada, observacion, cantidad_piezas)
	values (@id_solicitud_confirmacion_cultivo, @id_cuenta_interna, @aceptada, @observacion, @cantidad_piezas)

	set @id_confirmacion_bouquet_cultivo = scope_identity()
	
	if(@aceptada = 0)
	begin
		declare @subject1 nvarchar(255),
		@body1 nvarchar(max),
		@correo nvarchar(512),
		@perfil nvarchar(255)

		set @subject1 = 'RETURNED - Not Farm Confirmed'

		select @correo = ltrim(rtrim(isnull(correo,''))) from Cuenta_Interna where id_cuenta_interna = @id_cuenta_interna
		
		select @correo = ltrim(rtrim(vendedor.correo)) + ';' + @correo,
		@body1 = 'Last Modified by: ' + space(1) + ltrim(rtrim(cuenta_interna.nombre)) + char(13) +
		'Last Modified Date: ' + space(1) + convert(nvarchar,confirmacion_bouquet_cultivo.fecha_transaccion) + char(13) +
		'Description: ' + space(1) + @observacion + char(13) + char(13) +

		'Ship to: ' + space(1) + ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) + char(13) +
		'Carrier: ' + space(1) + ltrim(rtrim(transportador.nombre_transportador)) + char(13) +
		'Flower Type: ' + space(1) + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + char(13) +
		'Flower Variety: ' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + char(13) +
		'Flower Grade: ' + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)) + char(13) +
		'Farm: ' + space(1) + ltrim(rtrim(farm.nombre_farm)) + char(13) +
		'Lid: ' + space(1) + ltrim(rtrim(tapa.nombre_tapa)) + char(13) +
		'Box Type: ' + space(1) + ltrim(rtrim(tipo_caja.nombre_tipo_caja)) + char(13) +
		'Code: ' + space(1) + detalle_po.marca + char(13) +
		'Initial Date: ' + space(1) + convert(nvarchar,po.fecha_despacho_miami,101) + char(13) +
		'Pack: ' + space(1) + convert(nvarchar,
		isnull((
			select sum(detalle_version_bouquet.unidades)
			from detalle_version_bouquet
			where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
		),0)
		) + char(13) +
		'Pieces: ' + space(1) + convert(nvarchar,confirmacion_bouquet_cultivo.cantidad_piezas) + char(13)
		from farm_detalle_po,
		detalle_po,
		po,
		version_bouquet,
		bouquet,
		cliente_factura,
		cliente_despacho,
		vendedor,
		cuenta_interna,
		solicitud_confirmacion_cultivo,
		transportador,
		tipo_flor,
		variedad_flor,
		grado_flor,
		farm,
		tapa,
		caja,
		tipo_caja,
		confirmacion_bouquet_cultivo
		where bouquet.id_bouquet = version_bouquet.id_bouquet
		and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
		and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
		and cliente_despacho.id_despacho = po.id_despacho
		and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
		and vendedor.id_vendedor = cliente_factura.id_vendedor
		and po.id_po = detalle_po.id_po
		and cuenta_interna.id_cuenta_interna = confirmacion_bouquet_cultivo.id_cuenta_interna
		and transportador.id_transportador = po.id_transportador
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
		and grado_flor.id_grado_flor = bouquet.id_grado_flor
		and farm.id_farm = farm_detalle_po.id_farm
		and tapa.id_tapa = detalle_po.id_tapa
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		and caja.id_caja = version_bouquet.id_caja
		and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
		and confirmacion_bouquet_cultivo.id_confirmacion_bouquet_cultivo = @id_confirmacion_bouquet_cultivo		

		set @correo = replace(@correo, ',',';')
		set @perfil = 'Reportes_Fincas'

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @correo,
		@subject = @subject1,
		@profile_name = @perfil,
		@body = @body1,
		@body_format = 'TEXT';
	end
--	else
--	begin
--		declare @idc_tipo_factura nvarchar(5),
--		@numero_orden bigint,
--		@nombre_comida_bouquet nvarchar(255),
--		@upc nvarchar(255),
--		@id_orden_pedido int
--
--		set @upc = 'UPC'
--		set @nombre_comida_bouquet = ''
--
--		select @numero_orden = max(idc_orden_pedido)
--		from orden_pedido
--		where convert(bigint,idc_orden_pedido) > = 1000000000
--		and isnumeric(idc_orden_pedido) = 1
--
--		if(@numero_orden is null)
--		begin
--			set @numero_orden = 1000000000
--		end
--		else
--		begin
--			set @numero_orden = @numero_orden + 1
--		end
--
--		insert into orden_pedido 
--		(
--			idc_orden_pedido,
--			id_despacho,
--			id_variedad_flor,
--			id_grado_flor,
--			id_farm,
--			id_tapa,
--			id_transportador,
--			id_tipo_factura,
--			fecha_inicial,
--			fecha_final,
--			marca,
--			unidades_por_pieza,
--			cantidad_piezas,
--			valor_unitario,
--			disponible,
--			id_tipo_caja,
--			comentario,
--			id_vendedor,
--			fecha_creacion_orden,
--			comida,
--			upc,
--			numero_po
--		)
--		select @numero_orden,
--		cliente_despacho.id_despacho,
--		variedad_flor.id_variedad_flor,
--		grado_flor.id_grado_flor,
--		farm.id_farm,
--		tapa.id_tapa,
--		transportador.id_transportador,
--		tipo_factura.id_tipo_factura,
--		po.fecha_despacho_miami,
--		po.fecha_despacho_miami,
--		detalle_po.marca,
--		isnull((
--			select sum(detalle_version_bouquet.unidades)
--			from detalle_version_bouquet
--			where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
--		), 0),
--		detalle_po.cantidad_piezas,
--		(
--			select sum(detalle_version_bouquet.precio_miami)
--			from detalle_version_bouquet
--			where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
--		) /
--		(
--			select sum(detalle_version_bouquet.unidades)
--			from detalle_version_bouquet
--			where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
--		),
--		1,
--		tipo_caja.id_tipo_caja,
--		'',
--		vendedor.id_vendedor,
--		getdate(),
--		0,--No sabe como se manejara esta variable, segun conversacion con Carlos el 04 Dic 2013
--		isnull((
--			select upc_detalle_po.valor
--			from informacion_upc,
--			upc_detalle_po
--			where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
--			and detalle_po.id_detalle_po = upc_detalle_po.id_detalle_po
--			and informacion_upc.nombre_informacion_upc = @upc
--		), ''),
--		po.po_number
--		from po,
--		cliente_despacho,
--		detalle_po,
--		farm_detalle_po,
--		solicitud_confirmacion_cultivo,
--		confirmacion_bouquet_cultivo,
--		variedad_flor,
--		grado_flor,
--		version_bouquet,
--		bouquet,
--		farm,
--		tapa,
--		transportador,
--		tipo_factura,
--		caja,
--		tipo_caja,
--		cliente_factura,
--		vendedor
--		where po.id_po = detalle_po.id_po
--		and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
--		and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
--		and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
--		and confirmacion_bouquet_cultivo.id_confirmacion_bouquet_cultivo = @id_confirmacion_bouquet_cultivo
--		and cliente_despacho.id_despacho = po.id_despacho
--		and bouquet.id_bouquet = version_bouquet.id_bouquet
--		and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
--		and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
--		and grado_flor.id_grado_flor = bouquet.id_grado_flor
--		and farm.id_farm = farm_detalle_po.id_farm
--		and tapa.id_tapa = detalle_po.id_tapa
--		and transportador.id_transportador = po.id_transportador
--		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
--		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
--		and caja.id_caja = version_bouquet.id_caja
--		and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
--		and vendedor.id_vendedor = cliente_factura.id_vendedor
--
--		set @id_orden_pedido = scope_identity()
--
--		update orden_pedido
--		set id_orden_pedido_padre = @id_orden_pedido
--		where id_orden_pedido = @id_orden_pedido
--
--		insert into orden_pedido_bouquet (id_confirmacion_bouquet_cultivo, id_orden_pedido)
--		values (@id_confirmacion_bouquet_cultivo, @id_orden_pedido)
--	end

	select @id_confirmacion_bouquet_cultivo as id_confirmacion_bouquet_cultivo
end