set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[pbinv_registrar_item_cobol]

@idc_farm nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_tapa nvarchar(255),
@idc_tipo_caja nvarchar(255),
@unidades_por_pieza int,
@marca nvarchar(255),
@fecha_inicial nvarchar(255),
@cantidad_piezas int,
@cantidad_piezas_adcionales_finca int

AS

declare @id_inventario_preventa int,
@id_item_inventario_preventa int,
@id_detalle_item_inventario_preventa int

insert into Inventario_Preventa (id_farm)
select id_farm from farm where idc_farm = @idc_farm

set @id_inventario_preventa = scope_identity()

insert into Item_Inventario_Preventa (id_cuenta_interna, id_inventario_preventa, id_tapa, id_variedad_flor, id_grado_flor, unidades_por_pieza, marca, id_tipo_caja)
select cuenta_interna.id_cuenta_interna,
@id_inventario_preventa,
tapa.id_tapa,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
@unidades_por_pieza,
@marca,
tipo_caja.id_tipo_caja
from cuenta_interna,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
tipo_caja
where cuenta_interna.cuenta = 'cobol'
and tapa.idc_tapa = @idc_tapa
and tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor = @idc_tipo_flor+@idc_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.idc_tipo_flor+grado_flor.idc_grado_flor = @idc_tipo_flor+@idc_grado_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_caja.idc_tipo_caja = left(@idc_tipo_caja, 1)

set @id_item_inventario_preventa = scope_identity()

insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, cantidad_piezas_adicionales_finca)
select @id_item_inventario_preventa, @fecha_inicial, @cantidad_piezas, @cantidad_piezas_adcionales_finca

set @id_detalle_item_inventario_preventa = scope_identity()

update detalle_item_inventario_preventa
set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa