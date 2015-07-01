set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_etiquetas_version2]

@accion nvarchar(255),
@idc_persona nvarchar(255),
@idc_bloque nvarchar(255),
@idc_variedad_flor nvarchar(255), 
@idc_tipo_flor nvarchar(255),
@unidades_por_etiqueta int,
@cantidad_etiquetas int,
@idc_punto_corte nvarchar(255)

as

declare @id_item int,
@conteo int,
@id_conteo_propietario_cama int,
@id_tipo_conteo int

if(@accion = 'consultar')
begin
	select @id_tipo_conteo = tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama
	from tipo_conteo_propietario_cama,
	configuracion_bd
	where tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = configuracion_bd.id_tipo_conteo

	select top 1 @id_conteo_propietario_cama = conteo_propietario_cama.id_conteo_propietario_cama 
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama,
	estado_variedad_flor
	where dbo.Conteo_Propietario_Cama.id_tipo_conteo_propietario_cama = dbo.Tipo_Conteo_Propietario_Cama.id_tipo_conteo_propietario_cama
	and dbo.Tipo_Conteo_Propietario_Cama.id_tipo_conteo_propietario_cama = @id_tipo_conteo
	and dbo.Conteo_Propietario_Cama.id_estado_variedad_flor_final = dbo.Estado_Variedad_Flor.id_estado_variedad_flor
	and dbo.Estado_Variedad_Flor.nombre_estado = 'En Adelante'
	and dbo.Conteo_Propietario_Cama.fecha_conteo < = convert(datetime, convert(nvarchar,getdate(), 101))
	order by dbo.Conteo_Propietario_Cama.fecha_conteo desc

	select supervisor.id_supervisor,
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	bloque.id_bloque,
	bloque.idc_bloque,
	persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	isnull((
		select sum(detalle_conteo_propietario_cama.unidades_estimadas)
		from detalle_conteo_propietario_cama,
		conteo_propietario_cama
		where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
		and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
		and detalle_conteo_propietario_cama.id_bloque = bloque.id_bloque
		and detalle_conteo_propietario_cama.id_variedad_flor = variedad_flor.id_variedad_flor
		and detalle_conteo_propietario_cama.id_persona = persona.id_persona
	), 0) as unidades_estimadas
	from bloque,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	persona,
	tipo_flor,
	variedad_flor,
	detalle_area,
	area,
	estado_area,
	area_asignada,
	supervisor
	where bloque.id_bloque = cama_bloque.id_bloque
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
	and detalle_area.id_area = area.id_area
	and area.id_area = area_asignada.id_area
	and area_asignada.id_persona = persona.id_persona
	and area.id_estado_area = estado_area.id_estado_area
	and estado_area.nombre_estado_area = 'Asignada'
	and persona.id_supervisor = supervisor.id_supervisor
	and area_asignada.id_area_asignada in
	(
		select max(area_asignada.id_area_asignada)
		from area_asignada
		group by area_asignada.id_area
	)
	and not exists
	(
		select * from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	group by supervisor.id_supervisor,
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	bloque.id_bloque,
	bloque.idc_bloque,
	persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor))
end
else
if(@accion = 'insertar_etiqueta')
begin
	declare @id_area_asignada int,
	@id_area int

	select @id_area_asignada = max(area_asignada.id_area_asignada)
	from area_asignada,
	persona,
	area,
	estado_area
	where persona.id_persona = area_asignada.id_persona
	and persona.idc_persona = @idc_persona
	and area.id_area = area_asignada.id_area
	and area.id_estado_area = estado_area.id_estado_area
	and estado_area.nombre_estado_area = 'Asignada'
	group by area.id_area

	select @id_area = area_asignada.id_area 
	from area_asignada
	where area_asignada.id_area_asignada = @id_area_asignada

	insert into etiqueta (id_persona, id_bloque, id_variedad_flor, unidades, id_punto_corte, id_area)
	select persona.id_persona, bloque.id_bloque, variedad_flor.id_variedad_flor, @unidades_por_etiqueta, punto_corte.id_punto_corte, @id_area
	from persona,
	bloque,
	variedad_flor,
	tipo_flor,
	punto_corte
	where dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
	and persona.idc_persona = @idc_persona
	and bloque.idc_bloque = @idc_bloque
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and punto_corte.idc_punto_corte = @idc_punto_corte

	set @id_item = scope_identity()

	set @conteo = 0

	while (@conteo < @cantidad_etiquetas)
	begin
	  insert into etiqueta_impresa (id_etiqueta)
	  values (@id_item)
	  
	  set @conteo = @conteo + 1
	end

	select min(etiqueta_impresa.id_etiqueta_impresa) as id_etiqueta_inicial,
	max(etiqueta_impresa.id_etiqueta_impresa) as id_etiqueta_final
	from etiqueta_impresa
	where etiqueta_impresa.id_etiqueta = @id_item
end
else
if(@accion = 'consultar_conteo_semana_entrante')
begin
	declare @fecha_inicial datetime,
	@fecha_final datetime

	select top 1 @id_conteo_propietario_cama = conteo_propietario_cama.id_conteo_propietario_cama 
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama,
	estado_variedad_flor
	where dbo.Conteo_Propietario_Cama.id_tipo_conteo_propietario_cama = dbo.Tipo_Conteo_Propietario_Cama.id_tipo_conteo_propietario_cama
	and dbo.Tipo_Conteo_Propietario_Cama.nombre = 'Estimado semana entrante'
	and dbo.Conteo_Propietario_Cama.id_estado_variedad_flor_final = dbo.Estado_Variedad_Flor.id_estado_variedad_flor
	and dbo.Estado_Variedad_Flor.nombre_estado = 'En Adelante'
	and dbo.Conteo_Propietario_Cama.fecha_conteo < = convert(datetime, convert(nvarchar,getdate(), 101))
	order by dbo.Conteo_Propietario_Cama.fecha_conteo desc

	set @fecha_inicial = convert(datetime, convert(nvarchar, getdate() - 8, 101))
	set @fecha_final = convert(datetime, convert(nvarchar, getdate()-1, 101))

	select 'ER' as idc_finca,
	variedad_flor.id_variedad_flor,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.id_grado_flor
		else 0
	end as id_grado_flor,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.idc_grado_flor
		else '00'
	end as idc_grado_flor,
	convert(decimal(20,4),sum(ramo.tallos_por_ramo))/
	(
		select sum(r.tallos_por_ramo) 
		from ramo as r
		where convert(datetime, convert(nvarchar, r.fecha_entrada, 101)) between
		@fecha_inicial and @fecha_final
		and variedad_flor.id_variedad_flor = r.id_variedad_flor
	) as porcentaje into #grado
	from ramo,
	grado_flor,
	variedad_flor,
	tipo_flor
	where convert(datetime, convert(nvarchar, fecha_entrada, 101)) between
	@fecha_inicial and @fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = ramo.id_variedad_flor
	and grado_flor.id_grado_flor = ramo.id_grado_flor
	group by variedad_flor.id_variedad_flor,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.idc_grado_flor
		else '00'
	end,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.id_grado_flor
		else 0
	end

	union all

	select 
	case
		when finca.idc_finca = 'FY' then 'FA'
		when finca.idc_finca = 'MF' then 'MY'
	end as idc_farm,
	variedad_flor.id_variedad_flor,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.id_grado_flor
		else 0
	end as id_grado_flor,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.idc_grado_flor
		else '00'
	end as idc_grado_flor,
	convert(decimal(20,4),sum(ramo_comprado.tallos_por_ramo))/
	(
		select sum(r.tallos_por_ramo) 
		from ramo_comprado as r,
		etiqueta_impresa_finca_asignada as e,
		finca_asignada as f
		where convert(datetime, convert(nvarchar, r.fecha_lectura, 101)) between
		@fecha_inicial and @fecha_final
		and variedad_flor.id_variedad_flor = r.id_variedad_flor
		and r.id_etiqueta_impresa_finca_asignada = e.id_etiqueta_impresa_finca_asignada
		and e.id_finca = f.id_finca
		and f.id_finca = finca.id_finca
	) as porcentaje
	from ramo_comprado,
	etiqueta_impresa_finca_asignada,
	finca_asignada,
	finca,
	grado_flor,
	variedad_flor,
	tipo_flor
	where ramo_comprado.id_etiqueta_impresa_finca_asignada = etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada
	and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
	and finca.id_finca = finca_asignada.id_finca
	and 
	(
		finca.idc_finca = 'FY' or
		finca.idc_finca = 'MF'
	)
	and convert(datetime, convert(nvarchar, fecha_lectura, 101)) between
	@fecha_inicial and @fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = ramo_comprado.id_variedad_flor
	and grado_flor.id_grado_flor = ramo_comprado.id_grado_flor
	group by variedad_flor.id_variedad_flor,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.idc_grado_flor
		else '00'
	end,
	case
		when grado_flor.idc_grado_flor in ('40','50','60','70','80') then grado_flor.id_grado_flor
		else 0
	end,
	finca.id_finca,
	finca.idc_finca

	select #grado.idc_finca,
	#grado.id_variedad_flor,
	#grado.id_grado_flor,
	#grado.porcentaje,
	composicion_grado_flor.id_grado_flor_grado_flor into #grado_compuesto
	from grado_flor,
	grupo_grado_flor,
	composicion_grado_flor,
	#grado
	where grado_flor.id_grado_flor = grupo_grado_flor.id_grado_flor
	and grupo_grado_flor.id_grado_flor = composicion_grado_flor.id_grado_flor_grupo_grado_flor
	and #grado.id_grado_flor = grupo_grado_flor.id_grado_flor


	select #grado.idc_finca,
	#grado.id_variedad_flor,
	#grado.id_grado_flor,
	#grado.porcentaje,
	convert(decimal(20,4),#grado_compuesto.porcentaje)/
	(
		select count(*)
		from #grado_compuesto
		where #grado.id_variedad_flor = #grado_compuesto.id_variedad_flor
		and #grado.idc_finca = #grado_compuesto.idc_finca
	) as porcentaje_parcial into #resultado
	from #grado,
	#grado_compuesto
	where #grado.id_variedad_flor = #grado_compuesto.id_variedad_flor
	and #grado.idc_finca = #grado_compuesto.idc_finca
	and #grado.id_grado_flor = #grado_compuesto.id_grado_flor_grado_flor

	update #grado
	set porcentaje = #grado.porcentaje + #resultado.porcentaje_parcial
	from #resultado
	where #grado.id_variedad_flor = #resultado.id_variedad_flor
	and #grado.idc_finca = #resultado.idc_finca
	and #grado.id_grado_flor = #resultado.id_grado_flor

	alter table #grado
	add id int identity(1,1)

	delete from #grado
	where id in
	(
		select #grado.id 
		from #grado_compuesto,
		#grado
		where #grado.idc_finca = #grado_compuesto.idc_finca
		and #grado.id_variedad_flor = #grado_compuesto.id_variedad_flor
		and #grado.id_grado_flor = #grado_compuesto.id_grado_flor
		group by #grado.id
	)

	select supervisor.id_supervisor,
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	bloque.id_bloque,
	bloque.idc_bloque,
	persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	sum(detalle_conteo_propietario_cama.unidades_estimadas) as unidades_estimadas,
	conteo_propietario_cama.fecha_conteo,
	cuenta_interna.nombre as nombre_cuenta,
	tipo_conteo_propietario_cama.nombre as nombre_tipo_conteo into #conteo_semana_entrante
	from detalle_conteo_propietario_cama,
	conteo_propietario_cama,
	cuenta_interna,
	tipo_conteo_propietario_cama,
	bloque,
	variedad_flor,
	tipo_flor,
	persona,
	supervisor
	where conteo_propietario_cama.id_conteo_propietario_cama = detalle_conteo_propietario_cama.id_conteo_propietario_cama
	and conteo_propietario_cama.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_propietario_cama.id_tipo_conteo_propietario_cama
	and bloque.id_bloque = detalle_conteo_propietario_cama.id_bloque
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_conteo_propietario_cama.id_variedad_flor
	and persona.id_persona = detalle_conteo_propietario_cama.id_persona
	and conteo_propietario_cama.id_conteo_propietario_cama = @id_conteo_propietario_cama
	and supervisor.id_supervisor = persona.id_supervisor
	group by supervisor.id_supervisor,
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	bloque.id_bloque,
	bloque.idc_bloque,
	persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	conteo_propietario_cama.fecha_conteo,
	cuenta_interna.nombre,
	tipo_conteo_propietario_cama.nombre

	alter table #conteo_semana_entrante
	add cuarenta int
	
	alter table #conteo_semana_entrante
	add	cincuenta int

	alter table #conteo_semana_entrante
	add	sesenta int

	alter table #conteo_semana_entrante
	add	setenta int

	alter table #conteo_semana_entrante
	add	ochenta int

	alter table #conteo_semana_entrante
	add	Otros int

	update #conteo_semana_entrante
	set cuarenta = round(#grado.porcentaje * #conteo_semana_entrante.unidades_estimadas, 0)
	from #grado
	where #grado.id_variedad_flor = #conteo_semana_entrante.id_variedad_flor
	and #grado.idc_finca = left(#conteo_semana_entrante.idc_bloque, 2)
	and #grado.idc_grado_flor = '40'

	update #conteo_semana_entrante
	set cincuenta = round(#grado.porcentaje * #conteo_semana_entrante.unidades_estimadas, 0)
	from #grado
	where #grado.id_variedad_flor = #conteo_semana_entrante.id_variedad_flor
	and #grado.idc_finca = left(#conteo_semana_entrante.idc_bloque, 2)
	and #grado.idc_grado_flor = '50'

	update #conteo_semana_entrante
	set sesenta = round(#grado.porcentaje * #conteo_semana_entrante.unidades_estimadas, 0)
	from #grado
	where #grado.id_variedad_flor = #conteo_semana_entrante.id_variedad_flor
	and #grado.idc_finca = left(#conteo_semana_entrante.idc_bloque, 2)
	and #grado.idc_grado_flor = '60'

	update #conteo_semana_entrante
	set setenta = round(#grado.porcentaje * #conteo_semana_entrante.unidades_estimadas, 0)
	from #grado
	where #grado.id_variedad_flor = #conteo_semana_entrante.id_variedad_flor
	and #grado.idc_finca = left(#conteo_semana_entrante.idc_bloque, 2)
	and #grado.idc_grado_flor = '70'

	update #conteo_semana_entrante
	set ochenta = round(#grado.porcentaje * #conteo_semana_entrante.unidades_estimadas, 0)
	from #grado
	where #grado.id_variedad_flor = #conteo_semana_entrante.id_variedad_flor
	and #grado.idc_finca = left(#conteo_semana_entrante.idc_bloque, 2)
	and #grado.idc_grado_flor = '80'

	update #conteo_semana_entrante
	set Otros = round(#grado.porcentaje * #conteo_semana_entrante.unidades_estimadas, 0)
	from #grado
	where #grado.id_variedad_flor = #conteo_semana_entrante.id_variedad_flor
	and #grado.idc_finca = left(#conteo_semana_entrante.idc_bloque, 2)
	and #grado.idc_grado_flor = '00'

	update #conteo_semana_entrante
	set Otros = #conteo_semana_entrante.unidades_estimadas
	where (isnull(cuarenta,0) +
	isnull(cincuenta,0) +
	isnull(sesenta,0) +
	isnull(setenta,0) +
	isnull(ochenta,0) +
	isnull(Otros,0)) = 0

	select id_supervisor,
	idc_supervisor,
	nombre_supervisor,
	id_bloque,
	idc_bloque,
	id_persona,
	idc_persona,
	identificacion,
	nombre_persona,
	apellido_persona,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	unidades_estimadas,
	fecha_conteo,
	nombre_cuenta,
	nombre_tipo_conteo,
	isnull(cuarenta,0) as "40cm",
	isnull(cincuenta,0) as "50cm",
	isnull(sesenta,0) as "60cm",
	isnull(setenta,0) as "70cm",
	isnull(ochenta,0) as "80cm",
	isnull(Otros,0) as Otros
	from #conteo_semana_entrante

	drop table #grado
	drop table #grado_compuesto
	drop table #resultado
	drop table #conteo_semana_entrante
end