set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_guias_fresca_desde_cultivo_fecha_factura]

@fecha_inicial_fresca datetime,
@fecha_final_fresca datetime,
@idc_tipo_factura_ini nvarchar(2),
@idc_tipo_factura_fin nvarchar(2)

as

select detalle_credito.id_detalle_credito,
guia.idc_guia,
guia.fecha_guia,
'' as idc_pieza,
0 as unidades,
credito.fecha_numero_credito,
0 as fulls,
credito.idc_numero_credito,
detalle_credito.valor_credito,
DETALLE_CREDITO.cantidad_credito,
0 as cargo,
substring(idc_item_factura, 8, 2) as idc_farm into #creditos
from tipo_detalle_credito,
credito,
factura,
tipo_factura,
detalle_credito,
guia,
tipo_credito,
item_factura left join detalle_item_factura on item_factura.id_item_factura = detalle_item_factura.id_item_factura
left join pieza on pieza.id_pieza = detalle_item_factura.id_pieza
left join farm on farm.id_farm = pieza.id_farm
where tipo_credito.id_tipo_credito = credito.id_tipo_credito
and credito.id_credito = detalle_credito.id_credito
and guia.id_guia = detalle_credito.id_guia
and detalle_credito.id_item_factura = item_factura.id_item_factura
and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
and credito.id_factura = factura.id_factura
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between 
@fecha_inicial_fresca and @fecha_final_fresca
and tipo_factura.id_tipo_factura = factura.id_tipo_factura
and tipo_factura.idc_tipo_factura > =
case
	when @idc_tipo_factura_ini = '' then ' '
	else @idc_tipo_factura_ini
end
and tipo_factura.idc_tipo_factura < =
case
	when @idc_tipo_factura_fin = '' then 'Z'
	else @idc_tipo_factura_fin
end
group by detalle_credito.id_detalle_credito,
guia.idc_guia,
guia.fecha_guia,
credito.idc_numero_credito,
credito.fecha_numero_credito,
substring(idc_item_factura, 8, 2),
detalle_credito.valor_credito,
DETALLE_CREDITO.cantidad_credito

select guia.idc_guia,
guia.fecha_guia,
pieza.idc_pieza,
pieza.unidades_por_pieza,
factura.fecha_factura,
tipo_caja.factor_a_full as fulls,
factura.idc_llave_factura + factura.idc_numero_factura as numero_factura,
isnull(pieza.unidades_por_pieza * item_factura.valor_unitario, 0) as valor,
isnull((
	select sum(cargo.valor_cargo)
	from cargo,
	tipo_cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
), 0) as cargo,
farm.idc_farm as idc_farm 
from guia, 
pieza,
detalle_item_factura,
item_factura,
factura,
tipo_factura,
farm,
caja,
tipo_caja
where pieza.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and pieza.id_guia = guia.id_guia
and pieza.id_farm = farm.id_farm
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and item_factura.id_factura = factura.id_factura
and factura.fecha_factura between 
@fecha_inicial_fresca and @fecha_final_fresca
and (farm.idc_farm = 'AM' or farm.idc_farm = 'AN')
and tipo_factura.id_tipo_factura = factura.id_tipo_factura
and tipo_factura.idc_tipo_factura > =
case
	when @idc_tipo_factura_ini = '' then ' '
	else @idc_tipo_factura_ini
end
and tipo_factura.idc_tipo_factura < =
case
	when @idc_tipo_factura_fin = '' then 'Z'
	else @idc_tipo_factura_fin
end
group by item_factura.id_item_factura,
item_factura.valor_unitario,
item_factura.cargo_incluido,
guia.id_guia,
guia.idc_guia,
guia.fecha_guia,
pieza.idc_pieza,
factura.idc_llave_factura,
factura.idc_numero_factura,
pieza.unidades_por_pieza,
factura.fecha_factura,
tipo_caja.factor_a_full,
farm.idc_farm

union all

select idc_guia,
fecha_guia,
idc_pieza,
unidades,
fecha_numero_credito,
fulls,
idc_numero_credito,
sum(valor_credito) as Valor_credito,
cargo,
idc_farm
from #creditos
where (idc_farm = 'AM' or idc_farm = 'AN')
group by idc_guia,
fecha_guia,
idc_pieza,
unidades,
fecha_numero_credito,
fulls,
idc_numero_credito,
cargo,
idc_farm

drop table #creditos