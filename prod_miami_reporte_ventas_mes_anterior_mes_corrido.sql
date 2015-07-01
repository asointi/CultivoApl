set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[prod_miami_reporte_ventas_mes_anterior_mes_corrido]

@tipo_reporte int

AS

-- @tipo_reporte
-- 1. Mes Actual
-- 2. Mes Anterior
-- 3. Mes Actual Año Anterior
-- 4. Mes Anterior Año Anterior

declare @fecha_inicial datetime,
@fecha_final datetime,
@nombre_base_datos nvarchar(50),
@fresca nvarchar(50),
@natural nvarchar(50),
@idc_farm_inicial nvarchar(2),
@idc_farm_final nvarchar(2)

select @fecha_inicial =
case
	when @tipo_reporte = 1 then DATEADD(mm, DATEDIFF(mm, 0, GETDATE()-1), 0)
	when @tipo_reporte = 2 then DATEADD(mm,-1,DATEADD(mm,DATEDIFF(mm,0,GETDATE()-1),0))
	when @tipo_reporte = 3 then DATEADD(mm,-12,DATEADD(mm,DATEDIFF(mm,0,GETDATE()-1),0))
	when @tipo_reporte = 4 then DATEADD(mm,-13,DATEADD(mm,DATEDIFF(mm,0,GETDATE()-1),0))
end,
@fecha_final =
case
	when @tipo_reporte = 1 then convert(nvarchar,getdate()-1,103)
	when @tipo_reporte = 2 then DATEADD(ms,-3,DATEADD(mm,0,DATEADD(mm,DATEDIFF(mm,0,GETDATE()-1),0)))
	when @tipo_reporte = 3 then dateadd(mm, -12, convert(nvarchar,getdate()-1,103))
	when @tipo_reporte = 4 then DATEADD(ms,-3,DATEADD(mm,-12,DATEADD(mm,DATEDIFF(mm,0,GETDATE()-1),0)))
end

set @nombre_base_datos = DB_NAME()
set @fresca = 'BD_Fresca_Cubes'
set @natural = 'BD_NF_Cubes'

select @idc_farm_inicial =
case
	when @nombre_base_datos = 'BD_NF_Cubes' then 'N '
	when @nombre_base_datos = 'BD_Fresca_Cubes' then 'AM'
end,
@idc_farm_final =
case
	when @nombre_base_datos = 'BD_NF_Cubes' then 'NZ'
	when @nombre_base_datos = 'BD_Fresca_Cubes' then 'AQ'
end

select farm.id_farm,
tipo_flor.id_tipo_flor,
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
guia,
tipo_flor,
variedad_flor,
farm,
factura
where credito.id_credito = detalle_credito.id_credito
and item_factura.id_item_factura = detalle_credito.id_item_factura
and tipo_credito.id_tipo_credito = credito.id_tipo_credito
and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and pieza.id_pieza = detalle_item_factura.id_pieza
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and farm.id_farm = pieza.id_farm
and factura.id_factura = credito.id_factura
and factura.id_factura = item_factura.id_factura
and guia.id_guia = detalle_credito.id_guia
and farm.idc_farm >= @idc_farm_inicial
and farm.idc_farm <= @idc_farm_final
and guia.fecha_guia > =
case
	when @nombre_base_datos = @fresca then @fecha_inicial
	else '01/01/1900'
end
and guia.fecha_guia < =
case
	when @nombre_base_datos = @fresca then @fecha_final
	else '31/12/2030'
end
and credito.fecha_numero_credito > =
case
	when @nombre_base_datos = @natural then @fecha_inicial
	else '01/01/1900'
end
and credito.fecha_numero_credito < =
case
	when @nombre_base_datos = @natural then @fecha_final
	else '31/12/2030'
end
group by farm.id_farm,
tipo_flor.id_tipo_flor,
detalle_credito.valor_credito,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
item_factura.id_item_factura

select id_farm,
id_tipo_flor,
id_item_factura,
sum(valor_credito) as valor_credito into #credito
from #credito_sin_agrupar
group by id_farm,
id_tipo_flor,
id_item_factura

select farm.id_farm,
tipo_flor.id_tipo_flor,
farm.idc_farm,
item_factura.id_item_factura,
item_factura.cargo_incluido,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
sum(pieza.unidades_por_pieza) as unidades_por_pieza,
count(pieza.id_pieza) as cantidad_piezas,
sum(tipo_caja.factor_a_full) as fulles,
item_factura.valor_unitario * sum(pieza.unidades_por_pieza) as valor,
isnull((
	select sum(detalle_credito.valor_credito)
	from credito,
	detalle_credito,
	tipo_credito,
	tipo_detalle_credito,
	guia
	where credito.id_credito = detalle_credito.id_credito
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and tipo_credito.id_tipo_credito = credito.id_tipo_credito
	and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
	and guia.id_guia = detalle_credito.id_guia
	and guia.fecha_guia > =
	case
		when @nombre_base_datos = @fresca then @fecha_inicial
		else '01/01/1900'
	end
	and guia.fecha_guia < =
	case
		when @nombre_base_datos = @fresca then @fecha_final
		else '31/12/2030'
	end
	and credito.fecha_numero_credito > =
	case
		when @nombre_base_datos = @natural then @fecha_inicial
		else '01/01/1900'
	end
	and credito.fecha_numero_credito < =
	case
		when @nombre_base_datos = @natural then @fecha_final
		else '31/12/2030'
	end
), 0) as valor_credito,
isnull((
	select sum(cargo.valor_cargo)
	from cargo,
	tipo_cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
	and tipo_cargo.idc_tipo_cargo = 'BC'
), 0) * count(pieza.id_pieza) as valor_cargo_box_charge,
isnull((
	select sum(cargo.valor_cargo)
	from cargo,
	tipo_cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
	and tipo_cargo.idc_tipo_cargo = 'FS'
), 0) * count(pieza.id_pieza) as valor_cargo_fuel_surchage into #temp
from pieza,
detalle_item_factura,
item_factura,
factura,
farm,
guia,
tipo_caja,
caja,
tipo_flor,
variedad_flor
where farm.id_farm = pieza.id_farm
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and caja.id_caja = pieza.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and guia.id_guia = pieza.id_guia
and guia.fecha_guia > =
case
	when @nombre_base_datos = @fresca then @fecha_inicial
	else '01/01/1900'
end
and guia.fecha_guia < =
case
	when @nombre_base_datos = @fresca then @fecha_final
	else '31/12/2030'
end
and factura.fecha_factura > =
case
	when @nombre_base_datos = @natural then @fecha_inicial
	else '01/01/1900'
end
and factura.fecha_factura < =
case
	when @nombre_base_datos = @natural then @fecha_final
	else '31/12/2030'
end
and farm.idc_farm >= @idc_farm_inicial
and farm.idc_farm <= @idc_farm_final
group by item_factura.valor_unitario,
item_factura.id_item_factura,
item_factura.cargo_incluido,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
farm.idc_farm,
farm.id_farm,
tipo_flor.id_tipo_flor

select id_farm,
id_tipo_flor,
sum(valor_credito) as valor_credito into #credito_resultado
from #credito
where not exists 
(
	select * 
	from #temp
	where #temp.id_item_factura = #credito.id_item_factura
)
group by id_farm,
id_tipo_flor


alter table #temp
add valor_primario decimal(20,4),
valor_primario1 decimal(20,4),
valor_credito1 decimal(20,4)

update #temp
set valor_primario = 
case
	when cargo_incluido = 1 then (valor + valor_credito - valor_cargo_box_charge - valor_cargo_fuel_surchage) 
	else (valor + valor_credito) 	
end

select #temp.id_farm,
#temp.id_tipo_flor,
#temp.idc_farm AS FARM,
#temp.idc_tipo_flor + SPACE(1) + #temp.nombre_tipo_flor AS "FLOWER TYPE",
sum(#temp.fulles) as BOXES,
sum(#temp.unidades_por_pieza) as UNITS,
sum(#temp.valor_primario) as "VALUE",
sum(#temp.valor_cargo_box_charge) as "BOX CHARGE",
sum(#temp.valor_cargo_fuel_surchage) as "OTHER CHARGES",
sum(#temp.valor_credito) as CREDITS into #resultado
from #temp 
group by #temp.idc_farm,
#temp.idc_tipo_flor,
#temp.nombre_tipo_flor,
#temp.id_farm,
#temp.id_tipo_flor
order by #temp.idc_farm,
#temp.idc_tipo_flor

update #resultado
set CREDITS = #resultado.CREDITS + isnull(#credito_resultado.valor_credito, 0),
"VALUE" = "VALUE" + isnull(#credito_resultado.valor_credito, 0)
from #credito_resultado 
where #resultado.id_tipo_flor = #credito_resultado.id_tipo_flor 
and #resultado.id_farm = #credito_resultado.id_farm

SELECT SUM(VALOR_CREDITO) AS VALOR_CREDITOS_PASADOS INTO #CREDITOS_PASADOS
FROM #credito_resultado 
WHERE NOT EXISTS
(
	SELECT *
	FROM #resultado
	WHERE #resultado.ID_TIPO_FLOR = #credito_resultado.ID_TIPO_FLOR
	AND #resultado.ID_FARM = #credito_resultado.ID_FARM
)

select @fecha_inicial as fecha_inicial,
@fecha_final as fecha_final,
@idc_farm_inicial as finca_inicial,
@idc_farm_final as finca_final,
sum(BOXES) as BOXES,
sum(UNITS) as UNITS,
sum("VALUE") + (select isnull(VALOR_CREDITOS_PASADOS, 0) from  #CREDITOS_PASADOS) as "VALUE",
(sum("VALUE") + (select isnull(VALOR_CREDITOS_PASADOS, 0) from  #CREDITOS_PASADOS))/sum(UNITS) as "UNITS VALUE",
sum("BOX CHARGE") as "BOX CHARGES",
sum("OTHER CHARGES") as "OTHER CHARGES",
sum("VALUE")+ (select isnull(VALOR_CREDITOS_PASADOS, 0) from  #CREDITOS_PASADOS) + sum("BOX CHARGE")+sum("OTHER CHARGES") AS TOTAL,
(sum("VALUE")+ (select isnull(VALOR_CREDITOS_PASADOS, 0) from  #CREDITOS_PASADOS) + sum("BOX CHARGE")+sum("OTHER CHARGES"))/sum(UNITS) AS AVERAGE,
sum(CREDITS) + (select isnull(VALOR_CREDITOS_PASADOS, 0) from  #CREDITOS_PASADOS) as CREDITS
from #resultado

drop table #temp
drop table #credito
drop table #credito_sin_agrupar
drop table #resultado
drop table #credito_resultado
DROP TABLE #CREDITOS_PASADOS
