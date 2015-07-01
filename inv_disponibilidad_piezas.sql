set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[inv_disponibilidad_piezas]

@idc_estado_pieza varchar(10),
@idc_farm varchar(2),
@idc_tapa varchar(2),
@idc_tipo_flor varchar(2),
@idc_variedad_flor varchar(2),
@idc_grado_flor varchar(2),
@code varchar(5),
@idc_caja varchar(2),
@unidades_por_pieza int,
@tiene_marca bit

as

declare @id_estado_pieza int,
@id_farm int,
@id_tapa int,
@id_tipo_flor int,
@id_variedad_flor int,
@id_grado_flor int,
@id_caja int,
@id_tipo_caja int,
@idc_tipo_caja varchar(1)

set @idc_tipo_caja = left(@idc_caja, 1)
set @idc_caja = right(@idc_caja, 1)

select @id_estado_pieza = id_estado_pieza from estado_pieza where idc_estado_pieza = 
case
	when @idc_estado_pieza = '' then 'vendida'
	else @idc_estado_pieza
end

select @id_farm = id_farm from farm where idc_farm = @idc_farm
select @id_tapa = id_tapa from tapa where idc_tapa = @idc_tapa
select @id_tipo_flor = id_tipo_flor from tipo_flor where idc_tipo_flor = @idc_tipo_flor
select @id_variedad_flor = id_variedad_flor from variedad_flor where idc_variedad_flor = @idc_variedad_flor and id_tipo_flor = @id_tipo_flor
select @id_grado_flor = id_grado_flor from grado_flor where idc_grado_flor = @idc_grado_flor and id_tipo_flor = @id_tipo_flor
select @id_tipo_caja = id_tipo_caja from tipo_caja where idc_tipo_caja = @idc_tipo_caja
select @id_caja = id_caja from caja where idc_caja = @idc_caja and id_tipo_caja = @id_tipo_caja

update pieza
set tiene_marca = @tiene_marca
where pieza.id_tapa = @id_tapa
and pieza.id_caja = @id_caja
and pieza.id_farm = @id_farm
and pieza.id_variedad_flor = @id_variedad_flor
and pieza.id_grado_flor = @id_grado_flor
and pieza.id_estado_pieza = @id_estado_pieza
and pieza.marca = @code
and pieza.unidades_por_pieza = @unidades_por_pieza
and not exists
(
	select * 
	from detalle_item_factura
	where detalle_item_factura.id_pieza = pieza.id_pieza
)
and pieza.disponible = 1