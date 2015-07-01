set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_generar_reporte_grados_tres_años_rosa]

@fecha datetime,
@finca int,
@accion nvarchar(255)

as

declare @fecha_inicial datetime,
@fecha_final datetime,
@fecha_inicial_1 datetime,
@fecha_final_1 datetime,
@fecha_año_anterior datetime,
@fecha_inicial_año_anterior datetime,
@fecha_final_año_anterior datetime,
@semana_inicial int,
@semana_final int

select @fecha_año_anterior = dateadd(yyyy, -1,DATEADD(dd, 1 - DATEPART(DW, @fecha), @fecha) - 1)
select @fecha_inicial_1 = dateadd(year, datediff(year, '', @fecha_año_anterior),'') - 10
select @fecha_final_1 = dateadd(dd, 364, DATEADD(year, datediff(year, '', @fecha_año_anterior),'')) + 10

create table #fechas
(
	fecha datetime,
	año int,
	semana int
)

create table #dolar
(
	valor decimal(20,4),
	fecha datetime,
	semana int
)

while (@fecha_inicial_1 < = @fecha_final_1)
begin
	insert into #fechas (fecha, año, semana)
	select @fecha_inicial_1,
	datepart(yyyy,@fecha_inicial_1) as año,
	dbo.IsoWeek(@fecha_inicial_1) as semana

	set @fecha_inicial_1 = @fecha_inicial_1 + 1
end

set @semana_inicial = dbo.IsoWeek(dateadd(ww, -7,(DATEADD(dd, 1 - DATEPART(DW, @fecha), @fecha))))
set @semana_final = dbo.IsoWeek(DATEADD(dd, 1 - DATEPART(DW, @fecha), @fecha) - 1)

select @fecha_inicial_año_anterior = min(fecha),
@fecha_final_año_anterior = max(fecha)
from #fechas
where semana > = @semana_inicial
and semana < = @semana_final

set @fecha_inicial = dateadd(ww, -7,(DATEADD(dd, 1 - DATEPART(DW, @fecha), @fecha)))
set @fecha_final = DATEADD(dd, 1 - DATEPART(DW, @fecha), @fecha) - 1

select grado_flor.idc_grado_flor,
grado_flor.orden,
datepart(yyyy, factura.fecha_factura) as año,
sum(pieza.unidades_por_pieza) as unidades,
sum(pieza.unidades_por_pieza * item_factura.valor_unitario) as valor,
isnull((
	select sum(item_factura.valor_unitario)
	from cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and item_factura.cargo_incluido = 0
), 0) as valor_cargo,
(
	select sum(detalle_credito.valor_credito) 
	from credito,
	detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and detalle_credito.id_item_factura = item_factura.id_item_factura
) as valor_credito,
count(pieza.id_pieza) as cantidad_piezas,
dbo.IsoWeek(factura.fecha_factura) as semana,
1 as año_actual into #temp
from pieza,
variedad_flor,
grado_flor,
tipo_flor,
detalle_item_factura,
item_factura,
factura,
farm
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and farm.id_farm = pieza.id_farm
and farm.idc_farm > =
case
	when @finca = 1 then 'N '
	else '  '
end
and farm.idc_farm < =
case
	when @finca = 1 then 'NZ'
	else 'ZZ'
end
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between
@fecha_inicial and @fecha_final
and tipo_flor.idc_tipo_flor = 'RO'
and grado_flor.idc_grado_flor in ('40','50','60','70')
group by item_factura.id_item_factura,
item_factura.cargo_incluido,
grado_flor.idc_grado_flor,
grado_flor.orden,
datepart(yyyy, factura.fecha_factura),
dbo.IsoWeek(factura.fecha_factura)

union all

select grado_flor.idc_grado_flor,
grado_flor.orden,
datepart(yyyy, factura.fecha_factura) as año,
sum(pieza.unidades_por_pieza) as unidades,
sum(pieza.unidades_por_pieza * item_factura.valor_unitario) as valor,
isnull((
	select sum(item_factura.valor_unitario)
	from cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and item_factura.cargo_incluido = 0
), 0) as valor_cargo,
(
	select sum(detalle_credito.valor_credito) 
	from credito,
	detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and detalle_credito.id_item_factura = item_factura.id_item_factura
) as valor_credito,
count(pieza.id_pieza) as cantidad_piezas,
dbo.IsoWeek(factura.fecha_factura) as semana,
0 as año_actual
from pieza,
variedad_flor,
grado_flor,
tipo_flor,
detalle_item_factura,
item_factura,
factura,
farm
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and grado_flor.id_grado_flor = pieza.id_grado_flor
and farm.id_farm = pieza.id_farm
and farm.idc_farm > =
case
	when @finca = 1 then 'N '
	else '  '
end
and farm.idc_farm < =
case
	when @finca = 1 then 'NZ'
	else 'ZZ'
end
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between
@fecha_inicial_año_anterior and @fecha_final_año_anterior
and tipo_flor.idc_tipo_flor = 'RO'
and grado_flor.idc_grado_flor in ('40','50','60','70')
group by item_factura.id_item_factura,
item_factura.cargo_incluido,
grado_flor.idc_grado_flor,
grado_flor.orden,
datepart(yyyy, factura.fecha_factura),
dbo.IsoWeek(factura.fecha_factura)

insert into #dolar (valor, fecha, semana)
select valor,
fecha,
dbo.IsoWeek(fecha)
from bd_cultivo.bd_cultivo.dbo.dolar_tasa_representativa
where fecha between
@fecha_inicial_año_anterior and @fecha_final_año_anterior
and datepart(dw, fecha) = 1

insert into #dolar (valor, fecha, semana)
select valor,
fecha,
dbo.IsoWeek(fecha)
from bd_cultivo.bd_cultivo.dbo.dolar_tasa_representativa
where fecha between
@fecha_inicial and @fecha_final
and datepart(dw, fecha) = 1

delete from #fechas
set @fecha_año_anterior = null
set @fecha_inicial_1 = null
set @fecha_final_1 = null
set @fecha_inicial_año_anterior = null
set @fecha_final_año_anterior = null

select @fecha_año_anterior = dateadd(yyyy, -2,DATEADD(dd, 1 - DATEPART(DW, @fecha), @fecha) - 1)
select @fecha_inicial_1 = dateadd(year, datediff(year, '', @fecha_año_anterior),'') - 10
select @fecha_final_1 = dateadd(dd, 364, DATEADD(year, datediff(year, '', @fecha_año_anterior),'')) + 10

while (@fecha_inicial_1 < = @fecha_final_1)
begin
	insert into #fechas (fecha, año, semana)
	select @fecha_inicial_1,
	datepart(yyyy,@fecha_inicial_1) as año,
	dbo.IsoWeek(@fecha_inicial_1) as semana

	set @fecha_inicial_1 = @fecha_inicial_1 + 1
end

select @fecha_inicial_año_anterior = min(fecha),
@fecha_final_año_anterior = max(fecha)
from #fechas
where semana > = @semana_inicial
and semana < = @semana_final

insert into #dolar (valor, fecha, semana)
select valor,
fecha,
dbo.IsoWeek(fecha)
from bd_cultivo.bd_cultivo.dbo.dolar_tasa_representativa
where fecha between
@fecha_inicial_año_anterior and @fecha_final_año_anterior
and datepart(dw, fecha) = 1

if(@accion = 'consultar_precio_dolar')
begin
	select semana,
	(
		select isnull(valor, 0)
		from #dolar as d
		where d.semana = #dolar.semana
		and datepart(yyyy,d.fecha) = convert(nvarchar,datepart(yyyy, @fecha) - 2)  
	) as Col1,
	(
		select isnull(valor, 0)
		from #dolar as d
		where d.semana = #dolar.semana
		and datepart(yyyy,d.fecha) = convert(nvarchar,datepart(yyyy, @fecha) - 1)  
	) as Col2,
	(
		select isnull(valor, 0)
		from #dolar as d
		where d.semana = #dolar.semana
		and datepart(yyyy,d.fecha) = convert(nvarchar,datepart(yyyy, @fecha))  
	) as Col3 
	from #dolar
	group by semana
	order by semana
end
else
if(@accion = 'consultar_precio_unitario')
begin
	select idc_grado_flor,
	orden,
	año,
	semana,
	sum(unidades) as unidades,
	sum(valor) as valor,
	sum(valor_cargo * cantidad_piezas) as valor_cargo,
	sum(valor + valor_cargo + isnull(valor_credito, 0)) / sum(unidades) as valor_unitario,
	sum(unidades) * (sum(valor + valor_cargo + isnull(valor_credito, 0)) / sum(unidades)) as unidades_esperadas,
	(
		select sum(t.unidades)
		from #temp as t
		where t.año_actual = 1
		and t.semana = #temp.semana
		and t.idc_grado_flor = #temp.idc_grado_flor
	) *
	(
		select sum(valor + valor_cargo + isnull(valor_credito, 0)) / sum(unidades)
		from #temp as t
		where t.año_actual = 0
		and t.semana = #temp.semana
		and t.idc_grado_flor = #temp.idc_grado_flor
	) as unidades_esperadas_proyeccion,
	año_actual
	from #temp
	group by idc_grado_flor,
	orden,
	año,
	semana,
	año_actual
end
else
if(@accion = 'consultar_precio_venta')
begin
	select idc_grado_flor,
	orden,
	año,
	semana,
	sum(unidades) as unidades,
	sum(valor) as valor,
	sum(valor_cargo * cantidad_piezas) as valor_cargo,
	sum(valor + valor_cargo + isnull(valor_credito, 0)) / sum(unidades) as valor_unitario,
	sum(unidades) * (sum(valor + valor_cargo + isnull(valor_credito, 0)) / sum(unidades)) as unidades_esperadas,
	(
		select sum(t.unidades)
		from #temp as t
		where t.año_actual = 1
		and t.semana = #temp.semana
		and t.idc_grado_flor = #temp.idc_grado_flor
	) *
	(
		select sum(valor + valor_cargo + isnull(valor_credito, 0)) / sum(unidades)
		from #temp as t
		where t.año_actual = 0
		and t.semana = #temp.semana
		and t.idc_grado_flor = #temp.idc_grado_flor
	) as unidades_esperadas_proyeccion,
	año_actual
	from #temp
	where año_actual = 1
	group by idc_grado_flor,
	orden,
	año,
	semana,
	año_actual
end

drop table #temp
drop table #fechas
drop table #dolar
