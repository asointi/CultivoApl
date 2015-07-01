USE [BD_Fresca];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/29
-- Description:	maneja la informacion para enviar las solicitudes por e-mail a los cultivos
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_editar_solicitud_confirmacion_cultivo] 

@accion nvarchar(255),
@id_farm_detalle_po int, 
@id_cuenta_interna int, 
@aceptada bit, 
@observacion nvarchar(1024), 
@farm_price decimal(20,4),
@farm_price_modificado decimal(20,4)

as

if(@accion = 'consultar')
begin
	select max(detalle_po.id_detalle_po) as id_detalle_po into #detalle_po
	from detalle_po
	group by id_detalle_po_padre

	select max(farm_detalle_po.id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
	from farm_detalle_po
	group by id_farm_detalle_po_padre

	select id_solicitud_confirmacion_cultivo,
	max(id_confirmacion_bouquet_cultivo) as id_confirmacion_bouquet_cultivo,
	0 as cantidad_piezas into #confirmaciones_agrupadas
	from confirmacion_bouquet_cultivo
	where aceptada = 0 
	group by id_solicitud_confirmacion_cultivo

	update #confirmaciones_agrupadas
	set cantidad_piezas = confirmacion_bouquet_cultivo.cantidad_piezas
	from confirmacion_bouquet_cultivo
	where confirmacion_bouquet_cultivo.id_confirmacion_bouquet_cultivo = #confirmaciones_agrupadas.id_confirmacion_bouquet_cultivo

	select version_bouquet.id_version_bouquet,
	farm_detalle_po.id_farm_detalle_po,
	detalle_po.id_detalle_po,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	po.id_po,
	po.po_number,
	po.fecha_despacho_miami,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	farm_detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
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
	'carlos@natuflora.net,ricardo@natuflora.net,sisandres@natuflora.net,viviana@natuflora.com,lucia@natuflora.com,dpineros@natuflora.net' as correo_farm,
	--farm.correo as correo_farm,
	farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	(
		select sum(detalle_version_bouquet.unidades)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as unidades,
	(
		select b.imagen
		from bouquet as b
		where b.id_bouquet = bouquet.id_bouquet
	) as imagen into #temp
	from farm_detalle_po,
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
	cliente_despacho
	where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
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
		from solicitud_confirmacion_cultivo
		where farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	)
	and not exists
	(
		select *
		from cancela_detalle_po
		where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
	)
	and exists
	(
		select *
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	)
	group by version_bouquet.id_version_bouquet,
	farm_detalle_po.id_farm_detalle_po,
	bouquet.id_bouquet,
	detalle_po.id_detalle_po,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)),
	po.id_po,
	po.po_number,
	po.fecha_despacho_miami,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	farm_detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	caja.nombre_caja,
	caja.medida,
	farm_detalle_po.fecha_vuelo,
	farm.correo,
	farm.idc_farm,
	farm.id_farm,
	farm.nombre_farm

	select version_bouquet.id_version_bouquet,
	null as id_farm_detalle_po,
	detalle_po.id_detalle_po,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	po.id_po,
	po.po_number,
	po.fecha_despacho_miami,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	caja.nombre_caja,
	caja.medida as medida_caja,
	null as fecha_vuelo,
	'' as correo_farm,
	0 as id_farm,
	'' as idc_farm,
	'' as nombre_farm,
	(
		select sum(detalle_version_bouquet.unidades)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as unidades,
	(
		select b.imagen
		from bouquet as b
		where b.id_bouquet = bouquet.id_bouquet
	) as imagen into #fincas_sin_definir
	from detalle_po,
	po,
	version_bouquet,
	tipo_flor,
	variedad_flor,
	grado_flor,
	caja,
	tipo_caja,
	tapa,
	bouquet,
	cliente_despacho
	where caja.id_caja = version_bouquet.id_caja
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
	and exists
	(
		select *
		from #detalle_po
		where #detalle_po.id_detalle_po = detalle_po.id_detalle_po
	)
	and not exists
	(
		select *
		from cancela_detalle_po
		where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
	)
	and not exists
	(
		select *
		from farm_detalle_po
		where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	)
	and exists
	(
		select *
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	)
	group by version_bouquet.id_version_bouquet,
	detalle_po.id_detalle_po,
	bouquet.id_bouquet,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)),
	po.id_po,
	po.po_number,
	po.fecha_despacho_miami,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	caja.nombre_caja,
	caja.medida

	select version_bouquet.id_version_bouquet,
	null as id_farm_detalle_po,
	detalle_po.id_detalle_po,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	po.id_po,
	po.po_number,
	po.fecha_despacho_miami,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	isnull(
	(
		select sum(cbc.cantidad_piezas)
		from detalle_po as dp,
		farm_detalle_po as fdp,
		solicitud_confirmacion_cultivo as scc,
		#confirmaciones_agrupadas as cbc
		where dp.id_detalle_po = fdp.id_detalle_po
		and fdp.id_farm_detalle_po = scc.id_farm_detalle_po
		and scc.id_solicitud_confirmacion_cultivo = cbc.id_solicitud_confirmacion_cultivo
		and dp.id_detalle_po = detalle_po.id_detalle_po
	), 0) as cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	caja.nombre_caja,
	caja.medida as medida_caja,
	null as fecha_vuelo,
	'carlos@natuflora.net,ricardo@natuflora.net,sisandres@natuflora.net,viviana@natuflora.com,lucia@natuflora.com,dpineros@natuflora.net' as correo_farm,
	--farm.correo as correo_farm,
	farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	(
		select sum(detalle_version_bouquet.unidades)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as unidades,
	(
		select b.imagen
		from bouquet as b
		where b.id_bouquet = bouquet.id_bouquet
	) as imagen into #confirmaciones_canceladas
	from farm_detalle_po,
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
	solicitud_confirmacion_cultivo,
	confirmacion_bouquet_cultivo,
	farm
	where farm.id_farm = farm_detalle_po.id_farm
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
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
	and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
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
	and exists
	(
		select *
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	)
	group by version_bouquet.id_version_bouquet,
	bouquet.id_bouquet,
	detalle_po.id_detalle_po,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)),
	po.id_po,
	po.po_number,
	po.fecha_despacho_miami,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas,
	detalle_po.marca,
	detalle_po.ethyblock_sachet,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	caja.nombre_caja,
	caja.medida,
	farm.correo,
	farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm))	

	select id_version_bouquet,id_farm_detalle_po,id_detalle_po,id_despacho,idc_cliente_despacho,nombre_cliente,id_po,po_number,fecha_despacho_miami,idc_tapa,nombre_tapa,cantidad_piezas,marca,idc_tipo_flor,nombre_tipo_flor,idc_variedad_flor,nombre_variedad_flor,idc_grado_flor,nombre_grado_flor,nombre_tipo_caja,nombre_caja,medida_caja,fecha_vuelo,correo_farm,id_farm,idc_farm,nombre_farm,unidades,imagen,ethyblock_sachet into #resultado
	from #temp
	union all
	select id_version_bouquet,id_farm_detalle_po,id_detalle_po,id_despacho,idc_cliente_despacho,nombre_cliente,id_po,po_number,fecha_despacho_miami,idc_tapa,nombre_tapa,cantidad_piezas,marca,idc_tipo_flor,nombre_tipo_flor,idc_variedad_flor,nombre_variedad_flor,idc_grado_flor,nombre_grado_flor,nombre_tipo_caja,nombre_caja,medida_caja,fecha_vuelo,correo_farm,id_farm,idc_farm,nombre_farm,unidades,imagen,ethyblock_sachet
	from #fincas_sin_definir
	union all
	select id_version_bouquet,id_farm_detalle_po,id_detalle_po,id_despacho,idc_cliente_despacho,nombre_cliente,id_po,po_number,fecha_despacho_miami,idc_tapa,nombre_tapa,cantidad_piezas,marca,idc_tipo_flor,nombre_tipo_flor,idc_variedad_flor,nombre_variedad_flor,idc_grado_flor,nombre_grado_flor,nombre_tipo_caja,nombre_caja,medida_caja,fecha_vuelo,correo_farm,id_farm,idc_farm,nombre_farm,unidades,imagen,ethyblock_sachet
	from #confirmaciones_canceladas where cantidad_piezas > 0

	select * 
	from #resultado
	order by id_farm,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	po_number,
	nombre_tapa,
	nombre_tipo_caja,
	id_version_bouquet

	select id_farm,
	'[' + idc_farm + '] ' + ltrim(rtrim(nombre_farm)) as nombre_farm
	from #resultado
	where id_farm > 0
	GROUP BY id_farm,
	idc_farm,
	ltrim(rtrim(nombre_farm))
	order by idc_farm

	select detalle_po.id_detalle_po,
	variedad_restringida_cliente.observacion
	from variedad_restringida_cliente,
	cliente_despacho,
	po,
	detalle_po
	where cliente_despacho.id_despacho = variedad_restringida_cliente.id_despacho
	and po.id_despacho = cliente_despacho.id_despacho
	and po.id_po = detalle_po.id_po
	and not exists
	(
		select *
		from cancela_variedad_restringida_cliente
		where variedad_restringida_cliente.id_variedad_restringida_cliente = cancela_variedad_restringida_cliente.id_variedad_restringida_cliente
	)
	and exists
	(
		select *
		from version_bouquet,
		detalle_version_bouquet,
		formula_bouquet,
		formula_unica_bouquet,
		detalle_formula_bouquet
		where version_bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
		and detalle_version_bouquet.id_formula_bouquet = formula_bouquet.id_formula_bouquet
		and formula_unica_bouquet.id_formula_unica_bouquet = Formula_Bouquet.id_formula_unica_bouquet
		and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
		and detalle_formula_bouquet.id_variedad_flor_cultivo = variedad_restringida_cliente.id_variedad_flor_cultivo
		and Version_Bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	)
	group by detalle_po.id_detalle_po,
	variedad_restringida_cliente.observacion

	select detalle_version_bouquet.id_version_bouquet,
	detalle_version_bouquet.id_detalle_version_bouquet
	from detalle_version_bouquet
	where exists
	(
		select *
		from #resultado
		where #resultado.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	)
	group by detalle_version_bouquet.id_version_bouquet,
	detalle_version_bouquet.id_detalle_version_bouquet

	select id_despacho,
	idc_cliente_despacho + ' [' + nombre_cliente + ']' as idc_cliente_despacho
	from #resultado
	group by id_despacho,
	nombre_cliente,
	idc_cliente_despacho
	order by idc_cliente_despacho

	drop table #detalle_po
	drop table #farm_detalle_po
	drop table #temp
	drop table #fincas_sin_definir
	drop table #confirmaciones_canceladas
	drop table #resultado
	drop table #confirmaciones_agrupadas
end
else
if(@accion = 'insertar')
begin
	declare @conteo int,
	@fecha_despacho_miami datetime,
	@fecha_vuelo datetime,
	@diferencia_dias int,
	@fecha_actual datetime

	select @conteo = count(*)
	from solicitud_confirmacion_cultivo
	where id_farm_detalle_po = @id_farm_detalle_po

	if(@conteo = 0)
	begin
		set @fecha_actual = convert(nvarchar, getdate(), 103)
		
		select @fecha_despacho_miami = po.fecha_despacho_miami,
		@fecha_vuelo = farm_detalle_po.fecha_vuelo 
		from farm_detalle_po,
		detalle_po,
		po
		where po.id_po = detalle_po.id_po
		and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
		and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po

		set @diferencia_dias = datediff(dd, @fecha_vuelo, @fecha_despacho_miami)

		if(@diferencia_dias < 0)
			set @conteo = 1

		if(@fecha_vuelo < @fecha_actual)
			set @conteo = 1
	end

	if(@conteo = 0)
	begin
		declare @numero_solicitud int,
		@compania nvarchar(255),
		@nombre_farm nvarchar(255),
		@id_solicitud_confirmacion_cultivo int,
		@po_number nvarchar(255)

		select @compania =
		case
			when db_name() = 'BD_Fresca' then 'FRESCA FARMS'
			when db_name() = 'BD_NF' then 'NATURAL FLOWERS'
			else ''
		end

		if(@aceptada = 1)
		begin
			select @nombre_farm = ltrim(rtrim(farm.nombre_farm)),
			@po_number = po.po_number,
			@numero_solicitud = isnull(po.numero_solicitud, 0)
			from farm_detalle_po, 
			farm,
			detalle_po,
			po
			where farm.id_farm = farm_detalle_po.id_farm
			and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
			and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po			
			and po.id_po = detalle_po.id_po
		end
		else
		begin
			set @numero_solicitud = 0
		end

		insert into solicitud_confirmacion_cultivo (id_farm_detalle_po, id_cuenta_interna, aceptada, observacion, farm_price_maximo, farm_price)
		values (@id_farm_detalle_po, @id_cuenta_interna, @aceptada, @observacion, @farm_price, @farm_price_modificado)

		set @id_solicitud_confirmacion_cultivo = scope_identity()

		select @compania + '. ' +
		'Pedido Bouquet NUEVO. ' + 
		@nombre_farm + '. ' +
		convert(nvarchar,@numero_solicitud) + '. ' +
		'PO #: ' + @po_number as subject,
		@numero_solicitud as numero_solicitud

--		if(@aceptada = 0)
--		begin
--			declare @subject1 nvarchar(255),
--			@body1 nvarchar(max),
--			@correo nvarchar(512),
--			@perfil nvarchar(255)
--
--			set @subject1 = 'RETURNED - Not Sent to Farm'
--
--			select @correo = ltrim(rtrim(vendedor.correo)),
--			@body1 = 'Last Modified by: ' + space(1) + ltrim(rtrim(cuenta_interna.nombre)) + char(13) +
--			'Last Modified Date: ' + space(1) + convert(nvarchar,solicitud_confirmacion_cultivo.fecha_transaccion) + char(13) +
--			'Description: ' + space(1) + @observacion + char(13) + char(13) +
--
--			'Ship to: ' + space(1) + ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) + char(13) +
--			'Carrier: ' + space(1) + ltrim(rtrim(transportador.nombre_transportador)) + char(13) +
--			'Flower Type: ' + space(1) + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + char(13) +
--			'Flower Variety: ' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + char(13) +
--			'Flower Grade: ' + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)) + char(13) +
--			'Farm: ' + space(1) + ltrim(rtrim(farm.nombre_farm)) + char(13) +
--			'Lid: ' + space(1) + ltrim(rtrim(tapa.nombre_tapa)) + char(13) +
--			'Box Type: ' + space(1) + ltrim(rtrim(tipo_caja.nombre_tipo_caja)) + char(13) +
--			'Code: ' + space(1) + detalle_po.marca + char(13) +
--			'Initial Date: ' + space(1) + convert(nvarchar,po.fecha_despacho_miami,101) + char(13) +
--			'Pack: ' + space(1) + convert(nvarchar,
--			isnull((
--				select sum(detalle_version_bouquet.unidades)
--				from detalle_version_bouquet
--				where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
--			),0)
--			) + char(13) +
--			'Pieces: ' + space(1) + convert(nvarchar,detalle_po.cantidad_piezas) + char(13)
--			from farm_detalle_po,
--			detalle_po,
--			po,
--			version_bouquet,
--			bouquet,
--			cliente_factura,
--			cliente_despacho,
--			vendedor,
--			cuenta_interna,
--			solicitud_confirmacion_cultivo,
--			transportador,
--			tipo_flor,
--			variedad_flor,
--			grado_flor,
--			farm,
--			tapa,
--			caja,
--			tipo_caja
--			where bouquet.id_bouquet = version_bouquet.id_bouquet
--			and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
--			and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
--			and cliente_despacho.id_despacho = po.id_despacho
--			and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
--			and vendedor.id_vendedor = cliente_factura.id_vendedor
--			and po.id_po = detalle_po.id_po
--			and cuenta_interna.id_cuenta_interna = solicitud_confirmacion_cultivo.id_cuenta_interna
--			and transportador.id_transportador = po.id_transportador
--			and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
--			and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
--			and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
--			and grado_flor.id_grado_flor = bouquet.id_grado_flor
--			and farm.id_farm = farm_detalle_po.id_farm
--			and tapa.id_tapa = detalle_po.id_tapa
--			and tipo_caja.id_tipo_caja = caja.id_tipo_caja
--			and caja.id_caja = version_bouquet.id_caja
--			and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
--			and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = @id_solicitud_confirmacion_cultivo
--
--			set @correo = replace(@correo, ',',';')
--			set @perfil = 'Reportes_Fincas'
--
--			EXEC msdb.dbo.sp_send_dbmail 
--			@recipients = @correo,
--			@subject = @subject1,
--			@profile_name = @perfil,
--			@body = @body1,
--			@body_format = 'TEXT';
--		end
	end
end
GO