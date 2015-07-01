set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2007-08-23
-- Description:	consular rendimientos corte
-- =============================================

ALTER PROCEDURE [dbo].[inv_consultar_rendimiento]

@fecha_entrada_string nvarchar(255),
@accion nvarchar(255)

AS

BEGIN

declare @fecha_entrada datetime,
@id_conteo_propietario_cama int,
@id_conteo_propietario_cama_actual int,
@fecha_inicial datetime,
@fecha_conteo_actual datetime,
@fecha_final datetime

set @fecha_entrada = convert(datetime, @fecha_entrada_string, 101)

if(@accion = 'reporte_produccion_vs_estimados_san_valentin')
begin
	select top 1 @id_conteo_propietario_cama_actual = max(conteo_propietario_cama.id_conteo_propietario_cama),
	@fecha_conteo_actual = fecha_conteo
	from tipo_conteo_propietario_cama,
	conteo_propietario_cama
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and tipo_conteo_propietario_cama.nombre = 'Estimado San Valentin'
	group by fecha_conteo
	order by fecha_conteo desc

	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	persona.id_persona,
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as tallos_estimados_semana_actual,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	bloque.idc_bloque as bloque,
	bloque.id_bloque into #comparativo_matriz_estimado_san_valentin
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama,
	persona,
	tipo_flor,
	variedad_flor,
	supervisor,
	bloque
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama_actual
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and supervisor.id_supervisor = persona.id_supervisor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	group by persona.id_persona, 
	ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)),
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	tipo_flor.idc_tipo_flor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque

	insert into #comparativo_matriz_estimado_san_valentin
	(
		nombre, 
		tallos_estimados_semana_actual,
		codigo_supervisor,
		nombre_supervisor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		bloque,
		id_persona,
		id_variedad_flor,
		id_bloque
	)
	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	0,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	bloque.idc_bloque as bloque,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque
	from pieza_postcosecha,
	variedad_flor,
	tipo_flor,
	persona,
	supervisor,
	bloque
	where pieza_postcosecha.id_bloque = bloque.id_bloque
	and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and pieza_postcosecha.id_persona = persona.id_persona
	and persona.id_supervisor = supervisor.id_supervisor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) between
	dateadd(dd, 1, @fecha_conteo_actual) and dateadd(dd, 7, @fecha_conteo_actual)
	and not exists
	(
		select * from #comparativo_matriz_estimado_san_valentin
		where #comparativo_matriz_estimado_san_valentin.id_variedad_flor = variedad_flor.id_variedad_flor
		and #comparativo_matriz_estimado_san_valentin.id_persona = persona.id_persona
		and #comparativo_matriz_estimado_san_valentin.id_bloque = bloque.id_bloque
	)
	group by ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)), 
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	variedad_flor.idc_variedad_flor,
	bloque.idc_bloque,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque
	having sum(unidades_por_pieza) > 0

	alter table #comparativo_matriz_estimado_san_valentin
	add produccion_dia1 int,
	produccion_dia2 int,
	produccion_dia3 int,
	produccion_dia4 int,
	produccion_dia5 int,
	produccion_dia6 int,
	produccion_dia7 int

	select sum(unidades_por_pieza) as cantidad,
	id_persona,
	id_bloque,
	id_variedad_flor,
	convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) as fecha into #dias_semana_estimado_san_valentin
	from pieza_postcosecha
	where convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) between
	dateadd(dd, 1, @fecha_conteo_actual) and dateadd(dd, 7, @fecha_conteo_actual)
	group by id_persona,
	id_bloque,
	id_variedad_flor,
	convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101))	

	update #comparativo_matriz_estimado_san_valentin
	set produccion_dia1 = cantidad
	from #dias_semana_estimado_san_valentin
	where #dias_semana_estimado_san_valentin.id_persona = #comparativo_matriz_estimado_san_valentin.id_persona
	and #dias_semana_estimado_san_valentin.id_bloque = #comparativo_matriz_estimado_san_valentin.id_bloque
	and #dias_semana_estimado_san_valentin.id_variedad_flor = #comparativo_matriz_estimado_san_valentin.id_variedad_flor
	and #dias_semana_estimado_san_valentin.fecha = dateadd(dd, 1, @fecha_conteo_actual)

	update #comparativo_matriz_estimado_san_valentin
	set produccion_dia2 = cantidad
	from #dias_semana_estimado_san_valentin
	where #dias_semana_estimado_san_valentin.id_persona = #comparativo_matriz_estimado_san_valentin.id_persona
	and #dias_semana_estimado_san_valentin.id_bloque = #comparativo_matriz_estimado_san_valentin.id_bloque
	and #dias_semana_estimado_san_valentin.id_variedad_flor = #comparativo_matriz_estimado_san_valentin.id_variedad_flor
	and #dias_semana_estimado_san_valentin.fecha = dateadd(dd, 2, @fecha_conteo_actual)

	update #comparativo_matriz_estimado_san_valentin
	set produccion_dia3 = cantidad
	from #dias_semana_estimado_san_valentin
	where #dias_semana_estimado_san_valentin.id_persona = #comparativo_matriz_estimado_san_valentin.id_persona
	and #dias_semana_estimado_san_valentin.id_bloque = #comparativo_matriz_estimado_san_valentin.id_bloque
	and #dias_semana_estimado_san_valentin.id_variedad_flor = #comparativo_matriz_estimado_san_valentin.id_variedad_flor
	and #dias_semana_estimado_san_valentin.fecha = dateadd(dd, 3, @fecha_conteo_actual)

	update #comparativo_matriz_estimado_san_valentin
	set produccion_dia4 = cantidad
	from #dias_semana_estimado_san_valentin
	where #dias_semana_estimado_san_valentin.id_persona = #comparativo_matriz_estimado_san_valentin.id_persona
	and #dias_semana_estimado_san_valentin.id_bloque = #comparativo_matriz_estimado_san_valentin.id_bloque
	and #dias_semana_estimado_san_valentin.id_variedad_flor = #comparativo_matriz_estimado_san_valentin.id_variedad_flor
	and #dias_semana_estimado_san_valentin.fecha = dateadd(dd, 4, @fecha_conteo_actual)

	update #comparativo_matriz_estimado_san_valentin
	set produccion_dia5 = cantidad
	from #dias_semana_estimado_san_valentin
	where #dias_semana_estimado_san_valentin.id_persona = #comparativo_matriz_estimado_san_valentin.id_persona
	and #dias_semana_estimado_san_valentin.id_bloque = #comparativo_matriz_estimado_san_valentin.id_bloque
	and #dias_semana_estimado_san_valentin.id_variedad_flor = #comparativo_matriz_estimado_san_valentin.id_variedad_flor
	and #dias_semana_estimado_san_valentin.fecha = dateadd(dd, 5, @fecha_conteo_actual)

	update #comparativo_matriz_estimado_san_valentin
	set produccion_dia6 = cantidad
	from #dias_semana_estimado_san_valentin
	where #dias_semana_estimado_san_valentin.id_persona = #comparativo_matriz_estimado_san_valentin.id_persona
	and #dias_semana_estimado_san_valentin.id_bloque = #comparativo_matriz_estimado_san_valentin.id_bloque
	and #dias_semana_estimado_san_valentin.id_variedad_flor = #comparativo_matriz_estimado_san_valentin.id_variedad_flor
	and #dias_semana_estimado_san_valentin.fecha = dateadd(dd, 6, @fecha_conteo_actual)

	update #comparativo_matriz_estimado_san_valentin
	set produccion_dia7 = cantidad
	from #dias_semana_estimado_san_valentin
	where #dias_semana_estimado_san_valentin.id_persona = #comparativo_matriz_estimado_san_valentin.id_persona
	and #dias_semana_estimado_san_valentin.id_bloque = #comparativo_matriz_estimado_san_valentin.id_bloque
	and #dias_semana_estimado_san_valentin.id_variedad_flor = #comparativo_matriz_estimado_san_valentin.id_variedad_flor
	and #dias_semana_estimado_san_valentin.fecha = dateadd(dd, 7, @fecha_conteo_actual)

	select nombre, 
	tallos_estimados_semana_actual,
	codigo_supervisor,
	nombre_supervisor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	bloque,
	@fecha_conteo_actual as fecha_conteo_actual,
	produccion_dia1,
	produccion_dia2,
	produccion_dia3,
	produccion_dia4,
	produccion_dia5,
	produccion_dia6,
	produccion_dia7,
	(
	isnull(produccion_dia1, 0) +
	isnull(produccion_dia2, 0) +
	isnull(produccion_dia3, 0) +
	isnull(produccion_dia4, 0) +
	isnull(produccion_dia5, 0) +
	isnull(produccion_dia6, 0) +
	isnull(produccion_dia7, 0)
	) as produccion_total
	from #comparativo_matriz_estimado_san_valentin
	where 
	(
	(
		isnull(produccion_dia1, 0) +
		isnull(produccion_dia2, 0) +
		isnull(produccion_dia3, 0) +
		isnull(produccion_dia4, 0) +
		isnull(produccion_dia5, 0) +
		isnull(produccion_dia6, 0) +
		isnull(produccion_dia7, 0)
	) > 0
	or tallos_estimados_semana_actual > 0
	)
	order by 
	nombre_variedad_flor,
	bloque,
	nombre

	drop table #comparativo_matriz_estimado_san_valentin
	drop table #dias_semana_estimado_san_valentin
end
else
if(@accion = 'reporte_produccion_vs_estimados_matriz')
begin
	select top 1 @id_conteo_propietario_cama_actual = max(conteo_propietario_cama.id_conteo_propietario_cama),
	@fecha_conteo_actual = fecha_conteo
	from tipo_conteo_propietario_cama,
	conteo_propietario_cama
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and tipo_conteo_propietario_cama.nombre = 'Estimado semana entrante'
	group by fecha_conteo
	order by fecha_conteo desc

	select top 1 @id_conteo_propietario_cama = max(conteo_propietario_cama.id_conteo_propietario_cama),
	@fecha_inicial = dateadd(dd, 1, fecha_conteo),
	@fecha_final = dateadd(dd, 6, dateadd(dd, 1, fecha_conteo)) 
	from tipo_conteo_propietario_cama,
	conteo_propietario_cama
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and tipo_conteo_propietario_cama.nombre = 'Estimado semana entrante'
	and conteo_propietario_cama.id_conteo_propietario_cama < @id_conteo_propietario_cama_actual 
	group by 
	fecha_conteo
	order by fecha_conteo desc

	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	persona.id_persona,
	isnull((
		select sum(pieza_postcosecha.unidades_por_pieza)
		as tallos_cortados_semana
		from pieza_postcosecha
		where pieza_postcosecha.id_persona = Persona.id_persona
		and convert(nvarchar, pieza_postcosecha.fecha_entrada, 101) between
		@fecha_inicial and @fecha_final
		and pieza_postcosecha.id_bloque = bloque.id_bloque
		and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	), 0) as tallos_cortados_semana, 
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as tallos_estimados_semana,
	isnull(sum(detalle_conteo_propietario_cama.unidades_estimadas) - 
	(
		select sum(pieza_postcosecha.unidades_por_pieza)
		as tallos_cortados_semana
		from pieza_postcosecha
		where pieza_postcosecha.id_persona = Persona.id_persona
		and convert(nvarchar, pieza_postcosecha.fecha_entrada, 101) between
		@fecha_inicial and @fecha_final
		and pieza_postcosecha.id_bloque = bloque.id_bloque
		and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	), 0)  as faltante,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	bloque.idc_bloque as bloque,
	bloque.id_bloque,
	@fecha_inicial as fecha_inicial,
	@fecha_final as fecha_final into #comparativo_matriz
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama,
	persona,
	tipo_flor,
	variedad_flor,
	supervisor,
	bloque
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and supervisor.id_supervisor = persona.id_supervisor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	group by persona.id_persona, 
	ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)),
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	tipo_flor.idc_tipo_flor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque

	insert into #comparativo_matriz 
	(
		nombre, 
		tallos_cortados_semana, 
		tallos_estimados_semana,
		faltante,
		codigo_supervisor,
		nombre_supervisor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		bloque,
		fecha_inicial,
		fecha_final,
		id_persona,
		id_variedad_flor,
		id_bloque
	)
	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	sum(pieza_postcosecha.unidades_por_pieza),
	0,
	0 - sum(pieza_postcosecha.unidades_por_pieza),
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	bloque.idc_bloque as bloque,
	@fecha_inicial as fecha_inicial,
	@fecha_final as fecha_final,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque
	from pieza_postcosecha,
	variedad_flor,
	tipo_flor,
	persona,
	supervisor,
	bloque
	where pieza_postcosecha.id_bloque = bloque.id_bloque
	and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and pieza_postcosecha.id_persona = persona.id_persona
	and persona.id_supervisor = supervisor.id_supervisor
	and convert(nvarchar, pieza_postcosecha.fecha_entrada, 101) between
	@fecha_inicial and @fecha_final
	and not exists
	(
		select * from #comparativo_matriz
		where #comparativo_matriz.id_variedad_flor = variedad_flor.id_variedad_flor
		and #comparativo_matriz.id_persona = persona.id_persona
		and #comparativo_matriz.id_bloque = bloque.id_bloque
	)
	group by ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)), 
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	variedad_flor.idc_variedad_flor,
	bloque.idc_bloque,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque

	alter table #comparativo_matriz
	add tallos_estimados_semana_actual int,
	produccion_dia1 int,
	produccion_dia2 int,
	produccion_dia3 int,
	produccion_dia4 int,
	produccion_dia5 int,
	produccion_dia6 int,
	produccion_dia7 int

	insert into #comparativo_matriz
	(
		nombre, 
		id_persona,
		tallos_cortados_semana, 
		tallos_estimados_semana_actual,
		tallos_estimados_semana,
		faltante,
		codigo_supervisor,
		nombre_supervisor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_variedad_flor,	
		bloque,
		id_bloque,
		fecha_inicial,
		fecha_final		
	)
	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	persona.id_persona,
	0 as tallos_cortados_semana, 
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as tallos_estimados_semana_actual,
	0 as tallos_estimados_semana,
	0 as faltante,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	bloque.idc_bloque as bloque,
	bloque.id_bloque,
	@fecha_inicial as fecha_inicial,
	@fecha_final as fecha_final
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama,
	persona,
	tipo_flor,
	variedad_flor,
	supervisor,
	bloque
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama_actual
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and supervisor.id_supervisor = persona.id_supervisor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and not exists
		(
			select * from #comparativo_matriz
			where #comparativo_matriz.id_variedad_flor = variedad_flor.id_variedad_flor
			and #comparativo_matriz.id_persona = persona.id_persona
			and #comparativo_matriz.id_bloque = bloque.id_bloque
		)
	group by persona.id_persona, 
	ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)),
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	tipo_flor.idc_tipo_flor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque

	update #comparativo_matriz
	set tallos_estimados_semana_actual = detalle_conteo_propietario_cama.unidades_estimadas
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama_actual
	and detalle_conteo_propietario_cama.id_persona = #comparativo_matriz.id_persona
	and detalle_conteo_propietario_cama.id_bloque = #comparativo_matriz.id_bloque
	and detalle_conteo_propietario_cama.id_variedad_flor = #comparativo_matriz.id_variedad_flor


	select sum(unidades_por_pieza) as cantidad,
	id_persona,
	id_bloque,
	id_variedad_flor,
	convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) as fecha into #dias_semana
	from pieza_postcosecha
	where convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) between
	dateadd(dd, 1, @fecha_conteo_actual) and dateadd(dd, 7, @fecha_conteo_actual)
	group by id_persona,
	id_bloque,
	id_variedad_flor,
	convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101))	

	update #comparativo_matriz
	set produccion_dia1 = cantidad
	from #dias_semana
	where #dias_semana.id_persona = #comparativo_matriz.id_persona
	and #dias_semana.id_bloque = #comparativo_matriz.id_bloque
	and #dias_semana.id_variedad_flor = #comparativo_matriz.id_variedad_flor
	and #dias_semana.fecha = dateadd(dd, 1, @fecha_conteo_actual)

	update #comparativo_matriz
	set produccion_dia2 = cantidad
	from #dias_semana
	where #dias_semana.id_persona = #comparativo_matriz.id_persona
	and #dias_semana.id_bloque = #comparativo_matriz.id_bloque
	and #dias_semana.id_variedad_flor = #comparativo_matriz.id_variedad_flor
	and #dias_semana.fecha = dateadd(dd, 2, @fecha_conteo_actual)

	update #comparativo_matriz
	set produccion_dia3 = cantidad
	from #dias_semana
	where #dias_semana.id_persona = #comparativo_matriz.id_persona
	and #dias_semana.id_bloque = #comparativo_matriz.id_bloque
	and #dias_semana.id_variedad_flor = #comparativo_matriz.id_variedad_flor
	and #dias_semana.fecha = dateadd(dd, 3, @fecha_conteo_actual)

	update #comparativo_matriz
	set produccion_dia4 = cantidad
	from #dias_semana
	where #dias_semana.id_persona = #comparativo_matriz.id_persona
	and #dias_semana.id_bloque = #comparativo_matriz.id_bloque
	and #dias_semana.id_variedad_flor = #comparativo_matriz.id_variedad_flor
	and #dias_semana.fecha = dateadd(dd, 4, @fecha_conteo_actual)

	update #comparativo_matriz
	set produccion_dia5 = cantidad
	from #dias_semana
	where #dias_semana.id_persona = #comparativo_matriz.id_persona
	and #dias_semana.id_bloque = #comparativo_matriz.id_bloque
	and #dias_semana.id_variedad_flor = #comparativo_matriz.id_variedad_flor
	and #dias_semana.fecha = dateadd(dd, 5, @fecha_conteo_actual)

	update #comparativo_matriz
	set produccion_dia6 = cantidad
	from #dias_semana
	where #dias_semana.id_persona = #comparativo_matriz.id_persona
	and #dias_semana.id_bloque = #comparativo_matriz.id_bloque
	and #dias_semana.id_variedad_flor = #comparativo_matriz.id_variedad_flor
	and #dias_semana.fecha = dateadd(dd, 6, @fecha_conteo_actual)

	update #comparativo_matriz
	set produccion_dia7 = cantidad
	from #dias_semana
	where #dias_semana.id_persona = #comparativo_matriz.id_persona
	and #dias_semana.id_bloque = #comparativo_matriz.id_bloque
	and #dias_semana.id_variedad_flor = #comparativo_matriz.id_variedad_flor
	and #dias_semana.fecha = dateadd(dd, 7, @fecha_conteo_actual)

	select nombre, 
	tallos_cortados_semana, 
	tallos_estimados_semana,
	tallos_estimados_semana_actual,
	faltante,
	codigo_supervisor,
	nombre_supervisor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	bloque,
	fecha_inicial,
	fecha_final,
	@fecha_conteo_actual as fecha_conteo_actual,
	produccion_dia1,
	produccion_dia2,
	produccion_dia3,
	produccion_dia4,
	produccion_dia5,
	produccion_dia6,
	produccion_dia7,
	(
	isnull(produccion_dia1, 0) +
	isnull(produccion_dia2, 0) +
	isnull(produccion_dia3, 0) +
	isnull(produccion_dia4, 0) +
	isnull(produccion_dia5, 0) +
	isnull(produccion_dia6, 0) +
	isnull(produccion_dia7, 0)
	) as produccion_total
	from #comparativo_matriz
	order by 
	nombre_variedad_flor,
	bloque,
	nombre

	drop table #comparativo_matriz
	drop table #dias_semana
end
else
if(@accion = 'reporte_produccion_vs_estimados_porcentaje')
begin
	select @id_conteo_propietario_cama = conteo_propietario_cama.id_conteo_propietario_cama,
	@fecha_inicial = dateadd(dd, 1, fecha_conteo),
	@fecha_final = dateadd(dd, 6, dateadd(dd, 1, fecha_conteo)) 
	from tipo_conteo_propietario_cama,
	conteo_propietario_cama,
	detalle_conteo_propietario_cama
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and tipo_conteo_propietario_cama.nombre = 'Estimado semana entrante'
	and @fecha_entrada_string between
	dateadd(dd, 1, fecha_conteo) and dateadd(dd, 6, dateadd(dd, 1, fecha_conteo)) 
	group by 
	conteo_propietario_cama.id_conteo_propietario_cama,
	dateadd(dd, 1, fecha_conteo),
	dateadd(dd, 6, dateadd(dd, 1, fecha_conteo)) 

	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	persona.id_persona,
	isnull((
		select sum(pieza_postcosecha.unidades_por_pieza)
		as tallos_cortados_semana
		from pieza_postcosecha
		where pieza_postcosecha.id_persona = Persona.id_persona
		and convert(nvarchar, pieza_postcosecha.fecha_entrada, 101) between
		@fecha_inicial and @fecha_final
		and pieza_postcosecha.id_bloque = bloque.id_bloque
		and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	), 0) as tallos_cortados_semana, 
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as tallos_estimados_semana,
	isnull(sum(detalle_conteo_propietario_cama.unidades_estimadas) - 
	(
		select sum(pieza_postcosecha.unidades_por_pieza)
		as tallos_cortados_semana
		from pieza_postcosecha
		where pieza_postcosecha.id_persona = Persona.id_persona
		and convert(nvarchar, pieza_postcosecha.fecha_entrada, 101) between
		@fecha_inicial and @fecha_final
		and pieza_postcosecha.id_bloque = bloque.id_bloque
		and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	), 0)  as faltante,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	bloque.idc_bloque as bloque,
	bloque.id_bloque,
	@fecha_inicial as fecha_inicial,
	@fecha_final as fecha_final into #comparativo_porcentaje
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama,
	persona,
	tipo_flor,
	variedad_flor,
	supervisor,
	bloque
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and supervisor.id_supervisor = persona.id_supervisor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	group by persona.id_persona, 
	ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)),
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	tipo_flor.idc_tipo_flor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque

	insert into #comparativo_porcentaje 
	(
		nombre, 
		tallos_cortados_semana, 
		tallos_estimados_semana,
		faltante,
		codigo_supervisor,
		nombre_supervisor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		bloque,
		fecha_inicial,
		fecha_final,
		id_persona,
		id_variedad_flor,
		id_bloque
	)
	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	sum(pieza_postcosecha.unidades_por_pieza),
	0,
	0 - sum(pieza_postcosecha.unidades_por_pieza),
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	bloque.idc_bloque as bloque,
	@fecha_inicial as fecha_inicial,
	@fecha_final as fecha_final,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque
	from pieza_postcosecha,
	variedad_flor,
	tipo_flor,
	persona,
	supervisor,
	bloque
	where pieza_postcosecha.id_bloque = bloque.id_bloque
	and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and pieza_postcosecha.id_persona = persona.id_persona
	and persona.id_supervisor = supervisor.id_supervisor
	and convert(nvarchar, pieza_postcosecha.fecha_entrada, 101) between
	@fecha_inicial and @fecha_final
	and not exists
	(
		select * from #comparativo_porcentaje
		where #comparativo_porcentaje.id_variedad_flor = variedad_flor.id_variedad_flor
		and #comparativo_porcentaje.id_persona = persona.id_persona
		and #comparativo_porcentaje.id_bloque = bloque.id_bloque
	)
	group by ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)), 
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	variedad_flor.idc_variedad_flor,
	bloque.idc_bloque,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque

	select nombre, 
	tallos_cortados_semana, 
	tallos_estimados_semana,
	faltante,
	codigo_supervisor,
	nombre_supervisor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	bloque,
	fecha_inicial,
	fecha_final
	from #comparativo_porcentaje

	drop table #comparativo_porcentaje
end
else
if(@accion = 'reporte_rendimiento_diario')
begin
	select min(fecha) as fecha,
	persona.id_persona into #persona
	from detalle_labor_persona,
	persona
	where detalle_labor_persona.id_persona = persona.id_persona
	and convert(nvarchar, detalle_labor_persona.fecha, 101) = convert(nvarchar, @fecha_entrada, 101)
	group by persona.id_persona

	select persona.id_persona, persona.nombre +' '+ persona.apellido as nombre, 
	sum(pieza_postcosecha.unidades_por_pieza) as tallos_cortados, 
	convert(nvarchar, max(fecha_entrada) - #persona.fecha, 8) as tiempo,
	datediff(mi, #persona.fecha, max(fecha_entrada)) as minutos,
	supervisor.idc_supervisor as idc_area,
	supervisor.nombre_supervisor as nombre_area,
	#persona.fecha as fecha_inicial,
	max(fecha_entrada) as fecha_final into #temp
	from pieza_postcosecha left join #persona on pieza_postcosecha.id_persona = #persona.id_persona, 
	persona,
	supervisor
	where pieza_postcosecha.id_persona = Persona.id_persona
	and convert(nvarchar, pieza_postcosecha.fecha_entrada, 101) = convert(nvarchar, @fecha_entrada, 101)
	and supervisor.id_supervisor = persona.id_supervisor
	group by persona.id_persona, 
	persona.nombre +' '+ persona.apellido,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor,
	#persona.fecha

	select id_persona, 
	nombre, 
	tallos_cortados, 
	left(tiempo, 5) as tiempo, 
	((tallos_cortados * 60)/ minutos) as rendimiento,
	idc_area,
	nombre_area,
	CONVERT(NVARCHAR,fecha_inicial,8) AS fecha_inicial,
	CONVERT(NVARCHAR,fecha_final,8) as fecha_final
	from #temp
	order by rendimiento desc

	drop table #temp
	drop table #persona
end
else
if(@accion = 'reporte_produccion_vs_estimados')
begin
	select top 1 @id_conteo_propietario_cama_actual = max(conteo_propietario_cama.id_conteo_propietario_cama),
	@fecha_conteo_actual = fecha_conteo
	from tipo_conteo_propietario_cama,
	conteo_propietario_cama
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and tipo_conteo_propietario_cama.nombre = 'Estimado semana entrante'
	and conteo_propietario_cama.fecha_conteo < = getdate() - 1
	group by fecha_conteo
	order by fecha_conteo desc

	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	persona.id_persona,
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as tallos_estimados_semana_actual,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	bloque.idc_bloque as bloque,
	bloque.id_bloque,
	detalle_conteo_propietario_cama.numero_consecutivo into #comparativo_matriz_estimado
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama,
	persona,
	tipo_flor,
	variedad_flor,
	supervisor,
	bloque
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama_actual
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and supervisor.id_supervisor = persona.id_supervisor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and bloque.idc_bloque not like 'FA%'
	group by persona.id_persona, 
	ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)),
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	tipo_flor.idc_tipo_flor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	detalle_conteo_propietario_cama.numero_consecutivo

	insert into #comparativo_matriz_estimado
	(
		nombre, 
		tallos_estimados_semana_actual,
		codigo_supervisor,
		nombre_supervisor,
		nombre_tipo_flor,
		nombre_variedad_flor,
		bloque,
		id_persona,
		id_variedad_flor,
		id_bloque,
		numero_consecutivo
	)
	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	0,
	supervisor.idc_supervisor as codigo_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)) + ' (' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' (' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	bloque.idc_bloque as bloque,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque,
	0
	from pieza_postcosecha,
	variedad_flor,
	tipo_flor,
	persona,
	supervisor,
	bloque
	where pieza_postcosecha.id_bloque = bloque.id_bloque
	and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and pieza_postcosecha.id_persona = persona.id_persona
	and persona.id_supervisor = supervisor.id_supervisor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) between
	dateadd(dd, 1, @fecha_conteo_actual) and dateadd(dd, 7, @fecha_conteo_actual)
	and not exists
	(
		select * from #comparativo_matriz_estimado
		where #comparativo_matriz_estimado.id_variedad_flor = variedad_flor.id_variedad_flor
		and #comparativo_matriz_estimado.id_persona = persona.id_persona
		and #comparativo_matriz_estimado.id_bloque = bloque.id_bloque
	)
	--and bloque.idc_bloque like '%ER%'
	and bloque.idc_bloque not like 'FA%'
	group by ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)), 
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	rtrim(ltrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	variedad_flor.idc_variedad_flor,
	bloque.idc_bloque,
	persona.id_persona,
	variedad_flor.id_variedad_flor,
	bloque.id_bloque
	having sum(unidades_por_pieza) > 0

	alter table #comparativo_matriz_estimado
	add produccion_dia1 int,
	produccion_dia2 int,
	produccion_dia3 int,
	produccion_dia4 int,
	produccion_dia5 int,
	produccion_dia6 int,
	produccion_dia7 int

	select sum(unidades_por_pieza) as cantidad,
	id_persona,
	bloque.id_bloque,
	id_variedad_flor,
	convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) as fecha into #dias_semana_estimado
	from pieza_postcosecha,
	bloque
	where convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) between
	dateadd(dd, 1, @fecha_conteo_actual) and dateadd(dd, 7, @fecha_conteo_actual)
	and pieza_postcosecha.id_bloque = bloque.id_bloque
	--and bloque.idc_bloque like '%ER%'
	and bloque.idc_bloque not like 'FA%'
	group by id_persona,
	bloque.id_bloque,
	id_variedad_flor,
	convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101))	

	update #comparativo_matriz_estimado
	set produccion_dia1 = cantidad
	from #dias_semana_estimado
	where #dias_semana_estimado.id_persona = #comparativo_matriz_estimado.id_persona
	and #dias_semana_estimado.id_bloque = #comparativo_matriz_estimado.id_bloque
	and #dias_semana_estimado.id_variedad_flor = #comparativo_matriz_estimado.id_variedad_flor
	and #dias_semana_estimado.fecha = dateadd(dd, 1, @fecha_conteo_actual)

	update #comparativo_matriz_estimado
	set produccion_dia2 = cantidad
	from #dias_semana_estimado
	where #dias_semana_estimado.id_persona = #comparativo_matriz_estimado.id_persona
	and #dias_semana_estimado.id_bloque = #comparativo_matriz_estimado.id_bloque
	and #dias_semana_estimado.id_variedad_flor = #comparativo_matriz_estimado.id_variedad_flor
	and #dias_semana_estimado.fecha = dateadd(dd, 2, @fecha_conteo_actual)

	update #comparativo_matriz_estimado
	set produccion_dia3 = cantidad
	from #dias_semana_estimado
	where #dias_semana_estimado.id_persona = #comparativo_matriz_estimado.id_persona
	and #dias_semana_estimado.id_bloque = #comparativo_matriz_estimado.id_bloque
	and #dias_semana_estimado.id_variedad_flor = #comparativo_matriz_estimado.id_variedad_flor
	and #dias_semana_estimado.fecha = dateadd(dd, 3, @fecha_conteo_actual)

	update #comparativo_matriz_estimado
	set produccion_dia4 = cantidad
	from #dias_semana_estimado
	where #dias_semana_estimado.id_persona = #comparativo_matriz_estimado.id_persona
	and #dias_semana_estimado.id_bloque = #comparativo_matriz_estimado.id_bloque
	and #dias_semana_estimado.id_variedad_flor = #comparativo_matriz_estimado.id_variedad_flor
	and #dias_semana_estimado.fecha = dateadd(dd, 4, @fecha_conteo_actual)

	update #comparativo_matriz_estimado
	set produccion_dia5 = cantidad
	from #dias_semana_estimado
	where #dias_semana_estimado.id_persona = #comparativo_matriz_estimado.id_persona
	and #dias_semana_estimado.id_bloque = #comparativo_matriz_estimado.id_bloque
	and #dias_semana_estimado.id_variedad_flor = #comparativo_matriz_estimado.id_variedad_flor
	and #dias_semana_estimado.fecha = dateadd(dd, 5, @fecha_conteo_actual)

	update #comparativo_matriz_estimado
	set produccion_dia6 = cantidad
	from #dias_semana_estimado
	where #dias_semana_estimado.id_persona = #comparativo_matriz_estimado.id_persona
	and #dias_semana_estimado.id_bloque = #comparativo_matriz_estimado.id_bloque
	and #dias_semana_estimado.id_variedad_flor = #comparativo_matriz_estimado.id_variedad_flor
	and #dias_semana_estimado.fecha = dateadd(dd, 6, @fecha_conteo_actual)

	update #comparativo_matriz_estimado
	set produccion_dia7 = cantidad
	from #dias_semana_estimado
	where #dias_semana_estimado.id_persona = #comparativo_matriz_estimado.id_persona
	and #dias_semana_estimado.id_bloque = #comparativo_matriz_estimado.id_bloque
	and #dias_semana_estimado.id_variedad_flor = #comparativo_matriz_estimado.id_variedad_flor
	and #dias_semana_estimado.fecha = dateadd(dd, 7, @fecha_conteo_actual)

	select nombre, 
	tallos_estimados_semana_actual,
	codigo_supervisor,
	nombre_supervisor,
	nombre_tipo_flor,
	nombre_variedad_flor,
	bloque,
	numero_consecutivo,
	@fecha_conteo_actual as fecha_conteo_actual,
	produccion_dia1,
	produccion_dia2,
	produccion_dia3,
	produccion_dia4,
	produccion_dia5,
	produccion_dia6,
	produccion_dia7,
	(
	isnull(produccion_dia1, 0) +
	isnull(produccion_dia2, 0) +
	isnull(produccion_dia3, 0) +
	isnull(produccion_dia4, 0) +
	isnull(produccion_dia5, 0) +
	isnull(produccion_dia6, 0) +
	isnull(produccion_dia7, 0)
	) as produccion_total
	from #comparativo_matriz_estimado
	where 
	(
	(
		isnull(produccion_dia1, 0) +
		isnull(produccion_dia2, 0) +
		isnull(produccion_dia3, 0) +
		isnull(produccion_dia4, 0) +
		isnull(produccion_dia5, 0) +
		isnull(produccion_dia6, 0) +
		isnull(produccion_dia7, 0)
	) > 0
	or tallos_estimados_semana_actual > = 0
	)
	order by 
	nombre_variedad_flor,
	bloque,
	nombre

	drop table #comparativo_matriz_estimado
	drop table #dias_semana_estimado
end
END




