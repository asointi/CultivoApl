alter PROCEDURE [dbo].[Ventas_reporte_ultimo_mes_por_producto] 

@id_vendedor int,
@accion nvarchar(255)

as

DECLARE @fecha_inicial_semana datetime,
@fecha_final_semana datetime,
@fecha_inicial_mes datetime,
@fecha_final_mes datetime,
@fecha_inicial_mes_anterior datetime,
@fecha_final_mes_anterior datetime,
@fecha_inicial_ano datetime,
@fecha_final_ano datetime,
@conteo int,
@idc_vendedor nvarchar(10),
@nombre_vendedor nvarchar(50)

/*ingresar el primer y ùltimo dìa de la semana inmediatamente anterior*/
SELECT @fecha_inicial_semana = DATEADD(WK, DATEDIFF(WK,0,dateadd(wk, -1, GETDATE())),0)
SELECT @fecha_final_semana = @fecha_inicial_semana + 6

/*ingresar el primer y ùltimo dìa del mes inmediatamente anterior*/
SELECT @fecha_inicial_mes = DATEADD(m, DATEDIFF(m,0,dateadd(m, 0, GETDATE())),0)
SELECT @fecha_final_mes = @fecha_final_semana
SELECT @fecha_inicial_mes_anterior = DATEADD(mm,DATEDIFF(m,0,dateadd(m, -1, GETDATE())),0)
SELECT @fecha_final_mes_anterior = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))

/*ingresar el primer y ùltimo dìa del año actual*/
SELECT @fecha_inicial_ano = DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)
SELECT @fecha_final_ano = @fecha_final_semana

select grupo_tipo_flor.nombre_grupo_tipo_flor,
tipo_flor.id_tipo_flor into #flor_agrupada
from grupo_tipo_flor,
tipo_flor_agrupado,
tipo_flor
where tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor
and grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor

if(@accion = 'consultar_detalle_todos_los_vendedores')
begin
	/*consultar las ventas (Open Market y PreBook) por cliente  y tipo de flor realizadas para la semana inmediatamente anterior de todos los vendedores*/
	select 
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then tipo_flor.id_tipo_flor
		else grupo_tipo_flor.id_grupo_tipo_flor
	end	as id_tipo_flor,
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor
		else ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor))
	end as nombre_tipo_flor,
	sum(tipo_caja.factor_a_full) as fulls_sold_semana,
	@fecha_inicial_ano as fecha_inicial_semana,
	@fecha_final_ano as fecha_final_semana into #todos_vendedores
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	caja,
	tipo_caja,
	tipo_factura,
	tipo_flor left join tipo_flor_agrupado on tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor 
	left join grupo_tipo_flor on grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor,
	variedad_flor,
	farm,
	tipo_farm
	where pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_ano and @fecha_final_ano
	group by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor)),
	grupo_tipo_flor.id_grupo_tipo_flor 

	select ROW_NUMBER() OVER(ORDER BY sum(fulls_sold_semana) DESC, nombre_tipo_flor) AS id,
	id_tipo_flor,
	nombre_tipo_flor,
	sum(fulls_sold_semana) as fulls_sold_semana,
	fecha_inicial_semana,
	fecha_final_semana
	from #todos_vendedores
	group by id_tipo_flor,
	nombre_tipo_flor,
	fecha_inicial_semana,
	fecha_final_semana

	drop table #todos_vendedores
end
else
if(@accion = 'consultar_semana_anterior_agrupada')
begin
	/*consultar las ventas (Open Market y PreBook) por cliente  y tipo de flor realizadas para la semana inmediatamente anterior de todos los vendedores*/
	select 
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then tipo_flor.id_tipo_flor
		else grupo_tipo_flor.id_grupo_tipo_flor
	end	as id_tipo_flor,
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor
		else ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor))
	end as nombre_tipo_flor,
	sum(tipo_caja.factor_a_full) as fulls_sold_semana,
	@fecha_inicial_ano as fecha_inicial_semana,
	@fecha_final_ano as fecha_final_semana into #todos_vendedores_semana_anterior
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	caja,
	tipo_caja,
	tipo_factura,
	tipo_flor left join tipo_flor_agrupado on tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor 
	left join grupo_tipo_flor on grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor,
	variedad_flor,
	farm,
	tipo_farm
	where pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_semana and @fecha_final_semana
	group by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor)),
	grupo_tipo_flor.id_grupo_tipo_flor 

	select ROW_NUMBER() OVER(ORDER BY sum(fulls_sold_semana) DESC, nombre_tipo_flor) AS id,
	id_tipo_flor,
	nombre_tipo_flor,
	sum(fulls_sold_semana) as fulls_sold_semana,
	fecha_inicial_semana,
	fecha_final_semana
	from #todos_vendedores_semana_anterior
	group by id_tipo_flor,
	nombre_tipo_flor,
	fecha_inicial_semana,
	fecha_final_semana

	drop table #todos_vendedores_semana_anterior
end
ELSE
if(@accion = 'consultar_detalle_por_vendedor_grafico_pie')
begin
	/*consultar las ventas (Open Market y PreBook) por cliente  y tipo de flor realizadas para la semana inmediatamente anterior de un vendedor en particular*/
	select 
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then tipo_flor.id_tipo_flor
		else grupo_tipo_flor.id_grupo_tipo_flor
	end	as id_tipo_flor,
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor
		else ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor))
	end as nombre_tipo_flor,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
	sum(tipo_caja.factor_a_full) as fulls_sold_semana,
	@fecha_inicial_ano as fecha_inicial_semana,
	@fecha_final_ano as fecha_final_semana into #resultado
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	caja,
	tipo_caja,
	tipo_factura,
	tipo_flor left join tipo_flor_agrupado on tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor 
	left join grupo_tipo_flor on grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor,
	variedad_flor,
	farm,
	tipo_farm,
	cliente_factura,
	cliente_despacho,
	vendedor
	where cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_ano and @fecha_final_ano
	group by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor)),
	grupo_tipo_flor.id_grupo_tipo_flor,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre))

	select ROW_NUMBER() OVER(ORDER BY sum(fulls_sold_semana) DESC, nombre_tipo_flor) AS id,
	id_tipo_flor,
	nombre_tipo_flor,
	sum(fulls_sold_semana) as fulls into #orden
	from #resultado
	group by id_tipo_flor,
	nombre_tipo_flor

	select id_tipo_flor,
	nombre_tipo_flor,
	id_vendedor,
	idc_vendedor,
	nombre_vendedor,
	sum(fulls_sold_semana) as fulls_sold_semana,
	fecha_inicial_semana,
	fecha_final_semana into #resultado2
	from #resultado
	where id_vendedor = @id_vendedor
	group by id_tipo_flor,
	nombre_tipo_flor,
	id_vendedor,
	idc_vendedor,
	nombre_vendedor,
	fecha_inicial_semana,
	fecha_final_semana

	insert into #resultado2
	(
		id_vendedor,
		id_tipo_flor,
		idc_vendedor,
		nombre_vendedor,
		nombre_tipo_flor,
		fulls_sold_semana,
		fecha_inicial_semana,
		fecha_final_semana
	)

	select 0,
	id_tipo_flor,
	'',
	'',
	nombre_tipo_flor,
	0,
	'',
	''	
	from #resultado
	where not exists
	(
		select *
		from #resultado2
		where #resultado.id_tipo_flor = #resultado2.id_tipo_flor
		and #resultado.nombre_tipo_flor = #resultado2.nombre_tipo_flor
	)
	group by id_tipo_flor,
	nombre_tipo_flor

	alter table #resultado2
	add orden int

	update #resultado2
	set orden = id
	from #orden
	where #orden.id_tipo_flor = #resultado2.id_tipo_flor
	and #orden.nombre_tipo_flor = #resultado2.nombre_tipo_flor

	select * 
	from #resultado2
	order by orden

	drop table #resultado
	drop table #resultado2
	drop table #orden
end
else
if(@accion = 'consultar_vendedor_semana_anterior')
begin
	/*consultar las ventas (Open Market y PreBook) por cliente  y tipo de flor realizadas para la semana inmediatamente anterior de un vendedor en particular*/
	select 
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then tipo_flor.id_tipo_flor
		else grupo_tipo_flor.id_grupo_tipo_flor
	end	as id_tipo_flor,
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor
		else ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor))
	end as nombre_tipo_flor,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
	sum(tipo_caja.factor_a_full) as fulls_sold_semana,
	@fecha_inicial_semana as fecha_inicial_semana,
	@fecha_final_semana as fecha_final_semana into #resultado_semana_anterior
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	caja,
	tipo_caja,
	tipo_factura,
	tipo_flor left join tipo_flor_agrupado on tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor 
	left join grupo_tipo_flor on grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor,
	variedad_flor,
	farm,
	tipo_farm,
	cliente_factura,
	cliente_despacho,
	vendedor
	where cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_semana and @fecha_final_semana
	group by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor)),
	grupo_tipo_flor.id_grupo_tipo_flor,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre))

	select ROW_NUMBER() OVER(ORDER BY sum(fulls_sold_semana) DESC, nombre_tipo_flor) AS id,
	id_tipo_flor,
	nombre_tipo_flor,
	sum(fulls_sold_semana) as fulls into #orden_semana_anterior
	from #resultado_semana_anterior
	group by id_tipo_flor,
	nombre_tipo_flor

	select id_tipo_flor,
	nombre_tipo_flor,
	id_vendedor,
	idc_vendedor,
	nombre_vendedor,
	sum(fulls_sold_semana) as fulls_sold_semana,
	fecha_inicial_semana,
	fecha_final_semana into #resultado2_semana_anterior
	from #resultado_semana_anterior
	where id_vendedor = @id_vendedor
	group by id_tipo_flor,
	nombre_tipo_flor,
	id_vendedor,
	idc_vendedor,
	nombre_vendedor,
	fecha_inicial_semana,
	fecha_final_semana

	insert into #resultado2_semana_anterior
	(
		id_vendedor,
		id_tipo_flor,
		idc_vendedor,
		nombre_vendedor,
		nombre_tipo_flor,
		fulls_sold_semana,
		fecha_inicial_semana,
		fecha_final_semana
	)
	select 0,
	id_tipo_flor,
	'',
	'',
	nombre_tipo_flor,
	0,
	'',
	''	
	from #resultado_semana_anterior
	where not exists
	(
		select *
		from #resultado2_semana_anterior
		where #resultado_semana_anterior.id_tipo_flor = #resultado2_semana_anterior.id_tipo_flor
		and #resultado_semana_anterior.nombre_tipo_flor = #resultado2_semana_anterior.nombre_tipo_flor
	)
	group by id_tipo_flor,
	nombre_tipo_flor

	alter table #resultado2_semana_anterior
	add orden int

	update #resultado2_semana_anterior
	set orden = id
	from #orden_semana_anterior
	where #orden_semana_anterior.id_tipo_flor = #resultado2_semana_anterior.id_tipo_flor
	and #orden_semana_anterior.nombre_tipo_flor = #resultado2_semana_anterior.nombre_tipo_flor

	select * 
	from #resultado2_semana_anterior
	order by orden

	drop table #resultado_semana_anterior
	drop table #resultado2_semana_anterior
	drop table #orden_semana_anterior
end
ELSE
if(@accion = 'consultar_detalle')
begin
	/*consultar las ventas (Open Market y PreBook) por cliente  y tipo de flor realizadas para el mes corrido de un vendedor en particular*/
	select vendedor.id_vendedor,
	cliente_factura.id_cliente_factura,
	tipo_flor.id_tipo_flor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
	cliente_factura.idc_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor as nombre_tipo_flor,
	sum(tipo_caja.factor_a_full) as fulls_sold_mes,
	convert(decimal(20,4), 0) as fulls_sold_semana,
	@fecha_inicial_mes as fecha_inicial_mes,
	@fecha_final_mes as fecha_final_mes,
	@fecha_inicial_semana as fecha_inicial_semana,
	@fecha_final_semana as fecha_final_semana 
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	vendedor,
	cliente_factura,
	cliente_despacho,
	caja,
	tipo_caja,
	tipo_factura,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	tipo_farm
	where pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and grado_flor.id_grado_flor = pieza.id_grado_flor
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_mes and @fecha_final_mes
	and vendedor.id_vendedor = @id_vendedor
	group by vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)),
	cliente_factura.idc_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)),
	datename(mm, factura.fecha_factura),
	datename(yyyy, factura.fecha_factura),
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	vendedor.id_vendedor,
	cliente_factura.id_cliente_factura,
	tipo_flor.id_tipo_flor

	union all

	/*consultar las ventas (Open Market y PreBook) por cliente  y tipo de flor realizadas para la semana inmediatamente anterior de un vendedor en particular*/
	select vendedor.id_vendedor,
	cliente_factura.id_cliente_factura,
	tipo_flor.id_tipo_flor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
	cliente_factura.idc_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor as nombre_tipo_flor,
	0 as fulls_sold_mes,
	sum(tipo_caja.factor_a_full) as fulls_sold_semana,
	@fecha_inicial_mes as fecha_inicial_mes,
	@fecha_final_mes as fecha_final_mes,
	@fecha_inicial_semana as fecha_inicial_semana,
	@fecha_final_semana as fecha_final_semana
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	vendedor,
	cliente_factura,
	cliente_despacho,
	caja,
	tipo_caja,
	tipo_factura,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	tipo_farm
	where pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and grado_flor.id_grado_flor = pieza.id_grado_flor
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_semana and @fecha_final_semana
	and vendedor.id_vendedor = @id_vendedor
	group by vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)),
	cliente_factura.idc_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)),
	datename(mm, factura.fecha_factura),
	datename(yyyy, factura.fecha_factura),
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	vendedor.id_vendedor,
	cliente_factura.id_cliente_factura,
	tipo_flor.id_tipo_flor
end
else
if(@accion = 'consultar_todos_vendedores')
begin
	/*consultar los vendedores con ventas de tipo Open Market y PreBook en el mes corrido*/
	select vendedor.id_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
	vendedor.correo,
	vendedor.idc_vendedor into #vendedores
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	vendedor,
	cliente_factura,
	cliente_despacho,
	tipo_factura,
	farm,
	tipo_farm
	where pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_mes and @fecha_final_mes
	
	union all

	/*consultar los vendedores con ventas de tipo Open Market y PreBook en  la semana inmediatamente anterior*/
	select vendedor.id_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
	vendedor.correo,
	vendedor.idc_vendedor
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	vendedor,
	cliente_factura,
	cliente_despacho,
	tipo_factura,
	farm,
	tipo_farm
	where pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_semana and @fecha_final_semana

	select id_vendedor,
	nombre_vendedor,
	correo,
	convert(nvarchar, @fecha_inicial_semana, 103) + ' - ' + convert(nvarchar, @fecha_final_semana, 103) as fecha
	from #vendedores
	where correo is not null
	and len(correo) > 7
	and idc_vendedor not in ('020', '40', '500', '900', '990', '995', '997')
	group by id_vendedor,
	nombre_vendedor,
	correo

	drop table #vendedores
end
else
if(@accion = 'consultar_mes_anterior_por_vendedor')
begin
	/*consultar las ventas (Open Market y PreBook) por cliente  y tipo de flor realizadas para la semana inmediatamente anterior de un vendedor en particular*/
	select 
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then tipo_flor.id_tipo_flor
		else grupo_tipo_flor.id_grupo_tipo_flor
	end	as id_tipo_flor,
	case
		when grupo_tipo_flor.id_grupo_tipo_flor is null then ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor
		else ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor))
	end as nombre_tipo_flor,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
	sum(tipo_caja.factor_a_full) as fulls_sold_semana,
	@fecha_inicial_mes_anterior as fecha_inicial_semana,
	@fecha_final_mes_anterior as fecha_final_semana into #resultado_mes_anterior
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	caja,
	tipo_caja,
	tipo_factura,
	tipo_flor left join tipo_flor_agrupado on tipo_flor.id_tipo_flor = tipo_flor_agrupado.id_tipo_flor 
	left join grupo_tipo_flor on grupo_tipo_flor.id_grupo_tipo_flor = tipo_flor_agrupado.id_grupo_tipo_flor,
	variedad_flor,
	farm,
	tipo_farm,
	cliente_factura,
	cliente_despacho,
	vendedor
	where cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and farm.id_farm = pieza.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and tipo_farm.codigo <> 'D'
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and factura.fecha_factura between
	@fecha_inicial_mes_anterior and @fecha_final_mes_anterior
	group by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(grupo_tipo_flor.nombre_grupo_tipo_flor)),
	grupo_tipo_flor.id_grupo_tipo_flor,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre))

	select ROW_NUMBER() OVER(ORDER BY sum(fulls_sold_semana) DESC, nombre_tipo_flor) AS id,
	id_tipo_flor,
	nombre_tipo_flor,
	sum(fulls_sold_semana) as fulls into #orden_mes_anterior
	from #resultado_mes_anterior
	group by id_tipo_flor,
	nombre_tipo_flor

	create table #resultado2_mes_anterior
	(
		id_tipo_flor int,
		nombre_tipo_flor nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		id_vendedor int,
		idc_vendedor nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		nombre_vendedor nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		fulls_sold_semana decimal(20,4),
		fecha_inicial_semana datetime,
		fecha_final_semana datetime,
		orden int null
	)

	select IDENTITY(int, 1,1) AS id,
	id_vendedor,
	idc_vendedor,
	nombre_vendedor into #vendedor
	from #resultado_mes_anterior
	where idc_vendedor not in ('020', '40', '500', '900', '990', '995', '997')
	group by id_vendedor,
	idc_vendedor,
	nombre_vendedor
	order by nombre_vendedor

	select @conteo = count(id)
	from #vendedor

	while(@conteo > = 1)
	begin
		select @id_vendedor = id_vendedor,
		@idc_vendedor = idc_vendedor,
		@nombre_vendedor = nombre_vendedor
		from #vendedor
		where id = @conteo

		insert into #resultado2_mes_anterior
		(
			id_tipo_flor,
			nombre_tipo_flor,
			id_vendedor,
			idc_vendedor,
			nombre_vendedor,
			fulls_sold_semana,
			fecha_inicial_semana,
			fecha_final_semana
		)
		select id_tipo_flor,
		nombre_tipo_flor,
		id_vendedor,
		idc_vendedor,
		nombre_vendedor,
		sum(fulls_sold_semana) as fulls_sold_semana,
		fecha_inicial_semana,
		fecha_final_semana
		from #resultado_mes_anterior
		where id_vendedor = @id_vendedor
		group by id_tipo_flor,
		nombre_tipo_flor,
		id_vendedor,
		idc_vendedor,
		nombre_vendedor,
		fecha_inicial_semana,
		fecha_final_semana

		insert into #resultado2_mes_anterior
		(
			id_vendedor,
			id_tipo_flor,
			idc_vendedor,
			nombre_vendedor,
			nombre_tipo_flor,
			fulls_sold_semana,
			fecha_inicial_semana,
			fecha_final_semana
		)
		select @id_vendedor,
		id_tipo_flor,
		@idc_vendedor,
		@nombre_vendedor,
		nombre_tipo_flor,
		0,
		@fecha_inicial_mes_anterior,
		@fecha_final_mes_anterior
		from #resultado_mes_anterior
		where not exists
		(
			select *
			from #resultado2_mes_anterior
			where #resultado_mes_anterior.id_tipo_flor = #resultado2_mes_anterior.id_tipo_flor
			and #resultado_mes_anterior.nombre_tipo_flor = #resultado2_mes_anterior.nombre_tipo_flor
			and #resultado2_mes_anterior.id_vendedor = @id_vendedor
		)
		group by id_tipo_flor,
		nombre_tipo_flor

		set @conteo = @conteo -1
	end

	alter table #resultado2_mes_anterior
	add fulls_total decimal(20,4)

	update #resultado2_mes_anterior
	set orden = #orden_mes_anterior.id,
	fulls_total = #orden_mes_anterior.fulls
	from #orden_mes_anterior
	where #orden_mes_anterior.id_tipo_flor = #resultado2_mes_anterior.id_tipo_flor
	and #orden_mes_anterior.nombre_tipo_flor = #resultado2_mes_anterior.nombre_tipo_flor

	select *,
	(
		select sum(r.fulls_sold_semana)
		from #resultado2_mes_anterior as r
		where r.id_vendedor = #resultado2_mes_anterior.id_vendedor
	) as fulls_por_vendedor,
	(
		select sum(fulls)
		from #orden_mes_anterior
	) as fulls_total_agrupado
	from #resultado2_mes_anterior
	order by id_vendedor,
	orden

	drop table #resultado_mes_anterior
	drop table #resultado2_mes_anterior
	drop table #orden_mes_anterior
end

drop table #flor_agrupada