set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/10/10
-- Description:	genera los datos para un reporte comparativo de ventas entre Fresca y Natural
-- =============================================

alter PROCEDURE [dbo].[ventas_miami_reporte_precios_por_fecha_ano_anterior] 

as

declare @fecha_inicial datetime,
@fecha_final datetime,
@comercializadora nvarchar(50),
@nombre_base_datos nvarchar(50),
@id_farm nvarchar(50),
@sql varchar(8000)

create table #id_finca (id_farm int)

set @nombre_base_datos = DB_NAME()

if(@nombre_base_datos = 'BD_NF')
begin
	set @comercializadora = 'NATURAL FLOWERS'

	insert into #id_finca (id_farm)
	select farm.id_farm
	from farm
	where finca_propia = 1
end
else
if(@nombre_base_datos = 'BD_FRESCA')
begin
	set @comercializadora = 'FRESCA FARMS'

	insert into #id_finca (id_farm)
	select farm.id_farm
	from farm
	where finca_propia = 1	
end

set @fecha_inicial = CONVERT(VARCHAR(25),dateadd(yyyy, -1,DATEADD(dd,-(DAY(DATEADD(mm,-1,getdate()))-1),DATEADD(mm,-1,getdate()))),103)
set @fecha_final = dateadd(yyyy, -1,convert(datetime, convert(nvarchar, getdate()-1, 103)))

select credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
detalle_credito.valor_credito,
credito.fecha_numero_credito,
item_factura.id_item_factura into #credito_sin_agrupar
from credito,
detalle_credito,
tipo_credito,
tipo_detalle_credito,
item_factura,
detalle_item_factura,
pieza,
farm,
tipo_flor,
factura,
tipo_factura,
variedad_flor
where farm.id_farm = pieza.id_farm
and tipo_factura.id_tipo_factura = factura.id_tipo_factura
and credito.id_credito = detalle_credito.id_credito
and item_factura.id_item_factura = detalle_credito.id_item_factura
and tipo_credito.id_tipo_credito = credito.id_tipo_credito
and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and pieza.id_pieza = detalle_item_factura.id_pieza
and factura.id_factura = credito.id_factura
and factura.id_factura = item_factura.id_factura
and credito.fecha_numero_credito between 
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and exists
(
	select * 
	from #id_finca
	where #id_finca.id_farm = farm.id_farm
)
group by credito.fecha_numero_credito,
detalle_credito.valor_credito,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
item_factura.id_item_factura

select fecha_numero_credito,
id_item_factura,
sum(valor_credito) as valor_credito into #credito
from #credito_sin_agrupar
group by fecha_numero_credito,
id_item_factura

select tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
item_factura.id_item_factura,
item_factura.cargo_incluido,
sum(pieza.unidades_por_pieza) as unidades_por_pieza,
count(pieza.id_pieza) as cantidad_piezas,
sum(tipo_caja.factor_a_full) as fulles,
item_factura.valor_unitario * sum(pieza.unidades_por_pieza) as valor,
0 as valor_credito,
isnull((
	select sum(cargo.valor_cargo)
	from cargo,
	tipo_cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
), 0) * count(pieza.id_pieza) as valor_cargo,
factura.fecha_factura into #temp
from pieza,
detalle_item_factura,
item_factura,
factura,
tipo_caja,
farm,
tipo_factura,
caja,
tipo_flor,
variedad_flor
where farm.id_farm = pieza.id_farm
and tipo_factura.id_tipo_factura = factura.id_tipo_factura
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and caja.id_caja = pieza.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and factura.fecha_factura between 
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and exists
(
	select * 
	from #id_finca
	where #id_finca.id_farm = farm.id_farm
)
group by item_factura.valor_unitario,
item_factura.id_item_factura,
item_factura.cargo_incluido,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
factura.fecha_factura

select fecha_numero_credito,
sum(valor_credito) as valor_credito into #credito_resultado
from #credito
group by fecha_numero_credito

alter table #temp
add valor_primario decimal(20,4)

update #temp
set valor_primario = 
case
	when cargo_incluido = 1 then (valor + valor_credito - valor_cargo) 
	else (valor + valor_credito) 	
end

select #temp.fecha_factura,
sum(#temp.fulles) as fulles,
sum(#temp.unidades_por_pieza) as unidades,
sum(#temp.valor_primario) as valor_primario,
sum(#temp.valor_cargo) as cargo,
sum(#temp.valor_credito) as valor_credito into #resultado
from #temp 
group by #temp.fecha_factura

SELECT SUM(VALOR_CREDITO) AS VALOR_CREDITOS_PASADOS,
fecha_numero_credito INTO #CREDITOS_PASADOS
FROM #credito_resultado
WHERE NOT EXISTS
(
	SELECT *
	FROM #resultado
	WHERE #resultado.fecha_factura = #credito_resultado.fecha_numero_credito
)
group by fecha_numero_credito

INSERT INTO #resultado (fecha_factura,fulles,unidades,valor_primario,cargo,valor_credito)
SELECT fecha_numero_credito,
0,
0,
0,
0,
0
FROM #CREDITOS_PASADOS

update #resultado
set valor_credito = #resultado.valor_credito + isnull(#credito_resultado.valor_credito, 0),
valor_primario = valor_primario + isnull(#credito_resultado.valor_credito, 0)
from #credito_resultado
where #resultado.fecha_factura = #credito_resultado.fecha_numero_credito 

insert into bd_cultivo.bd_cultivo.dbo.detalle_facturacion_dia_por_fecha_ano_anterior (comercializadora, fecha, fulles, unidades, valor)
select @comercializadora as comercializadora,
fecha_factura,
sum(fulles) as fulles,
sum(unidades) as unidades,
sum(valor_primario) + sum(cargo) as total
from #resultado
group by fecha_factura

drop table #temp
drop table #credito
drop table #credito_sin_agrupar
drop table #credito_resultado
DROP TABLE #CREDITOS_PASADOS
drop table #resultado
drop table #id_finca