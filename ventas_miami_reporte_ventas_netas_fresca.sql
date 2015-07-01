set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/06/20
-- Description:	Se utiliza para generar el reporte de ventas netas en las comercializadoras
-- =============================================

alter PROCEDURE [dbo].[ventas_miami_reporte_ventas_netas_fresca] 

@fecha_inicial datetime,
@fecha_final datetime,
@idc_finca_inicial nvarchar(2),
@idc_finca_final nvarchar(2),
@idc_variedad_flor_inicial nvarchar(4),
@idc_variedad_flor_final nvarchar(4),
@idc_tipo_venta_inicial nvarchar(5),
@idc_tipo_venta_final nvarchar(5)

as

declare @fresca nvarchar(50),
@idc_finca_adicional nvarchar(2)

set @fresca = 'FRESCA FARMS'

select @idc_variedad_flor_inicial =
case
	when len(@idc_variedad_flor_inicial) = 0 then @idc_variedad_flor_inicial + '    '
	when len(@idc_variedad_flor_inicial) = 1 then @idc_variedad_flor_inicial + '   '
	when len(@idc_variedad_flor_inicial) = 2 then @idc_variedad_flor_inicial + '  '
	when len(@idc_variedad_flor_inicial) = 3 then @idc_variedad_flor_inicial + ' '
	else @idc_variedad_flor_inicial
end,
@idc_variedad_flor_final =
case
	when len(@idc_variedad_flor_final) = 0 then @idc_variedad_flor_final + '    '
	when len(@idc_variedad_flor_final) = 1 then @idc_variedad_flor_final + '   '
	when len(@idc_variedad_flor_final) = 2 then @idc_variedad_flor_final + '  '
	when len(@idc_variedad_flor_final) = 3 then @idc_variedad_flor_final + ' '
	else @idc_variedad_flor_final
end

set @idc_finca_inicial = replace(@idc_finca_inicial, ' ', '0')
set @idc_finca_final = replace(@idc_finca_final, ' ', 'Z')
set @idc_variedad_flor_inicial = replace(@idc_variedad_flor_inicial, ' ', '0')
set @idc_variedad_flor_final = replace(@idc_variedad_flor_final, ' ', 'Z')
set @idc_tipo_venta_inicial = replace(@idc_tipo_venta_inicial, ' ', '0')
set @idc_tipo_venta_final = replace(@idc_tipo_venta_final, ' ', 'Z')

if(@idc_finca_inicial = 'AM' or @idc_finca_inicial = 'AN' or @idc_finca_final = 'AM' or @idc_finca_final = 'AN')
begin
	set @idc_finca_adicional = 'MA'
end
else
begin
	set @idc_finca_adicional = ''
end

Select tipo_flor.id_tipo_flor,
idc_tipo_flor,
ltrim(rtrim(nombre_tipo_flor)) as nombre_tipo_flor,
id_variedad_flor,
idc_variedad_flor as idc_variedad_flor,
ltrim(rtrim(nombre_variedad_flor)) as nombre_variedad_flor into #variedad_flor
from bd_cultivo.bd_cultivo.dbo.tipo_flor,
bd_cultivo.bd_cultivo.dbo.variedad_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor

select tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
detalle_credito.valor_credito,
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
and factura.fecha_factura between
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and tipo_flor.idc_tipo_flor > = left(@idc_variedad_flor_inicial, 2)
and tipo_flor.idc_tipo_flor < = left(@idc_variedad_flor_final, 2)
and variedad_flor.idc_variedad_flor > = right(@idc_variedad_flor_inicial, 2)
and variedad_flor.idc_variedad_flor < = right(@idc_variedad_flor_final, 2)
and (
farm.idc_farm > = @idc_finca_inicial
and farm.idc_farm < = @idc_finca_final
or farm.idc_farm = @idc_finca_adicional
)
and tipo_factura.idc_tipo_factura > = @idc_tipo_venta_inicial
and tipo_factura.idc_tipo_factura < = @idc_tipo_venta_final
group by tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
detalle_credito.valor_credito,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
item_factura.id_item_factura

select id_tipo_flor,
id_variedad_flor,
id_item_factura,
sum(valor_credito) as valor_credito into #credito
from #credito_sin_agrupar
group by id_tipo_flor,
id_variedad_flor,
id_item_factura

select tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
item_factura.id_item_factura,
item_factura.cargo_incluido,
sum(pieza.unidades_por_pieza) as unidades_por_pieza,
count(pieza.id_pieza) as cantidad_piezas,
sum(tipo_caja.factor_a_full) as fulles,
item_factura.valor_unitario * sum(pieza.unidades_por_pieza) as valor,
isnull((
	select sum(detalle_credito.valor_credito)
	from credito,
	detalle_credito,
	tipo_credito,
	tipo_detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and tipo_credito.id_tipo_credito = credito.id_tipo_credito
	and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
), 0) as valor_credito,
isnull((
	select sum(cargo.valor_cargo)
	from cargo,
	tipo_cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
), 0) * count(pieza.id_pieza) as valor_cargo into #temp
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
and tipo_flor.idc_tipo_flor > = left(@idc_variedad_flor_inicial, 2)
and tipo_flor.idc_tipo_flor < = left(@idc_variedad_flor_final, 2)
and variedad_flor.idc_variedad_flor > = right(@idc_variedad_flor_inicial, 2)
and variedad_flor.idc_variedad_flor < = right(@idc_variedad_flor_final, 2)
and (
farm.idc_farm > = @idc_finca_inicial
and farm.idc_farm < = @idc_finca_final
or farm.idc_farm = @idc_finca_adicional
)
and tipo_factura.idc_tipo_factura > = @idc_tipo_venta_inicial
and tipo_factura.idc_tipo_factura < = @idc_tipo_venta_final
group by item_factura.valor_unitario,
item_factura.id_item_factura,
item_factura.cargo_incluido,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))

select id_tipo_flor,
id_variedad_flor,
sum(valor_credito) as valor_credito into #credito_resultado
from #credito
where not exists 
(
	select * 
	from #temp
	where #temp.id_item_factura = #credito.id_item_factura
)
group by id_tipo_flor,
id_variedad_flor

alter table #temp
add valor_primario decimal(20,4)

update #temp
set valor_primario = 
case
	when cargo_incluido = 1 then (valor + valor_credito - valor_cargo) 
	else (valor + valor_credito) 	
end

select #temp.idc_tipo_flor,
#temp.nombre_tipo_flor,
#temp.id_tipo_flor,
#temp.id_variedad_flor,
#temp.idc_variedad_flor,
#temp.nombre_variedad_flor,
Mapeo_Variedad_Flor_Natuflora.id_variedad_flor_natuflora as id_variedad_flor_mapeo,
sum(#temp.fulles) as fulles,
sum(#temp.unidades_por_pieza) as unidades,
sum(#temp.valor_primario) as valor_primario,
sum(#temp.valor_cargo) as cargo,
sum(#temp.valor_credito) as valor_credito into #resultado
from #temp left join Mapeo_Variedad_Flor_Natuflora on #temp.id_variedad_flor = Mapeo_Variedad_Flor_Natuflora.id_variedad_flor
group by #temp.id_tipo_flor,
#temp.id_variedad_flor,
Mapeo_Variedad_Flor_Natuflora.id_variedad_flor_natuflora,
#temp.idc_variedad_flor,
#temp.nombre_variedad_flor,
#temp.idc_tipo_flor,
#temp.nombre_tipo_flor

update #resultado
set valor_credito = #resultado.valor_credito + isnull(#credito_resultado.valor_credito, 0),
valor_primario = valor_primario + isnull(#credito_resultado.valor_credito, 0)
from #credito_resultado
where #resultado.id_tipo_flor = #credito_resultado.id_tipo_flor 
and #resultado.id_variedad_flor = #credito_resultado.id_variedad_flor

update #resultado
set idc_tipo_flor = #variedad_flor.idc_tipo_flor,
nombre_tipo_flor = #variedad_flor.nombre_tipo_flor,
idc_variedad_flor = #variedad_flor.idc_variedad_flor,
nombre_variedad_flor = #variedad_flor.nombre_variedad_flor
from #variedad_flor
where #resultado.id_variedad_flor_mapeo = #variedad_flor.id_variedad_flor

SELECT SUM(VALOR_CREDITO) AS VALOR_CREDITOS_PASADOS,
id_tipo_flor,
id_variedad_flor INTO #CREDITOS_PASADOS
FROM #credito_resultado
WHERE NOT EXISTS
(
	SELECT *
	FROM #resultado
	WHERE #resultado.id_tipo_flor = #credito_resultado.id_tipo_flor
	and #resultado.id_variedad_flor = #credito_resultado.id_variedad_flor
)
group by id_tipo_flor,
id_variedad_flor

update #resultado
set valor_primario = valor_primario + isnull(valor_creditos_pasados, 0)
from #CREDITOS_PASADOS
where #CREDITOS_PASADOS.id_tipo_flor = #resultado.id_tipo_flor 
and #CREDITOS_PASADOS.id_variedad_flor = #resultado.id_variedad_flor

drop table #temp
drop table #credito
drop table #credito_sin_agrupar
drop table #credito_resultado
DROP TABLE #CREDITOS_PASADOS

insert into bd_cultivo.bd_cultivo.dbo.reporte_ventas_netas 
(
	comercializadora,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	fulles,
	unidades,
	total,
	cargo
)
select @fresca as comercializadora,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
sum(fulles) as fulles,
sum(unidades) as unidades,
sum(valor_primario) + sum(cargo) as total,
sum(cargo) as cargo
from #resultado
group by idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor

drop table #resultado
drop table #variedad_flor