set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_ramo_comprado]

@accion nvarchar(255),
@idc_finca nvarchar(255),
@idc_persona nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255), 
@idc_grado_flor nvarchar(255),
@idc_punto_corte nvarchar(255),
@idc_ramo_comprado nvarchar(255),
@tallos_por_ramo int,
@fecha nvarchar(255),
@hora nvarchar(255),
@cantidad_etiquetas int,
@id_etiqueta_impresa int

as

declare @id_item int,
@conteo int,
@id_inicial int,
@id_final int

if(@accion = 'insertar_etiqueta_finca_asignada')
begin
	select @id_item = finca_asignada.id_finca_asignada
	from finca,
	finca_asignada
	where finca.idc_finca = @idc_finca
	and finca.id_finca = finca_asignada.id_finca

	if(@id_item > 0)
	begin
		set @conteo = 0

		while (@conteo < @cantidad_etiquetas)
		begin
			insert into etiqueta_impresa_finca_asignada (id_finca)
			select finca_asignada.id_finca
			from finca_asignada
			where finca_asignada.id_finca_asignada = @id_item
			
			if(@conteo = 0)
			begin
				set @id_inicial = scope_identity()
			end

			set @conteo = @conteo + 1

			set @id_final = scope_identity()
		end

		select @id_inicial as id_etiqueta_inicial,
		@id_final as id_etiqueta_final
	end
	else
	begin
		select 0 as id_etiqueta_inicial, 0 as id_etiqueta_final
	end
end
else
if(@accion = 'asignar_persona_finca')
begin
	select @conteo = count(*)
	from finca,
	finca_asignada
	where finca.idc_finca = @idc_finca
	and finca.id_finca = finca_asignada.id_finca
	
	if(@conteo = 0)
	begin
		insert into finca_asignada (id_finca, id_persona)
		select finca.id_finca,
		persona.id_persona
		from persona,
		finca
		where finca.idc_finca = @idc_finca
		and persona.idc_persona = @idc_persona

		select 1 as result
	end
	else
	begin
		select -1 as result
	end
end
else
if(@accion = 'consultar_etiqueta_impresa_finca_asignada')
begin
	select finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	persona.identificacion
	from etiqueta_impresa_finca_asignada,
	finca_asignada,
	finca,
	persona
	where etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = @id_etiqueta_impresa
	and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
	and finca_asignada.id_finca = finca.id_finca
	and finca_asignada.id_persona = persona.id_persona
end
else
if(@accion = 'insertar_ramo_comprado')
begin
	select @conteo = count(*)
	from ramo_comprado,
	etiqueta_impresa_finca_asignada
	where ramo_comprado.id_etiqueta_impresa_finca_asignada = etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada
	and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = @id_etiqueta_impresa

	if(@conteo = 0)
	begin
		insert into ramo_comprado (id_persona, id_punto_corte, id_grado_flor, id_variedad_flor, idc_ramo_comprado, tallos_por_ramo, fecha_lectura, id_etiqueta_impresa_finca_asignada)
		select persona.id_persona, 
		punto_corte.id_punto_corte,
		grado_flor.id_grado_flor,
		variedad_flor.id_variedad_flor,
		@idc_ramo_comprado,
		@tallos_por_ramo,
		(CAST(CONVERT(char(12),@fecha,113)+(LEFT(@hora, 2) +':'+ SUBSTRING(convert(nvarchar, @hora), 3, 2)+':'+ SUBSTRING(convert(nvarchar,@hora), 5, 2)) AS DATETIME)),
		@id_etiqueta_impresa
		from persona,
		tipo_flor,
		variedad_flor,
		grado_flor,
		punto_corte
		where persona.idc_persona = @idc_persona
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and punto_corte.idc_punto_corte = @idc_punto_corte

		select 1 as result
	end
	else
	begin
		select -1 as result
	end
end
else
if(@accion = 'consultar_finca_asignada')
begin
	select finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	persona.identificacion
	from finca_asignada,
	finca,
	persona
	where finca_asignada.id_finca = finca.id_finca
	and finca_asignada.id_persona = persona.id_persona
end
else
if(@accion = 'consultar_finca')
begin
	select finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca
	from finca
	order by idc_finca
end
else
if(@accion = 'consultar_persona')
begin
	select persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	persona.identificacion
	from 
	persona
	order by persona.idc_persona
end
else
if(@accion = 'consultar_ramo_comprado')
begin
	select @conteo = count(*)
	from ramo_comprado,
	etiqueta_impresa_finca_asignada
	where ramo_comprado.id_etiqueta_impresa_finca_asignada = etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada
	and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = @id_etiqueta_impresa

	if(@conteo > 0)
	begin
		select 1 as result
	end
	else
	begin
		select -1 as result
	end
end
else
if(@accion = 'consultar_etiqueta_impresa')
begin
	select @conteo = count(*)
	from etiqueta_impresa_finca_asignada
	where etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = @id_etiqueta_impresa

	if(@conteo > 0)
	begin
		select 1 as result
	end
	else
	begin
		select -1 as result
	end
end
else
if(@accion = 'consultar_ramo_comprado_detalle')
begin
	select finca.id_finca,
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	punto_corte.idc_punto_corte,
	punto_corte.nombre_punto_corte,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	tallos_por_ramo as cantidad_tallos,
	convert(datetime,convert(nvarchar, ramo_comprado.fecha_lectura, 101)) as fecha
	from ramo_comprado,
	punto_corte,
	persona,
	grado_flor,
	variedad_flor,
	tipo_flor,
	etiqueta_impresa_finca_asignada,
	finca_asignada,
	finca
	where ramo_comprado.id_persona = persona.id_persona
	and ramo_comprado.id_punto_corte = punto_corte.id_punto_corte
	and ramo_comprado.id_grado_flor = grado_flor.id_grado_flor
	and ramo_comprado.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and ramo_comprado.id_etiqueta_impresa_finca_asignada = etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada
	and etiqueta_impresa_finca_asignada.id_finca = finca_asignada.id_finca
	and finca_asignada.id_finca = finca.id_finca
	and ramo_comprado.idc_ramo_comprado = @idc_ramo_comprado
end