alter PROCEDURE [dbo].[pbinv_items_repetidos_inventario]

@idc_farm nvarchar(255),
@idc_tapa nvarchar(255),
@idc_tipo_caja nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@unidades_por_pieza int,
@fecha nvarchar(255)

as

declare @id_farm int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tapa int,
@id_tipo_caja int,
@conteo int,
@fecha_inicial_temporada datetime,
@id_temporada_año int

select @id_farm = id_farm from farm where idc_farm = @idc_farm

select @id_variedad_flor = variedad_flor.id_variedad_flor 
from variedad_flor, 
tipo_flor 
where variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor 
and variedad_flor.idc_variedad_flor = @idc_variedad_flor

select @id_grado_flor = grado_flor.id_grado_flor 
from grado_flor, 
tipo_flor 
where grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor

select @id_tapa = id_tapa from tapa where idc_tapa = @idc_tapa

select @id_tipo_caja = id_tipo_caja from tipo_caja where idc_tipo_caja = @idc_tipo_caja

select @id_temporada_año = temporada_año.id_temporada_año 
from temporada_cubo,
temporada_año,
temporada,
año
where convert(datetime,@fecha) between
temporada_cubo.fecha_inicial and temporada_cubo.fecha_final
and año.id_año = temporada_año.id_año
and temporada.id_temporada = temporada_año.id_temporada
and año.id_año = temporada_cubo.id_año
and temporada.id_temporada = temporada_cubo.id_temporada

select @fecha_inicial_temporada = min(fecha)
from fecha_inventario
where id_temporada_año = @id_temporada_año

select count(*) as cantidad_items,
isnull((
	select max(convert(int, iip.empaque_principal))
	from inventario_preventa as ip,
	item_inventario_preventa as iip,
	detalle_item_inventario_preventa as diip
	where ip.id_farm = @id_farm
	and ip.id_inventario_preventa = iip.id_inventario_preventa
	and iip.id_item_inventario_preventa = diip.id_item_inventario_preventa
	and iip.id_tapa = @id_tapa
	and iip.id_variedad_flor = @id_variedad_flor
	and iip.id_grado_flor = @id_grado_flor
	and iip.unidades_por_pieza = @unidades_por_pieza
	and diip.fecha_disponible_distribuidora = @fecha_inicial_temporada
), 0) as empaque_principal
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and item_inventario_preventa.id_tapa = @id_tapa
and inventario_preventa.id_farm = @id_farm
and item_inventario_preventa.id_tipo_caja = @id_tipo_caja
and item_inventario_preventa.id_variedad_flor = @id_variedad_flor
and item_inventario_preventa.id_grado_flor = @id_grado_flor
and item_inventario_preventa.unidades_por_pieza = @unidades_por_pieza
and detalle_item_inventario_preventa.fecha_disponible_distribuidora = @fecha_inicial_temporada