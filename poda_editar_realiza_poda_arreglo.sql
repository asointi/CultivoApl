SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[poda_editar_realiza_poda_arreglo]
	
@id_tipo_poda int,
@id_estado_variedad_flor_inicial int,
@id_estado_variedad_flor_final int, 
@id_variedad_flor int,
@id_persona int,
@id_realiza_poda_arreglo int,
@fecha datetime,
@cantidad_tallos int,
@idc_persona nvarchar(10),
@id_detalle_realiza_poda_arreglo bigint,
@accion nvarchar(255),
@numero_nave int = null

AS

if(@accion = 'consultar_formato')
begin
	select detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	nave.id_nave,
	nave.numero_nave,
	area.id_area,
	bloque.id_bloque,
	(
		select count(sembrar_cama_bloque.id_sembrar_cama_bloque)
		from sembrar_cama_bloque,
		detalle_area,
		construir_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
		and area.id_area = detalle_area.id_area
		and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
		and bloque.id_bloque = construir_cama_bloque.id_bloque
		and nave.id_nave = construir_cama_bloque.id_nave
	) as cantidad_camas,
	identity(int, 1,1) as id into #nave
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	nave,
	area,
	bloque
	where realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and area.id_area = detalle_realiza_poda_arreglo.id_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	nave.id_nave,
	nave.numero_nave,
	area.id_area,
	bloque.id_bloque
	order by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	nave.numero_nave

	declare @id int,
	@conteo int,
	@orden int,
	@conteo_registros int,
	@id_detalle_realiza_poda_arreglo1 int,
	@id_detalle_realiza_poda_arreglo_aux int,
	@id_nave int,
	@nave int,
	@cantidad_camas int

	create table #temp 
	(
		id_detalle_realiza_poda_arreglo int, 
		orden int, 
		id_nave int, 
		nave int,
		cantidad_camas int
	)

	set @id = 1

	select @conteo_registros = count(*)
	from #nave

	while (@id < = @conteo_registros)
	begin
		select @id_detalle_realiza_poda_arreglo1 = id_detalle_realiza_poda_arreglo,
		@id_nave = id_nave,
		@nave = numero_nave,
		@cantidad_camas = cantidad_camas
		from #nave
		where id = @id

		select @id_detalle_realiza_poda_arreglo_aux = id_detalle_realiza_poda_arreglo
		from #nave
		where id = @id + 1

		if(@id_detalle_realiza_poda_arreglo1 = @id_detalle_realiza_poda_arreglo_aux)
		begin
			select @conteo = count(*)
			from #temp
			where id_detalle_realiza_poda_arreglo = @id_detalle_realiza_poda_arreglo1

			if(@conteo = 0)
			begin
				set @orden = 1
			end
			else
			begin
				select @orden = max(orden) + 1
				from #temp
				where id_detalle_realiza_poda_arreglo = @id_detalle_realiza_poda_arreglo1
			end

			insert into #temp (id_detalle_realiza_poda_arreglo, orden, id_nave, nave, cantidad_camas)
			values (@id_detalle_realiza_poda_arreglo1, @orden, @id_nave, @nave, @cantidad_camas)
		end
		else
		begin
			select @orden = max(orden)
			from #temp
			where id_detalle_realiza_poda_arreglo = @id_detalle_realiza_poda_arreglo1

			IF(@orden is null)
			begin
				set @orden = 1
			end
			else
			begin
				set @orden = @orden + 1
			end
		
			insert into #temp (id_detalle_realiza_poda_arreglo, orden, id_nave, nave, cantidad_camas)
			values (@id_detalle_realiza_poda_arreglo1, @orden, @id_nave, @nave, @cantidad_camas)
		end

		set @id = @id + 1
	end

	select '2371' + 
	case
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 1 then '000000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 2 then '00000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 3 then '0000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 4 then '000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 5 then '00' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 6 then '0' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
	end as id_codigo_barras,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	a.imagen_estado as imagen_inicial,
	b.imagen_estado as imagen_final,
	b.nombre_estado as nombre_estado_final,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 1
	) as nave_1,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 2
	) as nave_2,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 3
	) as nave_3,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 4
	) as nave_4,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 1
	) as camas_1,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 2
	) as camas_2,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 3
	) as camas_3,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 4
	) as camas_4
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona,
	bloque,
	nave,
	#temp
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and persona.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.nave < = 4
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	a.imagen_estado,
	b.imagen_estado,
	b.nombre_estado,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo

	union all

	select '2372' + 
	case
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 1 then '000000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 2 then '00000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 3 then '0000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 4 then '000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 5 then '00' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 6 then '0' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
	end as id_codigo_barras,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	a.imagen_estado as imagen_inicial,
	b.imagen_estado as imagen_final,
	b.nombre_estado as nombre_estado_final,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 5
	) as nave_1,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 6
	) as nave_2,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 7
	) as nave_3,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 8
	) as nave_4,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 5
	) as camas_1,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 6
	) as camas_2,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 7
	) as camas_3,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 8
	) as camas_4
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona,
	bloque,
	nave,
	#temp
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and persona.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.nave > 4
	and #temp.nave < = 8
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	a.imagen_estado,
	b.imagen_estado,
	b.nombre_estado,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo

	union all

	select '2373' + 
	case
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 1 then '000000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 2 then '00000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 3 then '0000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 4 then '000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 5 then '00' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 6 then '0' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
	end as id_codigo_barras,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	a.imagen_estado as imagen_inicial,
	b.imagen_estado as imagen_final,
	b.nombre_estado as nombre_estado_final,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 9
	) as nave_1,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 10
	) as nave_2,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 11
	) as nave_3,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 12
	) as nave_4,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 9
	) as camas_1,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 10
	) as camas_2,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 11
	) as camas_3,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 12
	) as camas_4
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona,
	bloque,
	nave,
	#temp
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and persona.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.nave > 8
	and #temp.nave < = 12
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	a.imagen_estado,
	b.imagen_estado,
	b.nombre_estado,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo

	union all

	select '2374' + 
	case
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 1 then '000000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 2 then '00000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 3 then '0000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 4 then '000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 5 then '00' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 6 then '0' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
	end as id_codigo_barras,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	a.imagen_estado as imagen_inicial,
	b.imagen_estado as imagen_final,
	b.nombre_estado as nombre_estado_final,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 13
	) as nave_1,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 14
	) as nave_2,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 15
	) as nave_3,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 16
	) as nave_4,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 13
	) as camas_1,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 14
	) as camas_2,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 15
	) as camas_3,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 16
	) as camas_4
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona,
	bloque,
	nave,
	#temp
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and persona.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.nave > 12
	and #temp.nave < = 16
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	a.imagen_estado,
	b.imagen_estado,
	b.nombre_estado,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo
	
	union all

	select '2375' + 
	case
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 1 then '000000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 2 then '00000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 3 then '0000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 4 then '000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 5 then '00' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 6 then '0' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
	end as id_codigo_barras,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	a.imagen_estado as imagen_inicial,
	b.imagen_estado as imagen_final,
	b.nombre_estado as nombre_estado_final,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 17
	) as nave_1,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 18
	) as nave_2,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 19
	) as nave_3,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 20
	) as nave_4,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 17
	) as camas_1,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 18
	) as camas_2,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 19
	) as camas_3,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 20
	) as camas_4
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona,
	bloque,
	nave,
	#temp
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and persona.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.nave > 17
	and #temp.nave < = 20
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	a.imagen_estado,
	b.imagen_estado,
	b.nombre_estado,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo

	union all

	select '2376' + 
	case
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 1 then '000000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 2 then '00000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 3 then '0000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 4 then '000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 5 then '00' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 6 then '0' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
	end as id_codigo_barras,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	a.imagen_estado as imagen_inicial,
	b.imagen_estado as imagen_final,
	b.nombre_estado as nombre_estado_final,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 21
	) as nave_1,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 22
	) as nave_2,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 23
	) as nave_3,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 24
	) as nave_4,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 21
	) as camas_1,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 22
	) as camas_2,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 23
	) as camas_3,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 24
	) as camas_4
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona,
	bloque,
	nave,
	#temp
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and persona.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.nave > 20
	and #temp.nave < = 24
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	a.imagen_estado,
	b.imagen_estado,
	b.nombre_estado,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo

	union all

	select '2377' + 
	case
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 1 then '000000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 2 then '00000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 3 then '0000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 4 then '000' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 5 then '00' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
		when len(detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo) = 6 then '0' + convert(nvarchar, detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo)
	end as id_codigo_barras,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	a.imagen_estado as imagen_inicial,
	b.imagen_estado as imagen_final,
	b.nombre_estado as nombre_estado_final,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)) + ' ' + ltrim(rtrim(persona.apellido)) + ' [' + persona.idc_persona + ']' as nombre_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 25
	) as nave_1,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 26
	) as nave_2,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 27
	) as nave_3,
	(
		select nave
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 28
	) as nave_4,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 25
	) as camas_1,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 26
	) as camas_2,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 27
	) as camas_3,
	(
		select cantidad_camas
		from #temp
		where #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and #temp.nave = 28
	) as camas_4
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b,
	persona,
	bloque,
	nave,
	#temp
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	and persona.id_persona = detalle_realiza_poda_arreglo.id_persona_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.id_detalle_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and #temp.nave > 24
	and #temp.nave < = 28
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	a.imagen_estado,
	b.imagen_estado,
	b.nombre_estado,
	realiza_poda_arreglo.fecha_generacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.idc_persona,
	bloque.idc_bloque,
	detalle_realiza_poda_arreglo.numero_consecutivo
	order by detalle_realiza_poda_arreglo.numero_consecutivo

	drop table #nave
	drop table #temp
end
else
if(@accion = 'insertar_poda')
begin
	declare @id_realiza_poda_arreglo_aux int

	insert into Realiza_Poda_Arreglo (id_tipo_poda, id_variedad_flor, id_estado_variedad_flor_final, id_estado_variedad_flor_inicial)
	values (@id_tipo_poda, @id_variedad_flor, @id_estado_variedad_flor_final, @id_estado_variedad_flor_inicial)

	set @id_realiza_poda_arreglo_aux = scope_identity()

	select max(area_asignada.id_area_asignada) as id_area_asignada into #area_asignada
	from area_asignada
	group by area_asignada.id_area

	select @id_realiza_poda_arreglo_aux as id_realiza_poda_arreglo,
	persona.id_persona,
	bloque.id_bloque,
	nave.id_nave,
	area.id_area into #temp1
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
	nave
	where nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and bloque.id_bloque = cama_bloque.id_bloque
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = @id_variedad_flor
	and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
	and detalle_area.id_area = area.id_area
	and area.id_area = area_asignada.id_area
	and area_asignada.id_persona = persona.id_persona
	and area.id_estado_area = estado_area.id_estado_area
	and estado_area.nombre_estado_area = 'Asignada'
	and exists
	(
		select *
		from #area_asignada
		where #area_asignada.id_area_asignada = area_asignada.id_area_asignada
	)
	and not exists
	(
		select * 
		from erradicar_cama_bloque
		where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	group by persona.id_persona,
	bloque.id_bloque,
	nave.id_nave,
	area.id_area
	order by bloque.id_bloque,
	nave.id_nave,
	persona.id_persona

	select id_realiza_poda_arreglo,
	id_persona,
	id_bloque,
	id_area,
	identity(int, 1,1) as numero_consecutivo into #Detalle_Realiza_Poda_Arreglo
	from #temp1
	group by id_realiza_poda_arreglo,
	id_bloque,
	id_persona,
	id_area

	insert into Detalle_Realiza_Poda_Arreglo (id_realiza_poda_arreglo, id_persona_area, id_bloque, id_area, numero_consecutivo)
	select id_realiza_poda_arreglo,
	id_persona,
	id_bloque,
	id_area,
	numero_consecutivo 
	from #Detalle_Realiza_Poda_Arreglo
	order by numero_consecutivo

	insert into Nave_Detalle_Realiza_Poda_Arreglo (id_Detalle_Realiza_Poda_Arreglo, id_nave)
	select Detalle_Realiza_Poda_Arreglo.id_Detalle_Realiza_Poda_Arreglo,
	#temp1.id_nave
	from #temp1,
	Detalle_Realiza_Poda_Arreglo
	where Detalle_Realiza_Poda_Arreglo.id_persona_area = #temp1.id_persona
	and Detalle_Realiza_Poda_Arreglo.id_bloque = #temp1.id_bloque
	and Detalle_Realiza_Poda_Arreglo.id_Realiza_Poda_Arreglo = @id_realiza_poda_arreglo_aux

	select @id_realiza_poda_arreglo_aux as id_realiza_poda_arreglo
	
	drop table #area_asignada
	drop table #Detalle_Realiza_Poda_Arreglo
end
else
if(@accion = 'cargar_poda')
begin
	select realiza_poda_arreglo.fecha_generacion,
	realiza_poda_arreglo.id_realiza_poda_arreglo
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo
	where realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and convert(datetime,convert(nvarchar, realiza_poda_arreglo.fecha_generacion, 101)) > = convert(datetime,convert(nvarchar, getdate() - 30, 101))
	group by realiza_poda_arreglo.fecha_generacion,
	realiza_poda_arreglo.id_realiza_poda_arreglo
	order by realiza_poda_arreglo.fecha_generacion asc
end
else
if(@accion = 'consultar_informacion_general')
begin
	select ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado as nombre_estado_inicial,
	b.nombre_estado as nombre_estado_final,
	isnull(sum(nave_detalle_realiza_poda_arreglo.cantidad_tallos), 0) as cantidad_tallos
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	variedad_flor,
	tipo_poda,
	estado_variedad_flor as a,
	estado_variedad_flor as b
	where realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and variedad_flor.id_variedad_flor = realiza_poda_arreglo.id_variedad_flor
	and tipo_poda.id_tipo_poda = realiza_poda_arreglo.id_tipo_poda
	and a.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_inicial
	and b.id_estado_variedad_flor = realiza_poda_arreglo.id_estado_variedad_flor_final
	group by ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	tipo_poda.nombre_tipo_poda,
	a.nombre_estado,
	b.nombre_estado
end
else
if(@accion = 'corregir_informacion')
begin
	select detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	nave.id_nave,
	nave.numero_nave,
	area.id_area,
	bloque.id_bloque,
	identity(int, 1,1) as id into #nave2
	from realiza_poda_arreglo,
	detalle_realiza_poda_arreglo,
	nave_detalle_realiza_poda_arreglo,
	nave,
	area,
	bloque
	where realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	and nave.id_nave = nave_detalle_realiza_poda_arreglo.id_nave
	and area.id_area = detalle_realiza_poda_arreglo.id_area
	and bloque.id_bloque = detalle_realiza_poda_arreglo.id_bloque
	group by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	nave.id_nave,
	nave.numero_nave,
	area.id_area,
	bloque.id_bloque
	order by detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo,
	nave.numero_nave

	declare @id_1 int,
	@conteo_1 int,
	@orden_1 int,
	@conteo_registros_1 int,
	@id_detalle_realiza_poda_arreglo1_1 int,
	@id_detalle_realiza_poda_arreglo_aux_1 int,
	@id_nave_1 int,
	@nave_1 int

	create table #temp2 
	(
		id_detalle_realiza_poda_arreglo int, 
		orden int, 
		id_nave int, 
		nave int
	)

	set @id_1 = 1

	select @conteo_registros_1 = count(*)
	from #nave2

	while (@id_1 < = @conteo_registros_1)
	begin
		select @id_detalle_realiza_poda_arreglo1_1 = id_detalle_realiza_poda_arreglo,
		@id_nave_1 = id_nave,
		@nave_1 = numero_nave
		from #nave2
		where id = @id_1

		select @id_detalle_realiza_poda_arreglo_aux_1 = id_detalle_realiza_poda_arreglo
		from #nave2
		where id = @id_1 + 1

		if(@id_detalle_realiza_poda_arreglo1_1 = @id_detalle_realiza_poda_arreglo_aux_1)
		begin
			select @conteo_1 = count(*)
			from #temp2
			where id_detalle_realiza_poda_arreglo = @id_detalle_realiza_poda_arreglo1_1

			if(@conteo_1 = 0)
			begin
				set @orden_1 = 1
			end
			else
			begin
				select @orden_1 = max(orden) + 1
				from #temp2
				where id_detalle_realiza_poda_arreglo = @id_detalle_realiza_poda_arreglo1_1
			end

			insert into #temp2 (id_detalle_realiza_poda_arreglo, orden, id_nave, nave)
			values (@id_detalle_realiza_poda_arreglo1_1, @orden_1, @id_nave_1, @nave_1)
		end
		else
		begin
			select @orden_1 = max(orden)
			from #temp2
			where id_detalle_realiza_poda_arreglo = @id_detalle_realiza_poda_arreglo1_1

			IF(@orden_1 is null)
			begin
				set @orden_1 = 1
			end
			else
			begin
				set @orden_1 = @orden_1 + 1
			end
		
			insert into #temp2 (id_detalle_realiza_poda_arreglo, orden, id_nave, nave)
			values (@id_detalle_realiza_poda_arreglo1_1, @orden_1, @id_nave_1, @nave_1)
		end

		set @id_1 = @id_1 + 1
	end

	update detalle_realiza_poda_arreglo
	set id_persona_realiza_poda = persona.id_persona
	from persona,
	realiza_poda_arreglo
	where persona.idc_persona = @idc_persona
	and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
	and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
	and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo

	if(convert(int, right(left(@id_detalle_realiza_poda_arreglo, 4), 1)) = 1)
	begin
		update nave_detalle_realiza_poda_arreglo
		set cantidad_tallos = @cantidad_tallos,
		fecha = @fecha
		from detalle_realiza_poda_arreglo,
		nave,
		realiza_poda_arreglo
		where detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
		and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and nave_detalle_realiza_poda_arreglo.id_nave = nave.id_nave
		and nave.numero_nave = @numero_nave
		and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
		and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	end
	else
	if(convert(int,right(left(@id_detalle_realiza_poda_arreglo, 4), 1)) = 2)
	begin
		update nave_detalle_realiza_poda_arreglo
		set cantidad_tallos = @cantidad_tallos,
		fecha = @fecha
		from detalle_realiza_poda_arreglo,
		nave,
		realiza_poda_arreglo
		where detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
		and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and nave_detalle_realiza_poda_arreglo.id_nave = nave.id_nave
		and nave.numero_nave = @numero_nave + 4
		and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
		and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	end
	else
	if(convert(int,right(left(@id_detalle_realiza_poda_arreglo, 4), 1)) = 3)
	begin
		update nave_detalle_realiza_poda_arreglo
		set cantidad_tallos = @cantidad_tallos,
		fecha = @fecha
		from detalle_realiza_poda_arreglo,
		nave,
		realiza_poda_arreglo
		where detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
		and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and nave_detalle_realiza_poda_arreglo.id_nave = nave.id_nave
		and nave.numero_nave = @numero_nave + 8
		and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
		and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	end
	else
	if(convert(int,right(left(@id_detalle_realiza_poda_arreglo, 4), 1)) = 4)
	begin
		update nave_detalle_realiza_poda_arreglo
		set cantidad_tallos = @cantidad_tallos,
		fecha = @fecha
		from detalle_realiza_poda_arreglo,
		nave,
		realiza_poda_arreglo
		where detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
		and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and nave_detalle_realiza_poda_arreglo.id_nave = nave.id_nave
		and nave.numero_nave = @numero_nave + 12
		and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
		and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	end
	else
	if(convert(int,right(left(@id_detalle_realiza_poda_arreglo, 4), 1)) = 5)
	begin
		update nave_detalle_realiza_poda_arreglo
		set cantidad_tallos = @cantidad_tallos,
		fecha = @fecha
		from detalle_realiza_poda_arreglo,
		nave,
		realiza_poda_arreglo
		where detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
		and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and nave_detalle_realiza_poda_arreglo.id_nave = nave.id_nave
		and nave.numero_nave = @numero_nave + 16
		and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
		and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	end
	else
	if(convert(int,right(left(@id_detalle_realiza_poda_arreglo, 4), 1)) = 6)
	begin
		update nave_detalle_realiza_poda_arreglo
		set cantidad_tallos = @cantidad_tallos,
		fecha = @fecha
		from detalle_realiza_poda_arreglo,
		nave,
		realiza_poda_arreglo
		where detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
		and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and nave_detalle_realiza_poda_arreglo.id_nave = nave.id_nave
		and nave.numero_nave = @numero_nave + 20
		and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
		and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	end
	else
	if(convert(int,right(left(@id_detalle_realiza_poda_arreglo, 4), 1)) = 7)
	begin
		update nave_detalle_realiza_poda_arreglo
		set cantidad_tallos = @cantidad_tallos,
		fecha = @fecha
		from detalle_realiza_poda_arreglo,
		nave,
		realiza_poda_arreglo
		where detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = convert(int,right(@id_detalle_realiza_poda_arreglo, 7))
		and detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo = nave_detalle_realiza_poda_arreglo.id_detalle_realiza_poda_arreglo
		and nave_detalle_realiza_poda_arreglo.id_nave = nave.id_nave
		and nave.numero_nave = @numero_nave + 24
		and realiza_poda_arreglo.id_realiza_poda_arreglo = detalle_realiza_poda_arreglo.id_realiza_poda_arreglo
		and realiza_poda_arreglo.id_realiza_poda_arreglo = @id_realiza_poda_arreglo
	end

	drop table #temp2
	drop table #nave2
end
else
if(@accion = 'consultar_tipo_poda')
begin
	select id_tipo_poda,
	nombre_tipo_poda
	from tipo_poda
	where id_tipo_poda = 2
	or id_tipo_poda = 1
	order by nombre_tipo_poda
end