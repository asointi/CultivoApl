set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012/06/07
-- Description:	Se utiliza para extraer los datos presentados en un reporte que visualiza las ventas por grado de flor de las ultimas 52 semanas
-- =============================================

alter PROCEDURE [dbo].[prod_miami_reporte_ventas_ultimo_ano_por_grado] 

@id_tipo_flor_fresca int,
@id_variedad_flor_fresca int,
@fecha datetime,
@id_grado_flor_fresca nvarchar(512),
@id_tipo_flor_natural int,
@id_variedad_flor_natural int,
@id_grado_flor_natural nvarchar(512)

as

create table #grados (id int)

declare @sql varchar(8000),
@fecha_inicial datetime,
@fecha_final datetime,
@fresca nvarchar(50),
@natural nvarchar(50),
@nombre_base_datos nvarchar(30),
@semana int,
@fecha_inicial_semana datetime,
@fecha_final_semana datetime

set language spanish
set @nombre_base_datos = DB_NAME()
set @fresca = 'Fresca'
set @natural = 'Natural'
set @fecha_inicial = dateadd(wk, -52, dateadd(dd, -7, DATEADD(DAY, 1- DATEPART(DW, @fecha), @fecha)))
set @fecha_final = dateadd(dd, -7, DATEADD(DAY, 7- DATEPART(DW, @fecha), @fecha))

create table #fechas
(
	id int identity(1,1),
	fecha_inicial datetime,
	fecha_final datetime,
	ano int,
	semana int
)

set @semana = 0
set @fecha_inicial_semana = dateadd(dd, -6, @fecha_final)
set @fecha_final_semana = @fecha_final

while (@semana < 53)
begin
	insert into #fechas (fecha_inicial, fecha_final, ano, semana)
	select @fecha_inicial_semana, @fecha_final_semana, datepart(yyyy, @fecha_inicial_semana), datepart(wk, @fecha_inicial_semana)

	set @fecha_inicial_semana = dateadd(dd, -7, @fecha_inicial_semana)
	set @fecha_final_semana = dateadd(dd, -7, @fecha_final_semana)

	set @semana = @semana + 1
end


/*Realizar primero el recorrido por la informacion de FRESCA FARMS*/
/******************************************************************/
/******************************************************************/
/******************************************************************/
	
/*crear la insercion para los valores separados por comas*/
select @sql = 'insert into #grados select '+	replace(@id_grado_flor_fresca,',',' union all select ')

/*cargar todos los valores de la variable @id_grado_flor en la tabla temporal*/
exec (@SQL)

select tipo_flor.id_tipo_flor,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
datepart(wk, factura.fecha_factura) as semana,
datepart(yyyy, factura.fecha_factura) as ano,
detalle_credito.valor_credito,
item_factura.id_item_factura into #credito_sin_agrupar_fresca
from bd_fresca.dbo.credito,
bd_fresca.dbo.detalle_credito,
bd_fresca.dbo.tipo_credito,
bd_fresca.dbo.tipo_detalle_credito,
bd_fresca.dbo.item_factura,
bd_fresca.dbo.detalle_item_factura,
bd_fresca.dbo.pieza,
bd_fresca.dbo.tipo_flor,
bd_fresca.dbo.grado_flor,
bd_fresca.dbo.factura,
bd_fresca.dbo.variedad_flor
where credito.id_credito = detalle_credito.id_credito
and item_factura.id_item_factura = detalle_credito.id_item_factura
and tipo_credito.id_tipo_credito = credito.id_tipo_credito
and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and pieza.id_pieza = detalle_item_factura.id_pieza
and factura.id_factura = credito.id_factura
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = @id_tipo_flor_fresca
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor_fresca = 0 then 1
	else @id_variedad_flor_fresca
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor_fresca = 0 then 9999999
	else @id_variedad_flor_fresca
end
and exists
(
	select *
	from #grados
	where #grados.id = grado_flor.id_grado_flor
)
group by tipo_flor.id_tipo_flor,
detalle_credito.valor_credito,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
item_factura.id_item_factura,
datepart(wk, factura.fecha_factura),
datepart(yyyy, factura.fecha_factura)

select id_tipo_flor,
id_item_factura,
semana,
ano,
sum(valor_credito) as valor_credito into #credito_fresca
from #credito_sin_agrupar_fresca
group by id_tipo_flor,
id_item_factura,
ano,
semana

select tipo_flor.id_tipo_flor,
item_factura.id_item_factura,
item_factura.cargo_incluido,
datepart(wk, factura.fecha_factura) as semana,
datepart(yyyy, factura.fecha_factura) as ano,
sum(pieza.unidades_por_pieza) as unidades_por_pieza,
count(pieza.id_pieza) as cantidad_piezas,
sum(tipo_caja.factor_a_full) as fulles,
item_factura.valor_unitario * sum(pieza.unidades_por_pieza) as valor,
isnull((
	select sum(detalle_credito.valor_credito)
	from bd_fresca.dbo.credito,
	bd_fresca.dbo.detalle_credito,
	bd_fresca.dbo.tipo_credito,
	bd_fresca.dbo.tipo_detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and tipo_credito.id_tipo_credito = credito.id_tipo_credito
	and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
), 0) as valor_credito into #temp_fresca
from bd_fresca.dbo.pieza,
bd_fresca.dbo.detalle_item_factura,
bd_fresca.dbo.item_factura,
bd_fresca.dbo.factura,
bd_fresca.dbo.tipo_caja,
bd_fresca.dbo.caja,
bd_fresca.dbo.tipo_flor,
bd_fresca.dbo.grado_flor,
bd_fresca.dbo.variedad_flor
where pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and caja.id_caja = pieza.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and factura.fecha_factura between
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = @id_tipo_flor_fresca
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor_fresca = 0 then 1
	else @id_variedad_flor_fresca
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor_fresca = 0 then 9999999
	else @id_variedad_flor_fresca
end
and exists
(
	select *
	from #grados
	where #grados.id = grado_flor.id_grado_flor
)
group by item_factura.valor_unitario,
item_factura.id_item_factura,
item_factura.cargo_incluido,
tipo_flor.id_tipo_flor,
datepart(wk, factura.fecha_factura),
datepart(yyyy, factura.fecha_factura)

select item_factura.id_item_factura,
sum(cargo.valor_cargo) as valor_cargo into #cargo_fresca
from cargo,
tipo_cargo,	
item_factura,
factura
where item_factura.id_item_factura = cargo.id_item_factura
and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between
@fecha_inicial and @fecha_final
group by item_factura.id_item_factura

alter table #temp_fresca
add valor_cargo decimal(20,4),
valor_primario decimal(20,4)

update #temp_fresca
set valor_cargo = #cargo_fresca.valor_cargo * #temp_fresca.cantidad_piezas
from #cargo_fresca
where #cargo_fresca.id_item_factura = #temp_fresca.id_item_factura

select id_tipo_flor,
ano,
semana,
sum(valor_credito) as valor_credito into #credito_resultado_fresca
from #credito_fresca
where not exists 
(
	select * 
	from #temp_fresca
	where #temp_fresca.id_item_factura = #credito_fresca.id_item_factura
)
group by id_tipo_flor,
ano,
semana

update #temp_fresca
set valor_primario = 
case
	when cargo_incluido = 1 then (valor + valor_credito - isnull(valor_cargo, 0)) 
	else (valor + valor_credito) 	
end

select #temp_fresca.id_tipo_flor,
#temp_fresca.ano,
#temp_fresca.semana,
sum(#temp_fresca.fulles) as fulles,
sum(#temp_fresca.unidades_por_pieza) as unidades,
sum(#temp_fresca.valor_primario) as valor_primario,
sum(#temp_fresca.valor_cargo) as valor_cargo,
sum(#temp_fresca.valor_credito) as valor_credito into #resultado_fresca
from #temp_fresca 
group by #temp_fresca.id_tipo_flor,
#temp_fresca.ano,
#temp_fresca.semana
order by #temp_fresca.id_tipo_flor,
#temp_fresca.ano,
#temp_fresca.semana

update #resultado_fresca
set valor_credito = #resultado_fresca.valor_credito + isnull(#credito_resultado_fresca.valor_credito, 0),
valor_primario = valor_primario + isnull(#credito_resultado_fresca.valor_credito, 0)
from #credito_resultado_fresca
where #resultado_fresca.id_tipo_flor = #credito_resultado_fresca.id_tipo_flor 
and #resultado_fresca.ano = #credito_resultado_fresca.ano
and #resultado_fresca.semana = #credito_resultado_fresca.semana

SELECT SUM(VALOR_CREDITO) AS VALOR_CREDITOS_PASADOS,
id_tipo_flor,
semana,
ano INTO #CREDITOS_PASADOS_fresca
FROM #credito_resultado_fresca 
WHERE NOT EXISTS
(
	SELECT *
	FROM #resultado_fresca
	WHERE #resultado_fresca.id_tipo_flor = #credito_resultado_fresca.id_tipo_flor
	and #resultado_fresca.ano = #credito_resultado_fresca.ano
	and #resultado_fresca.semana = #credito_resultado_fresca.semana
)
group by id_tipo_flor,
semana,
ano

update #resultado_fresca
set valor_primario = valor_primario + isnull(valor_creditos_pasados, 0)
from #CREDITOS_PASADOS_fresca
where #CREDITOS_PASADOS_fresca.id_tipo_flor = #resultado_fresca.id_tipo_flor 
and #CREDITOS_PASADOS_fresca.ano = #resultado_fresca.ano
and #CREDITOS_PASADOS_fresca.semana = #resultado_fresca.semana

delete from #grados 

drop table #temp_fresca
drop table #credito_fresca
drop table #credito_sin_agrupar_fresca
drop table #credito_resultado_fresca
DROP TABLE #CREDITOS_PASADOS_fresca
drop table #cargo_fresca

/******************************************************************/
/******************************************************************/
/******************************************************************/

/*Realizar el recorrido por NATURAL FLOWERS*/
/******************************************************************/
/******************************************************************/
/******************************************************************/

/*crear la insercion para los valores separados por comas*/
select @sql = 'insert into #grados select '+	replace(@id_grado_flor_natural,',',' union all select ')

/*cargar todos los valores de la variable @id_grado_flor en la tabla temporal*/
exec (@SQL)

select tipo_flor.id_tipo_flor,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
datepart(wk, factura.fecha_factura) as semana,
datepart(yyyy, factura.fecha_factura) as ano,
detalle_credito.valor_credito,
item_factura.id_item_factura into #credito_sin_agrupar_natural
from bd_nf.bd_nf.dbo.credito,
bd_nf.bd_nf.dbo.detalle_credito,
bd_nf.bd_nf.dbo.tipo_credito,
bd_nf.bd_nf.dbo.tipo_detalle_credito,
bd_nf.bd_nf.dbo.item_factura,
bd_nf.bd_nf.dbo.detalle_item_factura,
bd_nf.bd_nf.dbo.pieza,
bd_nf.bd_nf.dbo.tipo_flor,
bd_nf.bd_nf.dbo.grado_flor,
bd_nf.bd_nf.dbo.factura,
bd_nf.bd_nf.dbo.variedad_flor
where credito.id_credito = detalle_credito.id_credito
and item_factura.id_item_factura = detalle_credito.id_item_factura
and tipo_credito.id_tipo_credito = credito.id_tipo_credito
and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and pieza.id_pieza = detalle_item_factura.id_pieza
and factura.id_factura = credito.id_factura
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = @id_tipo_flor_natural
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor_natural = 0 then 1
	else @id_variedad_flor_natural
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor_natural = 0 then 9999999
	else @id_variedad_flor_natural
end
and exists
(
	select *
	from #grados
	where #grados.id = grado_flor.id_grado_flor
)
group by tipo_flor.id_tipo_flor,
detalle_credito.valor_credito,
credito.idc_numero_credito,
detalle_credito.id_detalle_credito,
item_factura.id_item_factura,
datepart(wk, factura.fecha_factura),
datepart(yyyy, factura.fecha_factura)

select id_tipo_flor,
id_item_factura,
semana,
ano,
sum(valor_credito) as valor_credito into #credito_natural
from #credito_sin_agrupar_natural
group by id_tipo_flor,
id_item_factura,
ano,
semana

select tipo_flor.id_tipo_flor,
item_factura.id_item_factura,
item_factura.cargo_incluido,
datepart(wk, factura.fecha_factura) as semana,
datepart(yyyy, factura.fecha_factura) as ano,
sum(pieza.unidades_por_pieza) as unidades_por_pieza,
count(pieza.id_pieza) as cantidad_piezas,
sum(tipo_caja.factor_a_full) as fulles,
item_factura.valor_unitario * sum(pieza.unidades_por_pieza) as valor,
isnull((
	select sum(detalle_credito.valor_credito)
	from bd_nf.bd_nf.dbo.credito,
	bd_nf.bd_nf.dbo.detalle_credito,
	bd_nf.bd_nf.dbo.tipo_credito,
	bd_nf.bd_nf.dbo.tipo_detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and tipo_credito.id_tipo_credito = credito.id_tipo_credito
	and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
), 0) as valor_credito into #temp_natural
from bd_nf.bd_nf.dbo.pieza,
bd_nf.bd_nf.dbo.detalle_item_factura,
bd_nf.bd_nf.dbo.item_factura,
bd_nf.bd_nf.dbo.factura,
bd_nf.bd_nf.dbo.tipo_caja,
bd_nf.bd_nf.dbo.caja,
bd_nf.bd_nf.dbo.tipo_flor,
bd_nf.bd_nf.dbo.grado_flor,
bd_nf.bd_nf.dbo.variedad_flor
where pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and caja.id_caja = pieza.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and factura.fecha_factura between
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = @id_tipo_flor_natural
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and variedad_flor.id_variedad_flor > =
case
	when @id_variedad_flor_natural = 0 then 1
	else @id_variedad_flor_natural
end
and variedad_flor.id_variedad_flor < =
case
	when @id_variedad_flor_natural = 0 then 9999999
	else @id_variedad_flor_natural
end
and exists
(
	select *
	from #grados
	where #grados.id = grado_flor.id_grado_flor
)
group by item_factura.valor_unitario,
item_factura.id_item_factura,
item_factura.cargo_incluido,
tipo_flor.id_tipo_flor,
datepart(wk, factura.fecha_factura),
datepart(yyyy, factura.fecha_factura)

select item_factura.id_item_factura,
sum(cargo.valor_cargo) as valor_cargo into #cargo_natural
from bd_nf.bd_nf.dbo.cargo,
bd_nf.bd_nf.dbo.tipo_cargo,	
bd_nf.bd_nf.dbo.item_factura,
bd_nf.bd_nf.dbo.factura
where item_factura.id_item_factura = cargo.id_item_factura
and tipo_cargo.id_tipo_cargo = cargo.id_tipo_cargo
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between
@fecha_inicial and @fecha_final
group by item_factura.id_item_factura

alter table #temp_natural
add valor_cargo decimal(20,4),
valor_primario decimal(20,4)

update #temp_natural
set valor_cargo = #cargo_natural.valor_cargo * #temp_natural.cantidad_piezas
from #cargo_natural
where #cargo_natural.id_item_factura = #temp_natural.id_item_factura

select id_tipo_flor,
ano,
semana,
sum(valor_credito) as valor_credito into #credito_resultado_natural
from #credito_natural
where not exists 
(
	select * 
	from #temp_natural
	where #temp_natural.id_item_factura = #credito_natural.id_item_factura
)
group by id_tipo_flor,
ano,
semana

update #temp_natural
set valor_primario = 
case
	when cargo_incluido = 1 then (valor + valor_credito - isnull(valor_cargo, 0)) 
	else (valor + valor_credito) 	
end

select #temp_natural.id_tipo_flor,
#temp_natural.ano,
#temp_natural.semana,
sum(#temp_natural.fulles) as fulles,
sum(#temp_natural.unidades_por_pieza) as unidades,
sum(#temp_natural.valor_primario) as valor_primario,
sum(#temp_natural.valor_cargo) as valor_cargo,
sum(#temp_natural.valor_credito) as valor_credito into #resultado_natural
from #temp_natural 
group by #temp_natural.id_tipo_flor,
#temp_natural.ano,
#temp_natural.semana
order by #temp_natural.id_tipo_flor,
#temp_natural.ano,
#temp_natural.semana

update #resultado_natural
set valor_credito = #resultado_natural.valor_credito + isnull(#credito_resultado_natural.valor_credito, 0),
valor_primario = valor_primario + isnull(#credito_resultado_natural.valor_credito, 0)
from #credito_resultado_natural
where #resultado_natural.id_tipo_flor = #credito_resultado_natural.id_tipo_flor 
and #resultado_natural.ano = #credito_resultado_natural.ano
and #resultado_natural.semana = #credito_resultado_natural.semana

SELECT SUM(VALOR_CREDITO) AS VALOR_CREDITOS_PASADOS,
id_tipo_flor,
semana,
ano INTO #CREDITOS_PASADOS_natural
FROM #credito_resultado_natural 
WHERE NOT EXISTS
(
	SELECT *
	FROM #resultado_natural
	WHERE #resultado_natural.id_tipo_flor = #credito_resultado_natural.id_tipo_flor
	and #resultado_natural.ano = #credito_resultado_natural.ano
	and #resultado_natural.semana = #credito_resultado_natural.semana
)
group by id_tipo_flor,
semana,
ano

update #resultado_natural
set valor_primario = valor_primario + isnull(valor_creditos_pasados, 0)
from #CREDITOS_PASADOS_natural
where #CREDITOS_PASADOS_natural.id_tipo_flor = #resultado_natural.id_tipo_flor 
and #CREDITOS_PASADOS_natural.ano = #resultado_natural.ano
and #CREDITOS_PASADOS_natural.semana = #resultado_natural.semana

drop table #temp_natural
drop table #credito_natural
drop table #credito_sin_agrupar_natural
drop table #credito_resultado_natural
DROP TABLE #CREDITOS_PASADOS_natural
drop table #cargo_natural

/******************************************************************/
/******************************************************************/
/******************************************************************/

select @fresca as comercializadora,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
#fechas.semana,
#fechas.ano,
#fechas.fecha_inicial,
#fechas.fecha_final,
sum(fulles) as fulles,
sum(unidades) as unidades,
sum(valor_primario) as valor_primario,
sum(valor_credito) as valor_credito,
sum(valor_primario) + sum(valor_cargo) as total,
(sum(valor_primario) + sum(valor_cargo))/ sum(unidades) as valor_unitario
from #resultado_fresca,
#fechas,
bd_fresca.dbo.tipo_flor
where tipo_flor.id_tipo_flor = #resultado_fresca.id_tipo_flor
and #resultado_fresca.ano = #fechas.ano
and #resultado_fresca.semana = #fechas.semana
group by tipo_flor.id_tipo_flor,
#fechas.ano,
#fechas.semana,
#fechas.fecha_inicial,
#fechas.fecha_final,
tipo_flor.idc_tipo_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor))

union all

select @natural as comercializadora,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
#fechas.semana,
#fechas.ano,
#fechas.fecha_inicial,
#fechas.fecha_final,
sum(fulles) as fulles,
sum(unidades) as unidades,
sum(valor_primario) as valor_primario,
sum(valor_credito) as valor_credito,
sum(valor_primario) + sum(valor_cargo) as total,
(sum(valor_primario) + sum(valor_cargo))/ sum(unidades) as valor_unitario
from #resultado_natural,
bd_nf.bd_nf.dbo.tipo_flor,
#fechas
where tipo_flor.id_tipo_flor = #resultado_natural.id_tipo_flor
and #resultado_natural.ano = #fechas.ano
and #resultado_natural.semana = #fechas.semana
group by tipo_flor.id_tipo_flor,
#fechas.ano,
#fechas.semana,
#fechas.fecha_inicial,
#fechas.fecha_final,
tipo_flor.idc_tipo_flor,
rtrim(ltrim(tipo_flor.nombre_tipo_flor))

drop table #resultado_natural
drop table #resultado_fresca
drop table #grados
drop table #fechas