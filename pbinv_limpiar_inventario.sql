set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE PROCEDURE [dbo].[pbinv_limpiar_inventario]

@idc_farm nvarchar(2),
@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2),
@idc_grado_flor nvarchar(2),
@fecha_inicial_temporada datetime

as

declare @fecha_inicial datetime,
@fecha_final datetime

select @fecha_inicial = fecha_inicial,
@fecha_final = fecha_final 
from temporada_cubo
where @fecha_inicial_temporada between
fecha_inicial and fecha_final

update detalle_item_inventario_preventa
set cantidad_piezas = 0
where id_detalle_item_inventario_preventa in
(
	select detalle_item_inventario_preventa.id_detalle_item_inventario_preventa
	from farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	inventario_preventa,
	item_inventario_preventa,
	detalle_item_inventario_preventa
	where farm.id_farm = inventario_preventa.id_farm
	and inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
	and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
	and item_inventario_preventa.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and farm.idc_farm > = 
	case
		when @idc_farm = '' then '%%'
		else @idc_farm
	end 
	and farm.idc_farm < = 
	case
		when @idc_farm = '' then 'ZZ'
		else @idc_farm
	end 

	and tipo_flor.idc_tipo_flor > = 
	case
		when @idc_tipo_flor = '' then '%%'
		else @idc_tipo_flor
	end 
	and tipo_flor.idc_tipo_flor < = 
	case
		when @idc_tipo_flor = '' then 'ZZ'
		else @idc_tipo_flor
	end 

	and variedad_flor.idc_variedad_flor > = 
	case
		when @idc_variedad_flor = '' then '%%'
		else @idc_variedad_flor
	end 
	and variedad_flor.idc_variedad_flor < = 
	case
		when @idc_variedad_flor = '' then 'ZZ'
		else @idc_variedad_flor
	end 

	and grado_flor.idc_grado_flor > = 
	case
		when @idc_grado_flor = '' then '%%'
		else @idc_grado_flor
	end 
	and grado_flor.idc_grado_flor < = 
	case
		when @idc_grado_flor = '' then 'ZZ'
		else @idc_grado_flor
	end 
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora > = @fecha_inicial
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora < = @fecha_final
)


