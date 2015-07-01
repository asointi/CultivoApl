set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_consultar_ramo]

@accion nvarchar(255),
@id_tipo_flor int,
@id_variedad_flor int,
@fecha_entrada_string nvarchar(255),
@periodo nvarchar(255),
@numero_periodos int

AS
BEGIN

set language 'spanish'

declare @fecha_entrada DATETIME, 
@fecha_entrada_inicial DATETIME,
@conteo int

set @fecha_entrada = CONVERT(DATETIME, @fecha_entrada_string)

if(@accion = 'consultar_reporte_tv')
begin
	declare @fecha_final datetime,
	@fecha_inicial datetime 

	set @fecha_inicial = DATEADD(month, DATEDIFF(month, 0, DATEADD(month, - 14, getdate())), 0)

	set @fecha_final = dateadd(dd, -1, DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 0, getdate())), 0))

	SELECT datepart(month, r.fecha_entrada) as numero_mes,
	datename(month, r.fecha_entrada) as nombre_mes,
	datepart(year,r.fecha_entrada) as ano,
	isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_meses_tv
	FROM tipo_flor as t, 
	variedad_flor as v, 
	grado_flor as g, 
	ramo as r
	WHERE v.id_tipo_flor = t.id_tipo_flor
	and g.id_tipo_flor = t.id_tipo_flor
	and v.id_variedad_flor = r.id_variedad_flor
	and v.id_variedad_flor = 851
	and g.id_grado_flor = r.id_grado_flor
	and r.fecha_entrada 
	between @fecha_inicial and @fecha_final
	group by datename(month, r.fecha_entrada),
	datepart(month, r.fecha_entrada),
	datepart(year,r.fecha_entrada)

	SELECT v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	datepart(month, r.fecha_entrada) as numero_mes,
	datename(month, r.fecha_entrada) as nombre_mes, 
	datepart(year,r.fecha_entrada) as ano, 
	isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
	(
		select #temp_meses_tv.tallos_por_ramo_total 
		from #temp_meses_tv
		where #temp_meses_tv.numero_mes = datepart(month, r.fecha_entrada)
		and #temp_meses_tv.ano = datepart(year,r.fecha_entrada)
	) as tallos_por_ramo_total into #temp_detalle
	FROM tipo_flor as t, 
	variedad_flor as v, 
	grado_flor as g, 
	ramo as r
	WHERE v.id_tipo_flor = t.id_tipo_flor
	and g.id_tipo_flor = t.id_tipo_flor
	and v.id_variedad_flor = r.id_variedad_flor
	and g.id_grado_flor = r.id_grado_flor
	and r.fecha_entrada 
	between @fecha_inicial and @fecha_final
	and v.id_variedad_flor = 851
	group by v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	datename(month, r.fecha_entrada), 
	datepart(year,r.fecha_entrada),
	datepart(month, r.fecha_entrada)

	insert into #temp_detalle 
	(
	id_tipo_flor, 
	id_variedad_flor, 
	nombre_tipo_flor, 
	nombre_variedad_flor, 
	id_grado_flor, 
	nombre_grado_flor, 
	numero_mes,
	nombre_mes, 
	ano, 
	tallos_por_ramo,
	tallos_por_ramo_total
	)
	SELECT v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	30 as numero_mes,
	left(convert(nvarchar,getdate(), 1), 5) as nombre_mes, 
	datepart(year,r.fecha_entrada) as ano, 
	isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
	(
		select sum(tallos_por_ramo)
		from ramo,
		variedad_flor
		where ramo.id_variedad_flor = variedad_flor.id_variedad_flor
		and variedad_flor.id_variedad_flor = 851
		and convert(datetime,convert(nvarchar,ramo.fecha_entrada, 103)) between
		(DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 0, getdate())), 0)) and convert(datetime,convert(nvarchar, getdate(), 103))
	) as tallos_por_ramo_total
	FROM tipo_flor as t, 
	variedad_flor as v, 
	grado_flor as g, 
	ramo as r
	WHERE v.id_tipo_flor = t.id_tipo_flor
	and g.id_tipo_flor = t.id_tipo_flor
	and v.id_variedad_flor = r.id_variedad_flor
	and g.id_grado_flor = r.id_grado_flor
	and convert(datetime,convert(nvarchar,r.fecha_entrada, 103)) = convert(datetime,convert(nvarchar,getdate(), 103))
	and v.id_variedad_flor = 851
	group by v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	datepart(year,r.fecha_entrada) 

	insert into #temp_detalle 
	(
	id_tipo_flor, 
	id_variedad_flor, 
	nombre_tipo_flor, 
	nombre_variedad_flor, 
	id_grado_flor, 
	nombre_grado_flor, 
	numero_mes,
	nombre_mes, 
	ano, 
	tallos_por_ramo,
	tallos_por_ramo_total
	)
	SELECT v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	25 as numero_mes,
	left(convert(nvarchar,getdate() - 1, 1), 5) as nombre_mes, 
	datepart(year,r.fecha_entrada) as ano, 
	isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
	(
		select sum(tallos_por_ramo)
		from ramo,
		variedad_flor
		where ramo.id_variedad_flor = variedad_flor.id_variedad_flor
		and variedad_flor.id_variedad_flor = 851
		and convert(datetime,convert(nvarchar,ramo.fecha_entrada, 103)) between
		(DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 0, getdate())), 0)) and convert(datetime,convert(nvarchar, getdate(), 103))
	) as tallos_por_ramo_total
	FROM tipo_flor as t, 
	variedad_flor as v, 
	grado_flor as g, 
	ramo as r
	WHERE v.id_tipo_flor = t.id_tipo_flor
	and g.id_tipo_flor = t.id_tipo_flor
	and v.id_variedad_flor = r.id_variedad_flor
	and g.id_grado_flor = r.id_grado_flor
	and convert(datetime,convert(nvarchar,r.fecha_entrada, 103)) = convert(datetime,convert(nvarchar,getdate() - 1, 103))
	and v.id_variedad_flor = 851
	group by v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	datepart(year,r.fecha_entrada) 

	insert into #temp_detalle 
	(
	id_tipo_flor, 
	id_variedad_flor, 
	nombre_tipo_flor, 
	nombre_variedad_flor, 
	id_grado_flor, 
	nombre_grado_flor, 
	numero_mes,
	nombre_mes, 
	ano, 
	tallos_por_ramo,
	tallos_por_ramo_total
	)
	SELECT v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	20 as numero_mes,
	left(convert(nvarchar,getdate() - 2, 1), 5) as nombre_mes, 
	datepart(year,r.fecha_entrada) as ano, 
	isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
	(
		select sum(tallos_por_ramo)
		from ramo,
		variedad_flor
		where ramo.id_variedad_flor = variedad_flor.id_variedad_flor
		and variedad_flor.id_variedad_flor = 851
		and convert(datetime,convert(nvarchar,ramo.fecha_entrada, 103)) between
		(DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 0, getdate())), 0)) and convert(datetime,convert(nvarchar, getdate(), 103))
	) as tallos_por_ramo_total
	FROM tipo_flor as t, 
	variedad_flor as v, 
	grado_flor as g, 
	ramo as r
	WHERE v.id_tipo_flor = t.id_tipo_flor
	and g.id_tipo_flor = t.id_tipo_flor
	and v.id_variedad_flor = r.id_variedad_flor
	and g.id_grado_flor = r.id_grado_flor
	and convert(datetime,convert(nvarchar,r.fecha_entrada, 103)) = convert(datetime,convert(nvarchar,getdate() - 2, 103))
	and v.id_variedad_flor = 851
	group by v.id_tipo_flor, 
	v.id_variedad_flor, 
	t.nombre_tipo_flor, 
	v.nombre_variedad_flor, 
	g.id_grado_flor, 
	g.nombre_grado_flor, 
	datepart(year,r.fecha_entrada) 

	if(datepart(dd, getdate()) > 3)
	begin
		insert into #temp_detalle 
		(
		id_tipo_flor, 
		id_variedad_flor, 
		nombre_tipo_flor, 
		nombre_variedad_flor, 
		id_grado_flor, 
		nombre_grado_flor, 
		numero_mes,
		nombre_mes, 
		ano, 
		tallos_por_ramo,
		tallos_por_ramo_total
		)
		SELECT v.id_tipo_flor, 
		v.id_variedad_flor, 
		t.nombre_tipo_flor, 
		v.nombre_variedad_flor, 
		g.id_grado_flor, 
		g.nombre_grado_flor, 
		datepart(month, getdate()) as numero_mes,
		datename(month, getdate()) as nombre_mes, 
		datepart(year,r.fecha_entrada) as ano, 
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
		(
			select sum(tallos_por_ramo)
			from ramo,
			variedad_flor
			where ramo.id_variedad_flor = variedad_flor.id_variedad_flor
			and variedad_flor.id_variedad_flor = 851
			and convert(datetime,convert(nvarchar,ramo.fecha_entrada, 103)) between
			(DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 0, getdate())), 0)) and convert(datetime,convert(nvarchar, getdate(), 103))
		) as tallos_por_ramo_total
		FROM tipo_flor as t, 
		variedad_flor as v, 
		grado_flor as g, 
		ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and convert(datetime,convert(nvarchar,r.fecha_entrada, 103)) between
		(DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 0, getdate())), 0)) and convert(datetime,convert(nvarchar,getdate() - 2, 103))
		and v.id_variedad_flor = 851
		group by v.id_tipo_flor, 
		v.id_variedad_flor, 
		t.nombre_tipo_flor, 
		v.nombre_variedad_flor, 
		g.id_grado_flor, 
		g.nombre_grado_flor, 
		datepart(year,r.fecha_entrada) 
	end

	select id_tipo_flor, 
	id_variedad_flor, 
	nombre_tipo_flor, 
	nombre_variedad_flor, 
	id_grado_flor, 
	nombre_grado_flor, 
	numero_mes,
	case
	when isnumeric(left(nombre_mes,1)) = 0 then left(nombre_mes,3)
	else nombre_mes 
	end as nombre_mes, 
	ano, 
	tallos_por_ramo,
	tallos_por_ramo_total 
	from #temp_detalle 
	order by ano, numero_mes

	drop table #temp_meses_tv
	drop table #temp_detalle
end
else
IF @accion = 'consultar'
BEGIN
	create table #resultado
	(
		id_tipo_flor int,
		id_variedad_flor int,
		nombre_tipo_flor nvarchar(255),
		nombre_variedad_flor nvarchar(255),
		id_grado_flor int,
		nombre_grado_flor nvarchar(255),
		periodo nvarchar(255),
		ano int,
		tallos_por_ramo int,
		tallos_por_ramo_total int,
		dia_año int
	)

	IF @periodo = 'DIAS'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(day, DATEDIFF(day, 0, DATEADD(day, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(day, 1, @fecha_entrada)

		SELECT convert(nvarchar,datepart(month, r.fecha_entrada)) + '/' + datename(day, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_dias
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		group by convert(nvarchar,datepart(month, r.fecha_entrada)),
		datename(day, r.fecha_entrada),
		datepart(year,r.fecha_entrada)


		insert into #resultado
		(
		id_tipo_flor,
		id_variedad_flor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_grado_flor,
		nombre_grado_flor,
		periodo,
		ano,
		tallos_por_ramo,
		tallos_por_ramo_total,
		dia_año
		)
		SELECT v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, convert(nvarchar,datepart(month, r.fecha_entrada)) + '/' + datename(day, r.fecha_entrada) as periodo
		, datepart(year,r.fecha_entrada) as ano
		, isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
		(
			select #temp_dias.tallos_por_ramo_total 
			from #temp_dias
			where #temp_dias.periodo = convert(nvarchar,datepart(month, r.fecha_entrada)) + '/' + datename(day, r.fecha_entrada)
			and #temp_dias.ano = datepart(year,r.fecha_entrada)
		) as tallos_por_ramo_total,
		datepart(dy, r.fecha_entrada) as dia_año
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada

		drop table #temp_dias
	END
	ELSE IF @periodo = 'SEMANAS'
	BEGIN 
		set @fecha_entrada_inicial = DATEADD(week, DATEDIFF(week, 0, DATEADD(week, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(week, 1, @fecha_entrada)

		SELECT datename(week, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_semanas
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		group by datename(week, r.fecha_entrada),
		datepart(year,r.fecha_entrada)

		insert into #resultado
		(
		id_tipo_flor,
		id_variedad_flor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_grado_flor,
		nombre_grado_flor,
		periodo,
		ano,
		tallos_por_ramo,
		tallos_por_ramo_total,
		dia_año
		)
		SELECT v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, datename(week, r.fecha_entrada) as periodo
		, datepart(year,r.fecha_entrada) as ano
		, isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
		(select #temp_semanas.tallos_por_ramo_total from #temp_semanas
		where #temp_semanas.periodo = datename(week, r.fecha_entrada)
		and #temp_semanas.ano = datepart(year,r.fecha_entrada)) as tallos_por_ramo_total,
		datepart(dy, r.fecha_entrada) as dia_año
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada

		drop table #temp_semanas
	END
	ELSE IF @periodo = 'MESES'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(month, DATEDIFF(month, 0, DATEADD(month, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(month, 1, @fecha_entrada)

		SELECT datename(month, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_meses
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		group by datename(month, r.fecha_entrada),
		datepart(year,r.fecha_entrada)

		insert into #resultado
		(
		id_tipo_flor,
		id_variedad_flor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_grado_flor,
		nombre_grado_flor,
		periodo,
		ano,
		tallos_por_ramo,
		tallos_por_ramo_total,
		dia_año
		)
		SELECT v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, datename(month, r.fecha_entrada) as periodo
		, datepart(year,r.fecha_entrada) as ano
		, isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
		(
			select #temp_meses.tallos_por_ramo_total 
			from #temp_meses
			where #temp_meses.periodo = datename(month, r.fecha_entrada)
			and #temp_meses.ano = datepart(year,r.fecha_entrada)
		) as tallos_por_ramo_total,
		datepart(dy, r.fecha_entrada) as dia_año
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada

		drop table #temp_meses
	END
	ELSE IF @periodo = 'TRIMESTRES'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(quarter, DATEDIFF(quarter, 0, DATEADD(quarter, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(quarter, 1, @fecha_entrada)

		SELECT datename(quarter, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_trimestres
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		group by datename(quarter, r.fecha_entrada),
		datepart(year,r.fecha_entrada)

		insert into #resultado
		(
		id_tipo_flor,
		id_variedad_flor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_grado_flor,
		nombre_grado_flor,
		periodo,
		ano,
		tallos_por_ramo,
		tallos_por_ramo_total,
		dia_año
		)
		SELECT v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, datename(quarter, r.fecha_entrada) as periodo
		, datepart(year,r.fecha_entrada) as ano
		, isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
		(select #temp_trimestres.tallos_por_ramo_total from #temp_trimestres
		where #temp_trimestres.periodo = datename(quarter, r.fecha_entrada)
		and #temp_trimestres.ano = datepart(year,r.fecha_entrada)) as tallos_por_ramo_total,
		datepart(dy, r.fecha_entrada) as dia_año
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada

		drop table #temp_trimestres
	END
	ELSE IF @periodo = 'AÑOS'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(year, DATEDIFF(year, 0, DATEADD(year, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(year, 1, @fecha_entrada)

		SELECT datename(year, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_anos
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		group by datepart(year,r.fecha_entrada),
		datename(year, r.fecha_entrada)

		insert into #resultado
		(
		id_tipo_flor,
		id_variedad_flor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_grado_flor,
		nombre_grado_flor,
		periodo,
		ano,
		tallos_por_ramo,
		tallos_por_ramo_total,
		dia_año
		)
		SELECT v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, datename(year, r.fecha_entrada) as periodo
		, datepart(year,r.fecha_entrada) as ano
		, isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo,
		(select #temp_anos.tallos_por_ramo_total from #temp_anos
		where #temp_anos.periodo = datename(year, r.fecha_entrada)
		and #temp_anos.ano = datepart(year,r.fecha_entrada)) as tallos_por_ramo_total,
		datepart(dy, r.fecha_entrada) as dia_año
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada

		drop table #temp_anos
	END

select @conteo = count(*)
from #resultado
where id_grado_flor = 616

if(@conteo = 0)
begin
	if(@id_variedad_flor  = 851)
	begin
		insert into #resultado
		(
		periodo,
		ano,
		id_tipo_flor,
		id_variedad_flor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_grado_flor,
		nombre_grado_flor,
		tallos_por_ramo,
		tallos_por_ramo_total,
		dia_año
		)
		select top 1 #resultado.periodo, #resultado.ano, 77, 851, 'ROSES', 'FREEDOM', 616, '30 Cm', 0, #resultado.tallos_por_ramo_total, 1
		from #resultado
	end
end

select * from #resultado

drop table #resultado
END			
ELSE IF @accion = 'tipo_flor'
BEGIN
	IF @periodo = 'DIAS' 
	BEGIN
		set @fecha_entrada_inicial = DATEADD(day, DATEDIFF(day, 0, DATEADD(day, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(day, 1, @fecha_entrada)

		SELECT v.id_tipo_flor
		, t.nombre_tipo_flor
		FROM tipo_flor as t
		, variedad_flor as v
		, ramo as r
		WHERE t.id_tipo_flor = v.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		group by v.id_tipo_flor
		, t.nombre_tipo_flor
		--order by t.nombre_tipo_flor
	END
	ELSE IF @periodo = 'SEMANAS'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(week, DATEDIFF(week, 0, DATEADD(week, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(week, 1, @fecha_entrada)

		SELECT v.id_tipo_flor
		, t.nombre_tipo_flor
		FROM tipo_flor as t
		, variedad_flor as v
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		group by v.id_tipo_flor
		, t.nombre_tipo_flor
		--order by t.nombre_tipo_flor
	END
	ELSE IF @periodo = 'MESES'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(month, DATEDIFF(month, 0, DATEADD(month, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(month, 1, @fecha_entrada)

		SELECT v.id_tipo_flor
		, t.nombre_tipo_flor
		FROM tipo_flor as t
		, variedad_flor as v
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		group by v.id_tipo_flor
		, t.nombre_tipo_flor
		--order by t.nombre_tipo_flor
	END
	ELSE IF @periodo = 'TRIMESTRES'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(quarter, DATEDIFF(quarter, 0, DATEADD(quarter, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(quarter, 1, @fecha_entrada)

		SELECT v.id_tipo_flor
		, t.nombre_tipo_flor
		FROM tipo_flor as t
		, variedad_flor as v
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		group by v.id_tipo_flor
		, t.nombre_tipo_flor
		order by t.nombre_tipo_flor
	END
	ELSE IF @periodo = 'AÑOS'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(year, DATEDIFF(year, 0, DATEADD(year, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(year, 1, @fecha_entrada)

		SELECT v.id_tipo_flor
		, t.nombre_tipo_flor
		FROM tipo_flor as t
		, variedad_flor as v
		, ramo as r
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		group by v.id_tipo_flor
		, t.nombre_tipo_flor
		order by t.nombre_tipo_flor
	END
END
ELSE IF @accion = 'variedad_flor'
BEGIN
	IF @periodo = 'DIAS' 
	BEGIN
		set @fecha_entrada_inicial = DATEADD(day, DATEDIFF(day, 0, DATEADD(day, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(day, 1, @fecha_entrada)

		SELECT v.id_variedad_flor
		, v.nombre_variedad_flor
		FROM variedad_flor as v
		, ramo as r
		WHERE v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_tipo_flor = @id_tipo_flor
		group by v.id_variedad_flor
		, v.nombre_variedad_flor
		order by v.nombre_variedad_flor
	END
	ELSE IF @periodo = 'SEMANAS'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(week, DATEDIFF(week, 0, DATEADD(week, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(week, 1, @fecha_entrada)

		SELECT v.id_variedad_flor
		, v.nombre_variedad_flor
		FROM variedad_flor as v
		, ramo as r
		WHERE v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_tipo_flor = @id_tipo_flor
		group by v.id_variedad_flor
		, v.nombre_variedad_flor
		order by v.nombre_variedad_flor
	END
	ELSE IF @periodo = 'MESES'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(month, DATEDIFF(month, 0, DATEADD(month, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(month, 1, @fecha_entrada)

		SELECT v.id_variedad_flor
		, v.nombre_variedad_flor
		FROM variedad_flor as v
		, ramo as r
		WHERE v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_tipo_flor = @id_tipo_flor
		group by v.id_variedad_flor
		, v.nombre_variedad_flor
		order by v.nombre_variedad_flor
	END
	ELSE IF @periodo = 'TRIMESTRES'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(quarter, DATEDIFF(quarter, 0, DATEADD(quarter, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(quarter, 1, @fecha_entrada)

		SELECT v.id_variedad_flor
		, v.nombre_variedad_flor
		FROM variedad_flor as v
		, ramo as r
		WHERE v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_tipo_flor = @id_tipo_flor
		group by v.id_variedad_flor
		, v.nombre_variedad_flor
		order by v.nombre_variedad_flor
	END
	ELSE IF @periodo = 'AÑOS'
	BEGIN
		set @fecha_entrada_inicial = DATEADD(year, DATEDIFF(year, 0, DATEADD(year, -(@numero_periodos-1), @fecha_entrada)), 0)
		set @fecha_entrada = DATEADD(year, 1, @fecha_entrada)

		SELECT v.id_variedad_flor
		, v.nombre_variedad_flor
		FROM variedad_flor as v
		, ramo as r
		WHERE v.id_variedad_flor = r.id_variedad_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_tipo_flor = @id_tipo_flor
		group by v.id_variedad_flor
		, v.nombre_variedad_flor
		order by v.nombre_variedad_flor
	END
END
END