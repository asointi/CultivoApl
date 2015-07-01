set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/10/19
-- Description:	Genera informacion de Gross Profit por finca segun fechas de Guia
-- =============================================

ALTER PROCEDURE [dbo].[na_generar_reporte_gross_profit_por_finca] 

@fecha_inicial datetime,
@fecha_final datetime

as

declare @impuesto_carga decimal(20,4)

select @impuesto_carga = impuesto_carga from configuracion_bd

select estado_guia.idc_estado_guia,
guia.id_guia,
pieza.id_pieza,
pieza.idc_pieza,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
isnull((
	select sum(p.unidades_por_pieza)
	from Detalle_Item_Factura as dif,
	item_factura as ifac,
	factura as f,
	pieza as p
	where ifac.id_factura = f.id_factura
	and dif.id_item_factura = ifac.id_item_factura
	and dif.Id_pieza = p.id_pieza
	and p.id_pieza = Pieza.Id_pieza
), 0) as unidades_vendidas,
sum(pieza.unidades_por_pieza) as unidades_recibidas,
isnull((
	select sum(tc.factor_a_full)
	from Detalle_Item_Factura as dif,
	item_factura as ifac,
	factura as f,
	pieza as p,
	caja as c,
	tipo_caja as tc
	where ifac.id_factura = f.id_factura
	and dif.id_item_factura = ifac.id_item_factura
	and dif.Id_pieza = p.id_pieza
	and p.id_pieza = Pieza.Id_pieza
	and p.id_caja = c.id_caja
	and tc.id_tipo_caja = c.id_tipo_caja
), 0) as full_vendidas,
isnull((
  select sum(item_factura.valor_unitario * p.unidades_por_pieza)
  from Detalle_Item_Factura,
  item_factura,
  factura,
  pieza as p
  where dbo.Item_Factura.id_factura = dbo.Factura.id_factura
  and dbo.Detalle_Item_Factura.id_item_factura = dbo.Item_Factura.id_item_factura
  and dbo.Detalle_Item_Factura.Id_pieza = p.Id_pieza
  and pieza.id_pieza = p.Id_pieza
), 0) as gross_sales,
isnull((
  select sum(cargo.valor_cargo)
  from Detalle_Item_Factura,
  item_factura,
  factura,
  cargo
  where dbo.Item_Factura.id_factura = dbo.Factura.id_factura
  and dbo.Detalle_Item_Factura.id_item_factura = dbo.Item_Factura.id_item_factura
  and dbo.Detalle_Item_Factura.Id_pieza = dbo.Pieza.Id_pieza
  and item_factura.cargo_incluido = 0
  and dbo.Cargo.id_item_factura = dbo.Item_Factura.id_item_factura
), 0) as valor_cargo_no_incluido,
isnull((
  select sum(cargo.valor_cargo)
  from Detalle_Item_Factura,
  item_factura,
  factura,
  cargo
  where dbo.Item_Factura.id_factura = dbo.Factura.id_factura
  and dbo.Detalle_Item_Factura.id_item_factura = dbo.Item_Factura.id_item_factura
  and dbo.Detalle_Item_Factura.Id_pieza = dbo.Pieza.Id_pieza
  and item_factura.cargo_incluido = 1
  and dbo.Cargo.id_item_factura = dbo.Item_Factura.id_item_factura
), 0) as valor_cargo_incluido,
isnull((
	select sum(detalle_credito.valor_credito)
	from credito,
	detalle_credito,
	factura,
	item_factura,
	detalle_item_factura
	where credito.id_credito = detalle_credito.id_credito
	and credito.id_factura = factura.id_factura
	and detalle_credito.id_item_factura = item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and detalle_credito.id_guia = guia.id_guia
), 0) as valor_credito,
(
  select sum(g.valor_impuesto + g.valor_flete)
  from estado_guia,
  guia as g
  where g.id_estado_guia = estado_guia.id_estado_guia
  and g.id_guia = guia.id_guia
  and estado_guia.idc_estado_guia = 'C'
) as impuesto_guia_cerrada,
(
  select sum(ciudad.impuesto_por_caja)
  from Ciudad,
  guia as g,
  estado_guia
  where ciudad.id_ciudad = g.id_ciudad
  and guia.id_guia = g.id_guia
  and g.id_estado_guia = estado_guia.id_estado_guia
  and estado_guia.idc_estado_guia <> 'C'
) as impuesto_guia_no_cerrada,
sum(tipo_caja.factor_a_full) as full_recibidas,
isnull((
  select sum(tipo_caja.factor_a_full)
  from tipo_caja,
  caja,
  pieza as p
  where tipo_caja.id_tipo_caja = caja.id_tipo_caja
  and caja.id_caja = p.id_caja
  and p.id_guia = guia.id_guia
), 0) as full_total_recibidas,
isnull((
  select sum(valor_credito_farm)
  from credito_farm
  where credito_farm.id_guia = guia.id_guia
  and credito_farm.id_farm = farm.id_farm
), 0) as valor_credito_farm,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
ciudad.idc_ciudad,
tipo_farm.id_tipo_farm,
tipo_farm.nombre_tipo_farm,
farm.comision_farm,
pieza.costo_por_unidad,
isnull((
  select sum(p.costo_por_unidad * p.unidades_por_pieza)
  from Detalle_Item_Factura,
  item_factura,
  factura,
pieza as p
  where dbo.Item_Factura.id_factura = dbo.Factura.id_factura
  and dbo.Detalle_Item_Factura.id_item_factura = dbo.Item_Factura.id_item_factura
  and dbo.Detalle_Item_Factura.Id_pieza = p.Id_pieza
and p.id_pieza = pieza.id_pieza
), 0) as costo_total_vendidas,
isnull((
  select sum(p.costo_por_unidad * p.unidades_por_pieza)
  from pieza as p
  where p.id_pieza = Pieza.Id_pieza
  and not exists
  (	
	select *
	from Detalle_Item_Factura,
	item_factura,
	factura
	where dbo.Item_Factura.id_factura = dbo.Factura.id_factura
	and dbo.Detalle_Item_Factura.id_item_factura = dbo.Item_Factura.id_item_factura
	and dbo.Detalle_Item_Factura.Id_pieza = p.Id_pieza
  )
), 0) as costo_total into #temp
from pieza,
guia,
estado_guia,
tipo_flor,
variedad_flor,
grado_flor,
caja,
tipo_caja,
farm,
ciudad,
tipo_farm
where dbo.Pieza.id_guia = dbo.Guia.id_guia
and estado_guia.id_estado_guia = guia.id_estado_guia
and dbo.Guia.fecha_guia between
@fecha_inicial and @fecha_final
and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
and tipo_flor.id_tipo_flor = dbo.Grado_Flor.id_tipo_flor
and dbo.Pieza.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
and dbo.Pieza.id_grado_flor = dbo.Grado_Flor.id_grado_flor
and dbo.Pieza.id_caja = dbo.Caja.id_caja
and dbo.Caja.id_tipo_caja = dbo.Tipo_Caja.id_tipo_caja
and farm.id_farm = pieza.id_farm
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and ciudad.id_ciudad = farm.id_ciudad
group by tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
pieza.id_pieza,
pieza.idc_pieza,
pieza.id_caja,
guia.id_guia,
estado_guia.idc_estado_guia,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tipo_farm.id_tipo_farm,
tipo_farm.nombre_tipo_farm,
farm.comision_farm,
ciudad.idc_ciudad,
pieza.costo_por_unidad,
pieza.unidades_por_pieza

select ID_GUIA,
idc_estado_guia,
idc_farm,
idc_ciudad,
nombre_farm,
nombre_tipo_farm,
sum(unidades_vendidas) as unidades_vendidas,
sum(unidades_recibidas) as unidades_recibidas,
sum(full_vendidas) as full_vendidas,
sum(full_recibidas) as full_recibidas,
sum(valor_cargo_incluido) as valor_cargo_incluido,
sum(valor_cargo_no_incluido) as valor_cargo_no_incluido,
valor_credito,
full_total_recibidas,
sum(gross_sales) + sum(valor_cargo_no_incluido) as "GROSS SALES",
impuesto_guia_no_cerrada,
impuesto_guia_cerrada,
valor_credito_farm as "FARM CREDIT",
comision_farm,
sum(costo_total) as costo_total,
SUM(costo_total_vendidas) AS costo_total_vendidas into #resultado
from #temp
group by ID_GUIA,
idc_estado_guia,
idc_farm,
idc_ciudad,
nombre_farm,
nombre_tipo_farm,
full_total_recibidas,
impuesto_guia_no_cerrada,
impuesto_guia_cerrada,
comision_farm,
valor_credito_farm,
valor_credito

select idc_farm,
nombre_farm,
idc_ciudad,
sum(full_vendidas) as full_vendidas,
sum(full_recibidas) as full_recibidas,
sum(unidades_vendidas) as unidades_vendidas,
case
  when nombre_tipo_farm = 'Natuflora BOUQUETS' then (sum("GROSS SALES") + sum(valor_cargo_no_incluido)) * (1 - comision_farm / 100)
  when nombre_tipo_farm = 'Natuflora' then ((sum("GROSS SALES") - sum(valor_cargo_incluido)) + sum(valor_credito)) * (1 - comision_farm / 100) - (sum(full_vendidas) * @impuesto_carga)
  else sum(costo_total_vendidas)
end as "GROSS COST",
"FARM CREDIT",
case
  when idc_estado_guia = 'C' then sum(impuesto_guia_cerrada) / sum(full_total_recibidas)
  else sum(impuesto_guia_no_cerrada)
end * sum(full_vendidas) as FREIGHT,
sum("GROSS SALES") as "GROSS SALES",
sum(valor_credito) as CREDITS,
case
  when nombre_tipo_farm = 'Natuflora BOUQUETS' then 0
  when nombre_tipo_farm = 'Natuflora' then 0
  else (sum(costo_total)) + (sum(full_recibidas) - sum(full_vendidas))
end
as "INVENTORY COST" INTO #RESULTADO2
from #resultado
group by idc_farm,
nombre_farm,
idc_ciudad,
comision_farm,
nombre_tipo_farm,
idc_estado_guia,
ID_GUIA,
"FARM CREDIT"

select guia.idc_guia,
farm.idc_farm,
farm.nombre_farm,
isnull((
	select sum(detalle_credito.valor_credito)
	from credito,
	detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and credito.id_factura = factura.id_factura
	and detalle_credito.id_item_factura = item_factura.id_item_factura
	and guia.id_guia = detalle_credito.id_guia
), 0) as valor_credito,
isnull((
	select sum(detalle_credito.cantidad_credito)
	from credito,
	detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and credito.id_factura = factura.id_factura
	and detalle_credito.id_item_factura = item_factura.id_item_factura
	and guia.id_guia = detalle_credito.id_guia
), 0) as cantidad_credito,
isnull((
	select sum(cargo.valor_cargo)
	from cargo,
	tipo_cargo
	where cargo.id_item_factura = item_factura.id_item_factura
	and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
	and tipo_cargo.idc_tipo_cargo = 'FR'
), 0) as valor_cargo,
sum(pieza.unidades_por_pieza) as unidades_por_pieza into #valor_fincas
from guia,
pieza,
detalle_item_factura,
item_factura,
factura,
farm
where guia.id_guia = pieza.id_guia
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and farm.id_farm = pieza.id_farm
and guia.fecha_guia between
@fecha_inicial and @fecha_final
group by factura.id_factura,
item_factura.id_item_factura,
farm.idc_farm,
farm.nombre_farm,
guia.id_guia,
guia.idc_guia


select idc_farm,
nombre_farm,
sum(valor_credito) + ((sum(valor_cargo) * sum(cantidad_credito)) / sum(unidades_por_pieza)) as valor_credito into #valor_fincas2
from #valor_fincas
where cantidad_credito > 0
group by idc_farm,
nombre_farm

select idc_farm,
nombre_farm,
idc_ciudad,
sum(full_vendidas) as "SOLD BOXES",
sum(full_recibidas) as "RECEIVED BOXES",
SUM(unidades_vendidas) AS UNITS,
SUM("GROSS COST") AS "GROSS COST",
SUM("FARM CREDIT") AS "FARM CREDIT",
SUM("GROSS COST") + SUM("FARM CREDIT") AS "NET COST",
(SUM("GROSS COST") + SUM("FARM CREDIT")) / SUM(unidades_vendidas) AS "COST AVERAGE",
SUM(FREIGHT) as FREIGHT,
SUM(FREIGHT) / sum(full_vendidas) AS "FREIGHT BY BOX",
sum("GROSS SALES") as "GROSS SALES",
SUM("INVENTORY COST") AS "INVENTORY COST" into #resultado3
FROM #RESULTADO2
GROUP BY idc_farm,
nombre_farm,
idc_ciudad

alter table #resultado3
add valor_credito decimal(20,4)

update #resultado3
SET valor_credito = ISNULL(#valor_fincas2.valor_credito, 0)
from #valor_fincas2
where #valor_fincas2.idc_farm = #resultado3.idc_farm

select idc_farm,
nombre_farm,
idc_ciudad,
"SOLD BOXES",
UNITS,
"GROSS COST",
"FARM CREDIT",
"NET COST",
"COST AVERAGE",
FREIGHT,
"FREIGHT BY BOX",
"GROSS SALES",
ISNULL(valor_credito, 0) as CREDITS,
"GROSS SALES" + ISNULL(valor_credito, 0) as "NET SALES",
case
	when UNITS = 0 then 0
	else ("GROSS SALES" + ISNULL(valor_credito, 0)) / UNITS 
end AS "SALES AVERAGE",
("NET COST" + FREIGHT - ("GROSS SALES" + ISNULL(valor_credito, 0))) * -1 as "PROFIT LOSS",
case
	when "GROSS SALES" + ISNULL(valor_credito, 0) = 0 then 0
	else (("NET COST" + FREIGHT - ("GROSS SALES" + ISNULL(valor_credito, 0))) * -1) / ("GROSS SALES" + ISNULL(valor_credito, 0)) * 100 
end AS "PROFIT LOSS %",
case
	when "SOLD BOXES" = 0 then 0
	else (("NET COST" + FREIGHT - ("GROSS SALES" + ISNULL(valor_credito, 0))) * -1) / "SOLD BOXES" 
end as "PROFIT LOSS BX",
isnull("RECEIVED BOXES", 0) - isnull("SOLD BOXES", 0) as "INVENTORY BOXES",
"INVENTORY COST"
FROM #RESULTADO3
ORDER BY idc_farm,
nombre_farm

drop table #temp
drop table #resultado
DROP TABLE #RESULTADO2
DROP TABLE #RESULTADO3
drop table #valor_fincas
drop table #valor_fincas2