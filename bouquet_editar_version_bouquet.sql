set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/09/04
-- Description:	Permite crear bouquets sin tener el cliente
-- =============================================

alter PROCEDURE [dbo].[bouquet_editar_version_bouquet] 

@accion nvarchar(255),
@id_variedad_flor int, 
@id_grado_flor int, 
@imagen image,
@id_caja int, 
@id_capuchon_cultivo int, 
@unidades int, 
@precio_miami_pieza decimal(20,4), 
@id_comida_bouquet int,
@id_version_bouquet int

as

declare @upc nvarchar(255),
@descripcion nvarchar(255),
@fecha nvarchar(255),
@precio nvarchar(255)

set @upc = 'UPC'
set @descripcion = 'Descripcion'
set @fecha = 'Fecha'
set @precio = 'Precio'

if(@accion = 'consultar')
begin
	select max(id_detalle_po) as id_detalle_po into #detalle_po
	from detalle_po
	group by id_detalle_po_padre

	select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
	from farm_detalle_po
	group by id_farm_detalle_po_padre

	select version_bouquet.id_version_bouquet,
	solicitud_confirmacion_cultivo.aceptada into #estado
	from version_bouquet left join detalle_po on version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and exists
	(
		select *
		from #detalle_po
		where #detalle_po.id_detalle_po = detalle_po.id_detalle_po
	)
	left join farm_detalle_po on detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and exists
	(
		select *
		from #farm_detalle_po
		where #farm_detalle_po.id_farm_detalle_po = farm_detalle_po.id_farm_detalle_po
	)
	left join farm on farm.id_farm = farm_detalle_po.id_farm
	left join solicitud_confirmacion_cultivo on farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
	
	select bouquet.id_bouquet,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	bouquet.imagen,
	version_bouquet.id_version_bouquet,
	caja.id_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(caja.medida)) as medida_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	(
		select sum(detalle_version_bouquet.unidades)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as unidades,
	(
		select sum(detalle_version_bouquet.precio_miami)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as precio_miami,
	(
		select grado_flor_cultivo.id_grado_flor_cultivo
		from grado_flor_cultivo,
		tipo_flor_grado_flor_cultivo
		where grado_flor_cultivo.id_grado_flor_cultivo = tipo_flor_grado_flor_cultivo.id_grado_flor_cultivo
		and tipo_flor.id_tipo_flor = tipo_flor_grado_flor_cultivo.id_tipo_flor
	) as id_grado_flor_cultivo,
	isnull((
		select top 1 aceptada
		from #estado
		where version_bouquet.id_version_bouquet = #estado.id_version_bouquet
	), 0) as id_status,
	(
		select count(*)
		from detalle_version_bouquet
		where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	) as cantidad_formulas,
	null as id_comida_bouquet,
	null as nombre_comida_bouquet,
	null as nombre_formula_bouquet,
	null as especificacion_bouquet,
	null as construccion_bouquet,
	null as id_formula_bouquet,
	null as upc,
	null as orden_upc,
	null as descripcion_upc,
	null as orden_descripcion_upc,
	null as fecha_upc,
	null as orden_fecha_upc,
	null as precio_upc,
	null as orden_precio_upc,
	null as opcion_menu,
	null as id_detalle_version_bouquet into #temp
	from version_bouquet,
	bouquet,
	caja,
	tipo_caja,
	tipo_flor,
	variedad_flor,
	grado_flor
	where bouquet.id_bouquet = version_bouquet.id_bouquet
	and caja.id_caja = version_bouquet.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and grado_flor.id_grado_flor = bouquet.id_grado_flor

	select * 
	from #temp
	order by nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	idc_caja

	select id_tipo_flor,
	nombre_tipo_flor
	from #temp
	group by id_tipo_flor,
	nombre_tipo_flor
	order by nombre_tipo_flor

	select id_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor
	from #temp
	group by id_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor
	order by nombre_variedad_flor

	select id_tipo_flor,
	id_grado_flor,
	nombre_grado_flor 
	from #temp
	group by id_tipo_flor,
	id_grado_flor,
	nombre_grado_flor 
	order by nombre_grado_flor

	drop table #temp
	drop table #detalle_po
	drop table #estado
	drop table #farm_detalle_po
end
else
if(@accion = 'insertar')
begin
	declare @id_bouquet int

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

	select scope_identity() as id_version_bouquet
end
else
if(@accion = 'actualizar')
begin
	update bouquet
	set id_variedad_flor = @id_variedad_flor,
	id_grado_flor = @id_grado_flor,
	imagen =
	case
		when @imagen is null then imagen
		else @imagen
	end
	from version_bouquet
	where bouquet.id_bouquet = version_bouquet.id_bouquet
	and version_bouquet.id_version_bouquet = @id_version_bouquet

	update version_bouquet
	set id_caja = @id_caja
	where version_bouquet.id_version_bouquet = @id_version_bouquet
end