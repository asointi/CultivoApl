set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_consultar_precio_finca]

@id_item_orden_sin_aprobar int

as

declare @codigo nvarchar(10),
@impuesto_andino bit,
@precio_al_que_aplica nvarchar(1),
@porcentaje_ecuador_duty decimal(20,4),
@flor nvarchar(50),
@tapa nvarchar(25),
@code nvarchar(10),
@cantidad_piezas int,
@cliente nvarchar(50),
@caja nvarchar(25),
@farm nvarchar(25),
@ciudad nvarchar(25),
@Miami_FOB_Price decimal(20,4),
@box_charges decimal(20,4), 
@box_charge_adicional decimal(20,4),
@unidades_por_pieza int,
@comision_farm decimal(20,4),
@impuesto_por_caja decimal(20,4),
@factor_a_full decimal(20,4),
@ecuadorian_duty decimal(20,4),
@nombre_base_datos NVARCHAR(25)

set @nombre_base_datos = DB_NAME()

select @codigo = tipo_farm.codigo
from tipo_farm,
farm,
item_orden_sin_aprobar
where tipo_farm.id_tipo_farm = farm.id_tipo_farm
and farm.id_farm = item_orden_sin_aprobar.id_farm
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

select @flor =  ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)),
@tapa = tapa.idc_tapa,
@code = item_orden_sin_aprobar.code,
@cantidad_piezas = item_orden_sin_aprobar.cantidad_piezas,
@cliente = cliente_despacho.idc_cliente_despacho + space(1) + ltrim(rtrim(cliente_despacho.nombre_cliente)),
@caja = tipo_caja.idc_tipo_caja + caja.idc_caja + space(1) + ltrim(rtrim(caja.nombre_caja)),
@farm = ltrim(rtrim(farm.nombre_farm)),
@ciudad = ciudad.idc_ciudad + space(1) + ltrim(rtrim(ciudad.nombre_ciudad)),
@Miami_FOB_Price = item_orden_sin_aprobar.valor_unitario,
@box_charges = 
case
	when @nombre_base_datos = 'BD_NF' and @codigo <> 'C' then 0
	else item_orden_sin_aprobar.box_charges
end,
@unidades_por_pieza = item_orden_sin_aprobar.unidades_por_pieza,
@comision_farm = 
case
	when @nombre_base_datos = 'BD_NF' and @codigo <> 'C' then 35
	else farm.comision_farm
end,
@impuesto_por_caja = ciudad.impuesto_por_caja,
@factor_a_full = tipo_caja.factor_a_full,
@impuesto_andino = ciudad.impuesto_andino,
@precio_al_que_aplica = item_orden_sin_aprobar.precio_al_que_aplica,
@porcentaje_ecuador_duty = item_orden_sin_aprobar.porcentaje_ecuador_duty,
@ecuadorian_duty = 
case
	when @precio_al_que_aplica = 'V' and @impuesto_andino = 1 then @Miami_FOB_Price * (@porcentaje_ecuador_duty / 100)
	else 0
end 
from item_orden_sin_aprobar,
orden_sin_aprobar,
cliente_despacho,
tapa,
variedad_flor,
tipo_flor,
grado_flor,
farm,
ciudad,
caja,
tipo_caja
where item_orden_sin_aprobar.id_farm = farm.id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

select  @flor as Flower,
@tapa as Brand,
@code as code,
@cantidad_piezas as Pieces,
@cliente as Customer,
@caja as Specific_Box,
@unidades_por_pieza as Pack,
@farm as Farm,
@ciudad as City,
@Miami_FOB_Price as Miami_FOB_Price,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	else @box_charges 
end as Box_charges,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	else convert(decimal(20,4), @box_charges / @unidades_por_pieza)
end as Charges_per_unit,
@ecuadorian_duty as ecuadorian_duty,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	else convert(decimal(20,4), @Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty)
end as Subtotal_3,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	else @comision_farm
end as Valor_comision,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	when @comision_farm = 0 then 0
	else convert(decimal(20,4), (@Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty) * (@comision_farm / 100))
end as Comission,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	when @comision_farm = 0 then 0
	else convert(decimal(20,4), (@Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty) - ((@Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty) * (@comision_farm / 100)))
end as Subtotal_5,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	when @comision_farm = 0 then 0
	else @impuesto_por_caja
end as Freight_per_full_box,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	when @comision_farm = 0 then 0
	else convert(decimal(20,4), @impuesto_por_caja * @factor_a_full)
end as Freight_per_specific_box,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	when @comision_farm = 0 then 0
	else convert(decimal(20,4), (@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza)
end as Freight_per_unit,
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	when @comision_farm = 0 then 0
	else convert(decimal(20,4), ((@Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty) - ((@Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty) * (@comision_farm / 100))) - ((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza))
end as Farm_price