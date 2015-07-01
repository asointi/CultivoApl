USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_consultar_reporte_formato_cultivo]    Script Date: 04/11/2014 9:18:38 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[bouquet_consultar_reporte_formato_cultivo] 

@id_farm_detalle_po int,
@accion nvarchar(255)

as

declare @id_farm_detalle_po_padre int

select @id_farm_detalle_po_padre = farm_detalle_po.id_farm_detalle_po_padre
from farm_detalle_po
where farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po

select @id_farm_detalle_po = max(farm_detalle_po.id_farm_detalle_po)
from farm_detalle_po
where farm_detalle_po.id_farm_detalle_po_padre = @id_farm_detalle_po_padre

if(@accion = 'Detalle')
begin
	declare @cantidad_recetas int,
	@cantidad_sticker int,
	@cantidad_suma_sticker int,
	@stickers int,
	@conteo_upc int,
	@upc int,
	@cantidad_capuchon int,
	@cantidad_suma_capuchones int,
	@capuchones int

	select @cantidad_recetas = count(detalle_version_bouquet.id_detalle_version_bouquet)
	from farm_detalle_po,
	detalle_po,
	version_bouquet,
	detalle_version_bouquet
	where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po

	select informacion_upc.nombre_informacion_upc,
	informacion_upc.id_informacion_upc,
	ltrim(rtrim(upc_detalle_po.valor)) as valor,
	upc_detalle_po.orden into #upc
	from farm_detalle_po,
	detalle_po,
	version_bouquet,
	detalle_version_bouquet,
	upc_detalle_po,
	informacion_upc
	where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
	and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_Po.id_detalle_version_bouquet
	and informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
	group by informacion_upc.id_informacion_upc,
	informacion_upc.nombre_informacion_upc,
	ltrim(rtrim(upc_detalle_po.valor)),
	upc_detalle_po.orden

	select detalle_version_bouquet.id_detalle_version_bouquet,
	ltrim(rtrim(sticker.nombre_sticker)) as nombre_sticker into #sticker_sin_agrupar
	from farm_detalle_po,
	detalle_po,
	version_bouquet,
	detalle_version_bouquet,
	sticker_bouquet,
	sticker
	where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_Po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
	and detalle_version_bouquet.id_detalle_version_bouquet = sticker_bouquet.id_detalle_version_bouquet
	and sticker.id_sticker = sticker_bouquet.id_sticker
	group by detalle_version_bouquet.id_detalle_version_bouquet,
	ltrim(rtrim(sticker.nombre_sticker))

	select nombre_sticker,
	count(*) as conteo into #sticker
	from #sticker_sin_agrupar
	group by nombre_sticker

	select detalle_version_bouquet.id_detalle_version_bouquet,
	ltrim(rtrim(Capuchon_Cultivo.descripcion)) + ' [' + convert(nvarchar,convert(decimal(20,2), Capuchon_Cultivo.ancho_superior)) + ']' as nombre_capuchon into #capuchon_sin_agrupar
	from farm_detalle_po,
	detalle_po,
	version_bouquet,
	detalle_version_bouquet,
	capuchon_formula_bouquet,
	Capuchon_Cultivo
	where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_Po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
	and detalle_version_bouquet.id_detalle_version_bouquet = Capuchon_formula_bouquet.id_detalle_version_bouquet
	and Capuchon_Cultivo.id_Capuchon_Cultivo = Capuchon_formula_bouquet.id_Capuchon_Cultivo
	group by detalle_version_bouquet.id_detalle_version_bouquet,
	ltrim(rtrim(Capuchon_Cultivo.descripcion)),
	Capuchon_Cultivo.ancho_superior 

	select nombre_capuchon,
	count(*) as conteo into #capuchon
	from #capuchon_sin_agrupar
	group by nombre_capuchon

	select @cantidad_sticker = count(*),
	@cantidad_suma_sticker = sum(conteo) from #sticker
	select @conteo_upc = count(*) from #upc
	select @cantidad_capuchon = count(*),
	@cantidad_suma_capuchones = sum(conteo) from #capuchon

	if(@cantidad_sticker > 0 and @cantidad_suma_sticker = (@cantidad_sticker * @cantidad_recetas))
	begin
		set @stickers = 1
	end

	if(@conteo_upc = 4)
	begin
		set @upc = 1
	end 

	if(@cantidad_capuchon > 0 and @cantidad_suma_capuchones = (@cantidad_capuchon * @cantidad_recetas))
	begin

		set @capuchones = 1
	end

	select row_number() over(order by Formula_Bouquet.nombre_formula_bouquet) as orden_receta,
	Detalle_Version_Bouquet.id_detalle_version_bouquet,
	Formula_Bouquet.id_formula_bouquet,
	Formula_Bouquet.nombre_formula_bouquet,
	Formula_Bouquet.especificacion_bouquet,
	Formula_Bouquet.construccion_bouquet,
	Detalle_Version_Bouquet.unidades,
	Comida_Bouquet.nombre_comida,
	(
		select Formato_UPC.nombre_formato 
		from Formato_UPC
		where Formato_UPC.id_formato_upc = detalle_version_bouquet.id_formato_upc
	) as nombre_formato,
	@stickers as sticker,
	@capuchones as capuchon,
	@upc as upc
	from formula_bouquet,
	Detalle_Version_Bouquet,
	Version_Bouquet,
	detalle_po,
	Farm_Detalle_PO,
	Comida_Bouquet
	where Formula_Bouquet.id_formula_bouquet = Detalle_Version_Bouquet.id_formula_bouquet
	and Version_Bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
	and Version_Bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and detalle_po.id_detalle_po = Farm_Detalle_PO.id_detalle_po
	and Farm_Detalle_PO.id_farm_detalle_po = @id_farm_detalle_po
	and Comida_Bouquet.id_comida_bouquet = Detalle_Version_Bouquet.id_comida_bouquet

	drop table #upc
	drop table #sticker_sin_agrupar
	drop table #sticker
	drop table #capuchon_sin_agrupar
	drop table #capuchon
end
else
if(@accion = 'Encabezado')
begin
	select po.po_number,
	po.numero_solicitud,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
	ltrim(rtrim(caja.nombre_caja)) + ' [' + ltrim(rtrim(caja.medida)) + ']' as nombre_caja,
	detalle_po.marca,
	case
		when detalle_po.ethyblock_sachet = 0 then 'No'
		when detalle_po.ethyblock_sachet = 1 then 'Si'
	end as ethyblock_sachet,
	(
		select sum(detalle_version_bouquet.unidades)
		from detalle_version_bouquet
		where Version_Bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as cantidad_ramos,
	detalle_po.cantidad_piezas,
	case
		when solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo is not null then solicitud_confirmacion_cultivo.farm_price
		else [dbo].[calcular_farm_price] (farm.id_farm, detalle_po.id_detalle_po)
	end as precio_finca,
	Farm_Detalle_PO.fecha_vuelo,
	bouquet.imagen
	from Farm_Detalle_PO left join solicitud_confirmacion_cultivo on Farm_Detalle_PO.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po,
	Detalle_PO,
	po,
	version_bouquet,
	bouquet,
	Detalle_Version_Bouquet,
	Tipo_Flor,
	Variedad_Flor,
	Grado_Flor,
	farm,
	tapa,
	caja
	where Farm_Detalle_PO.id_farm_detalle_po = @id_farm_detalle_po
	and detalle_po.id_detalle_po = Farm_Detalle_PO.id_detalle_po
	and po.id_po = detalle_po.id_po
	and Version_Bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and bouquet.id_bouquet = Version_Bouquet.id_bouquet
	and Version_Bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = Grado_Flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = Bouquet.id_variedad_flor
	and Grado_Flor.id_grado_flor = Bouquet.id_grado_flor
	and farm.id_farm = Farm_Detalle_PO.id_farm
	and tapa.id_tapa = detalle_po.id_tapa
	and caja.id_caja = Version_Bouquet.id_caja
end