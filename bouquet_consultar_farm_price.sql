/****** Object:  StoredProcedure [dbo].[bouquet_consultar_farm_price]    Script Date: 14/11/2013 4:56:47 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[bouquet_consultar_farm_price]

@id_detalle_po int,
@id_farm int

as
set language spanish

declare @codigo nvarchar(10),
@nombre_farm nvarchar(255),
@nombre_tipo_caja nvarchar(255),
@nombre_ciudad nvarchar(255),
@nombre_cliente nvarchar(255),
@ciudad nvarchar(25),
@Miami_FOB_Price decimal(20,2),
@box_charges decimal(20,4), 
@box_charges_aux decimal(20,4), 
@unidades_por_pieza int,
@comision_farm decimal(20,1),
@impuesto_por_caja decimal(20,2),
@factor_a_full decimal(20,2),
@ecuadorian_duty decimal(20,1),
@nombre_base_datos NVARCHAR(25),
@descuento_box_charge decimal(20,4),
@delivery_cube_rate decimal(20,2),
@idc_farm nvarchar(5),
@fecha_despacho_miami datetime,
@correo nvarchar(max),
@impuesto_andino bit,
@cube_rate decimal(20,2),
@delivery_piece_fee decimal(20,2),
@delivery_fuel_surcharge decimal(20,2),
@medida_alto int,
@medida_ancho int,
@medida_largo int,
@valor_denominador_cube_rate int,
@porcentaje_devolucion_box_charge decimal(20,4)

set @nombre_base_datos = DB_NAME()
set @valor_denominador_cube_rate = 1728

select @impuesto_andino = isnull(ciudad.impuesto_andino, 0),
@porcentaje_devolucion_box_charge = farm.porcentaje_devolucion_box_charge
from farm,
ciudad
where ciudad.id_ciudad = farm.id_ciudad
and farm.id_farm = @id_farm

select @ecuadorian_duty = 
case
	when @impuesto_andino = 1 then 6.4
	else 0
end

select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
from farm_detalle_Po
group by id_farm_detalle_po_padre

select @codigo = tipo_farm.codigo,
@correo = farm.correo,
@idc_farm = farm.idc_farm,
@nombre_farm = farm.idc_farm + ' [' + ltrim(rtrim(farm.nombre_farm)) + ']',
@nombre_ciudad = ltrim(rtrim(ciudad.nombre_ciudad)),
@comision_farm = 
case
	when @nombre_base_datos = 'BD_NF' AND @codigo <> 'C' then 35
	else farm.comision_farm
end,
@impuesto_por_caja = ciudad.impuesto_por_caja
from farm,
tipo_farm,
ciudad
where tipo_farm.id_tipo_farm = farm.id_tipo_farm
and farm.id_farm = @id_farm
and ciudad.id_ciudad = farm.id_ciudad

select @Miami_FOB_Price = 
isnull((
	select sum(precio_miami)
	from Detalle_Version_Bouquet
	where Version_Bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
),0),
@unidades_por_pieza = 
isnull((
	select sum(unidades)
	from Detalle_Version_Bouquet
	where Version_Bouquet.id_version_bouquet = Detalle_Version_Bouquet.id_version_bouquet
),0),
@box_charges_aux = 
case
	when @nombre_base_datos = 'BD_NF' and @codigo <> 'C' then 0
	else detalle_po.box_charge
end,
@delivery_cube_rate = isnull(cliente_despacho.delivery_cube_rate, 0),
@delivery_piece_fee = isnull(cliente_despacho.delivery_piece_fee, 0),
@delivery_fuel_surcharge = isnull(cliente_despacho.delivery_fuel_surcharge, 0),
@cube_rate = isnull(convert(decimal(20,2),(caja.medida_alto * caja.medida_ancho * caja.medida_largo))/@valor_denominador_cube_rate, 0),
@medida_alto = caja.medida_alto,
@medida_ancho = caja.medida_ancho,
@medida_largo = caja.medida_largo,
@factor_a_full = tipo_caja.factor_a_full,
@nombre_tipo_caja = ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
@nombre_cliente = ltrim(rtrim(cliente_despacho.idc_cliente_despacho)),
@fecha_despacho_miami = po.fecha_despacho_miami,
@descuento_box_charge = 
isnull((
	select descuento_box_charge.valor_descuento
	from descuento_box_charge
	where farm_detalle_po.id_farm_detalle_po = descuento_box_charge.id_farm_detalle_po
), 0)
from detalle_Po left join farm_detalle_po on detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po,
version_bouquet,
po,
cliente_despacho,
caja,
tipo_caja
where detalle_Po.id_detalle_Po = @id_detalle_Po
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and po.id_po = detalle_po.id_po
and cliente_despacho.id_despacho = po.id_despacho
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = version_bouquet.id_caja

select @unidades_por_pieza =
case
	when @unidades_por_pieza = 0 then 1
	else @unidades_por_pieza
end

set @box_charges = @box_charges_aux - (@box_charges_aux * (@porcentaje_devolucion_box_charge/100))

select convert(decimal(20,2),@Miami_FOB_Price / @unidades_por_pieza) as miami_fob_price,
convert(decimal(20,2), @box_charges_aux * @unidades_por_pieza) as box_charge,
'(' + convert(nvarchar,convert(decimal(20,2), @box_charges_aux)) + ')' as box_charge_unidad,
convert(decimal(20,2),@porcentaje_devolucion_box_charge) as porcentaje_descuento_finca,
convert(decimal(20,2), (@box_charges_aux * (@porcentaje_devolucion_box_charge/100)) * @unidades_por_pieza) as descuento_farm_box_charge,
'(' + convert(nvarchar,convert(decimal(20,2), @box_charges_aux * (@porcentaje_devolucion_box_charge/100))) + ')' as descuento_farm_box_charge_unidad,
convert(decimal(20,2),@descuento_box_charge * @unidades_por_pieza) as box_charge_discount_pieza,
convert(decimal(20,2),@descuento_box_charge) as box_charge_discount,
'(' + convert(nvarchar,(convert(decimal(20,2),@box_charges - @descuento_box_charge))) + ')' as net_box_charge,
@delivery_cube_rate as delivery_cube_rate,
convert(nvarchar,@medida_alto) + 'x' + convert(nvarchar,@medida_ancho) + 'x' + convert(nvarchar,@medida_largo) as medidas_caja,
@valor_denominador_cube_rate as denominador_cube,
@delivery_piece_fee as delivery_piece_fee,
@delivery_fuel_surcharge as delivery_fuel_surcharge,
convert(decimal(20,2), ((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100)))) as delivery_charge,
'(' + convert(nvarchar,convert(decimal(20,2), abs(((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza))) + ')' as delivery_charge_unidad,
convert(decimal(20,2), (@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) as subtotal_1,
'(' + convert(nvarchar,convert(decimal(20,2), abs(((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) * (@comision_farm / 100)))) + ')' as valor_comission,
convert(decimal(20,2), ((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) - ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) * (@comision_farm / 100)))) as subtotal_2,
convert(decimal(20,2), @impuesto_por_caja * @factor_a_full) as freight,
'(' + convert(nvarchar,convert(decimal(20,2),abs((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza))) + ')' as freight_por_unidad,
'(' + convert(nvarchar,convert(decimal(20,2), abs((@ecuadorian_duty / 100) * ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) - ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) * (@comision_farm / 100)))) - ((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza)) / (1 + (@ecuadorian_duty / 100))))) + ')' as valor_ecuadorian_duty,
convert(decimal(20,2),
case	
	when ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) - ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) * (@comision_farm / 100)))) - ((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza) - ((@ecuadorian_duty / 100) * ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) - ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) * (@comision_farm / 100)))) - ((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza)) / (1 + (@ecuadorian_duty / 100)))) < 0 then 0
	else ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) - ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) * (@comision_farm / 100)))) - ((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza) - ((@ecuadorian_duty / 100) * ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) - ((((@Miami_FOB_Price / @unidades_por_pieza) - (@box_charges - @descuento_box_charge) - (((@delivery_cube_rate * @cube_rate + @delivery_piece_fee) * (1+ (@delivery_fuel_surcharge / 100))) / @unidades_por_pieza)) * (@comision_farm / 100)))) - ((@impuesto_por_caja * @factor_a_full) / @unidades_por_pieza)) / (1 + (@ecuadorian_duty / 100))))
end
) as maximun_farm_price,
@correo as correo,
[dbo].[calcular_dia_vuelo_mass_market] (@fecha_despacho_miami, @idc_farm) as fecha_vuelo,
@nombre_farm as nombre_farm,
@nombre_cliente as nombre_cliente,
@nombre_tipo_caja as nombre_tipo_caja,
@nombre_ciudad as nombre_ciudad,
@unidades_por_pieza as unidades_por_pieza,
@comision_farm as comision_farm,
@ecuadorian_duty as ecuadorian_duty

select [dbo].[calcular_dia_vuelo_mass_market] (@fecha_despacho_miami, @idc_farm)

drop table #farm_detalle_po