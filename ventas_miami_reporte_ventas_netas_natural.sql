set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/06/20
-- Description:	Se utiliza para generar el reporte de ventas netas en las comercializadoras
-- =============================================

alter PROCEDURE [dbo].[ventas_miami_reporte_ventas_netas_natural] 

@fecha_inicial datetime,
@fecha_final datetime,
@idc_tipo_venta_inicial nvarchar(5),
@idc_tipo_venta_final nvarchar(5),
@idc_finca_inicial_natural nvarchar(2),
@idc_finca_final_natural nvarchar(2),
@idc_variedad_flor_inicial_natural nvarchar(4),
@idc_variedad_flor_final_natural nvarchar(4)

as

declare @natural nvarchar(50)

set @natural = 'NATURAL FLOWERS'

select @idc_variedad_flor_inicial_natural =
case
	when len(@idc_variedad_flor_inicial_natural) = 0 then @idc_variedad_flor_inicial_natural + '    '
	when len(@idc_variedad_flor_inicial_natural) = 1 then @idc_variedad_flor_inicial_natural + '   '
	when len(@idc_variedad_flor_inicial_natural) = 2 then @idc_variedad_flor_inicial_natural + '  '
	when len(@idc_variedad_flor_inicial_natural) = 3 then @idc_variedad_flor_inicial_natural + ' '
	else @idc_variedad_flor_inicial_natural
end,
@idc_variedad_flor_final_natural =
case
	when len(@idc_variedad_flor_final_natural) = 0 then @idc_variedad_flor_final_natural + '    '
	when len(@idc_variedad_flor_final_natural) = 1 then @idc_variedad_flor_final_natural + '   '
	when len(@idc_variedad_flor_final_natural) = 2 then @idc_variedad_flor_final_natural + '  '
	when len(@idc_variedad_flor_final_natural) = 3 then @idc_variedad_flor_final_natural + ' '
	else @idc_variedad_flor_final_natural
end

set @idc_tipo_venta_inicial = replace(@idc_tipo_venta_inicial, ' ', '0')
set @idc_tipo_venta_final = replace(@idc_tipo_venta_final, ' ', 'Z')
set @idc_finca_inicial_natural = replace(@idc_finca_inicial_natural, ' ', '0')
set @idc_finca_final_natural = replace(@idc_finca_final_natural, ' ', 'Z')
set @idc_variedad_flor_inicial_natural = replace(@idc_variedad_flor_inicial_natural, ' ', '0')
set @idc_variedad_flor_final_natural = replace(@idc_variedad_flor_final_natural, ' ', 'Z')

/*datos traidos desde Natural*/
select tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
detalle_credito.valor_credito,
item_factura.id_item_factura into #credito_sin_agrupar_natural
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
and tipo_flor.idc_tipo_flor > = left(@idc_variedad_flor_inicial_natural, 2)
and tipo_flor.idc_tipo_flor < = left(@idc_variedad_flor_final_natural, 2)
and variedad_flor.idc_variedad_flor > = right(@idc_variedad_flor_inicial_natural, 2)
and variedad_flor.idc_variedad_flor < = right(@idc_variedad_flor_final_natural, 2)
and farm.idc_farm > = @idc_finca_inicial_natural
and farm.idc_farm < = @idc_finca_final_natural
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
sum(valor_credito) as valor_credito into #credito_natural
from #credito_sin_agrupar_natural
group by id_tipo_flor,
id_variedad_flor,
id_item_factura

select tipo_flor.id_tipo_flor,
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
), 0) * count(pieza.id_pieza) as valor_cargo into #temp_natural
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
and tipo_flor.idc_tipo_flor > = left(@idc_variedad_flor_inicial_natural, 2)
and tipo_flor.idc_tipo_flor < = left(@idc_variedad_flor_final_natural, 2)
and variedad_flor.idc_variedad_flor > = right(@idc_variedad_flor_inicial_natural, 2)
and variedad_flor.idc_variedad_flor < = right(@idc_variedad_flor_final_natural, 2)
and farm.idc_farm > = @idc_finca_inicial_natural
and farm.idc_farm < = @idc_finca_final_natural
and tipo_factura.idc_tipo_factura > = @idc_tipo_venta_inicial
and tipo_factura.idc_tipo_factura < = @idc_tipo_venta_final
group by item_factura.valor_unitario,
item_factura.id_item_factura,
item_factura.cargo_incluido,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor

select id_tipo_flor,
id_variedad_flor,
sum(valor_credito) as valor_credito into #credito_resultado_natural
from #credito_natural
where not exists 
(
	select * 
	from #temp_natural
	where #temp_natural.id_item_factura = #credito_natural.id_item_factura
)
group by id_tipo_flor,
id_variedad_flor

alter table #temp_natural
add valor_primario decimal(20,4)

update #temp_natural
set valor_primario = 
case
	when cargo_incluido = 1 then (valor + valor_credito - valor_cargo) 
	else (valor + valor_credito) 	
end

select #temp_natural.id_tipo_flor,
#temp_natural.id_variedad_flor,
sum(#temp_natural.fulles) as fulles,
sum(#temp_natural.unidades_por_pieza) as unidades,
sum(#temp_natural.valor_primario) as valor_primario,
sum(#temp_natural.valor_cargo) as cargo,
sum(#temp_natural.valor_credito) as valor_credito into #resultado_natural
from #temp_natural
group by #temp_natural.id_tipo_flor,
#temp_natural.id_variedad_flor

update #resultado_natural
set valor_credito = #resultado_natural.valor_credito + isnull(#credito_resultado_natural.valor_credito, 0),
valor_primario = valor_primario + isnull(#credito_resultado_natural.valor_credito, 0)
from #credito_resultado_natural
where #resultado_natural.id_tipo_flor = #credito_resultado_natural.id_tipo_flor 
and #resultado_natural.id_variedad_flor = #credito_resultado_natural.id_variedad_flor

SELECT SUM(VALOR_CREDITO) AS VALOR_CREDITOS_PASADOS,
id_tipo_flor,
id_variedad_flor INTO #CREDITOS_PASADOS_natural
FROM #credito_resultado_natural
WHERE NOT EXISTS
(
	SELECT *
	FROM #resultado_natural
	WHERE #resultado_natural.id_tipo_flor = #credito_resultado_natural.id_tipo_flor
	and #resultado_natural.id_variedad_flor = #credito_resultado_natural.id_variedad_flor
)
group by id_tipo_flor,
id_variedad_flor

update #resultado_natural
set valor_primario = valor_primario + isnull(valor_creditos_pasados, 0)
from #CREDITOS_PASADOS_natural
where #CREDITOS_PASADOS_natural.id_tipo_flor = #resultado_natural.id_tipo_flor 
and #CREDITOS_PASADOS_natural.id_variedad_flor = #resultado_natural.id_variedad_flor

drop table #temp_natural
drop table #credito_natural
drop table #credito_sin_agrupar_natural
drop table #credito_resultado_natural
DROP TABLE #CREDITOS_PASADOS_natural

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
select @natural as comercializadora,
tipo_flor.idc_tipo_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
sum(fulles) as fulles,
sum(unidades) as unidades,
sum(valor_primario) + sum(cargo) as total,
sum(cargo) as cargo
from #resultado_natural,
tipo_flor,
variedad_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = #resultado_natural.id_tipo_flor
and variedad_flor.id_variedad_flor = #resultado_natural.id_variedad_flor
group by tipo_flor.idc_tipo_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor))

drop table #resultado_natural