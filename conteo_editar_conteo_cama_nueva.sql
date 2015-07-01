set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2012-10-22
-- Description:	manejar toda la informacion de conteos de camas nuevas
-- =============================================

alter PROCEDURE [dbo].[conteo_editar_conteo_cama_nueva]

@accion nvarchar(255),
@id_cuenta_interna int, 
@id_tipo_conteo int, 
@fecha_conteo datetime,
@id_conteo_cama_nueva int,
@id_detalle_conteo_cama_nueva bigint,
@idc_persona nvarchar(10), 
@fecha_realiza_conteo datetime, 
@unidades_basales int, 
@unidades_cortados int, 
@unidades_delgados int

AS

declare @conteo int

if(@accion = 'consultar_datos_cargados')
begin
	select 1 as tipo_conteo,
	bloque.idc_bloque,
	detalle_conteo_cama_nueva.id_detalle_conteo_cama_nueva,
	sum(detalle_conteo_cama_nueva.unidades_basales) as unidades_basales,
	sum(detalle_conteo_cama_nueva.unidades_cortados) as unidades_cortados,
	sum(detalle_conteo_cama_nueva.unidades_delgados) as unidades_delgados into #temp
	from conteo_cama_nueva,
	detalle_conteo_cama_nueva,
	bloque
	where conteo_cama_nueva.id_conteo_cama_nueva = detalle_conteo_cama_nueva.id_conteo_cama_nueva
	and conteo_cama_nueva.id_conteo_cama_nueva = @id_conteo_cama_nueva
	and bloque.id_bloque = detalle_conteo_cama_nueva.id_bloque
	group by bloque.idc_bloque,
	detalle_conteo_cama_nueva.id_detalle_conteo_cama_nueva
	having sum(detalle_conteo_cama_nueva.unidades_basales) is not null
	and sum(detalle_conteo_cama_nueva.unidades_cortados) is not null
	and sum(detalle_conteo_cama_nueva.unidades_delgados) is not null
	union all
	select 2 as tipo_conteo,
	bloque.idc_bloque,
	detalle_conteo_cama_nueva.id_detalle_conteo_cama_nueva,
	sum(detalle_conteo_cama_nueva.unidades_basales) as unidades_basales,
	sum(detalle_conteo_cama_nueva.unidades_cortados) as unidades_cortados,
	sum(detalle_conteo_cama_nueva.unidades_delgados) as unidades_delgados
	from conteo_cama_nueva,
	detalle_conteo_cama_nueva,
	bloque
	where conteo_cama_nueva.id_conteo_cama_nueva = detalle_conteo_cama_nueva.id_conteo_cama_nueva
	and conteo_cama_nueva.id_conteo_cama_nueva = @id_conteo_cama_nueva
	and bloque.id_bloque = detalle_conteo_cama_nueva.id_bloque
	group by bloque.idc_bloque,
	detalle_conteo_cama_nueva.id_detalle_conteo_cama_nueva
	having sum(detalle_conteo_cama_nueva.unidades_basales) is null
	and sum(detalle_conteo_cama_nueva.unidades_cortados) is null
	and sum(detalle_conteo_cama_nueva.unidades_delgados) is null

	select tipo_conteo,
	idc_bloque,
	count(id_detalle_conteo_cama_nueva) as cantidad_camas,
	sum(unidades_basales) as unidades_basales,
	sum(unidades_cortados) as unidades_cortados,
	sum(unidades_delgados) as unidades_delgados
	from #temp
	group by tipo_conteo,
	idc_bloque

	drop table #temp
end
else
if(@accion = 'consultar_detalle_conteo')
begin
	select detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva,
	convert(nvarchar, '2371') + 
	case
		when len(detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva) = 1 then '000000' + convert(nvarchar, detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva)
		when len(detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva) = 2 then '00000' + convert(nvarchar, detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva)
		when len(detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva) = 3 then '0000' + convert(nvarchar, detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva)
		when len(detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva) = 4 then '000' + convert(nvarchar, detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva)
		when len(detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva) = 5 then '00' + convert(nvarchar, detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva)
		when len(detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva) = 6 then '0' + convert(nvarchar, detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva)
	end as id_codigo_barras,
	detalle_Conteo_cama_nueva.numero_consecutivo,
	bloque.idc_bloque,
	nave.numero_nave,
	cama.numero_cama,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre_persona
	from Conteo_cama_nueva,
	detalle_Conteo_cama_nueva,
	bloque,
	variedad_flor,
	persona,
	sembrar_cama_bloque,
	construir_cama_bloque,
	cama_bloque,
	cama,
	nave
	where cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and nave.id_nave = cama_bloque.id_nave
	and cama.id_cama = cama_bloque.id_cama
	and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_conteo_cama_nueva.id_sembrar_cama_bloque
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and Conteo_cama_nueva.id_Conteo_cama_nueva = detalle_Conteo_cama_nueva.id_Conteo_cama_nueva
	and detalle_Conteo_cama_nueva.id_variedad_flor = variedad_flor.id_variedad_flor
	and detalle_Conteo_cama_nueva.id_persona_asignada = persona.id_persona
	and detalle_Conteo_cama_nueva.id_bloque = bloque.id_bloque
	and Conteo_cama_nueva.id_Conteo_cama_nueva = @id_Conteo_cama_nueva
	and bloque.disponible = 1
	order by
	detalle_Conteo_cama_nueva.numero_consecutivo
end
else
if(@accion = 'consultar_tipo_conteo')
begin
	select id_tipo_conteo_propietario_cama,
	nombre 
	from tipo_conteo_propietario_cama
	where nombre = 'Camas Nuevas de Rosa'
end
else
if(@accion = 'consultar_conteo')
begin
	select Conteo_cama_nueva.id_Conteo_cama_nueva,
	Conteo_cama_nueva.fecha_conteo
	from Conteo_cama_nueva,
	detalle_Conteo_cama_nueva
	where Conteo_cama_nueva.id_Conteo_cama_nueva = detalle_Conteo_cama_nueva.id_Conteo_cama_nueva
	group by Conteo_cama_nueva.id_Conteo_cama_nueva,
	Conteo_cama_nueva.fecha_conteo
	having sum(detalle_Conteo_cama_nueva.unidades_basales) is null
	order by Conteo_cama_nueva.fecha_conteo desc
end
else
if(@accion = 'corregir_conteo')
begin
	select Conteo_cama_nueva.id_Conteo_cama_nueva,
	Conteo_cama_nueva.fecha_conteo
	from Conteo_cama_nueva,
	detalle_Conteo_cama_nueva
	where Conteo_cama_nueva.id_Conteo_cama_nueva = detalle_Conteo_cama_nueva.id_Conteo_cama_nueva
	group by Conteo_cama_nueva.id_Conteo_cama_nueva,
	Conteo_cama_nueva.fecha_conteo
	having sum(detalle_Conteo_cama_nueva.unidades_basales) is not null
	order by Conteo_cama_nueva.fecha_conteo desc
end
else
if(@accion = 'insertar_conteo')
begin
	select @conteo = count(*)
	from Conteo_cama_nueva
	where id_tipo_conteo_propietario_cama = @id_tipo_conteo
	and  fecha_conteo = @fecha_conteo

	if(@conteo = 0)
	begin
		insert into Conteo_cama_nueva
		(
			id_tipo_conteo_propietario_cama,
			id_cuenta_interna,
			fecha_conteo
		) 
		values (@id_tipo_conteo, @id_cuenta_interna, @fecha_conteo)
	
		set @id_conteo_cama_nueva = scope_identity()
	
		select max(area_asignada.id_area_asignada) as id_area_asignada into #area
		from area_asignada
		group by area_asignada.id_area

		select identity(int, 1,1) as consecutivo,
		variedad_flor.id_variedad_flor,
		bloque.id_bloque,
		bloque.idc_bloque,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
		sembrar_cama_bloque.id_sembrar_cama_bloque,
		persona.id_persona into #resultado
		from bloque,
		cama,
		nave,
		cama_bloque,
		construir_cama_bloque,
		sembrar_cama_bloque,
		persona,
		detalle_area,
		area,
		estado_area,
		area_asignada,
		variedad_flor,
		tipo_flor
		where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and bloque.id_bloque = cama_bloque.id_bloque
		and cama.id_cama = cama_bloque.id_cama
		and nave.id_nave = cama_bloque.id_nave
		and construir_cama_bloque.id_bloque = cama_bloque.id_bloque
		and construir_cama_bloque.id_cama = cama_bloque.id_cama
		and construir_cama_bloque.id_nave = cama_bloque.id_nave
		and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
		and variedad_flor.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
		and not exists
		(
			select *
			from erradicar_cama_bloque
			where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
		)
		and not exists
		(
			select *
			from destruir_cama_bloque
			where construir_cama_bloque.id_construir_cama_bloque = destruir_cama_bloque.id_construir_cama_bloque
		)
		and sembrar_cama_bloque.fecha > = convert(datetime, '20111215')
		and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
		and detalle_area.id_area = area.id_area
		and area.id_area = area_asignada.id_area
		and area_asignada.id_persona = persona.id_persona
		and area.id_estado_area = estado_area.id_estado_area
		and estado_area.nombre_estado_area = 'Asignada'
		and exists
		(
			select *
			from #area
			where #area.id_area_asignada = area_asignada.id_area_asignada
		)
		and tipo_flor.idc_tipo_flor = 'RO'
		and variedad_flor.idc_variedad_flor = 'FR'
		group by variedad_flor.id_variedad_flor,
		bloque.id_bloque,
		persona.id_persona,
		bloque.idc_bloque,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
		sembrar_cama_bloque.id_sembrar_cama_bloque,
		construir_cama_bloque.id_construir_cama_bloque
		order by bloque.idc_bloque,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor))

		insert into detalle_Conteo_cama_nueva (id_conteo_cama_nueva, numero_consecutivo, id_bloque, id_variedad_flor, id_persona_asignada, id_persona_realiza_conteo, fecha_realiza_conteo, unidades_basales, unidades_cortados, unidades_delgados, id_sembrar_cama_bloque)
		select @id_conteo_cama_nueva,
		consecutivo,
		id_bloque,
		id_variedad_flor,
		id_persona,
		null,
		null,
		null,
		null,
		null,
		id_sembrar_cama_bloque
		from #resultado

		drop table #area
		drop table #resultado

		select @id_conteo_cama_nueva as id_conteo_cama_nueva
	end
	else
	begin
		select -1 as id_conteo_cama_nueva
	end
end
else
if(@accion = 'actualizar_detalle_conteo')
begin
	update detalle_Conteo_cama_nueva
	set id_persona_realiza_conteo = persona.id_persona,
	fecha_realiza_conteo = @fecha_realiza_conteo, 
	unidades_basales = @unidades_basales, 
	unidades_cortados = @unidades_cortados, 
	unidades_delgados = @unidades_delgados
	from persona,
	Conteo_cama_nueva
	where persona.idc_persona = @idc_persona
	and detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva = convert(int,right(@id_detalle_Conteo_cama_nueva, 7))
	and Conteo_cama_nueva.id_Conteo_cama_nueva = detalle_Conteo_cama_nueva.id_Conteo_cama_nueva
	and Conteo_cama_nueva.id_Conteo_cama_nueva = @id_Conteo_cama_nueva
end
else
if(@accion = 'consultar_conteo_datos_generales')
begin
	select Conteo_cama_nueva.fecha_transaccion,
	ltrim(rtrim(cuenta_interna.nombre)) as nombre_cuenta_interna,
	count(detalle_Conteo_cama_nueva.id_detalle_Conteo_cama_nueva) as numero_registros,
	sum(detalle_Conteo_cama_nueva.unidades_basales) as unidades_basales,
	sum(detalle_Conteo_cama_nueva.unidades_cortados) as unidades_cortados,
	sum(detalle_Conteo_cama_nueva.unidades_delgados) as unidades_delgados
	from Conteo_cama_nueva,
	detalle_Conteo_cama_nueva,
	cuenta_interna
	where Conteo_cama_nueva.id_Conteo_cama_nueva = detalle_Conteo_cama_nueva.id_Conteo_cama_nueva 
	and cuenta_interna.id_cuenta_interna = Conteo_cama_nueva.id_cuenta_interna
	and Conteo_cama_nueva.id_Conteo_cama_nueva = @id_Conteo_cama_nueva
	group by Conteo_cama_nueva.fecha_transaccion,
	ltrim(rtrim(cuenta_interna.nombre))
end
else
if(@accion = 'generar_etiquetas')
begin
	select Conteo_cama_nueva.fecha_conteo,
	convert(nvarchar,detalle_conteo_cama_nueva.fecha_realiza_conteo, 103) + ' (' +
	convert(nvarchar,datediff(dd, Conteo_cama_nueva.fecha_conteo, detalle_conteo_cama_nueva.fecha_realiza_conteo)) + ')' as fecha_realiza_conteo,
	tipo_conteo_propietario_cama.nombre as nombre_tipo_conteo,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona_asignada,
	persona.idc_persona as codigo_persona_asignada,
	(
		select ltrim(rtrim(p.nombre)) + ' ' + ltrim(rtrim(p.apellido))
		from persona as p
		where p.id_persona = detalle_conteo_cama_nueva.id_persona_realiza_conteo
	) + ' [' +
	(
		select p.idc_persona
		from persona as p
		where p.id_persona = detalle_conteo_cama_nueva.id_persona_realiza_conteo
	) + ']' as nombre_persona_realiza_conteo,
	(
		select p.idc_persona
		from persona as p
		where p.id_persona = detalle_conteo_cama_nueva.id_persona_realiza_conteo
	) as codigo_persona_realiza_conteo,
	bloque.idc_bloque,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	detalle_conteo_cama_nueva.numero_consecutivo,
	nave.numero_nave,
	cama.numero_cama,
	sum(detalle_Conteo_cama_nueva.unidades_basales) as unidades_basales,
	sum(detalle_Conteo_cama_nueva.unidades_cortados) as unidades_cortados,
	sum(detalle_Conteo_cama_nueva.unidades_delgados) as unidades_delgados
	from tipo_conteo_propietario_cama,
	Conteo_cama_nueva,
	detalle_Conteo_cama_nueva,
	persona,
	bloque,
	tipo_flor,
	variedad_flor,
	sembrar_cama_bloque,
	construir_cama_bloque,
	cama_bloque,
	cama,
	nave
	where cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and nave.id_nave = cama_bloque.id_nave
	and cama.id_cama = cama_bloque.id_cama
	and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_conteo_cama_nueva.id_sembrar_cama_bloque
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = detalle_conteo_cama_nueva.id_variedad_flor
	and bloque.id_bloque = detalle_conteo_cama_nueva.id_bloque
	and persona.id_persona = detalle_conteo_cama_nueva.id_persona_asignada
	and tipo_conteo_propietario_cama.id_tipo_conteo_propietario_cama = conteo_cama_nueva.id_tipo_conteo_propietario_cama
	and Conteo_cama_nueva.id_Conteo_cama_nueva = detalle_Conteo_cama_nueva.id_Conteo_cama_nueva 
	and Conteo_cama_nueva.id_Conteo_cama_nueva = @id_Conteo_cama_nueva
	group by Conteo_cama_nueva.fecha_conteo,
	detalle_conteo_cama_nueva.fecha_realiza_conteo,
	tipo_conteo_propietario_cama.nombre,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	detalle_conteo_cama_nueva.id_persona_realiza_conteo,
	detalle_conteo_cama_nueva.numero_consecutivo,
	nave.numero_nave,
	cama.numero_cama
	having 	sum(detalle_Conteo_cama_nueva.unidades_basales) is not null
	and sum(detalle_Conteo_cama_nueva.unidades_cortados) is not null
	and sum(detalle_Conteo_cama_nueva.unidades_delgados) is not null
	order by detalle_conteo_cama_nueva.numero_consecutivo
end