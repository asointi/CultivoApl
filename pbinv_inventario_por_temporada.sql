set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[pbinv_inventario_por_temporada]

@id_temporada_año int, 
@id_farm int,
@rosa bit

as

declare @fecha_inicial datetime,
@fecha_final datetime

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final 
from temporada_cubo,
temporada_año
where temporada_año.id_año = temporada_cubo.id_año
and temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_temporada_año = @id_temporada_año

if(@rosa = 1)
begin
	select tipo_caja.factor_a_full,
	ltrim(rtrim(ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '-' + space(1) + tipo_flor.idc_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '-' + space(1) + variedad_flor.idc_variedad_flor)) as nombre_variedad_flor, 
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	sum(detalle_item_inventario_preventa.cantidad_piezas) as cantidad_piezas
	from farm, 
	tipo_flor, 
	variedad_flor, 
	grado_flor, 
	tipo_caja,
	inventario_preventa, 
	item_inventario_preventa, 
	detalle_item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
	and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
	and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor in 
	(
	select id_tipo_flor from tipo_flor where idc_tipo_flor = 'RO' or idc_tipo_flor = 'RS'
	)
	and inventario_preventa.id_farm = farm.id_farm
	and farm.id_farm = @id_farm
	and item_inventario_preventa.id_tipo_caja = tipo_caja.id_tipo_caja
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
	@fecha_inicial and @fecha_final
	and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa in 
	(
	select max(id_detalle_item_inventario_preventa)
	from detalle_item_inventario_preventa
	group by id_detalle_item_inventario_preventa_padre
	)
	group by
	tipo_caja.factor_a_full,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor, 
	grado_flor.nombre_grado_flor
	having sum(detalle_item_inventario_preventa.cantidad_piezas) > 0
	order by tipo_caja.factor_a_full,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor
end
else
if(@rosa = 0)
begin
	select tipo_caja.factor_a_full,
	ltrim(rtrim(ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '-' + space(1) + tipo_flor.idc_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '-' + space(1) + variedad_flor.idc_variedad_flor)) as nombre_variedad_flor, 
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	sum(detalle_item_inventario_preventa.cantidad_piezas) as cantidad_piezas
	from farm, 
	tipo_flor, 
	variedad_flor, 
	grado_flor, 
	tipo_caja,
	inventario_preventa, 
	item_inventario_preventa, 
	detalle_item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
	and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
	and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor in 
	(
	select id_tipo_flor from tipo_flor where idc_tipo_flor <> 'RO' and idc_tipo_flor <> 'RS'
	)
	and inventario_preventa.id_farm = farm.id_farm
	and farm.id_farm = @id_farm
	and item_inventario_preventa.id_tipo_caja = tipo_caja.id_tipo_caja
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
	@fecha_inicial and @fecha_final
	and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa in 
	(
	select max(id_detalle_item_inventario_preventa)
	from detalle_item_inventario_preventa
	group by id_detalle_item_inventario_preventa_padre
	)
	group by
	tipo_caja.factor_a_full,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor, 
	grado_flor.nombre_grado_flor
	having sum(detalle_item_inventario_preventa.cantidad_piezas) > 0
	order by tipo_caja.factor_a_full,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor
end


