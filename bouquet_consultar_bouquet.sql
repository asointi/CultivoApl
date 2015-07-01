USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_consultar_bouquet]    Script Date: 11/08/2014 1:39:02 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/08/01
-- Description:	Consulta los Bouquets Grabados en la BD
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_consultar_bouquet] 

@texto nvarchar(50),
@items_a_buscar nvarchar(255),
@texto2 nvarchar(50) = NULL,
@items_a_buscar2 nvarchar(255) = NULL

as

declare @texto_aux nvarchar(50),
@texto2_aux nvarchar(50)

SET @texto_aux = '"' + isnull(REPLACE(@Texto, ' ', '_'), '') + '*"'
SET @texto2_aux = '"' + isnull(REPLACE(@texto2, ' ', '_'), '') + '*"'

declare @nombre_tipo_flor nvarchar(50),
@nombre_variedad_flor nvarchar(50),
@nombre_grado_flor nvarchar(50),
@nombre_formula_bouquet nvarchar(50),
@usuario_formula_bouquet nvarchar(50),
@nombre_tipo_flor_cultivo nvarchar(50),
@nombre_variedad_flor_cultivo nvarchar(50),
@nombre_grado_flor_cultivo nvarchar(50),
@nombre_cliente nvarchar(50),
@code nvarchar(50),
@sql varchar(8000)

select max(id_detalle_po) as id_detalle_po into #detalle_po
from detalle_po
group by id_detalle_po_padre

select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
from farm_detalle_po
group by id_farm_detalle_po_padre

create table #temp (id int)
create table #item_recetas (id int)
create table #resultado_bouquet
(
	id_detalle_po int,
	id_bouquet int,
	id_version_bouquet int,
	id_tipo_flor int,
	idc_tipo_flor nvarchar(2),
	nombre_tipo_flor nvarchar(50),
	id_variedad_flor int,
	idc_variedad_flor nvarchar(2),
	nombre_variedad_flor nvarchar(50),
	id_grado_flor int,
	idc_grado_flor nvarchar(2),
	nombre_grado_flor nvarchar(50),
	nombre_tipo_caja nvarchar(50),
	id_caja int,
	nombre_caja nvarchar(50),
	medida_caja nvarchar(50),
	unidades int,
	precio_miami decimal(20,4),
	imagen image,
	code nvarchar(10),
	id_tapa int,
	idc_tapa nvarchar(2),
	nombre_tapa nvarchar(50),
	cantidad_piezas int,
	ethyblock_sachet bit,
	id_farm int,
	nombre_farm nvarchar(50),
	item_number nvarchar(25),
	cantidad_formulas int null
)
create table #resultado_receta
(
	id_detalle_po int,
	id_bouquet int,
	id_version_bouquet int,
	id_tipo_flor int,
	idc_tipo_flor nvarchar(2),
	nombre_tipo_flor nvarchar(50),
	id_variedad_flor int,
	idc_variedad_flor nvarchar(2),
	nombre_variedad_flor nvarchar(50),
	id_grado_flor int,
	idc_grado_flor nvarchar(2),
	nombre_grado_flor nvarchar(50),
	nombre_tipo_caja nvarchar(50),
	id_caja int,
	nombre_caja nvarchar(50),
	medida_caja nvarchar(50),
	unidades int,
	precio_miami decimal(20,4),
	imagen image,
	code nvarchar(10),
	id_tapa int,
	idc_tapa nvarchar(2),
	nombre_tapa nvarchar(50),
	cantidad_piezas int,
	ethyblock_sachet bit,
	id_farm int,
	nombre_farm nvarchar(50),
	item_number nvarchar(25),
	cantidad_formulas int null
)

select max(#detalle_po.id_detalle_po) as id_detalle_po into #detalle_po_maximo
from detalle_po,
#detalle_po,
Version_Bouquet,
detalle_version_bouquet,
bouquet
where bouquet.id_bouquet = version_bouquet.id_bouquet
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and detalle_po.id_detalle_po = #detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
group by Version_Bouquet.id_caja,
bouquet.id_variedad_flor,
bouquet.id_grado_flor,
detalle_po.id_tapa,
detalle_po.marca

if(@texto is not null)
begin
	/*crear la insercion para los valores separados por comas para los bouquets*/
	select @sql = 'insert into #temp select '+	replace(@items_a_buscar,',',' union all select ')

	/*cargar todos los valores de la variable @id_nave en la tabla temporal*/
	exec (@SQL)

	select @nombre_tipo_flor =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @Texto_aux
	end
	from #temp where id = 1

	select @nombre_variedad_flor =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @TEXTO_aux
	end
	from #temp where id = 2

	select @nombre_grado_flor =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @TEXTO_aux
	end
	from #temp where id = 3

	select @nombre_cliente =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @TEXTO_aux
	end
	from #temp where id = 11

	select @code =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @TEXTO_aux
	end
	from #temp where id = 12

	insert into #resultado_bouquet
	(
		id_detalle_po,
		id_bouquet,
		id_version_bouquet,
		id_tipo_flor,
		idc_tipo_flor,
		nombre_tipo_flor,
		id_variedad_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		id_grado_flor,
		idc_grado_flor,
		nombre_grado_flor,
		nombre_tipo_caja,
		id_caja,
		nombre_caja,
		medida_caja,
		unidades,
		precio_miami,
		imagen,
		code,
		id_tapa,
		idc_tapa,
		nombre_tapa,
		cantidad_piezas,
		ethyblock_sachet,
		id_farm,
		nombre_farm,
		item_number
	)
	select detalle_po.id_detalle_po,
	bouquet.id_bouquet,
	version_bouquet.id_version_bouquet,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)),
	caja.medida,
	detalle_version_bouquet.unidades,
	detalle_version_bouquet.precio_miami,
	(
		select b.imagen
		from bouquet as b
		where b.id_bouquet = bouquet.id_bouquet
	),
	detalle_po.marca,
	tapa.id_tapa,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas,
	detalle_po.ethyblock_sachet,
	farm.id_farm,
	'[' + farm.idc_farm + '] ' + ltrim(rtrim(farm.nombre_farm)),
	(
		select top 1 item_number.numero_item
		from item_number,
		cliente_despacho,
		cliente_factura
		where version_bouquet.id_version_bouquet = item_number.id_version_bouquet
		and cliente_despacho.id_despacho = po.id_despacho
		and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
		and cliente_factura.id_cliente_factura = item_number.id_cliente_factura
		order by item_number.id_item_number desc
	) from bouquet,
	po,
	version_bouquet,
	detalle_po,
	tipo_flor,
	variedad_flor,
	grado_flor,
	caja,
	tipo_caja,
	tapa,
	farm_detalle_Po,
	farm,
	detalle_version_bouquet,
	formula_bouquet,
	Cuenta_Interna,
	formula_unica_bouquet,
	detalle_formula_bouquet,
	tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo,
	cliente_despacho
	where cliente_despacho.id_despacho = po.id_despacho
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and Cuenta_Interna.id_cuenta_interna = Formula_Bouquet.id_cuenta_interna
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = version_bouquet.id_caja
	and tapa.id_tapa = detalle_po.id_tapa
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm.id_farm = farm_detalle_po.id_farm
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and po.id_po = detalle_po.id_po
	and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
	and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
	and exists
	(
		select *
		from #farm_detalle_po
		where farm_detalle_po.id_farm_detalle_po = #farm_detalle_po.id_farm_detalle_po
	)
	and exists
	(
		select *
		from #detalle_po_maximo
		where #detalle_po_maximo.id_detalle_po = detalle_po.id_detalle_po
	)
	and 
	(
	CONTAINS (tipo_flor.nombre_tipo_flor_concatenado, @nombre_tipo_flor)
	or CONTAINS (variedad_flor.nombre_variedad_flor_concatenado, @nombre_variedad_flor)
	or CONTAINS (grado_flor.nombre_grado_flor_concatenado, @nombre_grado_flor)
	or CONTAINS (cliente_despacho.nombre_cliente, @nombre_cliente)
	or CONTAINS (cliente_despacho.idc_cliente_despacho, @nombre_cliente)
	or CONTAINS (detalle_po.marca, @code)
	)
	GROUP BY Formula_Bouquet.id_formula_bouquet,
	detalle_version_bouquet.unidades,
	detalle_version_bouquet.precio_miami,
	detalle_po.id_detalle_po,
	bouquet.id_bouquet,
	po.id_despacho,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	detalle_po.cantidad_piezas,
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)),
	caja.medida,
	detalle_po.marca,
	tapa.id_tapa,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.ethyblock_sachet,
	farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)),
	Farm_Detalle_PO.id_farm_detalle_po,
	version_bouquet.id_version_bouquet
end

if(@texto2 is not null)
begin
	/*crear la insercion para los valores separados por comas para las recetas*/
	select @sql = 'insert into #item_recetas select '+	replace(@items_a_buscar2,',',' union all select ')

	/*cargar todos los valores de la variable @id_nave en la tabla temporal*/
	exec (@SQL)

	select @nombre_formula_bouquet =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @texto2_aux
	end
	from #item_recetas where id = 5

	select @usuario_formula_bouquet =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @texto2_aux
	end
	from #item_recetas where id = 6

	select @nombre_tipo_flor_cultivo =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @texto2_aux
	end
	from #item_recetas where id = 7

	select @nombre_variedad_flor_cultivo =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @texto2_aux
	end
	from #item_recetas where id = 8

	select @nombre_grado_flor_cultivo =
	case
		when count(*) = 0 then 'ZZZZZZZZZZZZZZZZ'
		else @texto2_aux
	end
	from #item_recetas where id = 9

	insert into #resultado_receta
	(
		id_detalle_po,
		id_bouquet,
		id_version_bouquet,
		id_tipo_flor,
		idc_tipo_flor,
		nombre_tipo_flor,
		id_variedad_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		id_grado_flor,
		idc_grado_flor,
		nombre_grado_flor,
		nombre_tipo_caja,
		id_caja,
		nombre_caja,
		medida_caja,
		unidades,
		precio_miami,
		imagen,
		code,
		id_tapa,
		idc_tapa,
		nombre_tapa,
		cantidad_piezas,
		ethyblock_sachet,
		id_farm,
		nombre_farm,
		item_number
	)
	select detalle_po.id_detalle_po,
	bouquet.id_bouquet,
	version_bouquet.id_version_bouquet,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)),
	caja.medida,
	detalle_version_bouquet.unidades,
	detalle_version_bouquet.precio_miami,
	(
		select b.imagen
		from bouquet as b
		where b.id_bouquet = bouquet.id_bouquet
	),
	detalle_po.marca,
	tapa.id_tapa,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.cantidad_piezas,
	detalle_po.ethyblock_sachet,
	farm.id_farm,
	'[' + farm.idc_farm + '] ' + ltrim(rtrim(farm.nombre_farm)),
	(
		select top 1 item_number.numero_item
		from item_number,
		cliente_despacho,
		cliente_factura
		where version_bouquet.id_version_bouquet = item_number.id_version_bouquet
		and cliente_despacho.id_despacho = po.id_despacho
		and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
		and cliente_factura.id_cliente_factura = item_number.id_cliente_factura
		order by item_number.id_item_number desc
	) from bouquet,
	po,
	version_bouquet,
	detalle_po,
	tipo_flor,
	variedad_flor,
	grado_flor,
	caja,
	tipo_caja,
	tapa,
	farm_detalle_Po,
	farm,
	detalle_version_bouquet,
	formula_bouquet,
	Cuenta_Interna,
	formula_unica_bouquet,
	detalle_formula_bouquet,
	tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo,
	cliente_despacho
	where cliente_despacho.id_despacho = po.id_despacho
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and Cuenta_Interna.id_cuenta_interna = Formula_Bouquet.id_cuenta_interna
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = version_bouquet.id_caja
	and tapa.id_tapa = detalle_po.id_tapa
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and farm.id_farm = farm_detalle_po.id_farm
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and po.id_po = detalle_po.id_po
	and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
	and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
	and exists
	(
		select *
		from #farm_detalle_po
		where farm_detalle_po.id_farm_detalle_po = #farm_detalle_po.id_farm_detalle_po
	)
	and exists
	(
		select *
		from #detalle_po_maximo
		where #detalle_po_maximo.id_detalle_po = detalle_po.id_detalle_po
	)
	and 
	(
	CONTAINS (formula_bouquet.nombre_formula_bouquet_concatenado, @nombre_formula_bouquet)
	or CONTAINS (cuenta_interna.nombre, @usuario_formula_bouquet)
	or CONTAINS (tipo_flor_cultivo.nombre_tipo_flor, @nombre_tipo_flor_cultivo)
	or CONTAINS (variedad_flor_cultivo.nombre_variedad_flor, @nombre_variedad_flor_cultivo)
	or CONTAINS (grado_flor_cultivo.nombre_grado_flor, @nombre_grado_flor_cultivo)
	)
	GROUP BY Formula_Bouquet.id_formula_bouquet,
	detalle_version_bouquet.unidades,
	detalle_version_bouquet.precio_miami,
	detalle_po.id_detalle_po,
	bouquet.id_bouquet,
	po.id_despacho,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	detalle_po.cantidad_piezas,
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)),
	caja.medida,
	detalle_po.marca,
	tapa.id_tapa,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	detalle_po.ethyblock_sachet,
	farm.id_farm,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)),
	Farm_Detalle_PO.id_farm_detalle_po,
	version_bouquet.id_version_bouquet
end

if(@texto is not null and @texto2 is not null)
begin
	select id_detalle_po,
	id_bouquet,
	max(id_version_bouquet) as id_version_bouquet,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	nombre_tipo_caja,
	id_caja,
	nombre_caja,
	medida_caja,
	sum(unidades) as unidades,
	sum(precio_miami) as precio_miami,
	(
		select top 1 r.imagen
		from #resultado_receta as r
		where r.id_bouquet = #resultado_receta.id_bouquet
	) as imagen,
	code,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	cantidad_piezas,
	ethyblock_sachet,
	id_farm,
	nombre_farm,
	item_number,
	null as nombre_formula_bouquet,
	2 as cantidad_formulas
	from #resultado_receta
	where exists
	(
		select *
		from #resultado_bouquet
		where #resultado_bouquet.id_version_bouquet = #resultado_receta.id_version_bouquet
	)
	group by id_detalle_po,
	id_bouquet,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	nombre_tipo_caja,
	id_caja,
	nombre_caja,
	medida_caja,
	code,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	cantidad_piezas,
	ethyblock_sachet,
	id_farm,
	nombre_farm,
	item_number
end
else
if(@texto is not null and @texto2 is null)
begin
	select id_detalle_po,
	id_bouquet,
	max(id_version_bouquet) as id_version_bouquet,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	nombre_tipo_caja,
	id_caja,
	nombre_caja,
	medida_caja,
	sum(unidades) as unidades,
	sum(precio_miami) as precio_miami,
	(
		select top 1 r.imagen
		from #resultado_bouquet as r
		where r.id_bouquet = #resultado_bouquet.id_bouquet
	) as imagen,
	code,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	cantidad_piezas,
	ethyblock_sachet,
	id_farm,
	nombre_farm,
	item_number,
	null as nombre_formula_bouquet,
	2 as cantidad_formulas
	from #resultado_bouquet
	group by id_detalle_po,
	id_bouquet,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	nombre_tipo_caja,
	id_caja,
	nombre_caja,
	medida_caja,
	code,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	cantidad_piezas,
	ethyblock_sachet,
	id_farm,
	nombre_farm,
	item_number
end
else
if(@texto is null and @texto2 is not null)
begin
	select id_detalle_po,
	id_bouquet,
	max(id_version_bouquet) as id_version_bouquet,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	nombre_tipo_caja,
	id_caja,
	nombre_caja,
	medida_caja,
	sum(unidades) as unidades,
	sum(precio_miami) as precio_miami,
	(
		select top 1 r.imagen
		from #resultado_receta as r
		where r.id_bouquet = #resultado_receta.id_bouquet
	) as imagen,
	code,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	cantidad_piezas,
	ethyblock_sachet,
	id_farm,
	nombre_farm,
	item_number,
	null as nombre_formula_bouquet,
	2 as cantidad_formulas
	from #resultado_receta
	group by id_detalle_po,
	id_bouquet,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	nombre_tipo_caja,
	id_caja,
	nombre_caja,
	medida_caja,
	code,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	cantidad_piezas,
	ethyblock_sachet,
	id_farm,
	nombre_farm,
	item_number
end

drop table #farm_detalle_po
drop table #detalle_po
drop table #temp
drop table #item_recetas
drop table #resultado_receta
drop table #resultado_bouquet
drop table #detalle_po_maximo