set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_consultar_ramo_version2]

@accion nvarchar(255),
@id_tipo_flor int,
@id_variedad_flor int,
@fecha_entrada_string nvarchar(255),
@periodo nvarchar(255),
@numero_periodos int,
@id_punto_corte int

AS

if (@accion = 'consultar')
begin
	set language 'spanish'

	declare @fecha_entrada DATETIME, 
	@fecha_entrada_inicial DATETIME,
	@conteo int

	set @fecha_entrada = @fecha_entrada_string

	select @fecha_entrada_inicial =
	case
		when @periodo = 'DIAS' then DATEADD(day, DATEDIFF(day, 0, DATEADD(day, -(@numero_periodos-1), @fecha_entrada)), 0)
		when @periodo = 'SEMANAS' then DATEADD(week, DATEDIFF(week, 0, DATEADD(week, -(@numero_periodos-1), @fecha_entrada)), 0)
		when @periodo = 'MESES' then DATEADD(month, DATEDIFF(month, 0, DATEADD(month, -(@numero_periodos-1), @fecha_entrada)), 0)
		when @periodo = 'TRIMESTRES' then DATEADD(quarter, DATEDIFF(quarter, 0, DATEADD(quarter, -(@numero_periodos-1), @fecha_entrada)), 0)
		when @periodo = 'AÑOS' then DATEADD(year, DATEDIFF(year, 0, DATEADD(year, -(@numero_periodos-1), @fecha_entrada)), 0)
	end,
	@fecha_entrada = 
	case
		when @periodo = 'DIAS' then DATEADD(day, 1, @fecha_entrada)
		when @periodo = 'SEMANAS' then DATEADD(week, 1, @fecha_entrada)
		when @periodo = 'MESES' then DATEADD(month, 1, @fecha_entrada)
		when @periodo = 'TRIMESTRES' then DATEADD(quarter, 1, @fecha_entrada)
		when @periodo = 'AÑOS' then DATEADD(year, 1, @fecha_entrada)
	end

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
		dia_año int,
		nombre_punto_corte nvarchar(255)
	)

	IF (@periodo = 'DIAS')
	begin
		SELECT convert(nvarchar,datepart(month, r.fecha_entrada)) + '/' + datename(day, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_dias
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
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
		dia_año,
		nombre_punto_corte
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
		datepart(dy, r.fecha_entrada) as dia_año,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end as nombre_punto_corte
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end

		drop table #temp_dias
	END
	ELSE IF @periodo = 'SEMANAS'
	BEGIN 
		SELECT datename(week, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_semanas
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
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
		dia_año,
		nombre_punto_corte
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
		datepart(dy, r.fecha_entrada) as dia_año,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end as nombre_punto_corte
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end

		drop table #temp_semanas
	END
	ELSE IF @periodo = 'MESES'
	BEGIN
		SELECT datename(month, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_meses
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
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
		dia_año,
		nombre_punto_corte
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
		datepart(dy, r.fecha_entrada) as dia_año,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end as nombre_punto_corte
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end

		drop table #temp_meses
	END
	ELSE IF @periodo = 'TRIMESTRES'
	BEGIN
		SELECT datename(quarter, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_trimestres
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
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
		dia_año,
		nombre_punto_corte
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
		datepart(dy, r.fecha_entrada) as dia_año,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end as nombre_punto_corte
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end

		drop table #temp_trimestres
	END
	ELSE IF @periodo = 'AÑOS'
	BEGIN
		SELECT datename(year, r.fecha_entrada) as periodo,
		datepart(year,r.fecha_entrada) as ano,
		isnull(sum(r.tallos_por_ramo) ,0) as tallos_por_ramo_total into #temp_anos
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada			
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
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
		dia_año,
		nombre_punto_corte
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
		datepart(dy, r.fecha_entrada) as dia_año,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end as nombre_punto_corte
		FROM tipo_flor as t
		, variedad_flor as v
		, grado_flor as g
		, ramo as r,
		punto_corte
		WHERE v.id_tipo_flor = t.id_tipo_flor
		and g.id_tipo_flor = t.id_tipo_flor
		and v.id_variedad_flor = r.id_variedad_flor
		and g.id_grado_flor = r.id_grado_flor
		and r.fecha_entrada between @fecha_entrada_inicial and @fecha_entrada
		and v.id_variedad_flor = @id_variedad_flor
		and punto_corte.id_punto_corte = r.id_punto_corte
		and punto_corte.id_punto_corte > = 
		case
			when @id_punto_corte = 0 then 1
			else @id_punto_corte
		end
		and punto_corte.id_punto_corte < = 
		case
			when @id_punto_corte = 0 then 999
			else @id_punto_corte
		end
		group by v.id_tipo_flor
		, v.id_variedad_flor
		, t.nombre_tipo_flor
		, v.nombre_variedad_flor
		, g.id_grado_flor
		, g.nombre_grado_flor
		, r.fecha_entrada,
		case
			when @id_punto_corte = 0 then 'TODOS'
			else punto_corte.nombre_punto_corte
		end

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
		dia_año,
		nombre_punto_corte
		)
		select top 1 #resultado.periodo, #resultado.ano, 77, 851, 'ROSES', 'FREEDOM', 616, '30 Cm', 0, #resultado.tallos_por_ramo_total, 1, #resultado.nombre_punto_corte
		from #resultado
	end
end

select * from #resultado

drop table #resultado
END			
ELSE IF @accion = 'tipo_flor'
BEGIN
	SELECT tipo_flor.id_tipo_flor,
	tipo_flor.nombre_tipo_flor
	FROM tipo_flor
	where tipo_flor.idc_tipo_flor in ('RO', 'RS')
	order by tipo_flor.nombre_tipo_flor
END
ELSE IF @accion = 'variedad_flor'
BEGIN
	SELECT variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor
	FROM variedad_flor
	WHERE variedad_flor.id_tipo_flor = @id_tipo_flor
	and variedad_flor.disponible = 1
	order by variedad_flor.nombre_variedad_flor
END
ELSE 
if (@accion = 'punto_corte')
begin
	SELECT punto_corte.id_punto_corte,
	punto_corte.nombre_punto_corte
	FROM punto_corte
	WHERE disponible = 1
	order by punto_corte.nombre_punto_corte
end