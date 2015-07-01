USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_consultar_reporte_formato_cultivo_agrupado]    Script Date: 28/11/2014 4:18:39 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[bouquet_consultar_reporte_formato_cultivo_agrupado] 

@id_farm_detalle_po int,
@accion nvarchar(255)

as

declare @cantidad_recetas int,
@conteo_upc int,
@cantidad_sticker int,
@cantidad_capuchon int,
@cantidad_comida int,
@cantidad_formatoUPC int,
@cantidad_especificacion int,
@cantidad_construccion int,
@cantidad_suma_capuchones int,
@cantidad_suma_sticker int,
@cantidad_suma_especificacion int,
@cantidad_suma_construccion int,
@cantidad_suma_upc int,
@id_farm_detalle_po_padre int

select @id_farm_detalle_po_padre = farm_detalle_po.id_farm_detalle_po_padre
from farm_detalle_po
where farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po

select @id_farm_detalle_po = max(farm_detalle_po.id_farm_detalle_po)
from farm_detalle_po
where farm_detalle_po.id_farm_detalle_po_padre = @id_farm_detalle_po_padre

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

select ltrim(rtrim(comida_bouquet.nombre_Comida)) as nombre_comida into #comida
from farm_detalle_po,
detalle_po,
version_bouquet,
detalle_version_bouquet,
Comida_Bouquet
where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
and Comida_Bouquet.id_comida_bouquet = Detalle_Version_Bouquet.id_comida_bouquet
group by ltrim(rtrim(comida_bouquet.nombre_Comida))

select Formato_UPC.nombre_formato into #formato_upc
from farm_detalle_po,
detalle_po,
version_bouquet,
detalle_version_bouquet,
Formato_UPC
where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
and Formato_UPC.id_formato_upc = Detalle_Version_Bouquet.id_formato_upc
group by Formato_UPC.nombre_formato

select detalle_version_bouquet.id_detalle_version_bouquet,
ltrim(rtrim(formula_bouquet.especificacion_bouquet)) as especificacion_bouquet into #especificacion_sin_agrupar
from farm_detalle_po,
detalle_po,
version_bouquet,
detalle_version_bouquet,
formula_bouquet
where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
and ltrim(rtrim(formula_bouquet.especificacion_bouquet)) <> ''
group by detalle_version_bouquet.id_detalle_version_bouquet,
ltrim(rtrim(formula_bouquet.especificacion_bouquet))

select especificacion_bouquet,
count(*) as conteo into #especificacion
from #especificacion_sin_agrupar
group by especificacion_bouquet

select detalle_version_bouquet.id_detalle_version_bouquet,
ltrim(rtrim(formula_bouquet.construccion_bouquet)) as construccion_bouquet into #construccion_sin_agrupar
from farm_detalle_po,
detalle_po,
version_bouquet,
detalle_version_bouquet,
formula_bouquet
where detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
and farm_detalle_po.id_farm_detalle_po = @id_farm_detalle_po
and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
and ltrim(rtrim(formula_bouquet.construccion_bouquet)) <> ''
group by detalle_version_bouquet.id_detalle_version_bouquet,
ltrim(rtrim(formula_bouquet.construccion_bouquet))

select construccion_bouquet,
count(*) as conteo into #construccion
from #construccion_sin_agrupar
group by construccion_bouquet

select @cantidad_construccion = count(*),
@cantidad_suma_construccion = sum(conteo) from #construccion
select @cantidad_especificacion = count(*),
@cantidad_suma_especificacion = sum(conteo) from #especificacion
select @cantidad_formatoUPC = count(*) from #formato_upc
select @cantidad_comida = count(*) from #comida
select @cantidad_capuchon = count(*),
@cantidad_suma_capuchones = sum(conteo) from #capuchon
select @cantidad_sticker = count(*),
@cantidad_suma_sticker = sum(conteo) from #sticker
select @conteo_upc = count(*) from #upc

declare @resultado table 
(
	dato nvarchar(1024), 
	orden int, 
	orden_upc int, 
	encabezado bit
)

declare @construccion int,
@especificaciones int,
@formato_upc int,
@comida int

--1 -- Construcción
--2 -- Especificaciones
--3 -- Formato UPC
--4 -- Comida

if(@cantidad_construccion = 1 and @cantidad_suma_construccion = @cantidad_recetas)
begin
	insert into @resultado (dato, orden, orden_upc, encabezado)
	select 'Construcción', 2, 0, 1 	
	union all 
	select construccion_bouquet, 2, 0, 0
	from #construccion
	group by construccion_bouquet

	set @construccion = 1
end

if(@cantidad_especificacion = 1 and @cantidad_suma_especificacion = @cantidad_recetas)
begin
	insert into @resultado (dato, orden, orden_upc, encabezado)
	select 'Especificaciones', 1, 0, 1 	
	union all 
	select especificacion_bouquet, 1, 0, 0
	from #especificacion
	group by especificacion_bouquet

	set @especificaciones = 2
end

if(@cantidad_formatoUPC = 1)
begin
	insert into @resultado (dato, orden, orden_upc, encabezado)
	select 'Formato UPC', 7, 0, 1 	
	union all 
	select nombre_formato, 7, 0, 0
	from #formato_upc
	group by nombre_formato

	set @formato_upc = 3
end

if(@cantidad_comida = 1)
begin
	insert into @resultado (dato, orden, orden_upc, encabezado)
	select 'Comida', 3, 0, 1 	
	union all 
	select nombre_comida, 3, 0, 0
	from #comida
	group by nombre_comida

	set @comida = 4
end

if(@cantidad_capuchon > 0 and @cantidad_suma_capuchones = (@cantidad_capuchon * @cantidad_recetas))
begin
	insert into @resultado (dato, orden, orden_upc, encabezado)
	select 'Capuchones', 4, 0, 1 	
	union all 
	select nombre_capuchon, 4, 0, 0
	from #capuchon
	group by nombre_capuchon
end

if(@cantidad_sticker > 0 and @cantidad_suma_sticker = (@cantidad_sticker * @cantidad_recetas))
begin
	insert into @resultado (dato, orden, orden_upc, encabezado)
	select 'Stickers', 5, 0, 1 	
	union all 
	select nombre_sticker, 5, 0, 0
	from #sticker
	group by nombre_sticker
end

if(@conteo_upc = 4)
begin
	insert into @resultado (dato, orden, orden_upc, encabezado)
	select 'UPC' as valor,	6,	0, 1
	union all
	select nombre_informacion_upc + ': ' + char(9) + valor,	6, orden, 0 
	from #upc
	where valor <> ''
	group by nombre_informacion_upc,
	valor,
	orden
end 

select dato, 
orden, 
orden_upc, 
encabezado,
@construccion as construccion,
@especificaciones as especificaciones,
@formato_upc as formato_upc,
@comida as comida
from @resultado
order by orden,
orden_upc

drop table #upc
drop table #sticker_sin_agrupar
drop table #capuchon_sin_agrupar
drop table #sticker
drop table #capuchon
drop table #comida
drop table #formato_upc
drop table #especificacion
drop table #construccion