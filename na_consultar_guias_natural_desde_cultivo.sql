set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_guias_natural_desde_cultivo]

@fecha_inicial_natural datetime,
@fecha_final_natural datetime,
@idc_tipo_factura_ini nvarchar(2),
@idc_tipo_factura_fin nvarchar(2)

as

select Llave as idc_guia,
convert(datetime, convert(nvarchar,guia.Fechac, 103)) as fecha_guia into #guia_cultivo
from bd_cultivo.bd_cultivo_temp.dbo.guia
where Fechac <> '0'

create table #guia_distribuidora
(
	id_guia int,
	idc_guia nvarchar(255),
	fecha_guia datetime
)

insert into #guia_distribuidora (id_guia, idc_guia, fecha_guia)
select guia.id_guia,
guia.idc_guia,
guia.fecha_guia
from guia

update #guia_distribuidora
set fecha_guia = #guia_cultivo.fecha_guia
from #guia_cultivo
where #guia_cultivo.idc_guia collate SQL_Latin1_General_CP1_CI_AS = #guia_distribuidora.idc_guia

select  #guia_distribuidora.idc_guia,
#guia_distribuidora.fecha_guia,
'' as idc_pieza,
0 as unidades,
credito.fecha_numero_credito,
0 as fulls,
credito.idc_numero_credito,
detalle_credito.valor_credito,
DETALLE_CREDITO.cantidad_credito,
0 as cargo,
substring(idc_item_factura, 8, 2) as idc_farm,
(
	select SUM(cargo.valor_cargo)
	from detalle_credito,
	factura,
	item_factura,
	cargo,
	detalle_item_factura,
	pieza
	where credito.id_credito = detalle_credito.id_credito
	and detalle_credito.id_guia = #guia_distribuidora.id_guia
	and credito.id_factura = factura.id_factura
	and detalle_credito.id_item_factura = item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and cargo.id_item_FActura = item_factura.id_item_factura
	and item_factura.id_Item_factura = detalle_item_factura.id_Item_factura
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and detalle_credito.cantidad_credito > 0
) as valor_total_cargo,
(
	select sum(pieza.unidades_por_pieza)
	from detalle_item_factura,
	pieza,
	item_factura
	where item_factura.id_Item_factura = detalle_item_factura.id_Item_factura
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and detalle_credito.id_item_factura = item_factura.id_item_factura
)as unidades_total_pieza into #creditos
from tipo_detalle_credito,
credito,
detalle_credito,
#guia_distribuidora,
tipo_credito,
factura,
tipo_factura,
item_factura left join detalle_item_factura on item_factura.id_item_factura = detalle_item_factura.id_item_factura
left join pieza on pieza.id_pieza = detalle_item_factura.id_pieza
left join farm on farm.id_farm = pieza.id_farm 
where tipo_credito.id_tipo_credito = credito.id_tipo_credito
and credito.id_credito = detalle_credito.id_credito
and #guia_distribuidora.id_guia = detalle_credito.id_guia
and detalle_credito.id_item_factura = item_factura.id_item_factura
and tipo_credito.aplica_a_farm = 1
and #guia_distribuidora.fecha_guia between 
@fecha_inicial_natural and @fecha_final_natural
and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
and tipo_detalle_credito.idc_tipo_detalle_credito = '02'
and credito.id_factura = factura.id_factura
and item_factura.id_factura = factura.id_factura
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
group by #guia_distribuidora.idc_guia,
#guia_distribuidora.fecha_guia,
#guia_distribuidora.id_guia,
credito.idc_numero_credito,
credito.id_factura,
credito.fecha_numero_credito,
detalle_credito.valor_credito,
substring(idc_item_factura, 8, 2),
credito.id_credito,
DETALLE_CREDITO.cantidad_credito,
detalle_credito.id_item_factura

select #guia_distribuidora.idc_guia,
#guia_distribuidora.fecha_guia,
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
from #guia_distribuidora, 
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
and pieza.id_guia = #guia_distribuidora.id_guia
and pieza.id_farm = farm.id_farm
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and item_factura.id_factura = factura.id_factura
and #guia_distribuidora.fecha_guia between 
@fecha_inicial_natural and @fecha_final_natural
and farm.idc_farm like 'N%'
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
#guia_distribuidora.id_guia,
#guia_distribuidora.idc_guia,
#guia_distribuidora.fecha_guia,
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
sum(valor_credito) + ((valor_total_cargo * sum(cantidad_credito)) / sum(unidades_total_pieza)) as Valor_credito,
cargo,
idc_farm
from #creditos
where idc_farm like 'N%'
group by idc_guia,
fecha_guia,
idc_pieza,
unidades,
fecha_numero_credito,
fulls,
idc_numero_credito,
valor_total_cargo,
cargo,
idc_farm

drop table #creditos

drop table #guia_cultivo
drop table #guia_distribuidora