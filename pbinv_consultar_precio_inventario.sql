/****** Object:  StoredProcedure [dbo].[pbinv_consultar_inventario_cobol_total]    Script Date: 05/14/2008 10:46:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_consultar_precio_inventario]

@idc_farm nvarchar(255),
@idc_tapa nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@code nvarchar(255),
@idc_tipo_caja nvarchar(255),
@unidades_por_pieza int,
@fecha datetime

AS

declare @fecha_inicial datetime,
@fecha_final datetime

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final
from temporada_año,
temporada_cubo
where temporada_año.id_año = temporada_cubo.id_año
and temporada_año.id_temporada = temporada_cubo.id_temporada
and @fecha between
temporada_cubo.fecha_inicial and temporada_cubo.fecha_final

select TOP 1 max(item_inventario_preventa.precio_minimo) as valor_unitario
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa,
detalle_item_inventario_preventa as diip, 
farm, 
tapa,
variedad_flor,
grado_flor,
tipo_flor,
tipo_caja
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and inventario_preventa.id_farm = farm.id_farm
and item_inventario_preventa.id_tapa = tapa.id_tapa
and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
and item_inventario_preventa.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and item_inventario_preventa.id_tipo_caja = tipo_caja.id_tipo_caja
and farm.idc_farm = @idc_farm
and tapa.idc_tapa = @idc_tapa
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and tipo_caja.idc_tipo_caja = @idc_tipo_caja
and item_inventario_preventa.unidades_por_pieza = @unidades_por_pieza
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa < = diip.id_detalle_item_inventario_preventa
and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa_padre = diip.id_detalle_item_inventario_preventa_padre
and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_inicial and @fecha_final
group by
detalle_item_inventario_preventa.id_detalle_item_inventario_preventa
having
detalle_item_inventario_preventa.id_detalle_item_inventario_preventa = max(diip.id_detalle_item_inventario_preventa)