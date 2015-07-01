SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[inv_consultar_empaque]

@accion nvarchar(255),
@fecha nvarchar(255),
@idc_farm nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_tapa nvarchar(255),
@code nvarchar(255)

AS
        
IF (@accion = 'consultar_packs')
BEGIN
	select item_inventario_preventa.id_item_inventario_preventa,
	unidades_por_pieza,
	tipo_caja.idc_tipo_caja,
	(
		select top 1 unidades_por_pieza
		from
		inventario_preventa,
		item_inventario_preventa,
		detalle_item_inventario_preventa,
		farm,
		tipo_flor,
		variedad_flor,
		grado_flor,
		tapa,
		tipo_caja
		where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
		and dbo.Detalle_Item_Inventario_Preventa.id_item_inventario_preventa = dbo.Item_Inventario_Preventa.id_item_inventario_preventa
		and dbo.Detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora = convert(datetime, @fecha)
		and dbo.Inventario_Preventa.id_farm = farm.id_farm
		and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
		and dbo.Item_Inventario_Preventa.id_grado_flor = dbo.Grado_Flor.id_grado_flor
		and dbo.Grado_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
		and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
		and dbo.Item_Inventario_Preventa.id_tapa = dbo.Tapa.id_tapa
		and dbo.Item_Inventario_Preventa.id_tipo_caja = dbo.Tipo_Caja.id_tipo_caja
		and farm.idc_farm = @idc_farm
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and tapa.idc_tapa = @idc_tapa
		and dbo.Item_Inventario_Preventa.marca = @code
		and dbo.Item_Inventario_Preventa.empaque_principal = 1
		group by unidades_por_pieza
	) as unidades_empaque_principal,
	(
		select top 1 detalle_item_inventario_preventa.cantidad_piezas
		from
		inventario_preventa,
		item_inventario_preventa,
		detalle_item_inventario_preventa,
		farm,
		tipo_flor,
		variedad_flor,
		grado_flor,
		tapa,
		tipo_caja
		where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
		and dbo.Detalle_Item_Inventario_Preventa.id_item_inventario_preventa = dbo.Item_Inventario_Preventa.id_item_inventario_preventa
		and dbo.Detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora = convert(datetime, @fecha)
		and dbo.Inventario_Preventa.id_farm = farm.id_farm
		and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
		and dbo.Item_Inventario_Preventa.id_grado_flor = dbo.Grado_Flor.id_grado_flor
		and dbo.Grado_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
		and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
		and dbo.Item_Inventario_Preventa.id_tapa = dbo.Tapa.id_tapa
		and dbo.Item_Inventario_Preventa.id_tipo_caja = dbo.Tipo_Caja.id_tipo_caja
		and farm.idc_farm = @idc_farm
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and tapa.idc_tapa = @idc_tapa
		and dbo.Item_Inventario_Preventa.marca = @code
		and dbo.Item_Inventario_Preventa.empaque_principal = 1
	) as inventario_empaque_principal
	from
	inventario_preventa,
	item_inventario_preventa,
	detalle_item_inventario_preventa,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	tipo_caja
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and dbo.Detalle_Item_Inventario_Preventa.id_item_inventario_preventa = dbo.Item_Inventario_Preventa.id_item_inventario_preventa
	and dbo.Detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora = convert(datetime, @fecha)
	and dbo.Inventario_Preventa.id_farm = farm.id_farm
	and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
	and dbo.Item_Inventario_Preventa.id_grado_flor = dbo.Grado_Flor.id_grado_flor
	and dbo.Grado_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
	and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
	and dbo.Item_Inventario_Preventa.id_tapa = dbo.Tapa.id_tapa
	and dbo.Item_Inventario_Preventa.id_tipo_caja = dbo.Tipo_Caja.id_tipo_caja
	and farm.idc_farm = @idc_farm
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and tapa.idc_tapa = @idc_tapa
	and dbo.Item_Inventario_Preventa.marca = @code
	group by item_inventario_preventa.id_item_inventario_preventa,
	unidades_por_pieza,
	tipo_caja.idc_tipo_caja
	order by unidades_por_pieza
end