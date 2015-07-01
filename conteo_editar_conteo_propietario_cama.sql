set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-01-13
-- Description:	extraer informacion de propietarios de camas
-- =============================================

alter PROCEDURE [dbo].[conteo_editar_conteo_propietario_cama]

@accion nvarchar(255),
@id_cuenta_interna int, 
@id_tipo_conteo_propietario_cama int, 
@fecha_conteo datetime,
@id_conteo_propietario_cama int,
@id_estado_variedad_flor_inicial int,
@id_estado_variedad_flor_final int

AS

declare @id_item int,
@conteo int,
@id_conteo_propietario_cama_actual int,
@fecha_conteo_actual datetime

if(@accion = 'reporte_produccion_vs_estimados_por_supervisor')
begin
	select top 1 @id_conteo_propietario_cama_actual = conteo_propietario_cama.id_conteo_propietario_cama,
	@fecha_conteo_actual = fecha_conteo
	from conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama

	select ltrim(rtrim(persona.nombre)) +' '+ ltrim(rtrim(persona.apellido)) as nombre, 
	persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
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
	group by persona.id_persona, 
	persona.idc_persona,
	persona.identificacion,
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
		idc_persona,
		identificacion,
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
	persona.idc_persona,
	persona.identificacion,
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
	--and bloque.idc_bloque like 'ER%'
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
	group by ltrim(rtrim(persona.nombre)),
	persona.idc_persona,
	persona.identificacion,
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
	id_bloque,
	id_variedad_flor,
	convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) as fecha into #dias_semana_estimado
	from pieza_postcosecha
	where convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) between
	dateadd(dd, 1, @fecha_conteo_actual) and dateadd(dd, 7, @fecha_conteo_actual)
	group by id_persona,
	id_bloque,
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
	idc_persona,
	identificacion,
	id_persona,
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

	drop table #comparativo_matriz_estimado
	drop table #dias_semana_estimado
end
else
if(@accion = 'consultar_reporte_por_variedad_bloque')
begin
	/*La consulta es utilizada para generar un reporte que muestra los datos de un conteo específico,
	agrupando la información por variedad y llegando al detalle del bloque y la persona. El reporte en el cual se carga la información
	se llama: Cultivo_Conteo_Variedad_Bloque.rdl*/
	select bloque.idc_bloque,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	sum(unidades_estimadas) as conteo,
	finca_propia.idc_finca_propia,
	finca_propia.nombre_finca_propia
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	bloque,
	variedad_flor,
	tipo_flor,
	persona,
	supervisor,
	finca_bloque,
	finca_propia
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and supervisor.id_supervisor = persona.id_supervisor
	and bloque.disponible = 1
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and finca_propia.id_finca_propia = finca_bloque.id_finca_propia
	and bloque.id_bloque = finca_bloque.id_bloque
	group by bloque.idc_bloque,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	finca_propia.idc_finca_propia,
	finca_propia.nombre_finca_propia
	order by ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	bloque.idc_bloque
end
else
if(@accion = 'reporte_por_area')
begin
	/*La consulta es utilizada para generar un reporte que muestra los datos de un conteo específico,
	agrupando la información por supervisor. Este reporte se envía automáticamente cuando los usuarios 
	cargan información de los conteos o correcciones. El reporte en el cual se carga la información
	se llama: Cultivo_Conteo_Area_Bloque.rdl*/
	select supervisor.idc_supervisor as idc_area,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	bloque.idc_bloque,
	sum(unidades_estimadas) as conteo
	from tipo_conteo_propietario_cama,
	conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	persona,
	supervisor,
	bloque
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and persona.id_supervisor = supervisor.id_supervisor
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	group by
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	bloque.idc_bloque
	order by
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	bloque.idc_bloque
end
else
if(@accion = 'reporte_por_bloque')
begin
	select ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' - ' + variedad_flor.idc_variedad_flor as nombre_variedad_flor,
	bloque.idc_bloque,
	sum(unidades_estimadas) as conteo
	from tipo_conteo_propietario_cama,
	conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	tipo_flor,
	variedad_flor,
	bloque
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and conteo_propietario_cama.fecha_conteo = @fecha_conteo
	group by
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' - ' + variedad_flor.idc_variedad_flor,
	bloque.idc_bloque
	order by
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' - ' + tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' - ' + variedad_flor.idc_variedad_flor,
	bloque.idc_bloque
end
else
if(@accion = 'consultar_reporte_por_id')
begin
	/*La consulta es utilizada para generar un formato en el cual, los operarios colocarán el respectivo conteo
	realizado. Este formato se genera cuando el conteo es creado o se puede reimprimir en cualquier momento.
	El reporte en el cual se carga la información
	se llama: Cultivo_Conteo_Formato_Varios_Estados.rdl*/
	select detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama,
	convert(nvarchar, '232') + 
	case
	when len(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) = 1 then '0000000' + convert(nvarchar, detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama)
	when len(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) = 2 then '000000' + convert(nvarchar, detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama)
	when len(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) = 3 then '00000' + convert(nvarchar, detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama)
	when len(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) = 4 then '0000' + convert(nvarchar, detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama)
	when len(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) = 5 then '000' + convert(nvarchar, detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama)
	when len(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) = 6 then '00' + convert(nvarchar, detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama)
	when len(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) = 7 then '0' + convert(nvarchar, detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama)
	end as id_codigo_barras,
	detalle_conteo_propietario_cama.numero_consecutivo,
	supervisor.nombre_supervisor as nombre_area,
	supervisor.idc_supervisor as idc_area,
	bloque.idc_bloque,
	0 as bloque,--convert(int,replace(replace(replace(bloque.idc_bloque, 'ER', ''), 'MY', ''), 'FA', '')) as bloque,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre_persona into #codigo_barras
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	bloque,
	variedad_flor,
	persona,
	supervisor
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and supervisor.id_supervisor = persona.id_supervisor
	and bloque.disponible = 1

	select *,
	[dbo].[codigo_barras] (id_codigo_barras) as codigo_formateado
	from #codigo_barras
	order by numero_consecutivo

	drop table #codigo_barras
end
else
if(@accion = 'consultar_reporte_por_supervisor')
begin
	/*La consulta es utilizada para generar un reporte que despliega la información agrupada por supervisor de
	las personas que deben realizar el conteo con su respectivo bloque y variedad, aunque el reporte sale de la 
	información de los conteos no contiene datos de tallos o algo por el estilo.
	El reporte en el cual se carga la información
	se llama: Cultivo_Conteo_Propietario_Cama.rdl*/
	select supervisor.nombre_supervisor as nombre_area,
	supervisor.idc_supervisor as idc_area,
	bloque.idc_bloque,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre_persona
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	bloque,
	variedad_flor,
	persona,
	supervisor
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
	and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and supervisor.id_supervisor = persona.id_supervisor
	order by 
	supervisor.nombre_supervisor,
	bloque.idc_bloque,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)),	
	ltrim(rtrim(variedad_flor.nombre_variedad_flor))
end
else
if(@accion = 'consultar_operario_por_bloque')
begin
	select 0 as consecutivo,
	persona.idc_persona as codigo,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as persona,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor )) as variedad,
	bloque.idc_bloque as bloque	
	from sembrar_cama_bloque,
	construir_cama_bloque,
	cama_bloque,
	bloque,
	tipo_flor,
	variedad_flor,
	persona,
	detalle_area,
	area,
	estado_area,
	area_asignada
	where not exists
	(
		select * 
		from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
	and detalle_area.id_area = area.id_area
	and area.id_area = area_asignada.id_area
	and area_asignada.id_persona = persona.id_persona
	and area.id_estado_area = estado_area.id_estado_area
	and estado_area.nombre_estado_area = 'Asignada'
	and area_asignada.id_area_asignada in
	(
		select max(area_asignada.id_area_asignada)
		from area_asignada
		group by area_asignada.id_area
	)
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and cama_bloque.id_bloque = bloque.id_bloque
	and tipo_flor.id_tipo_flor in (77, 78)
	--and bloque.idc_bloque like 'ER%'
	group by
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	bloque.idc_bloque,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor ))
	order by bloque.idc_bloque
end
if(@accion = 'insertar_conteo_propietario_cama')
begin
	select @conteo = count(*)
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = @id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.fecha_conteo = @fecha_conteo

	if(@conteo = 0)
	begin
		select @conteo = count(*)
		from conteo_propietario_cama,
		tipo_conteo_propietario_cama
		where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
		and tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = @id_tipo_conteo_propietario_cama
		and conteo_propietario_cama.fecha_conteo > @fecha_conteo

		if(@conteo = 0)
		begin
			/*esta acción es utilizada para insertar los conteos creados por los usuarios para una fecha específica*/
			insert into conteo_propietario_cama (id_cuenta_interna, id_tipo_conteo_propietario_cama, fecha_conteo, id_estado_variedad_flor_inicial, id_estado_variedad_flor_final)
			values (@id_cuenta_interna, @id_tipo_conteo_propietario_cama, @fecha_conteo, @id_estado_variedad_flor_inicial, @id_estado_variedad_flor_final)

			set @id_item = scope_identity()

			/*creación de tabla temporal para incluisión de datos de siembras*/
			create table #detalle_conteo_propietario_cama 
			(
			numero_consecutivo int identity(1,1), 
			id_conteo_propietario_cama int, 
			id_bloque int, 
			id_variedad_flor int, 
			id_persona int, 
			unidades_estimadas int
			)
			
			/*se insertan los datos en una tabla temporal con el fin de crear un consecutivo autonumérico
			que será el consecutivo que irá impreso en los formatos*/
			insert into #detalle_conteo_propietario_cama 
			(
			id_conteo_propietario_cama, 
			id_bloque, 
			id_variedad_flor, 
			id_persona, 
			unidades_estimadas
			)
			select @id_item,
			bloque.id_bloque,
			variedad_flor.id_variedad_flor,
			persona.id_persona,
			0 as unidades_estimadas
			from sembrar_cama_bloque,
			construir_cama_bloque,
			cama_bloque,
			bloque,
			tipo_flor,
			variedad_flor,
			persona,
			detalle_area,
			area,
			estado_area,
			area_asignada
			where not exists
			(
				select * 
				from erradicar_cama_bloque
				where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
			)
			and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
			and detalle_area.id_area = area.id_area
			and area.id_area = area_asignada.id_area
			and area_asignada.id_persona = persona.id_persona
			and area.id_estado_area = estado_area.id_estado_area
			and estado_area.nombre_estado_area = 'Asignada'
			and area_asignada.id_area_asignada in
			(
				select max(area_asignada.id_area_asignada)
				from area_asignada
				group by area_asignada.id_area
			)
			and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
			and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
			and cama_bloque.id_nave = construir_cama_bloque.id_nave
			and cama_bloque.id_cama = construir_cama_bloque.id_cama
			and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
			and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
			and cama_bloque.id_bloque = bloque.id_bloque
			and tipo_flor.id_tipo_flor in (77, 78)
			and bloque.idc_bloque <> 'ER999'
			and bloque.idc_bloque <> 'MY999'
			--and bloque.idc_bloque like 'ER%'
			group by
			bloque.id_bloque,
			variedad_flor.id_variedad_flor,
			persona.id_persona
			order by bloque.id_bloque

			/*inserción en la tabla del detalle de los conteos la consulta que incluye el consecutivo*/
			insert into detalle_conteo_propietario_cama 
			(
			id_conteo_propietario_cama, 
			id_bloque, 
			id_variedad_flor, 
			id_persona, 
			unidades_estimadas, 
			numero_consecutivo
			)
			select id_conteo_propietario_cama, 
			id_bloque, 
			id_variedad_flor, 
			id_persona, 
			unidades_estimadas, 
			numero_consecutivo
			from #detalle_conteo_propietario_cama
			order by numero_consecutivo

			/*eliminación de la tabla temporal*/
			drop table #detalle_conteo_propietario_cama

			/*se retorna el id de la tabla del conteo, el cual es necesario para poder generar el formato*/
			select @id_item as id_conteo_propietario_cama
		end
		else
		begin
			select -3 as id_conteo_propietario_cama
		end
	end
	else
	begin
		select -2 as id_conteo_propietario_cama
	end
end
else
if(@accion = 'consultar_tipo_conteo_propietario_cama')
begin
	/*consulta utilizada al momento de crear un conteo ya que es necesario conocer a que tipo de conteo pertenece*/
	select id_tipo_conteo_propietario_cama,
	nombre  
	from tipo_conteo_propietario_cama 
	where id_tipo_conteo_propietario_cama <> 12
	and id_tipo_conteo_propietario_cama <> 13
	order by nombre
end
else
if(@accion = 'consultar_estado_variedad_flor')
begin
	/*los conteos que se realizan pueden tener un rango de estados de la flor, para que los operarios
	realicen la cuenta entre ese rang. Ésta consulta muestra los estados de la flor disponibles en el sistema*/
	select id_estado_variedad_flor,
	nombre_estado
	from estado_variedad_flor
	order by orden
end
else
if(@accion = 'consultar_conteo_carga_archivo')
begin
	/*consulta utilizada para mostrar los conteos que están pendientes por cargar*/

	/*verificar cuantos registros componen el conteo desde la generación del mismo*/
	select conteo_propietario_cama.id_conteo_propietario_cama, 
	count(*) as cantidad_registros into #cantidad_registros
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	group by conteo_propietario_cama.id_conteo_propietario_cama

	/*verificar cuantos registros han sido cargados del conteo*/
	select conteo_propietario_cama.id_conteo_propietario_cama, 
	count(*) as cantidad_registros into #cantidad_registros_procesados
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	detalle_item_conteo_propietario_cama,
	estado_detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.nombre_estado = 'Procesado'
	group by conteo_propietario_cama.id_conteo_propietario_cama

	alter table #cantidad_registros
	add cantidad_registros_procesados int

	update #cantidad_registros
	set cantidad_registros_procesados = #cantidad_registros_procesados.cantidad_registros
	from #cantidad_registros_procesados
	where #cantidad_registros_procesados.id_conteo_propietario_cama = #cantidad_registros.id_conteo_propietario_cama

	
	/*consulta enviada a pantalla en donde se muestra información si el conteo aun no ha sido cargado
	ni siquiera en 1 de los registros o la fecha del conteo no es inferior a 7 días atras. En caso
	contrario, la consulta no retorna ningún dato*/
	select conteo_propietario_cama.id_conteo_propietario_cama,
	convert(nvarchar,conteo_propietario_cama.fecha_conteo,101) + space(1) + '(' + tipo_conteo_propietario_cama.nombre + ')' as nombre_conteo
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama
	where conteo_propietario_cama.id_tipo_conteo_propietario_cama = tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama in
	(
		select #cantidad_registros.id_conteo_propietario_cama
		from #cantidad_registros
		where #cantidad_registros.cantidad_registros > isnull(#cantidad_registros.cantidad_registros_procesados, 0)
		and isnull(#cantidad_registros.cantidad_registros_procesados, 0) = 0
	)
	and conteo_propietario_cama.fecha_conteo > = convert(datetime,convert(nvarchar,dateadd(dd, -7, getdate()),101))
	order by conteo_propietario_cama.fecha_conteo,
	tipo_conteo_propietario_cama.nombre

	/*eliminación de tablas temporales*/
	drop table #cantidad_registros
	drop table #cantidad_registros_procesados
end
else
if(@accion = 'consultar_conteo_correccion_archivo')
begin
	/*esta consulta es utilizada para cargar un drop en donde se visualizan los conteos que yan ha sido procesados
	y se encuentran pendientes para correción*/

	/*contar la cantidad de registros al momento de su creación*/
	select conteo_propietario_cama.id_conteo_propietario_cama, 
	count(*) as cantidad_registros into #registros_cargados
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	group by conteo_propietario_cama.id_conteo_propietario_cama

	/*contar la cantidad de registros que fueron procesados*/
	select conteo_propietario_cama.id_conteo_propietario_cama, 
	count(*) as cantidad_registros into #registros_procesados
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	detalle_item_conteo_propietario_cama,
	estado_detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.nombre_estado = 'Procesado'
	group by conteo_propietario_cama.id_conteo_propietario_cama

	alter table #registros_cargados
	add cantidad_registros_procesados int

	update #registros_cargados
	set cantidad_registros_procesados = #registros_procesados.cantidad_registros
	from #registros_procesados
	where #registros_procesados.id_conteo_propietario_cama = #registros_cargados.id_conteo_propietario_cama

	/*La consulta enviará datos a pantalla si por lo menos un registro fue procesado o si la fecha del conteo no es inferior a 7 días atras
	de la fecha actual, en caso contrario no devuelve datos*/
	select conteo_propietario_cama.id_conteo_propietario_cama,
	convert(nvarchar,conteo_propietario_cama.fecha_conteo,101) + space(1) + '(' + tipo_conteo_propietario_cama.nombre + ')' as nombre_conteo
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama
	where conteo_propietario_cama.id_tipo_conteo_propietario_cama = tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama in
	(
		select #registros_cargados.id_conteo_propietario_cama
		from #registros_cargados
		where #registros_cargados.cantidad_registros_procesados > 0
	)
	and conteo_propietario_cama.fecha_conteo > = convert(datetime,convert(nvarchar,dateadd(dd, -7, getdate()),101))
	order by conteo_propietario_cama.fecha_conteo,
	tipo_conteo_propietario_cama.nombre

	/*Eliminación de tablas temporales*/
	drop table #registros_cargados
	drop table #registros_procesados
end
else
if(@accion = 'consultar_detalle_conteo_carga_archivo')
begin
	/*cuando se carga un conteo en pantalla ya sea para procesar o corregir, una vez seleccionado
	se muestra un detalle del mismo con el fin de que el usuario este seguro de seleccionar el deseado*/
	select conteo_propietario_cama.fecha_generacion, 
	cuenta_interna.nombre as nombre_cuenta_interna,
	count(detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama) as cantidad_consecutivos,
	estado_variedad_flor.nombre_estado as estado_flor_inicial,
	(
		select estado_variedad_flor.nombre_estado
		from estado_variedad_flor
		where conteo_propietario_cama.id_estado_variedad_flor_final = estado_variedad_flor.id_estado_variedad_flor
	) as estado_flor_final,
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as unidades_totales_estimadas
	from conteo_propietario_cama,
	cuenta_interna,
	detalle_conteo_propietario_cama,
	estado_variedad_flor
	where conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and conteo_propietario_cama.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_estado_variedad_flor_inicial = estado_variedad_flor.id_estado_variedad_flor
	group by conteo_propietario_cama.fecha_generacion, 
	cuenta_interna.nombre,
	estado_variedad_flor.nombre_estado,
	conteo_propietario_cama.id_estado_variedad_flor_final
end
else
if(@accion = 'consultar_pendientes_por_procesar')
begin
	/*cuando se carga un archivo para procesar, se muestra en pantalla cuantos registros faltan por procesar
	para que el usuario tenga presente que es esta cantidad o una inferior la que debe incluír en el archivo*/
	select - count(*) +
	(
		select count(*) 
		from conteo_propietario_cama,
		detalle_conteo_propietario_cama
		where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
		and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	) as items_por_procesar
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	detalle_item_conteo_propietario_cama,
	estado_detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.nombre_estado = 'Procesado'
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
end
else 
if(@accion = 'consultar_subject_carga')
begin
	select 'Conteo' + space(1) + '"' + tipo_conteo_propietario_cama.nombre + '"' + space(1) + convert(nvarchar,conteo_propietario_cama.fecha_conteo, 101) as subject
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama
	where conteo_propietario_cama.id_tipo_conteo_propietario_cama = tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
end
else 
if(@accion = 'consultar_subject_correcion')
begin
	select 'Correción Conteo' + space(1) + '"' + tipo_conteo_propietario_cama.nombre + '"' + space(1) + convert(nvarchar,conteo_propietario_cama.fecha_conteo, 101) as subject
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama
	where conteo_propietario_cama.id_tipo_conteo_propietario_cama = tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
end
else
if(@accion = 'consultar_conteo_generar_reporte_supervisor')
begin
	/*esta consulta es utilizada para cargar un drop en donde se visualizan los conteos que yan ha sido procesados
	y se encuentran pendientes para correción*/

	/*contar la cantidad de registros al momento de su creación*/
	select conteo_propietario_cama.id_conteo_propietario_cama, 
	count(*) as cantidad_registros into #registros_cargados_temp
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	group by conteo_propietario_cama.id_conteo_propietario_cama

	/*contar la cantidad de registros que fueron procesados*/
	select conteo_propietario_cama.id_conteo_propietario_cama, 
	count(*) as cantidad_registros into #registros_procesados_temp
	from conteo_propietario_cama,
	detalle_conteo_propietario_cama,
	detalle_item_conteo_propietario_cama,
	estado_detalle_conteo_propietario_cama
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and detalle_conteo_propietario_cama.id_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama = detalle_item_conteo_propietario_cama.id_estado_detalle_conteo_propietario_cama
	and estado_detalle_conteo_propietario_cama.nombre_estado = 'Procesado'
	group by conteo_propietario_cama.id_conteo_propietario_cama

	alter table #registros_cargados_temp
	add cantidad_registros_procesados int

	update #registros_cargados_temp
	set cantidad_registros_procesados = #registros_procesados_temp.cantidad_registros
	from #registros_procesados_temp
	where #registros_procesados_temp.id_conteo_propietario_cama = #registros_cargados_temp.id_conteo_propietario_cama


	/*La consulta enviará datos a pantalla si por lo menos un registro fue procesado o si la fecha del conteo no es inferior a 7 días atras
	de la fecha actual, en caso contrario no devuelve datos*/
	select conteo_propietario_cama.id_conteo_propietario_cama,
	convert(nvarchar,conteo_propietario_cama.fecha_conteo,101) + space(1) + '(' + tipo_conteo_propietario_cama.nombre + ')' as nombre_conteo
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama
	where conteo_propietario_cama.id_tipo_conteo_propietario_cama = tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and conteo_propietario_cama.id_conteo_propietario_cama in
	(
		select #registros_cargados_temp.id_conteo_propietario_cama
		from #registros_cargados_temp
		where #registros_cargados_temp.cantidad_registros_procesados > 0
	)
	and conteo_propietario_cama.fecha_conteo > = convert(datetime, '2010/03/01')
	order by conteo_propietario_cama.fecha_conteo,
	tipo_conteo_propietario_cama.nombre

	/*Eliminación de tablas temporales*/
	drop table #registros_cargados_temp
	drop table #registros_procesados_temp
end