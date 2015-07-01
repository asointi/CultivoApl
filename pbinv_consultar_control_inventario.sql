set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


alter PROCEDURE [dbo].[pbinv_consultar_control_inventario]

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
@fecha_inicial datetime,
@fecha_final datetime

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final
from temporada,
año,
temporada_año,
temporada_cubo
where temporada.id_temporada = temporada_año.id_temporada
and año.id_año = temporada_año.id_año
and temporada.id_temporada = temporada_cubo.id_temporada
and año.id_año = temporada_cubo.id_año
and @fecha between
temporada_cubo.fecha_inicial and temporada_cubo.fecha_final

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

select @conteo = count(*)
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
and detalle_item_inventario_preventa.fecha_disponible_distribuidora BETWEEN
@fecha_inicial AND @fecha_final

if(@conteo > 0)
begin
	select top 1 controla_saldos
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
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora BETWEEN
	@fecha_inicial AND @fecha_final
	order by item_inventario_preventa.fecha_transaccion desc
end
else
begin
	select 9 as controla_saldos
end