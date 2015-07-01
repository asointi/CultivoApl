set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

ALTER PROCEDURE [dbo].[na_editar_valor_producto]

@code nvarchar(10),
@unidades_por_pieza int,
@fecha_disponible_precio nvarchar(15),
@idc_estado_pieza nvarchar(50),
@idc_farm nvarchar(10),
@idc_tapa nvarchar(10),
@idc_tipo_flor nvarchar(10),
@idc_variedad_flor nvarchar(10),
@idc_grado_flor nvarchar(10),
@idc_caja nvarchar(10),
@precio decimal(20,4)

as

insert into valor_producto 
(
	id_caja,
	id_farm,
	id_tapa,
	id_variedad_flor,
	id_grado_flor,
	precio,
	fecha_disponible_precio,
	code,
	unidades_por_pieza
)
select caja.id_caja,
farm.id_farm, 
tapa.id_tapa, 
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
@precio,
getdate(),
@code,
@unidades_por_pieza
from estado_pieza,
farm, 
tapa, 
variedad_flor, 
tipo_flor, 
grado_flor, 
caja, 
tipo_caja
where estado_pieza.nombre_estado_pieza = 'Open Market'
and estado_pieza.idc_estado_pieza = @idc_estado_pieza
and farm.idc_farm = @idc_farm
and tapa.idc_tapa = @idc_tapa
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_caja.idc_tipo_caja+caja.idc_caja = @idc_caja
and caja.id_tipo_caja = tipo_caja.id_tipo_caja