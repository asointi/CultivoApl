USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_editar_detalle_po]    Script Date: 20/08/2014 2:34:53 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/17
-- Description:	Maneja informacion de la tabla Detalle_PO
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_editar_detalle_po] 

@accion nvarchar(255),
@id_variedad_flor int, 
@id_grado_flor int,
@id_po int,
@id_detalle_po int,
@id_cuenta_interna int, 
@id_tapa int, 
@id_caja int,
@id_capuchon_cultivo int,
@id_farm int,
@imagen image,
@unidades int,
@id_comida_bouquet int,
@cantidad_piezas int, 
@marca nvarchar(25), 
@ethyblock_sachet bit, 
@precio_miami_pieza decimal(20,4), 
@fecha_vuelo datetime,
@id_upc nvarchar(255),
@orden_upc int, 
@valor_upc nvarchar(255),
@observacion nvarchar(1024),
@numero_item nvarchar(25) = null,
@id_detalle_po_anterior int = null,
@id_detalle_version_bouquet int = null

as

declare @dia_vuelo_original int,
@factor_a_full decimal(20,4),
@id_farm_detalle_po int,
@id_farm_detalle_po_padre int,
@id_despacho int,
@conteo int,
@id_detalle_po_padre int,
@upc nvarchar(255),
@descripcion nvarchar(255),
@fecha nvarchar(255),
@precio nvarchar(255),
@id_bouquet int,
@id_version_bouquet int,
@id_cliente_factura int,
@valor decimal(20,4),
@nombre_formato_upc nvarchar(255)

set @upc = 'UPC'
set @descripcion = 'Descripcion'
set @fecha = 'Fecha'
set @precio = 'Precio'

if(@accion = 'actualizar_finca')
begin	
	select @id_farm_detalle_po_padre = farm_detalle_po.id_farm_detalle_po_padre
	from farm_detalle_po,
	detalle_po
	where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and detalle_po.id_detalle_po = @id_detalle_po
	group by farm_detalle_po.id_farm_detalle_po_padre

	select @factor_a_full = tipo_caja.factor_a_full,
	@unidades = 
	isnull((
		select sum(unidades)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	),0)
	from tipo_caja,
	caja,
	version_bouquet,
	detalle_po
	where caja.id_caja = version_bouquet.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and detalle_po.id_detalle_po = @id_detalle_po

	insert into farm_detalle_po (id_detalle_po, id_farm, id_cuenta_interna, fecha_vuelo, comision_farm, freight_por_pieza, cantidad_piezas)
	select @id_detalle_po,
	farm.id_farm,
	@id_cuenta_interna,
	@fecha_vuelo,
	farm.comision_farm,
	(ciudad.impuesto_por_caja * @factor_a_full),
	@cantidad_piezas
	from farm,
	ciudad
	where farm.id_farm = @id_farm
	and ciudad.id_ciudad = farm.id_ciudad

	set @id_farm_detalle_po = scope_identity()

	update farm_detalle_po
	set id_farm_detalle_po_padre = 
	case
		when @id_farm_detalle_po_padre is null then @id_farm_detalle_po
		else @id_farm_detalle_po_padre
	end
	where id_farm_detalle_po = @id_farm_detalle_po	

	select @id_farm_detalle_po as id_farm_detalle_po
end
else
if(@accion = 'consultar')
begin
	select max(id_detalle_po) as id_detalle_po into #detalle_po
	from detalle_po
	group by id_detalle_po_padre

	select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
	from farm_detalle_po
	group by id_farm_detalle_po_padre

	select detalle_po.id_detalle_po,
	farm.id_farm,
	idc_farm + space(1) + '['+ ltrim(rtrim(nombre_farm)) + ']'as nombre_farm, 
	solicitud_confirmacion_cultivo.aceptada,
	farm_detalle_po.fecha_vuelo,
	(
		select cancela_detalle_po.id_cancela_detalle_po
		from cancela_detalle_po
		where cancela_detalle_po.id_detalle_po = detalle_po.id_detalle_po 
	) as cancelada into #temp
	from po,
	version_bouquet,
	detalle_po left join farm_detalle_po on detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and exists
	(
		select *
		from #farm_detalle_po
		where #farm_detalle_po.id_farm_detalle_po = farm_detalle_po.id_farm_detalle_po
	)
	left join farm on farm.id_farm = farm_detalle_po.id_farm
	left join solicitud_confirmacion_cultivo on farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	where po.id_po = detalle_po.id_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and po.id_po = @id_po
	and exists
	(
		select *
		from #detalle_po
		where #detalle_po.id_detalle_po = detalle_po.id_detalle_po
	)

	update #temp
	set aceptada = 1
	where cancelada > = 1

	select bouquet.id_bouquet,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor,
	tapa.idc_tapa,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	bouquet.imagen,
	version_bouquet.id_version_bouquet,
	caja.id_caja,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	ltrim(rtrim(caja.medida)) as medida_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	(
		select sum(Detalle_Version_Bouquet.unidades)
		from Detalle_Version_Bouquet
		where Version_Bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
	) as unidades,
	'' as nombre_comida_bouquet,
	po.id_po,
	detalle_po.id_detalle_po,
	detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	convert(decimal(20,2),isnull((
		select sum(Detalle_Version_Bouquet.precio_miami)
		from Detalle_Version_Bouquet
		where Version_Bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
	),0)) as precio_miami_pieza,
	detalle_po.box_charge,
	NULL as upc,
	NULL as orden_upc,
	NULL as descripcion_upc,
	NULL as orden_descripcion_upc,
	NULL as fecha_upc,
	NULL as orden_fecha_upc,
	NULL as precio_upc,
	NULL as orden_precio_upc,
	NULL as nombre_formula_bouquet,
	NULL as especificacion_bouquet,
	NULL as construccion_bouquet,
	NULL as id_formula_bouquet,
	NULL as id_detalle_version_bouquet,
	NULL as id_grado_flor_cultivo,
	NULL as opcion_menu,	
	tapa.id_tapa,
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
	(
		select top 1 id_farm
		from #temp
		where detalle_po.id_detalle_po = #temp.id_detalle_po
	) as id_farm,
	(
		select top 1 nombre_farm
		from #temp
		where detalle_po.id_detalle_po = #temp.id_detalle_po
	) as nombre_farm,
	(
		select top 1 fecha_vuelo
		from #temp
		where detalle_po.id_detalle_po = #temp.id_detalle_po
	) as fecha_vuelo,
	dbo.consultar_estado_detalle_po (detalle_po.id_detalle_po) as status,
	isnull((
		select top 1 aceptada
		from #temp
		where detalle_po.id_detalle_po = #temp.id_detalle_po
	), 0) as id_status,
	(
		select top 1 numero_item
		from cliente_factura,
		cliente_despacho,
		item_number
		where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
		and cliente_despacho.id_despacho = po.id_despacho
		and cliente_factura.id_cliente_factura = item_number.id_cliente_factura
		and version_bouquet.id_version_bouquet = item_number.id_version_bouquet	
		order by item_number.id_item_number desc
	) as item_number,
	(
		select count(*)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) AS cantidad_formulas into #resultado
	from po,
	detalle_po,
	tapa,
	version_bouquet,
	bouquet,
	caja,
	tipo_caja,
	tipo_flor,
	variedad_flor,
	grado_flor
	where po.id_po = detalle_po.id_po
	and tapa.id_tapa = detalle_po.id_tapa
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and caja.id_caja = version_bouquet.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and po.id_po = @id_po
	and exists
	(
		select *
		from #detalle_po
		where #detalle_po.id_detalle_po = detalle_po.id_detalle_po
	)
	
	select *
	from #resultado
	ORDER BY idc_tipo_flor,
	nombre_variedad_flor,
	marca

	select 0 AS id_detalle_po,
	0 AS id_capuchon_cultivo,
	'' as nombre_capuchon 

	drop table #temp
	drop table #detalle_po
	drop table #farm_detalle_po
	drop table #resultado
end
else
if(@accion = 'insertar')
begin
	select @id_bouquet = bouquet.id_bouquet
	from bouquet
	where id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor

	if(@id_bouquet is null)
	begin
		insert into bouquet (id_variedad_flor, id_grado_flor, imagen)
		values (@id_variedad_flor, @id_grado_flor, @imagen)
	
		set @id_bouquet = scope_identity()
	end
	else
	begin
		update bouquet
		set imagen = 
		case
			when @imagen is null then imagen
			else @imagen
		end
		where id_bouquet = @id_bouquet
	end
	
	insert into version_bouquet (id_caja, id_bouquet)
	values (@id_caja, @id_bouquet)

	set @id_version_bouquet = scope_identity()

	select @valor =	isnull(sum(valor), 0)
	from cargo_box_charge,
	cliente_despacho,
	po,
	caja
	where cliente_despacho.id_despacho = cargo_box_charge.id_despacho
	and caja.id_caja  = cargo_box_charge.id_caja
	and po.id_despacho = cliente_despacho.id_despacho
	and po.id_po = @id_po
	and caja.id_caja = @id_caja

	insert into detalle_po (id_cuenta_interna, id_tapa, id_version_bouquet, id_po, cantidad_piezas, marca, ethyblock_sachet, box_charge, id_detalle_po_cancelado)
	values (@id_cuenta_interna, @id_tapa, @id_version_bouquet, @id_po, @cantidad_piezas, @marca, @ethyblock_sachet, @valor, @id_detalle_po_anterior)
		
	set @id_detalle_po = scope_identity()

	update detalle_po
	set id_detalle_po_padre = @id_detalle_po
	where id_detalle_po = @id_detalle_po

	insert into item_number (id_cliente_factura, numero_item, id_version_bouquet)
	select cliente_factura.id_cliente_factura, @numero_item, @id_version_bouquet
	from cliente_factura,
	cliente_despacho,
	po
	where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and po.id_despacho = cliente_despacho.id_despacho
	and po.id_po = @id_po
			
	if(@id_farm > 0)
	begin
		select @factor_a_full = tipo_caja.factor_a_full
		from tipo_caja,
		caja,
		version_bouquet
		where caja.id_caja = version_bouquet.id_caja
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		and version_bouquet.id_version_bouquet = @id_version_bouquet

		insert into farm_detalle_po (id_detalle_po, id_farm, id_cuenta_interna, fecha_vuelo, comision_farm, freight_por_pieza, cantidad_piezas)
		select @id_detalle_po,
		farm.id_farm,
		@id_cuenta_interna,
		@fecha_vuelo,
		farm.comision_farm,
		(ciudad.impuesto_por_caja * @factor_a_full),
		@cantidad_piezas
		from farm,
		ciudad
		where farm.id_farm = @id_farm
		and ciudad.id_ciudad = farm.id_ciudad

		set @id_farm_detalle_po = scope_identity()

		update farm_detalle_po
		set id_farm_detalle_po_padre = @id_farm_detalle_po
		where id_farm_detalle_po = @id_farm_detalle_po
	end

	select @id_detalle_po as id_detalle_po
end
else
if(@accion = 'actualizar_detalle_po')
begin
	select @id_detalle_po_padre = id_detalle_po_padre,
	@id_version_bouquet = version_bouquet.id_version_bouquet,
	@id_cliente_factura = cliente_factura.id_cliente_factura
	from detalle_po,
	po,
	version_bouquet,
	cliente_factura,
	cliente_despacho
	where detalle_po.id_detalle_po = @id_detalle_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and cliente_despacho.id_despacho = po.id_despacho
	and po.id_po = detalle_po.id_po

	select @id_bouquet = bouquet.id_bouquet
	from bouquet
	where id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor

	if(@id_bouquet is null)
	begin
		insert into bouquet (id_variedad_flor, id_grado_flor, imagen)
		values (@id_variedad_flor, @id_grado_flor, @imagen)
		
		set @id_bouquet = scope_identity()
	end

	update bouquet
	set imagen = 
	case
		when @imagen is null then imagen
		else @imagen
	end
	where id_bouquet = @id_bouquet

	update version_bouquet
	set id_caja = @id_caja,
	id_bouquet = @id_bouquet
	where id_version_bouquet = @id_version_bouquet

	select @valor = isnull(sum(valor), 0)
	from cargo_box_charge,
	cliente_despacho,
	po,
	caja,
	detalle_po
	where cliente_despacho.id_despacho = cargo_box_charge.id_despacho
	and caja.id_caja  = cargo_box_charge.id_caja
	and po.id_despacho = cliente_despacho.id_despacho
	and caja.id_caja = @id_caja
	and po.id_po = detalle_po.id_po
	and detalle_po.id_detalle_po = @id_detalle_po
	
	insert into detalle_po (id_cuenta_interna, id_tapa, id_version_bouquet, id_po, cantidad_piezas, marca, ethyblock_sachet, box_charge, id_detalle_po_padre)
	select @id_cuenta_interna, 
	@id_tapa, 
	version_bouquet.id_version_bouquet, 
	detalle_po.id_po, 
	@cantidad_piezas, 
	@marca, 
	@ethyblock_sachet, 
	@valor,
	@id_detalle_po_padre
	from detalle_po,
	version_bouquet
	where detalle_po.id_detalle_po = @id_detalle_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	group by version_bouquet.id_version_bouquet,
	detalle_po.id_po

	set @id_detalle_po = scope_identity()
	 
	insert into item_number (id_cliente_factura, numero_item, id_version_bouquet)
	select cliente_factura.id_cliente_factura, @numero_item, @id_version_bouquet
	from cliente_factura,
	cliente_despacho,
	po,
	detalle_po
	where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and po.id_despacho = cliente_despacho.id_despacho
	and po.id_po = detalle_Po.id_po
	and detalle_po.id_detalle_po = @id_detalle_po

	if(@id_farm > 0)
	begin
		select @factor_a_full = tipo_caja.factor_a_full
		from tipo_caja,
		caja,
		version_bouquet,
		detalle_po
		where caja.id_caja = version_bouquet.id_caja
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
		and detalle_po.id_detalle_po = @id_detalle_po

		select top 1 @id_farm_detalle_po_padre = farm_detalle_po.id_farm_detalle_po_padre
		from detalle_po,
		farm_detalle_po
		where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
		and detalle_po.id_detalle_po_padre = @id_detalle_po_padre
		order by farm_detalle_po.id_farm_detalle_po desc
		
		insert into farm_detalle_po (id_detalle_po, id_farm, id_cuenta_interna, fecha_vuelo, comision_farm, freight_por_pieza, id_farm_detalle_po_padre, cantidad_piezas)
		select @id_detalle_po,
		farm.id_farm,
		@id_cuenta_interna,
		@fecha_vuelo,
		farm.comision_farm,
		(ciudad.impuesto_por_caja * @factor_a_full),
		case
			when @id_farm_detalle_po_padre is null then null
			else @id_farm_detalle_po_padre
		end,
		@cantidad_piezas
		from farm,
		ciudad
		where farm.id_farm = @id_farm
		and ciudad.id_ciudad = farm.id_ciudad

		if(@id_farm_detalle_po_padre is null)	
		begin
			set @id_farm_detalle_po = scope_identity()

			update farm_detalle_po
			set id_farm_detalle_po_padre = @id_farm_detalle_po
			where id_farm_detalle_po = @id_farm_detalle_po
		end
	end
	select @id_detalle_po as id_detalle_po
end
else
if(@accion = 'cancelar_detalle_po')
begin	
	insert into cancela_detalle_po (id_detalle_po, id_cuenta_interna, observacion)
	values (@id_detalle_po, @id_cuenta_interna, @observacion)

	if(@id_detalle_po_anterior is not null)
	begin
		declare @subject1 nvarchar(255),
		@body1 nvarchar(max),
		@correo nvarchar(512),
		@perfil nvarchar(255)

		select @id_farm_detalle_po = max(id_farm_detalle_po) 
		from farm_detalle_po
		where id_detalle_po = @id_detalle_po

		set @subject1 = 'CANCEL CONFIRMED ORDER'
		set @correo = 'dpineros@natuflora.net;'

		select @correo = @correo + ltrim(rtrim(vendedor.correo)),
		@body1 = 'Cancel by: ' + space(1) + ltrim(rtrim(cuenta_interna.nombre)) + char(13) +
		'Cancel Date: ' + space(1) + convert(nvarchar,cancela_detalle_po.fecha_transaccion) + char(13) +
		'Description: ' + space(1) + cancela_detalle_po.observacion + char(13) + char(13) +

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
		'Pieces: ' + space(1) + convert(nvarchar,confirmacion_bouquet_cultivo.cantidad_piezas) + char(13) +
		'Order Number: ' + space(1) + [dbo].[concatenar_numero_orden_bouquet] (solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo) + char(13)
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
		cancela_detalle_po,
		confirmacion_bouquet_cultivo
		where bouquet.id_bouquet = version_bouquet.id_bouquet
		and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
		and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
		and cliente_despacho.id_despacho = po.id_despacho
		and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
		and vendedor.id_vendedor = cliente_factura.id_vendedor
		and po.id_po = detalle_po.id_po
		and cuenta_interna.id_cuenta_interna = cancela_detalle_Po.id_cuenta_interna
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
		and detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
		and detalle_po.id_detalle_po = @id_detalle_po
		and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po

		set @correo = replace(@correo, ',',';')
		set @perfil = 'Reportes_Fincas'

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @correo,
		@subject = @subject1,
		@profile_name = @perfil,
		@body = @body1,
		@body_format = 'TEXT';
	end
end
else
if(@accion = 'consultar_detalle_po')
begin
	declare @id_detalle_po_maximo int,
	@min_id_detalle_Po int,
	@min_id_farm_detalle_po int,	
	@id_farm_original int

	select @id_detalle_po_padre = detalle_po.id_detalle_po_padre
	from detalle_po
	where detalle_po.id_detalle_po = @id_detalle_po

	create table #id
	(
		id int identity(1,1),
		id_detalle_po int
	)

	insert into #id (id_detalle_Po)
	select detalle_po.id_detalle_po
	from detalle_po
	where id_detalle_po_padre = @id_detalle_po_padre
	order by detalle_po.id_detalle_po

	select @min_id_detalle_Po = min(id_detalle_po) from #id

	select @min_id_farm_detalle_po = min(farm_detalle_Po.id_farm_detalle_po)
	from farm_detalle_po,
	#id
	where #id.id_detalle_po = farm_detalle_po.id_detalle_po

	select @id_farm_original = id_farm
	from farm_detalle_po
	where id_farm_detalle_po = @min_id_farm_detalle_po

	select 1 as id,
	case
		when id_detalle_po_cancelado is null then 'Entered' 
		else 'C - Entered'
	end as status,
	cuenta_interna.nombre,
	detalle_po.fecha_transaccion,
	detalle_po.id_detalle_po,
	'' as comentario into #historia_detalle_po
	from detalle_po,
	cuenta_interna
	where detalle_po.id_detalle_po = @min_id_detalle_Po
	and cuenta_interna.id_cuenta_interna = detalle_po.id_cuenta_interna
	union all
	select 2 as id,
	'Modify' as status,
	cuenta_interna.nombre,
	detalle_po.fecha_transaccion,
	detalle_po.id_detalle_po,
	'' as comentario
	from detalle_po,
	cuenta_interna
	where detalle_po.id_detalle_po_padre = @id_detalle_po_padre
	and detalle_po.id_detalle_po <> @min_id_detalle_Po
	and cuenta_interna.id_cuenta_interna = detalle_po.id_cuenta_interna
	union all
	select 3 as id,
	'Farm Assigned' as status,
	cuenta_interna.nombre,
	farm_detalle_po.fecha_transaccion,
	detalle_po.id_detalle_po,
	farm.idc_farm + ' [' + ltrim(rtrim(farm.nombre_farm)) + '] - Flying: ' + convert(nvarchar,farm_detalle_po.fecha_vuelo, 101)
	from detalle_po,
	cuenta_interna,
	farm_detalle_po,
	farm
	where cuenta_interna.id_cuenta_interna = farm_detalle_po.id_cuenta_interna
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm_detalle_po.id_farm_detalle_Po = @min_id_farm_detalle_po
	and farm.id_farm = farm_detalle_po.id_farm
	union all
	select 4 as id,
	'Farm Modify' as status,
	cuenta_interna.nombre,
	farm_detalle_po.fecha_transaccion,
	detalle_po.id_detalle_po,
	farm.idc_farm + ' [' + ltrim(rtrim(farm.nombre_farm)) + '] - Flying: ' + convert(nvarchar,farm_detalle_po.fecha_vuelo, 101)
	from detalle_po,
	cuenta_interna,
	farm_detalle_po,
	farm
	where cuenta_interna.id_cuenta_interna = farm_detalle_po.id_cuenta_interna
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm_detalle_po.id_farm_detalle_Po <> @min_id_farm_detalle_po
	and detalle_po.id_detalle_po_padre = @id_detalle_po_padre
	and @id_farm_original <> farm_detalle_po.id_farm
	and farm.id_farm = farm_detalle_po.id_farm
	union all
	select 5 as id,
	case
		when solicitud_confirmacion_cultivo.aceptada = 1 then 'Sent to Farm'
		else 'Returned' 
	end as status,
	cuenta_interna.nombre,
	solicitud_confirmacion_cultivo.fecha_transaccion,
	detalle_po.id_detalle_po,
	case
		when solicitud_confirmacion_cultivo.aceptada = 1 then 'Num. Solicitud: ' + convert(nvarchar,po.numero_solicitud)
		else solicitud_confirmacion_cultivo.observacion
	end
	from detalle_po,
	po,
	cuenta_interna,
	farm_detalle_po,
	solicitud_confirmacion_cultivo
	where detalle_po.id_detalle_po_padre = @id_detalle_po_padre
	and cuenta_interna.id_cuenta_interna = solicitud_confirmacion_cultivo.id_cuenta_interna
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	and po.id_po = detalle_po.id_po
	union all
	select 6 as id,
	'Returned by Farm' as status,
	cuenta_interna.nombre,
	confirmacion_bouquet_cultivo.fecha_transaccion,
	detalle_po.id_detalle_po,
	'Pieces: ' + convert(nvarchar,confirmacion_bouquet_cultivo.cantidad_piezas) + ' -- Observation: ' + ltrim(rtrim(confirmacion_bouquet_cultivo.observacion))
	from detalle_po,
	cuenta_interna,
	farm_detalle_po,
	solicitud_confirmacion_cultivo,
	confirmacion_bouquet_cultivo
	where detalle_po.id_detalle_po_padre = @id_detalle_po_padre
	and cuenta_interna.id_cuenta_interna = confirmacion_bouquet_cultivo.id_cuenta_interna
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
	and confirmacion_bouquet_cultivo.aceptada = 0
	union all
	select 7 as id,
	'Confirmed',
	cuenta_interna.nombre,
	confirmacion_bouquet_cultivo.fecha_transaccion,
	detalle_po.id_detalle_po,
	'Pieces: ' + convert(nvarchar,confirmacion_bouquet_cultivo.cantidad_piezas) + ' -- PEPR: ' + isnull(confirmacion_bouquet_cultivo.idc_pedido_pepr, '')
	from detalle_po,
	cuenta_interna,
	farm_detalle_po,
	solicitud_confirmacion_cultivo,
	confirmacion_bouquet_cultivo--,
	--orden_pedido_bouquet,
	--orden_pedido
	where --orden_pedido.id_orden_pedido = orden_pedido_bouquet.id_orden_pedido
	--and confirmacion_bouquet_cultivo.id_confirmacion_bouquet_cultivo = orden_pedido_bouquet.id_confirmacion_bouquet_cultivo
	detalle_po.id_detalle_po_padre = @id_detalle_po_padre
	and cuenta_interna.id_cuenta_interna = confirmacion_bouquet_cultivo.id_cuenta_interna
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
	union all
	select 8 as id,
	'Cancel',
	cuenta_interna.nombre,
	cancela_detalle_po.fecha_transaccion,
	detalle_po.id_detalle_po,
	cancela_detalle_po.observacion
	from detalle_po,
	cancela_detalle_po,
	cuenta_interna
	where cuenta_interna.id_cuenta_interna = cancela_detalle_po.id_cuenta_interna
	and detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
	and detalle_po.id_detalle_po_padre = @id_detalle_po_padre

	select @conteo = count(*) from #id

	create table #resultado_historia
	(
		id int,
		id_detalle_po int,
		id_detalle_po_maximo int,
		texto nvarchar(255)
	)

	while(@conteo > = 1)
	begin
		declare @id_tipo_flor int,
		@nombre_tipo_flor nvarchar(255),
		@nombre_variedad_flor nvarchar(255),
		@nombre_grado_flor nvarchar(255),
		@nombre_caja nvarchar(255),
		@nombre_comida nvarchar(255),
		@nombre_capuchon nvarchar(255),
		@precio_miami decimal(20,2),
		@nombre_tapa nvarchar(255),
		@texto_unidades nvarchar(255),
		@texto_precio_miami nvarchar(255),
		@texto_cantidad_piezas nvarchar(255),
		@texto_ethyblock_sachet nvarchar(255),
		@farm_price decimal(20,2),
		@unidades_nuevas int
		
		select @id_detalle_po_maximo = id_detalle_po 
		from #id
		where id = @conteo -1

		select @id_detalle_po = id_detalle_po 
		from #id
		where id = @conteo

		select @id_tipo_flor = tipo_flor.id_tipo_flor,
		@nombre_tipo_flor = ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
		@id_variedad_flor = variedad_flor.id_variedad_flor,
		@nombre_variedad_flor = ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
		@id_grado_flor = grado_flor.id_grado_flor,
		@nombre_grado_flor = ltrim(rtrim(grado_flor.nombre_grado_flor)),
		@id_caja = caja.id_caja,
		@nombre_caja = ltrim(rtrim(caja.nombre_caja)),
		@unidades =
		isnull((
			select sum(detalle_version_bouquet.unidades)
			from detalle_version_bouquet
			where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
		),0),
		@precio_miami = 
		isnull((
			select sum(detalle_version_bouquet.precio_miami)
			from detalle_version_bouquet
			where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
		),0) /
		(
			select sum(detalle_version_bouquet.unidades)
			from detalle_version_bouquet
			where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
		),
		@id_tapa = tapa.id_tapa,
		@nombre_tapa = ltrim(rtrim(tapa.nombre_tapa)),
		@cantidad_piezas = detalle_po.cantidad_piezas,
		@marca = detalle_po.marca,
		@ethyblock_sachet = detalle_po.ethyblock_sachet,
		@farm_price = 
		(
			select solicitud_confirmacion_cultivo.farm_price
			from farm_detalle_po,
			solicitud_confirmacion_cultivo
			where detalle_Po.id_detalle_Po = farm_detalle_Po.id_detalle_po
			and solicitud_confirmacion_cultivo.id_farm_detalle_Po = farm_detalle_po.id_farm_detalle_Po
		)
		from detalle_po,
		bouquet,
		version_bouquet,
		variedad_flor,
		grado_flor,
		tipo_flor,
		caja,
		tapa
		where detalle_po.id_detalle_po = @id_detalle_po_maximo
		and bouquet.id_bouquet = version_bouquet.id_bouquet
		and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
		and grado_flor.id_grado_flor = bouquet.id_grado_flor
		and caja.id_caja = version_bouquet.id_caja
		and tapa.id_tapa = detalle_po.id_tapa

		select @nombre_tipo_flor =
		case
			when tipo_flor.id_tipo_flor <> @id_tipo_flor then 'Flower Type: ' + @nombre_tipo_flor + ' | ' + ltrim(rtrim(tipo_flor.nombre_tipo_flor))
			else null
		end,
		@nombre_variedad_flor = 
		case
			when variedad_flor.id_variedad_flor <> @id_variedad_flor then 'Variety: ' + @nombre_variedad_flor + ' | ' + ltrim(rtrim(variedad_flor.nombre_variedad_flor))
			else null
		end,
		@nombre_grado_flor = 
		case
			when grado_flor.id_grado_flor <> @id_grado_flor then 'Grade: ' + @nombre_grado_flor + ' | '+ ltrim(rtrim(grado_flor.nombre_grado_flor))
			else null
		end,
		@nombre_caja = 
		case
			when caja.id_caja <> @id_caja then 'Box: ' + @nombre_caja + ' | ' + ltrim(rtrim(caja.nombre_caja))
			else null
		end,
		@texto_unidades = 
		case
			when 
			isnull((
				select sum(detalle_version_bouquet.unidades)
				from detalle_version_bouquet
				where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
			),0) <> @unidades then 'Pack: ' + convert(nvarchar,@unidades) + ' | ' + 
			convert(nvarchar,
			isnull((
				select sum(detalle_version_bouquet.unidades)
				from detalle_version_bouquet
				where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
			),0))				
			else null
		end,
		@texto_precio_miami = 
		case
			when
			isnull((
				select sum(detalle_version_bouquet.precio_miami)
				from detalle_version_bouquet
				where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
			),0) <> @precio_miami then 'Miami Price: ' + convert(nvarchar,@precio_miami) + ' | ' + convert(nvarchar,convert(decimal(20,2),
			isnull((
				select sum(detalle_version_bouquet.precio_miami)
				from detalle_version_bouquet
				where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
			),0) /
			(
				select sum(detalle_version_bouquet.precio_miami)
				from detalle_version_bouquet
				where detalle_version_bouquet.id_version_bouquet = version_bouquet.id_version_bouquet
			)))
			else null
		end,
		@nombre_tapa = 
		case
			when tapa.id_tapa <> @id_tapa then 'Lid: ' + @nombre_tapa + ' | ' + ltrim(rtrim(tapa.nombre_tapa))
			else null
		end,
		@texto_cantidad_piezas = 
		case
			when detalle_po.cantidad_piezas <> @cantidad_piezas then 'Pieces: ' + convert(nvarchar,@cantidad_piezas) + ' | ' + convert(nvarchar,detalle_po.cantidad_piezas)
			else null
		end,
		@marca = 
		case
			when detalle_po.marca <> @marca then 'Code: ' + @marca + ' | ' + detalle_po.marca
			else null
		end,
		@texto_ethyblock_sachet =
		case
			when detalle_po.ethyblock_sachet <> @ethyblock_sachet then 'Eth. Sachet: ' + convert(nvarchar,replace(replace(@ethyblock_sachet, 1, 'YES'), 0, 'NO')) + ' | ' + convert(nvarchar,replace(replace(detalle_po.ethyblock_sachet, 1, 'YES'), 0, 'NO'))
			else null
		end,
		@farm_price = 
		case
			when 
			(
				select convert(decimal(20,2),solicitud_confirmacion_cultivo.farm_price)
				from farm_detalle_po,
				solicitud_confirmacion_cultivo
				where detalle_Po.id_detalle_Po = farm_detalle_Po.id_detalle_po
				and solicitud_confirmacion_cultivo.id_farm_detalle_Po = farm_detalle_po.id_farm_detalle_Po
			) <> @farm_price then 'Farm Price: ' + convert(nvarchar,@farm_price) + ' | ' + 
			convert(nvarchar,(
				select convert(decimal(20,2),solicitud_confirmacion_cultivo.farm_price)
				from farm_detalle_po,
				solicitud_confirmacion_cultivo
				where detalle_Po.id_detalle_Po = farm_detalle_Po.id_detalle_po
				and solicitud_confirmacion_cultivo.id_farm_detalle_Po = farm_detalle_po.id_farm_detalle_Po
			))
			else null
		end
		from detalle_po,
		bouquet,
		version_bouquet,
		variedad_flor,
		grado_flor,
		tipo_flor,
		caja,
		tapa
		where detalle_po.id_detalle_po = @id_detalle_po
		and bouquet.id_bouquet = version_bouquet.id_bouquet
		and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
		and grado_flor.id_grado_flor = bouquet.id_grado_flor
		and caja.id_caja = version_bouquet.id_caja
		and tapa.id_tapa = detalle_po.id_tapa

		insert into #resultado_historia (id, texto, id_detalle_po, id_detalle_po_maximo)
		select 2, @nombre_tipo_flor, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @nombre_variedad_flor, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @nombre_grado_flor, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @nombre_caja, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @texto_unidades, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @texto_precio_miami, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @nombre_tapa, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @texto_cantidad_piezas, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @marca, @id_detalle_po, @id_detalle_po_maximo
		union all
		select 2, @texto_ethyblock_sachet, @id_detalle_po, @id_detalle_po_maximo

		set @conteo = @conteo - 1
	end

	select #historia_detalle_po.id,
	#historia_detalle_po.id_detalle_po into #borrar
	from #historia_detalle_po,
	#resultado_historia
	where #historia_detalle_po.id = #resultado_historia.id
	and #historia_detalle_po.id_detalle_po = #resultado_historia.id_detalle_po
	and #historia_detalle_po.id = 2
	and #resultado_historia.texto is not null
	group by #historia_detalle_po.id,
	#historia_detalle_po.id_detalle_po

	delete from #historia_detalle_po
	where not exists
	(
		select *
		from #borrar
		where #borrar.id = #historia_detalle_po.id
		and #borrar.id_detalle_po = #historia_detalle_po.id_detalle_po
	)
	and #historia_detalle_po.id = 2

	select id,
	id_detalle_po,
	status,
	nombre,
	fecha_transaccion,
	comentario
	from #historia_detalle_po
	order by fecha_transaccion asc,
	id_detalle_po

	select id, id_detalle_po, texto from #resultado_historia where texto is not null

	drop table #historia_detalle_po
	drop table #resultado_historia
	drop table #id
	drop table #borrar
end
else
if(@accion = 'copiar_detalle_po')
begin
	select @id_bouquet = bouquet.id_bouquet
	from bouquet
	where id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor

	if(@id_bouquet is null)
	begin
		insert into bouquet (id_variedad_flor, id_grado_flor, imagen)
		values (@id_variedad_flor, @id_grado_flor, @imagen)
	
		set @id_bouquet = scope_identity()
	end

	insert into version_bouquet (id_caja, id_bouquet)
	values (@id_caja, @id_bouquet)

	set @id_version_bouquet = scope_identity()

	select IDENTITY(int, 1, 1) AS id,
	@id_version_bouquet as id_version_bouquet,
	detalle_version_bouquet.id_detalle_version_bouquet,
	detalle_version_bouquet.id_formula_bouquet,
	detalle_version_bouquet.unidades,
	detalle_version_bouquet.precio_miami,
	detalle_version_bouquet.opcion_menu,
	detalle_version_bouquet.id_comida_bouquet,
	isnull(formato_upc.id_formato_upc, 1) as id_formato_upc,
	isnull(formato_upc.nombre_formato, '') as nombre_formato into #detalle_version_bouquet
	from detalle_po,
	version_bouquet,
	detalle_version_bouquet left join formato_upc on formato_upc.id_formato_upc = detalle_version_bouquet.id_formato_upc
	where version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and detalle_po.id_detalle_po = @id_detalle_po
	group by detalle_version_bouquet.id_detalle_version_bouquet,
	detalle_version_bouquet.id_formula_bouquet,
	detalle_version_bouquet.unidades,
	detalle_version_bouquet.precio_miami,
	detalle_version_bouquet.opcion_menu,
	detalle_version_bouquet.id_comida_bouquet,
	isnull(formato_upc.id_formato_upc, 1),
	isnull(formato_upc.nombre_formato, '')

	select @conteo = count(*) from #detalle_version_bouquet

	while (@conteo > 0)
	begin
		declare @id int

		select @nombre_formato_upc = nombre_formato
		from #detalle_version_bouquet
		where id = @conteo

		insert into detalle_version_bouquet (id_version_bouquet, id_formula_bouquet, unidades, precio_miami, opcion_menu, id_comida_bouquet, id_formato_upc)
		select id_version_bouquet,
		id_formula_bouquet,
		unidades,
		precio_miami,
		opcion_menu,
		id_comida_bouquet,
		id_formato_upc
		from #detalle_version_bouquet
		where id = @conteo

		set @id_detalle_version_bouquet = scope_identity()

		insert into capuchon_formula_bouquet (id_capuchon_cultivo, id_detalle_version_bouquet)
		select capuchon_formula_bouquet.id_capuchon_cultivo,
		@id_detalle_version_bouquet
		from detalle_version_bouquet,
		capuchon_formula_bouquet,
		#detalle_version_bouquet
		where detalle_version_bouquet.id_detalle_version_bouquet = capuchon_formula_bouquet.id_detalle_version_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = #detalle_version_bouquet.id_detalle_version_bouquet
		and #detalle_version_bouquet.id = @conteo
		group by capuchon_formula_bouquet.id_capuchon_cultivo

		insert into sticker_bouquet (id_sticker, id_detalle_version_bouquet)
		select sticker_bouquet.id_sticker,
		@id_detalle_version_bouquet
		from detalle_version_bouquet,
		sticker_bouquet,
		#detalle_version_bouquet
		where detalle_version_bouquet.id_detalle_version_bouquet = sticker_bouquet.id_detalle_version_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = #detalle_version_bouquet.id_detalle_version_bouquet
		and #detalle_version_bouquet.id = @conteo
		group by sticker_bouquet.id_sticker

		select @id = id_informacion_upc 
		from Informacion_UPC
		where nombre_informacion_upc = @id_upc

		insert into upc_detalle_po (id_informacion_upc, valor, orden, id_detalle_version_bouquet)
		select upc_detalle_po.id_informacion_upc, 
		case
			when @nombre_formato_upc = 'NO UPC' then ''
			else upc_detalle_po.valor
		end, 
		upc_detalle_po.orden,
		@id_detalle_version_bouquet
		from detalle_version_bouquet,
		upc_detalle_po,
		Informacion_UPC,
		#detalle_version_bouquet 
		where detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = #detalle_version_bouquet.id_detalle_version_bouquet
		and Informacion_UPC.id_informacion_upc = UPC_Detalle_PO.id_informacion_upc
		and #detalle_version_bouquet.id = @conteo
		and Informacion_UPC.id_informacion_upc <> isnull(@id, 0)

		insert into upc_detalle_po (id_informacion_upc, valor, orden, id_detalle_version_bouquet)
		select upc_detalle_po.id_informacion_upc, 
		case
			when @nombre_formato_upc = 'NO UPC' then ''
			else @valor_upc
		end,  
		upc_detalle_po.orden,
		@id_detalle_version_bouquet
		from detalle_version_bouquet,
		upc_detalle_po,
		Informacion_UPC,
		#detalle_version_bouquet 
		where detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = #detalle_version_bouquet.id_detalle_version_bouquet
		and Informacion_UPC.id_informacion_upc = UPC_Detalle_PO.id_informacion_upc
		and #detalle_version_bouquet.id = @conteo
		and Informacion_UPC.id_informacion_upc = isnull(@id, 0)

		insert into observacion_detalle_formula_bouquet (id_detalle_formula_bouquet, id_detalle_version_bouquet, observacion)
		select observacion_detalle_formula_bouquet.id_detalle_formula_bouquet,
		@id_detalle_version_bouquet,
		observacion_detalle_formula_bouquet.observacion
		from observacion_detalle_formula_bouquet,
		#detalle_version_bouquet
		where #detalle_version_bouquet.id_detalle_version_bouquet = observacion_detalle_formula_bouquet.id_detalle_version_bouquet
		and #detalle_version_bouquet.id = @conteo

		insert into sustitucion_detalle_formula_bouquet (id_detalle_formula_bouquet, id_grado_flor_cultivo, id_variedad_flor_cultivo, id_detalle_version_bouquet)
		select sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet,
		sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo,
		sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo,
		@id_detalle_version_bouquet
		from sustitucion_detalle_formula_bouquet,
		#detalle_version_bouquet
		where #detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
		and #detalle_version_bouquet.id = @conteo

		set @conteo = @conteo - 1
	end

	select @valor = isnull(sum(valor),0)
	from cargo_box_charge,
	cliente_despacho,
	po,
	caja
	where cliente_despacho.id_despacho = cargo_box_charge.id_despacho
	and caja.id_caja  = cargo_box_charge.id_caja
	and po.id_despacho = cliente_despacho.id_despacho
	and po.id_po = @id_po
	and caja.id_caja = @id_caja

	insert into detalle_po (id_cuenta_interna, id_tapa, id_version_bouquet, id_po, cantidad_piezas, marca, ethyblock_sachet, box_charge)
	values (@id_cuenta_interna, @id_tapa, @id_version_bouquet, @id_po, @cantidad_piezas, @marca, @ethyblock_sachet, @valor)
	
	set @id_detalle_po = scope_identity()

	update detalle_po
	set id_detalle_po_padre = @id_detalle_po
	where id_detalle_po = @id_detalle_po

	insert into item_number (id_cliente_factura, numero_item, id_version_bouquet)
	select cliente_factura.id_cliente_factura, @numero_item, @id_version_bouquet
	from cliente_factura,
	cliente_despacho,
	po
	where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and po.id_despacho = cliente_despacho.id_despacho
	and po.id_po = @id_po
	 
	if(@id_farm > 0)
	begin
		select @fecha = fecha_despacho_miami
		from po
		where po.id_po = @id_po
		
		select @factor_a_full = tipo_caja.factor_a_full
		from tipo_caja,
		caja,
		version_bouquet
		where caja.id_caja = version_bouquet.id_caja
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		and version_bouquet.id_version_bouquet = @id_version_bouquet

		insert into farm_detalle_po (id_detalle_po, id_farm, id_cuenta_interna, fecha_vuelo, comision_farm, freight_por_pieza, cantidad_piezas)
		select @id_detalle_po,
		farm.id_farm,
		@id_cuenta_interna,
		[dbo].[calcular_dia_vuelo_mass_market] (@fecha, farm.idc_farm),
		farm.comision_farm,
		(ciudad.impuesto_por_caja * @factor_a_full),
		@cantidad_piezas
		from farm,
		ciudad
		where farm.id_farm = @id_farm
		and ciudad.id_ciudad = farm.id_ciudad

		set @id_farm_detalle_po = scope_identity()

		update farm_detalle_po
		set id_farm_detalle_po_padre = @id_farm_detalle_po
		where id_farm_detalle_po = @id_farm_detalle_po
	end

	drop table #detalle_version_bouquet

	select @id_detalle_po as id_detalle_po
end
else
if(@accion = 'consultar_bouquet')
begin
	select bouquet.id_bouquet,
	bouquet.imagen
	from bouquet
	where id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor
end
else
if(@accion = 'consultar_po_anteriores')
begin
	select max(id_detalle_po) as id_detalle_po into #detalle_po1
	from detalle_po
	group by id_detalle_po_padre

	select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po1
	from farm_detalle_po
	group by id_farm_detalle_po_padre

	select detalle_po.id_detalle_po,
	farm.id_farm,
	idc_farm + space(1) + '['+ ltrim(rtrim(nombre_farm)) + ']'as nombre_farm, 
	solicitud_confirmacion_cultivo.aceptada,
	NULL AS id_detalle_version_bouquet,
	farm_detalle_po.fecha_vuelo,
	(
		select cancela_detalle_po.id_cancela_detalle_po
		from cancela_detalle_po
		where cancela_detalle_po.id_detalle_po = detalle_po.id_detalle_po 
	) as cancelada into #temp1
	from po,
	version_bouquet,
	detalle_po left join farm_detalle_po on detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and exists
	(
		select *
		from #farm_detalle_po1
		where #farm_detalle_po1.id_farm_detalle_po = farm_detalle_po.id_farm_detalle_po
	)
	left join farm on farm.id_farm = farm_detalle_po.id_farm
	left join solicitud_confirmacion_cultivo on farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	where po.id_po = detalle_po.id_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and po.id_po = @id_po
	and exists
	(
		select *
		from #detalle_po1
		where #detalle_po1.id_detalle_po = detalle_po.id_detalle_po
	)

	update #temp1
	set aceptada = 1
	where cancelada > = 1

	select bouquet.id_bouquet,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor,
	tapa.idc_tapa,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	bouquet.imagen,
	version_bouquet.id_version_bouquet,
	caja.id_caja,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	ltrim(rtrim(caja.medida)) as medida_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	(
		select sum(unidades)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as unidades,
	po.id_po,
	detalle_po.id_detalle_po,
	detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	convert(decimal(20,2), (
		select sum(precio_miami)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	)) as precio_miami_pieza,
	detalle_po.box_charge,
	NULL as id_comida_bouquet,
	NULL as nombre_comida_bouquet,
	NULL as upc,
	NULL as orden_upc,
	NULL as descripcion_upc,
	NULL as orden_descripcion_upc,
	NULL as fecha_upc,
	NULL as orden_fecha_upc,
	NULL as precio_upc,
	NULL as orden_precio_upc,
	NULL AS nombre_formula_bouquet,
	NULL AS especificacion_bouquet,
	NULL AS construccion_bouquet,
	NULL AS id_formula_bouquet,
	NULL AS id_detalle_version_bouquet,
	NULL as id_grado_flor_cultivo,
	NULL AS opcion_menu,
	tapa.id_tapa,
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
	(
		select top 1 id_farm
		from #temp1
		where detalle_po.id_detalle_po = #temp1.id_detalle_po
	) as id_farm,
	(
		select top 1 nombre_farm
		from #temp1
		where detalle_po.id_detalle_po = #temp1.id_detalle_po
	) as nombre_farm,
	(
		select top 1 fecha_vuelo
		from #temp1
		where detalle_po.id_detalle_po = #temp1.id_detalle_po
	) as fecha_vuelo,
	dbo.consultar_estado_detalle_po (detalle_po.id_detalle_po) as status,
	isnull((
		select top 1 aceptada
		from #temp1
		where detalle_po.id_detalle_po = #temp1.id_detalle_po
	), 0) as id_status,
	(
		select top 1 numero_item
		from cliente_factura,
		cliente_despacho,
		item_number
		where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
		and cliente_despacho.id_despacho = po.id_despacho
		and cliente_factura.id_cliente_factura = item_number.id_cliente_factura
		and version_bouquet.id_version_bouquet = item_number.id_version_bouquet	
	) as item_number,
	(
		select count(*)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) AS cantidad_formulas into #resultado1
	from po,
	detalle_po,
	tapa,
	version_bouquet,
	bouquet,
	caja,
	tipo_caja,
	tipo_flor,
	variedad_flor,
	grado_flor
	where po.id_po = detalle_po.id_po
	and tapa.id_tapa = detalle_po.id_tapa
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and caja.id_caja = version_bouquet.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and po.id_po = @id_po
	and exists
	(
		select *
		from #detalle_po1
		where #detalle_po1.id_detalle_po = detalle_po.id_detalle_po
	)
	
	select id_bouquet,
	idc_tipo_flor,
	idc_grado_flor,
	max(idc_tapa) as idc_tapa,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	(
		select top 1 r.imagen
		from #resultado1 as r
		where r.id_bouquet = #resultado1.id_bouquet
	) as imagen,
	max(id_version_bouquet) as id_version_bouquet,
	id_caja,
	idc_caja,
	nombre_tipo_caja,
	medida_caja,
	nombre_caja,
	max(unidades) as unidades,
	max(id_comida_bouquet) as id_comida_bouquet,
	max(nombre_comida_bouquet) as nombre_comida_bouquet,
	id_po,
	max(id_detalle_po) as id_detalle_po,
	max(cantidad_piezas) as cantidad_piezas,
	marca,
	convert(bit, max(convert(int,ethyblock_sachet))) as ethyblock_sachet,
	precio_miami_pieza,
	max(box_charge) as box_charge,
	upc,
	orden_upc,
	descripcion_upc,
	orden_descripcion_upc,
	fecha_upc,
	orden_fecha_upc,
	precio_upc,
	orden_precio_upc,
	max(id_tapa) as id_tapa,
	max(nombre_tapa) as nombre_tapa,
	max(id_farm) as id_farm,
	max(nombre_farm) as nombre_farm,
	max(fecha_vuelo) as fecha_vuelo,
	max(status) as status,
	max(convert(int,id_status)) as id_status,
	max(nombre_formula_bouquet) as nombre_formula_bouquet,
	max(especificacion_bouquet) as especificacion_bouquet,
	max(construccion_bouquet) as construccion_bouquet,
	max(id_formula_bouquet) as id_formula_bouquet,
	max(id_detalle_version_bouquet) as id_detalle_version_bouquet,
	max(id_grado_flor_cultivo) as id_grado_flor_cultivo,
	max(item_number) as item_number,
	max(opcion_menu) as opcion_menu,
	sum(cantidad_formulas) as cantidad_formulas
	from #resultado1
	group by id_detalle_po,
	id_bouquet,
	idc_tipo_flor,
	idc_grado_flor,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	id_caja,
	idc_caja,
	nombre_tipo_caja,
	medida_caja,
	nombre_caja,
	id_po,
	marca,
	precio_miami_pieza,
	upc,
	orden_upc,
	descripcion_upc,
	orden_descripcion_upc,
	fecha_upc,
	orden_fecha_upc,
	precio_upc,
	orden_precio_upc
	ORDER BY idc_tipo_flor,
	nombre_variedad_flor,
	marca

	drop table #temp1
	drop table #detalle_po1
	drop table #farm_detalle_po1
	drop table #resultado1
end
else
if(@accion = 'actualizar_upc')
begin
	select @conteo = count(*)
	from informacion_upc,
	upc_detalle_po
	where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
	and upc_detalle_po.id_detalle_version_bouquet = @id_detalle_version_bouquet
	and informacion_upc.nombre_informacion_upc = @id_upc

	select @nombre_formato_upc = isnull(formato_upc.nombre_formato, '')
	from formato_upc,
	detalle_version_bouquet
	where formato_upc.id_formato_upc = detalle_version_bouquet.id_formato_upc
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet

	if(@conteo > 0)
	begin
		update upc_detalle_po
		set valor = 
		case
			when @nombre_formato_upc = 'NO UPC' then ''
			else @valor_upc
		end,
		orden = @orden_upc
		from informacion_upc
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and upc_detalle_po.id_detalle_version_bouquet = @id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @id_upc

		if(@id_upc = 'UPC')
		begin
			select @id_bouquet = bouquet.id_bouquet,
			@id_despacho = cliente_despacho.id_despacho
			from po,
			detalle_po,
			version_bouquet,
			detalle_version_bouquet,
			bouquet,
			cliente_despacho
			where po.id_po = detalle_po.id_po
			and bouquet.id_bouquet = version_bouquet.id_bouquet
			and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
			and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
			and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
			and cliente_despacho.id_despacho = po.id_despacho

			select @conteo = count(*)
			from define_upc
			where define_upc.id_despacho = @id_despacho
			and define_upc.id_bouquet = @id_bouquet
			
			if(@id_despacho is not null and @id_bouquet is not null)
			begin
				if(@conteo = 0)
				begin
					insert into define_upc (id_despacho, id_bouquet, upc)
					values (@id_despacho, @id_bouquet, @valor_upc)
				end
				else
				begin
					update define_upc
					set upc = @valor_upc
					where define_upc.id_bouquet = @id_bouquet
					and define_upc.id_despacho = @id_despacho 
				end
			end
		end
	end
	else
	if(@conteo = 0)
	begin
		insert into upc_detalle_po (id_detalle_version_bouquet, id_informacion_upc, valor, orden)
		select @id_detalle_version_bouquet, 
		informacion_upc.id_informacion_upc, 
		case
			when @nombre_formato_upc = 'NO UPC' then ''
			else @valor_upc
		end, 
		@orden_upc
		from informacion_upc
		where nombre_informacion_upc = @id_upc

		if(@id_upc = 'UPC')
		begin
			select @id_bouquet = bouquet.id_bouquet,
			@id_despacho = cliente_despacho.id_despacho
			from po,
			detalle_po,
			version_bouquet,
			detalle_version_bouquet,
			bouquet,
			cliente_despacho
			where po.id_po = detalle_po.id_po
			and bouquet.id_bouquet = version_bouquet.id_bouquet
			and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
			and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
			and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
			and cliente_despacho.id_despacho = po.id_despacho

			select @conteo = count(*)
			from define_upc
			where define_upc.id_despacho = @id_despacho
			and define_upc.id_bouquet = @id_bouquet
			
			if(@id_despacho is not null and @id_bouquet is not null)
			begin
				if(@conteo = 0)
				begin
					insert into define_upc (id_despacho, id_bouquet, upc)
					values (@id_despacho, @id_bouquet, @valor_upc)
				end
				else
				begin
					update define_upc
					set upc = @valor_upc
					where define_upc.id_bouquet = @id_bouquet
					and define_upc.id_despacho = @id_despacho 
				end
			end
		end
	end
end
else
if(@accion = 'insertar_upc')
begin
	select @nombre_formato_upc = isnull(formato_upc.nombre_formato, '')
	from formato_upc,
	detalle_version_bouquet
	where formato_upc.id_formato_upc = detalle_version_bouquet.id_formato_upc
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet

	insert into upc_detalle_po (id_detalle_version_bouquet, id_informacion_upc, valor, orden)
	select @id_detalle_version_bouquet, 
	informacion_upc.id_informacion_upc, 
	case
		when @nombre_formato_upc = 'NO UPC' then ''
		else @valor_upc
	end, 
	@orden_upc
	from informacion_upc
	where nombre_informacion_upc = @id_upc

	if(@id_upc = 'UPC')
	begin
		select @id_bouquet = bouquet.id_bouquet,
		@id_despacho = cliente_despacho.id_despacho
		from po,
		detalle_po,
		version_bouquet,
		detalle_version_bouquet,
		bouquet,
		cliente_despacho
		where po.id_po = detalle_po.id_po
		and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
		and bouquet.id_bouquet = version_bouquet.id_bouquet
		and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
		and cliente_despacho.id_despacho = po.id_despacho

		select @conteo = count(*)
		from define_upc
		where define_upc.id_despacho = @id_despacho
		and define_upc.id_bouquet = @id_bouquet
		
		if(@id_despacho is not null and @id_bouquet is not null)
		begin
			if(@conteo = 0)
			begin
				insert into define_upc (id_despacho, id_bouquet, upc)
				values (@id_despacho, @id_bouquet, @valor_upc)
			end
			else
			begin
				update define_upc
				set upc = @valor_upc
				where define_upc.id_bouquet = @id_bouquet
				and define_upc.id_despacho = @id_despacho 
			end
		end
	end

	select scope_identity() as id_upc_detalle_po
end