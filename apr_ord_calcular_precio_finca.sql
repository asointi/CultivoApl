set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_calcular_precio_finca]

@id_item_orden_sin_aprobar int

as

select 'Miami_FOB_Price' as Nombre, item_orden_sin_aprobar.valor_unitario
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all
select 'Box_charges', item_orden_sin_aprobar.box_charges
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all 
select 'Charges_per_unit', (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all 
select 'Subtotal_3', (item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza))
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all 
select  'Valor_comision', farm.comision_farm
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all
select 'Comission', ((item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) * (farm.comision_farm / 100))
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all
select 'Subtotal_5', ((item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) - ((item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) * (farm.comision_farm / 100)))
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all
select  'Freight_per_full_box', ciudad.impuesto_por_caja
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all
select  'Freight_per_specific_box', (ciudad.impuesto_por_caja * tipo_caja.factor_a_full)
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all
select  'Freight_per_unit', ((ciudad.impuesto_por_caja * tipo_caja.factor_a_full) / item_orden_sin_aprobar.unidades_por_pieza)
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

union all 
select 'Farm_price', item_orden_sin_aprobar.valor_pactado
from item_orden_sin_aprobar,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
