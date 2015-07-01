USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[apr_ord_editar_farm_price]    Script Date: 9/3/2013 4:44:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[apr_ord_editar_farm_price]

@id_farm int,
@id_item_orden_sin_aprobar int

as

declare @codigo nvarchar(10),
@impuesto_andino bit,
@precio_al_que_aplica nvarchar(1),
@porcentaje_ecuador_duty decimal(20,4),
@ciudad nvarchar(25),
@Miami_FOB_Price decimal(20,4),
@box_charges decimal(20,4), 
@box_charge_adicional decimal(20,4),
@unidades_por_pieza int,
@comision_farm decimal(20,4),
@impuesto_por_caja decimal(20,4),
@factor_a_full decimal(20,4),
@ecuadorian_duty decimal(20,4),
@contiene_mail bit,
@nombre_dia_vuelo nvarchar(25),
@fecha_vuelo nvarchar(50),
@fecha_inicial datetime,
@correo nvarchar(1024),
@idc_tipo_factura nvarchar(2),
@nombre_base_datos NVARCHAR(25)

set @nombre_base_datos = DB_NAME()

select @codigo = tipo_farm.codigo,
@correo = farm.correo
from tipo_farm,
farm
where tipo_farm.id_tipo_farm = farm.id_tipo_farm
and farm.id_farm = @id_farm

select @idc_tipo_factura = tipo_factura.idc_tipo_factura 
from item_orden_sin_aprobar,
orden_sin_aprobar,
tipo_factura
where tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

select @ciudad = ltrim(rtrim(ciudad.nombre_ciudad)),
@Miami_FOB_Price = item_orden_sin_aprobar.valor_unitario,
@unidades_por_pieza = item_orden_sin_aprobar.unidades_por_pieza,
@box_charges = 
case
	when @nombre_base_datos = 'BD_NF' and @codigo <> 'C' then 0
	else item_orden_sin_aprobar.box_charges
end,
@comision_farm = 
case
	when @nombre_base_datos = 'BD_NF' AND @codigo <> 'C' then 35
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
end,
@contiene_mail = 
case
	when @correo is null then 0
	when len(@correo) < 7 then 0 
	else 1
end,
@nombre_dia_vuelo =
case
	when @idc_tipo_factura = '9' then datename(dw, [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)) 
	else left(convert(nvarchar, [dbo].[calcular_dia_vuelo_preventa] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm), 103), 5)
end,
@fecha_vuelo =
case
	when @idc_tipo_factura = '9' then 'Fecha inicial: ' + convert(nvarchar,[dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm), 103) 
	else ''
end,
@fecha_inicial = 
case
	when @idc_tipo_factura = '9' then [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)
	else [dbo].[calcular_dia_vuelo_preventa] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)
end
from item_orden_sin_aprobar,
orden_sin_aprobar,
cliente_despacho,
farm,
ciudad,
caja,
tipo_caja
where farm.id_farm = @id_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

select @ciudad as nombre_ciudad,
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
convert(decimal(20, 2),
Round(
case
	when @precio_al_que_aplica = 'C' and @impuesto_andino = 1 then 0
	when @comision_farm = 0 then 0
	else convert(decimal(20,4), ((@Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty) - ((@Miami_FOB_Price - (@box_charges / @unidades_por_pieza) - @ecuadorian_duty) * (@comision_farm / 100))) - ((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza))
end
, 2, 0)) as Farm_price,
@contiene_mail as contiene_mail,
@nombre_dia_vuelo as nombre_dia_vuelo,
@fecha_vuelo as fecha_vuelo,
@fecha_inicial as fecha_inicial,
@impuesto_andino as impuesto_andino into #temp

select nombre_ciudad,
Miami_FOB_Price,
Box_charges,
Charges_per_unit,
ecuadorian_duty,
Subtotal_3,
Valor_comision,
Comission,
Subtotal_5,
Freight_per_full_box,
Freight_per_specific_box,
Freight_per_unit,
case	
	when Farm_price < 0 then 0
	else Farm_price
end as Farm_price,
contiene_mail,
nombre_dia_vuelo,
fecha_vuelo,
fecha_inicial,
impuesto_andino
from #temp

drop table #temp