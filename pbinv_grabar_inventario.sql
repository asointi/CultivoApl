set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv_grabar_inventario]

@idc_farm nvarchar(5),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@idc_tapa nvarchar(5),
@idc_tipo_caja nvarchar(5),
@unidades_por_pieza int,
@fecha_inicial nvarchar(15),
@cantidad_piezas int,
@empaque_principal bit,
@controla_saldos bit,
@precio_finca decimal(20,4)

AS

declare @conteo int,
@id_inventario_preventa int,
@id_item_inventario_preventa int,
@id_detalle_item_inventario_preventa int,
@marca nvarchar(5),
@precio_minimo decimal(20,4)

if(@empaque_principal = 0)
begin
	set @cantidad_piezas = 0
end

set @marca = 'PB'

select item_inventario_preventa.id_item_inventario_preventa,
detalle_item_inventario_preventa.id_detalle_item_inventario_preventa into #inventario
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa,
farm,
tipo_caja,
tipo_flor,
variedad_flor,
grado_flor
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and inventario_preventa.id_farm = farm.id_farm
and item_inventario_preventa.id_tipo_caja = tipo_caja.id_tipo_caja
and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
and item_inventario_preventa.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_caja.idc_tipo_caja = @idc_tipo_caja
and farm.idc_farm = @idc_farm
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and item_inventario_preventa.unidades_por_pieza = @unidades_por_pieza
and detalle_item_inventario_preventa.fecha_disponible_distribuidora = convert(datetime, @fecha_inicial)

select @precio_minimo = isnull(max(item_inventario_preventa.precio_minimo), 0)
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa,
farm,
tipo_flor,
variedad_flor,
grado_flor
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and inventario_preventa.id_farm = farm.id_farm
and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
and item_inventario_preventa.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and farm.idc_farm = @idc_farm
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and detalle_item_inventario_preventa.fecha_disponible_distribuidora = convert(datetime, @fecha_inicial)

select @conteo = count(*) 
from #inventario

if(@conteo = 0)
begin
	insert into Inventario_Preventa (id_farm)
	select id_farm 
	from farm 
	where idc_farm = @idc_farm

	set @id_inventario_preventa = scope_identity()

	insert into Item_Inventario_Preventa (id_cuenta_interna, id_inventario_preventa, id_tapa, id_variedad_flor, id_grado_flor, unidades_por_pieza, marca, id_tipo_caja, empaque_principal, controla_saldos, precio_finca, precio_minimo)
	select cuenta_interna.id_cuenta_interna,
	@id_inventario_preventa,
	tapa.id_tapa,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	@unidades_por_pieza,
	@marca,
	tipo_caja.id_tipo_caja,
	@empaque_principal,
	@controla_saldos, 
	@precio_finca, 
	@precio_minimo
	from cuenta_interna,
	farm,
	tapa,
	tipo_caja,
	tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and cuenta_interna.cuenta = 'cobol'
	and tipo_caja.idc_tipo_caja = @idc_tipo_caja
	and tapa.idc_tapa = @idc_tapa
	and farm.idc_farm = @idc_farm
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor

	set @id_item_inventario_preventa = scope_identity()

	insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, cantidad_piezas_adicionales_finca, cantidad_piezas_ofertadas_finca)
	values (@id_item_inventario_preventa, convert(datetime, @fecha_inicial), @cantidad_piezas, 0, 0)

	set @id_detalle_item_inventario_preventa = scope_identity()

	update detalle_item_inventario_preventa
	set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa
end
else
begin
	update item_inventario_preventa
	set controla_saldos = @controla_saldos,
	precio_finca = @precio_finca,
	empaque_principal = @empaque_principal	
	where exists
	(
		select *
		from #inventario
		where #inventario.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
	)
	
	update detalle_item_inventario_preventa
	set cantidad_piezas = @cantidad_piezas
	where exists
	(
		select *
		from #inventario
		where #inventario.id_detalle_item_inventario_preventa = detalle_item_inventario_preventa.id_detalle_item_inventario_preventa
	)
end