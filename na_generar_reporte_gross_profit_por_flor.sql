set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/10/19
-- Description:	Genera informacion de Gross Profit por flor segun fechas de Guia
-- =============================================

alter PROCEDURE [dbo].[na_generar_reporte_gross_profit_por_flor] 

@fecha_inicial datetime,
@fecha_final datetime,
@idc_cliente_inicial nvarchar(20),
@idc_cliente_final nvarchar(20),
@idc_farm_inicial nvarchar(2),
@idc_farm_final nvarchar(2),
@idc_tipo_farm_inicial nvarchar(1),
@idc_tipo_farm_final nvarchar(1),
@idc_variedad_flor_inicial nvarchar(4),
@idc_variedad_flor_final nvarchar(4)

as

declare @impuesto_carga decimal(20,4),
@cantidad int

select @impuesto_carga = impuesto_carga from configuracion_bd

select IDENTITY(int, 1,1) AS Id,
estado_guia.idc_estado_guia,
guia.id_guia,
pieza.id_pieza,
pieza.idc_pieza,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
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
sum(tipo_caja.factor_a_full) as full_recibidas,
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
isnull((
	select sum(tc.factor_a_full)
	from guia as g,
	estado_guia,
	pieza as p,
	caja as c,
	tipo_caja as tc
	where guia.id_guia = g.id_guia
	and g.id_estado_guia = estado_guia.id_estado_guia
	and estado_guia.idc_estado_guia <> 'C'
	and g.id_guia = p.id_guia
	and p.id_pieza = pieza.id_pieza
	and p.id_caja = c.id_caja
	and tc.id_tipo_caja = c.id_tipo_caja
), 0) as estimated_boxes,
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
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
ciudad.idc_ciudad,
tipo_farm.id_tipo_farm,
tipo_farm.nombre_tipo_farm,
tipo_farm.codigo,
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
), 0) as costo_total,
(
	select cliente_despacho.idc_cliente_despacho
	from factura,
	item_factura,
	detalle_item_factura,
	cliente_despacho
	where cliente_despacho.id_despacho = factura.id_despacho
	and factura.id_factura = item_factura.id_factura
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and pieza.id_pieza = detalle_item_factura.id_pieza
) as idc_cliente_despacho into #temp
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
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
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
tipo_farm.codigo,
farm.comision_farm,
ciudad.idc_ciudad,
pieza.costo_por_unidad,
pieza.unidades_por_pieza

select top 1 @cantidad = count(*)
from #temp
where valor_credito_farm <> 0
group by id_guia,
id_farm,
valor_credito_farm
having count(*) > 1
order by count(*) desc

while (@cantidad > 0)
begin
	update #temp
	set valor_credito_farm = 0
	where id in
	(
		select max(id)
		from #temp
		group by id_guia,
		id_farm,
		valor_credito_farm
		having count(*) > 1
	)

	set @cantidad = @cantidad - 1
end

select idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
ID_GUIA,
idc_estado_guia,
idc_farm,
idc_ciudad,
idc_cliente_despacho,
nombre_farm,
nombre_tipo_farm,
codigo,
sum(unidades_vendidas) as unidades_vendidas,
sum(unidades_recibidas) as unidades_recibidas,
sum(full_vendidas) as full_vendidas,
sum(full_recibidas) as full_recibidas,
sum(estimated_boxes) as estimated_boxes,
sum(valor_cargo_incluido) as valor_cargo_incluido,
sum(valor_cargo_no_incluido) as valor_cargo_no_incluido,
valor_credito,
full_total_recibidas,
sum(gross_sales) + sum(valor_cargo_no_incluido) as "GROSS SALES",
impuesto_guia_no_cerrada,
impuesto_guia_cerrada,
valor_credito_farm as "FARM CREDIT",
(
	select top 1 t.valor_credito_farm
	from #temp as t
	where t.id_farm = #temp.id_farm
	and t.id_guia = #temp.id_guia
) as valor_credito_farm_2,
comision_farm,
sum(costo_total) as costo_total,
SUM(costo_total_vendidas) AS costo_total_vendidas into #resultado
from #temp
group by ID_GUIA,
idc_estado_guia,
idc_farm,
id_farm,
idc_cliente_despacho,
idc_ciudad,
nombre_farm,
nombre_tipo_farm,
codigo,
full_total_recibidas,
impuesto_guia_no_cerrada,
impuesto_guia_cerrada,
comision_farm,
valor_credito_farm,
valor_credito,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor

select idc_farm,
nombre_farm,
nombre_tipo_farm,
codigo,
idc_cliente_despacho,
idc_ciudad,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
sum(full_vendidas) as full_vendidas,
sum(full_recibidas) as full_recibidas,
sum(estimated_boxes) as estimated_boxes,
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
idc_cliente_despacho,
comision_farm,
nombre_tipo_farm,
codigo,
idc_estado_guia,
ID_GUIA,
"FARM CREDIT",
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor

select guia.idc_guia,
farm.idc_farm,
farm.nombre_farm,
tipo_farm.nombre_tipo_farm,
tipo_farm.codigo,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
cliente_despacho.idc_cliente_despacho,
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
farm,
tipo_farm,
tipo_flor,
variedad_flor,
grado_flor,
cliente_despacho
where cliente_despacho.id_despacho = factura.id_despacho
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and guia.id_guia = pieza.id_guia
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and farm.id_farm = pieza.id_farm
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and guia.fecha_guia between
@fecha_inicial and @fecha_final
group by factura.id_factura,
item_factura.id_item_factura,
farm.idc_farm,
farm.nombre_farm,
cliente_despacho.idc_cliente_despacho,
guia.id_guia,
guia.idc_guia,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
tipo_farm.nombre_tipo_farm,
tipo_farm.codigo


select idc_farm,
nombre_farm,
nombre_tipo_farm,
codigo,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
idc_cliente_despacho,
sum(valor_credito) + ((sum(valor_cargo) * sum(cantidad_credito)) / sum(unidades_por_pieza)) as valor_credito into #valor_fincas2
from #valor_fincas
where cantidad_credito > 0
group by idc_farm,
nombre_farm,
nombre_tipo_farm,
codigo,
idc_cliente_despacho,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor

select idc_farm,
nombre_farm,
nombre_tipo_farm,
codigo,
idc_ciudad,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
idc_cliente_despacho,
sum(full_vendidas) as "SOLD BOXES",
sum(full_recibidas) as "RECEIVED BOXES",
sum(estimated_boxes) as estimated_boxes,
SUM(unidades_vendidas) AS UNITS,
SUM("GROSS COST") AS "GROSS COST",
SUM("FARM CREDIT") AS "FARM CREDIT",
SUM("GROSS COST") + SUM("FARM CREDIT") AS "NET COST",
case
	when SUM(unidades_vendidas) = 0 then 0
	else (SUM("GROSS COST") + SUM("FARM CREDIT")) / SUM(unidades_vendidas)
end AS "COST AVERAGE",
SUM(FREIGHT) as FREIGHT,
case
	when sum(full_vendidas) = 0 then 0
	else SUM(FREIGHT) / sum(full_vendidas)
end AS "FREIGHT BY BOX",
sum("GROSS SALES") as "GROSS SALES",
SUM("INVENTORY COST") AS "INVENTORY COST" into #resultado3
FROM #RESULTADO2
GROUP BY idc_farm,
nombre_farm,
idc_ciudad,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
idc_cliente_despacho,
nombre_tipo_farm,
codigo

alter table #resultado3
add valor_credito decimal(20,4)

update #resultado3
SET valor_credito = ISNULL(#valor_fincas2.valor_credito, 0)
from #valor_fincas2
where #valor_fincas2.idc_farm = #resultado3.idc_farm
and #valor_fincas2.idc_tipo_flor = #resultado3.idc_tipo_flor
and #valor_fincas2.idc_variedad_flor = #resultado3.idc_variedad_flor
and #valor_fincas2.idc_grado_flor = #resultado3.idc_grado_flor
and #valor_fincas2.idc_cliente_despacho = #resultado3.idc_cliente_despacho


select idc_farm,
nombre_farm,
nombre_tipo_farm,
codigo as codigo_tipo_farm,
idc_ciudad,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
isnull(idc_cliente_despacho, '') as idc_cliente_despacho,
"SOLD BOXES" as sold_boxes,
estimated_boxes,
UNITS,
"GROSS COST" as gross_cost,
"FARM CREDIT" as farm_credit,
FREIGHT,
"GROSS SALES" as gross_sales,
ISNULL(valor_credito, 0) as CREDITS,
isnull("RECEIVED BOXES", 0) - isnull("SOLD BOXES", 0) as INVENTORY_BOXES,
"INVENTORY COST" as inventory_cost
FROM #RESULTADO3
where isnull(idc_cliente_despacho, '') > = 
case
	when @idc_cliente_inicial = '' then '          '
	else @idc_cliente_inicial
end 
and isnull(idc_cliente_despacho, '') < = 
case
	when @idc_cliente_final = '' then 'ZZZZZZZZZZ'
	else @idc_cliente_final
end 
and idc_farm > = 
case
	when @idc_farm_inicial = '' then '  '
	else @idc_farm_inicial
end
and idc_farm < = 
case
	when @idc_farm_final = '' then 'ZZ'
	else @idc_farm_final
end
and idc_tipo_flor + idc_variedad_flor > =
case
	when @idc_variedad_flor_inicial = '' then '    '
	else @idc_variedad_flor_inicial
end
and idc_tipo_flor + idc_variedad_flor < =
case
	when @idc_variedad_flor_final = '' then 'ZZZZ'
	else @idc_variedad_flor_final
end
and codigo > =
case
	when @idc_tipo_farm_inicial = '' then ' '
	else @idc_tipo_farm_inicial
end
and codigo < =
case
	when @idc_tipo_farm_final = '' then 'Z'
	else @idc_tipo_farm_final
end
ORDER BY idc_farm,
nombre_farm,
nombre_tipo_farm,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
isnull(idc_cliente_despacho, '')

drop table #temp
drop table #resultado
DROP TABLE #RESULTADO2
DROP TABLE #RESULTADO3
drop table #valor_fincas
drop table #valor_fincas2