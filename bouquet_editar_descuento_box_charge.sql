set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/29
-- Description:	maneja la informacion de los descuentos de Box Charge para los pedidod por enviar al cultivo
-- =============================================

alter PROCEDURE [dbo].[bouquet_editar_descuento_box_charge] 

@accion nvarchar(255),
@id_farm_detalle_po int,
@id_farm int,
@po_number nvarchar(255),
@id_cuenta_interna int, 
@valor_descuento decimal(20,4)

as

if(@accion = 'consultar')
begin
	select max(detalle_po.id_detalle_po) as id_detalle_po into #detalle_po
	from detalle_po
	group by id_detalle_po_padre

	select max(farm_detalle_po.id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
	from farm_detalle_po
	group by id_farm_detalle_po_padre

	select detalle_po.id_detalle_po,
	farm_detalle_po.id_farm_detalle_po,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	caja.nombre_caja,
	caja.medida as medida_caja,
	comida_bouquet.id_comida_bouquet,
	comida_bouquet.nombre_comida,
	sum(detalle_version_bouquet.unidades) as unidades,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas,
	detalle_po.marca,
	convert(decimal(20,2),detalle_po.box_charge * detalle_version_bouquet.unidades) as box_charge,
	sum(Detalle_Version_Bouquet.precio_miami) as precio_miami_pieza,
	farm.idc_farm,
	farm.nombre_farm,
	farm.id_farm,
	farm_detalle_po.comision_farm,
	farm_detalle_po.freight_por_pieza,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	po.fecha_despacho_miami,
	po.po_number,
	farm_detalle_po.fecha_vuelo,
	descuento_box_charge.fecha_transaccion,
	cuenta_interna.nombre as nombre_cuenta_interna,
	convert(decimal(20,2),isnull(descuento_box_charge.valor_descuento * detalle_version_bouquet.unidades, 0)) as valor_descuento into #temp
	from farm_detalle_po left join descuento_box_charge on farm_detalle_po.id_farm_detalle_po = descuento_box_charge.id_farm_detalle_po
	left join cuenta_interna on cuenta_interna.id_cuenta_interna = descuento_box_charge.id_cuenta_interna,
	cliente_despacho,
	tapa,
	farm,
	caja,
	tipo_caja,
	detalle_po,
	po,
	bouquet,
	version_bouquet,
	tipo_flor,
	variedad_flor,
	grado_flor,
	comida_bouquet,
	detalle_version_bouquet
	where cliente_despacho.id_despacho = po.id_despacho
	and tapa.id_tapa = detalle_po.id_tapa
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and caja.id_caja = version_bouquet.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and comida_bouquet.id_comida_bouquet = detalle_version_bouquet.id_comida_bouquet
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and farm.id_farm = farm_detalle_po.id_farm
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and po.id_po = detalle_po.id_po
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and not exists
	(
		select *
		from solicitud_confirmacion_cultivo
		where farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	)
	and exists
	(
		select *
		from #detalle_po
		where #detalle_po.id_detalle_po = detalle_po.id_detalle_po
	)
	and exists
	(
		select *
		from #farm_detalle_po
		where #farm_detalle_po.id_farm_detalle_po = farm_detalle_po.id_farm_detalle_po
	)
	and not exists
	(
		select *
		from cancela_detalle_po
		where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
	)
	group by detalle_po.id_detalle_po,
	farm_detalle_po.id_farm_detalle_po,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	caja.nombre_caja,
	caja.medida,
	comida_bouquet.id_comida_bouquet,
	comida_bouquet.nombre_comida,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas,
	detalle_po.marca,
	convert(decimal(20,2),detalle_po.box_charge * detalle_version_bouquet.unidades),
	farm.idc_farm,
	farm.nombre_farm,
	farm.id_farm,
	farm_detalle_po.comision_farm,
	farm_detalle_po.freight_por_pieza,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.id_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)),
	po.fecha_despacho_miami,
	po.po_number,
	farm_detalle_po.fecha_vuelo,
	descuento_box_charge.fecha_transaccion,
	cuenta_interna.nombre,
	convert(decimal(20,2),isnull(descuento_box_charge.valor_descuento * detalle_version_bouquet.unidades, 0))

	select * 
	from #temp

	select id_farm,
	'[' + idc_farm + '] ' + LTRIM(RTRIM(nombre_farm)) as nombre_farm
	from #temp
	group by id_farm,
	idc_farm,
	LTRIM(RTRIM(nombre_farm))
	order by idc_farm

	select id_despacho,
	idc_cliente_despacho + ' [' + nombre_cliente + ']' as idc_cliente_despacho
	from #temp
	group by id_despacho,
	nombre_cliente,
	idc_cliente_despacho
	order by idc_cliente_despacho

	drop table #detalle_po
	drop table #farm_detalle_po
	drop table #temp
end
else
if(@accion = 'insertar')
begin
	declare @conteo int,
	@unidades int

	select @conteo = count(*)
	from descuento_box_charge
	where id_farm_detalle_po = @id_farm_detalle_po

	select @unidades = sum(detalle_version_bouquet.unidades)
	from detalle_po,
	version_bouquet,
	detalle_version_bouquet,
	farm_detalle_po
	where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet

	if(@conteo = 0)
	begin
		insert into descuento_box_charge (id_farm_detalle_po, id_cuenta_interna, valor_descuento)
		values (@id_farm_detalle_po, @id_cuenta_interna, @valor_descuento/@unidades)
	end
	else
	begin
		update descuento_box_charge
		set valor_descuento = @valor_descuento/@unidades,
		id_cuenta_interna = @id_cuenta_interna,	
		fecha_transaccion = getdate()
		where id_farm_detalle_po = @id_farm_detalle_po
	end
end