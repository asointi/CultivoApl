set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_bloque_reporte_areas_tipo_bloque]

@accion nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime,
@id_tipo_flor int,
@id_variedad_flor int,
@fecha_gracia datetime

as 

declare @promedio_maximo decimal(20,4)

SET DATEFIRST 1;

if(@id_variedad_flor is not null)
begin
	/*produccion calculada para el periodo solicitado por el usuario - se incluyen únicamente bloques*/
	/*que tengan fecha de siembra dentro del rango solicitado por el usuario y de la misma manera no se*/
	/*incluye la producción del día actual*/
	select bloque.id_bloque,
	bloque.idc_bloque,
	bloque.area,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	max(pieza_postcosecha.fecha_entrada) as fecha_maxima,
	sum(pieza_postcosecha.unidades_por_pieza) as cantidad_tallos,
	(
		select count(cama.id_cama)
		from cama,
		cama_bloque,
		construir_cama_bloque,
		sembrar_cama_bloque,
		tipo_flor as tf,
		variedad_flor as vf,
		bloque as b
		where b.id_bloque = cama_bloque.id_bloque
		and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
		and cama_bloque.id_nave = construir_cama_bloque.id_nave
		and cama_bloque.id_cama = construir_cama_bloque.id_cama
		and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
		and vf.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and vf.id_variedad_flor = @id_variedad_flor
		and cama.id_cama = cama_bloque.id_cama
		and tf.id_tipo_flor = tipo_flor.id_tipo_flor
		and vf.id_variedad_flor = variedad_flor.id_variedad_flor
		and b.id_bloque = bloque.id_bloque
		and sembrar_cama_bloque.fecha < = @fecha_final
		group by b.id_bloque
	) as camas_sembradas,
	(
		select count(distinct construir_cama_bloque.id_construir_cama_bloque)
		from bloque as b,
		cama_bloque,
		construir_cama_bloque
		where b.id_bloque = cama_bloque.id_bloque
		and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
		and cama_bloque.id_cama = construir_cama_bloque.id_cama
		and cama_bloque.id_nave = construir_cama_bloque.id_nave
		and bloque.id_bloque = b.id_bloque
		and construir_cama_bloque.fecha < = @fecha_final
		group by b.id_bloque
	) as camas_totales,
	(
		select max(sembrar_cama_bloque.fecha)
		from cama,
		cama_bloque,
		construir_cama_bloque,
		sembrar_cama_bloque,
		tipo_flor as tf,
		variedad_flor as vf,
		bloque as b
		where b.id_bloque = cama_bloque.id_bloque
		and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
		and cama_bloque.id_nave = construir_cama_bloque.id_nave
		and cama_bloque.id_cama = construir_cama_bloque.id_cama
		and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
		and vf.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and vf.id_variedad_flor = @id_variedad_flor
		and cama.id_cama = cama_bloque.id_cama
		and tf.id_tipo_flor = tipo_flor.id_tipo_flor
		and vf.id_variedad_flor = variedad_flor.id_variedad_flor
		and b.id_bloque = bloque.id_bloque
		and sembrar_cama_bloque.fecha < = @fecha_final
		group by b.id_bloque
	) as fecha_siembra into #temp
	from bloque,
	pieza_postcosecha,
	tipo_flor,
	variedad_flor
	where bloque.id_bloque = pieza_postcosecha.id_bloque
	and pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = @id_variedad_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) between
	@fecha_inicial and @fecha_final
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) <> convert(datetime, convert(nvarchar, getdate(), 101))
	group by bloque.id_bloque,
	bloque.idc_bloque,
	bloque.area,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor))
	having bloque.area is not null

	alter table #temp
	add promedio_maximo decimal(20,4),
	promedio decimal(20,4),
	area_por_cama decimal(20,4),
	area_por_cama_unitaria decimal(20,4)

	/*calcular el área que cada cama utiliza del bloque en total*/
	update #temp
	set area_por_cama = (area/camas_totales) * camas_sembradas,
	area_por_cama_unitaria = (area/camas_totales)

	if(@accion = 'reporte_area')
	begin
		/*calcular el promedio de cada bloque en los diferentes periodos de tiempo*/
		update #temp
		set promedio = cantidad_tallos/area_por_cama
		
		/*colocar el promedio máximo para que todas las gráficas del reporte vayan hasta el mismo valor en el eje X*/
		select @promedio_maximo = max(promedio) from #temp

		update #temp
		set promedio_maximo = @promedio_maximo
		
		select *, 'parciales' as tipo_bloque into #temp2 
		from #temp
		where camas_sembradas is not null
		and fecha_siembra > = @fecha_gracia
		union
		select *, 'estables'
		from #temp
		where camas_sembradas is not null
		and fecha_siembra < @fecha_gracia

		select * from #temp2
		order by convert(int, promedio) desc
	end
	drop table #temp
	drop table #temp2
end
