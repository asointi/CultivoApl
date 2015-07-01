set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[prod_generar_reporte_clasificacion]

@id_regla int,
@fecha datetime,
@accion nvarchar(255),
@id_tiempo_ejecucion_regla nvarchar(255)

as

declare @fecha_transaccion datetime,
@apertura_minima decimal(20,4),
@apertura_maxima decimal(20,4)

if(@id_tiempo_ejecucion_regla is not null)
begin
	select @fecha_transaccion = fecha_transaccion
	from tiempo_ejecucion_regla
	where id_tiempo_ejecucion_regla = convert(int,@id_tiempo_ejecucion_regla)
end

if(@id_tiempo_ejecucion_regla is null)
	set @id_tiempo_ejecucion_regla = '%%'

select @apertura_minima = apertura_minima from configuracion_bd
select @apertura_maxima = apertura_maxima from configuracion_bd

if(@accion = 'generar_reporte_ejecuciones')
begin
	select tiempo_ejecucion_regla.id_tiempo_ejecucion_regla,
	regla.nombre_regla,
	tiempo_ejecucion_regla.fecha_transaccion as fecha_inicio,
	grado_flor.idc_grado_flor,
	count(tallo_clasificado.id_tallo_clasificado) as cantidad_tallos into #temporal
	from regla,
	tiempo_ejecucion_regla,
	tipo_transaccion,
	tiempo_ejecucion_detalle_condicion,
	condicion,
	detalle_condicion,
	tallo_clasificado,
	grado_flor
	where regla.id_regla = tiempo_ejecucion_regla.id_regla
	and tiempo_ejecucion_regla.id_tipo_transaccion = tipo_transaccion.id_tipo_transaccion
	and tipo_transaccion.nombre_tipo_transaccion = 'inicio'
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
	and regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_regla = @id_regla
	and convert(datetime,convert(nvarchar,tiempo_ejecucion_regla.fecha_transaccion,101)) = convert(datetime,convert(nvarchar,@fecha,101))
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla like @id_tiempo_ejecucion_regla
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	group by tiempo_ejecucion_regla.id_tiempo_ejecucion_regla,
	regla.nombre_regla,
	tiempo_ejecucion_regla.fecha_transaccion,
	grado_flor.idc_grado_flor
	order by tiempo_ejecucion_regla.fecha_transaccion,
	grado_flor.idc_grado_flor

	alter table #temporal
	add fecha_fin datetime

	DECLARE @id_tiempo_ejecucion_regla_aux int
	DECLARE tiempo_ejecucion_regla_cursor CURSOR FOR 

	SELECT id_tiempo_ejecucion_regla 
	FROM #temporal
	group by id_tiempo_ejecucion_regla
	order by id_tiempo_ejecucion_regla

	OPEN tiempo_ejecucion_regla_cursor
		FETCH NEXT FROM tiempo_ejecucion_regla_cursor
		INTO @id_tiempo_ejecucion_regla_aux
		WHILE @@FETCH_STATUS = 0
		BEGIN
			declare @fecha_fin datetime,
			@fecha_fin_aux datetime

			select @fecha_fin_aux = min(tiempo_ejecucion_regla.fecha_transaccion)
			from tiempo_ejecucion_regla
			where tiempo_ejecucion_regla.id_tiempo_ejecucion_regla > @id_tiempo_ejecucion_regla_aux
						
			select @fecha_fin = min(tiempo_ejecucion_regla.fecha_transaccion)
			from tiempo_ejecucion_regla,
			tipo_transaccion
			where tiempo_ejecucion_regla.id_tiempo_ejecucion_regla > @id_tiempo_ejecucion_regla_aux
			and tipo_transaccion.id_tipo_transaccion = tiempo_ejecucion_regla.id_tipo_transaccion
			and tipo_transaccion.nombre_tipo_transaccion = 'fin'
			
			if(@fecha_fin = @fecha_fin_aux)
			begin
				update #temporal
				set fecha_fin = @fecha_fin
				where id_tiempo_ejecucion_regla = @id_tiempo_ejecucion_regla_aux
			end
			FETCH NEXT FROM tiempo_ejecucion_regla_cursor
			INTO @id_tiempo_ejecucion_regla_aux
		END 
	CLOSE tiempo_ejecucion_regla_cursor
	DEALLOCATE tiempo_ejecucion_regla_cursor

	select * from #temporal
	drop table #temporal
end
else
if(@accion = 'generar_reporte_ejecucion_detalle')
begin
	select regla.nombre_regla,
	condicion.nombre_condicion,
	grado_flor.idc_grado_flor,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	detalle_condicion.longitud_minima,
	detalle_condicion.longitud_maxima,
	detalle_condicion.ancho_minimo,
	detalle_condicion.ancho_maximo,
	detalle_condicion.altura_cabeza_minima,
	detalle_condicion.altura_cabeza_maxima,
	detalle_condicion.apertura_minima,
	detalle_condicion.apertura_maxima,
	detalle_condicion.numero_ordenamiento,
	tallo_clasificado.largo,
	tallo_clasificado.ancho,
	tallo_clasificado.alto_cabeza,
	tallo_clasificado.apertura,
	tallo_clasificado.eyector,
	tallo_clasificado.fecha_transaccion
	from regla,
	tiempo_ejecucion_regla,
	tipo_transaccion,
	tiempo_ejecucion_detalle_condicion,
	condicion,
	detalle_condicion,
	tallo_clasificado,
	grado_flor,
	tipo_apertura_rosematic
	where regla.id_regla = tiempo_ejecucion_regla.id_regla
	and tiempo_ejecucion_regla.id_tipo_transaccion = tipo_transaccion.id_tipo_transaccion
	and tipo_transaccion.nombre_tipo_transaccion = 'inicio'
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
	and regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_regla = @id_regla
	and convert(datetime,convert(nvarchar,tiempo_ejecucion_regla.fecha_transaccion,101)) = convert(datetime,convert(nvarchar,@fecha,101))
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and condicion.id_tipo_apertura_rosematic = tipo_apertura_rosematic.id_tipo_apertura_rosematic
end
else
if(@accion = 'generar_reporte_dia')
begin
	select regla.nombre_regla,
	convert(datetime,convert(nvarchar,@fecha,101)) as fecha,
	clasificadora.nombre_clasificadora,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	grado_flor.idc_grado_flor,
	count(tallo_clasificado.id_tallo_clasificado) as cantidad_tallos
	from clasificadora,
	regla,
	tiempo_ejecucion_regla,
	condicion,
	detalle_condicion,
	tiempo_ejecucion_detalle_condicion,
	tallo_clasificado,
	grado_flor,
	tipo_flor
	where clasificadora.id_clasificadora = regla.id_clasificadora
	and regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_regla = tiempo_ejecucion_regla.id_regla
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla =  tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
	and regla.id_regla = @id_regla
	and convert(datetime,convert(nvarchar,tiempo_ejecucion_regla.fecha_transaccion,101)) = convert(datetime,convert(nvarchar,@fecha,101))
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	group by regla.nombre_regla,
	clasificadora.nombre_clasificadora,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor
	order by tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor
end
else
if(@accion = 'generar_reporte_ultima_ejecucion')
begin
	select regla.nombre_regla,
	convert(datetime,convert(nvarchar,@fecha,101)) as fecha,
	clasificadora.nombre_clasificadora,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	grado_flor.idc_grado_flor,
	count(tallo_clasificado.id_tallo_clasificado) as cantidad_tallos,
	@fecha_transaccion as fecha_transaccion
	from clasificadora,
	regla,
	tiempo_ejecucion_regla,
	condicion,
	detalle_condicion,
	tiempo_ejecucion_detalle_condicion,
	tallo_clasificado,
	grado_flor,
	tipo_flor
	where clasificadora.id_clasificadora = regla.id_clasificadora
	and regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_regla = tiempo_ejecucion_regla.id_regla
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla =  tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
	and regla.id_regla = @id_regla
	and convert(datetime,convert(nvarchar,tiempo_ejecucion_regla.fecha_transaccion,101)) = convert(datetime,convert(nvarchar,@fecha,101))
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla like @id_tiempo_ejecucion_regla
	group by regla.nombre_regla,
	clasificadora.nombre_clasificadora,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor
	order by tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor
end
else
if(@accion = 'consultar_regla')
begin
	select id_regla,
	nombre_regla
	from regla
	where disponible = 1
	order by nombre_regla
end
else 
if(@accion = 'generar_reporte_barras_grado')
begin
	select ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	grado_flor.idc_grado_flor,
	condicion.nombre_condicion,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	detalle_condicion.numero_ordenamiento,
	fecha_transaccion =
	case 
		when @id_tiempo_ejecucion_regla ='%%' then null
		else @fecha_transaccion
	end,
	tallo_clasificado.largo,
	tallo_clasificado.apertura,
   	count(tallo_clasificado.id_tallo_clasificado) as cantidad_tallos,
	regla.nombre_regla into #temp
	from clasificadora,
	regla,
	condicion,
	detalle_condicion,
	tiempo_ejecucion_detalle_condicion,
	tiempo_ejecucion_regla,
	tallo_clasificado,
	grado_flor,
	tipo_flor,
	tipo_apertura_rosematic
	where clasificadora.id_clasificadora = regla.id_clasificadora
	and regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla = tiempo_ejecucion_regla.id_tiempo_ejecucion_regla
	and tiempo_ejecucion_regla.id_regla = regla.id_regla
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_apertura_rosematic.id_tipo_apertura_rosematic = condicion.id_tipo_apertura_rosematic
	and convert(datetime,convert(nvarchar,tiempo_ejecucion_regla.fecha_transaccion,101)) = convert(datetime,convert(nvarchar,@fecha,101))
	and regla.id_regla = @id_regla
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla like @id_tiempo_ejecucion_regla
	group by tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor,
	condicion.nombre_condicion,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	detalle_condicion.numero_ordenamiento,
	tallo_clasificado.largo,
	tallo_clasificado.apertura,
	tiempo_ejecucion_regla.fecha_transaccion,
	regla.nombre_regla
	order by tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor desc,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	condicion.nombre_condicion desc,
	detalle_condicion.numero_ordenamiento

	/*****************************************************************************/
	create table #temp2 
	(id int not null identity(1,1),
	idc_grado_flor nvarchar(255),
	nombre_tipo_apertura_rosematic nvarchar(255),
	largo decimal(20,4))

	insert into #temp2 (idc_grado_flor, nombre_tipo_apertura_rosematic, largo)
	select idc_grado_flor,
	nombre_tipo_apertura_rosematic,
	largo 
	from #temp
	order by 
	idc_grado_flor,
	nombre_tipo_apertura_rosematic,
	largo

	select idc_grado_flor, 
	nombre_tipo_apertura_rosematic,
	count(*) % 2 as modulo,
	id =
	case 
		when count(*) % 2 = 1 then (min(id)-1) + (count(*) / 2) + 1
		when count(*) % 2 = 0 then (min(id)-1) + (count(*) / 2)
	end into #temp3
	from #temp2
	group by idc_grado_flor, 
	nombre_tipo_apertura_rosematic
	order by idc_grado_flor, 
	nombre_tipo_apertura_rosematic

	select #temp3.idc_grado_flor,
	#temp3.nombre_tipo_apertura_rosematic,
	#temp2.largo into #temp4
	from #temp2, #temp3
	where #temp2.id = #temp3.id
	and modulo = 1
	order by #temp3.idc_grado_flor,
	#temp3.nombre_tipo_apertura_rosematic

	insert into #temp4 (idc_grado_flor, nombre_tipo_apertura_rosematic, largo)
	select #temp3.idc_grado_flor,
	#temp3.nombre_tipo_apertura_rosematic,
	avg(#temp2.largo)
	from #temp2, #temp3
	where #temp2.id in (#temp3.id, #temp3.id + 1)
	and modulo = 0
	group by #temp3.idc_grado_flor,
	#temp3.nombre_tipo_apertura_rosematic
	order by #temp3.idc_grado_flor,
	#temp3.nombre_tipo_apertura_rosematic

	alter table #temp 
	add largo_grado_apertura decimal(20,4)

	update #temp
	set largo_grado_apertura = #temp4.largo
	from #temp4
	where #temp.idc_grado_flor = #temp4.idc_grado_flor
	and #temp.nombre_tipo_apertura_rosematic = #temp4.nombre_tipo_apertura_rosematic

	/********************************************************************/
	create table #tempa2 
	(id int not null identity(1,1),
	idc_grado_flor nvarchar(255),
	largo decimal(20,4))

	insert into #tempa2 (idc_grado_flor, largo)
	select idc_grado_flor,
	apertura 
	from #temp
	order by 
	idc_grado_flor,
	apertura

	select idc_grado_flor, 
	count(*) % 2 as modulo,
	id =
	case 
		when count(*) % 2 = 1 then (min(id)-1) + (count(*) / 2) + 1
		when count(*) % 2 = 0 then (min(id)-1) + (count(*) / 2)
	end into #tempa3
	from #tempa2
	group by idc_grado_flor
	order by idc_grado_flor

	select #tempa3.idc_grado_flor,
	#tempa2.largo into #tempa4
	from #tempa2, #tempa3
	where #tempa2.id = #tempa3.id
	and modulo = 1
	order by #tempa3.idc_grado_flor

	insert into #tempa4 (idc_grado_flor, largo)
	select #tempa3.idc_grado_flor,
	avg(#tempa2.largo)
	from #tempa2, #tempa3
	where #tempa2.id in (#tempa3.id, #tempa3.id + 1)
	and modulo = 0
	group by #tempa3.idc_grado_flor
	order by #tempa3.idc_grado_flor

	alter table #temp 
	add largo_grado decimal(20,4)

	update #temp
	set largo_grado = #tempa4.largo
	from #tempa4
	where #temp.idc_grado_flor = #tempa4.idc_grado_flor

	/***********************************************************************/

	select * from #temp

	drop table #temp
	drop table #temp2
	drop table #temp3
	drop table #temp4
	drop table #tempa2
	drop table #tempa3
	drop table #tempa4
end
else 
if(@accion = 'generar_reporte_barras_grado_apertura')
begin
	select ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	grado_flor.idc_grado_flor,
	condicion.nombre_condicion,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	detalle_condicion.numero_ordenamiento,
	fecha_transaccion =
	case 
		when @id_tiempo_ejecucion_regla ='%%' then null
		else @fecha_transaccion
	end,
	tallo_clasificado.largo,
	tallo_clasificado.apertura,
   	count(tallo_clasificado.id_tallo_clasificado) as cantidad_tallos,
	regla.nombre_regla,
	regla.id_regla into #temp_ap
	from clasificadora,
	regla,
	condicion,
	detalle_condicion,
	tiempo_ejecucion_detalle_condicion,
	tiempo_ejecucion_regla,
	tallo_clasificado,
	grado_flor,
	tipo_flor,
	tipo_apertura_rosematic
	where clasificadora.id_clasificadora = regla.id_clasificadora
	and regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla = tiempo_ejecucion_regla.id_tiempo_ejecucion_regla
	and tiempo_ejecucion_regla.id_regla = regla.id_regla
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_apertura_rosematic.id_tipo_apertura_rosematic = condicion.id_tipo_apertura_rosematic
	and convert(datetime,convert(nvarchar,tiempo_ejecucion_regla.fecha_transaccion,101)) = convert(datetime,convert(nvarchar,@fecha,101))
	and regla.id_regla = @id_regla
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla like @id_tiempo_ejecucion_regla
	group by tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor,
	condicion.nombre_condicion,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	detalle_condicion.numero_ordenamiento,
	tallo_clasificado.largo,
	tallo_clasificado.apertura,
	tiempo_ejecucion_regla.fecha_transaccion,
	regla.nombre_regla,
	regla.id_regla
	order by tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	grado_flor.idc_grado_flor desc,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	condicion.nombre_condicion desc,
	detalle_condicion.numero_ordenamiento

	delete from #temp_ap
	where id_regla = 21
	and (apertura < @apertura_minima
	or apertura > @apertura_maxima)

	delete from #temp_ap
	where id_regla = 28
	and (apertura < 0
	or apertura > @apertura_maxima)

	/*****************************************************************************/
	create table #temp2_ap
	(id int not null identity(1,1),
	idc_grado_flor nvarchar(255),
	nombre_tipo_apertura_rosematic nvarchar(255),
	largo decimal(20,4))

	insert into #temp2_ap (idc_grado_flor, nombre_tipo_apertura_rosematic, largo)
	select idc_grado_flor,
	nombre_tipo_apertura_rosematic,
	largo 
	from #temp_ap
	order by 
	idc_grado_flor,
	nombre_tipo_apertura_rosematic,
	largo

	select idc_grado_flor, 
	nombre_tipo_apertura_rosematic,
	count(*) % 2 as modulo,
	id =
	case 
		when count(*) % 2 = 1 then (min(id)-1) + (count(*) / 2) + 1
		when count(*) % 2 = 0 then (min(id)-1) + (count(*) / 2)
	end into #temp3_ap
	from #temp2_ap
	group by idc_grado_flor, 
	nombre_tipo_apertura_rosematic
	order by idc_grado_flor, 
	nombre_tipo_apertura_rosematic

	select #temp3_ap.idc_grado_flor,
	#temp3_ap.nombre_tipo_apertura_rosematic,
	#temp2_ap.largo into #temp4_ap
	from #temp2_ap, #temp3_ap
	where #temp2_ap.id = #temp3_ap.id
	and modulo = 1
	order by #temp3_ap.idc_grado_flor,
	#temp3_ap.nombre_tipo_apertura_rosematic

	insert into #temp4_ap (idc_grado_flor, nombre_tipo_apertura_rosematic, largo)
	select #temp3_ap.idc_grado_flor,
	#temp3_ap.nombre_tipo_apertura_rosematic,
	avg(#temp2_ap.largo)
	from #temp2_ap, #temp3_ap
	where #temp2_ap.id in (#temp3_ap.id, #temp3_ap.id + 1)
	and modulo = 0
	group by #temp3_ap.idc_grado_flor,
	#temp3_ap.nombre_tipo_apertura_rosematic
	order by #temp3_ap.idc_grado_flor,
	#temp3_ap.nombre_tipo_apertura_rosematic

	alter table #temp_ap 
	add largo_grado_apertura decimal(20,4)

	update #temp_ap
	set largo_grado_apertura = #temp4_ap.largo
	from #temp4_ap
	where #temp_ap.idc_grado_flor = #temp4_ap.idc_grado_flor
	and #temp_ap.nombre_tipo_apertura_rosematic = #temp4_ap.nombre_tipo_apertura_rosematic

	/********************************************************************/
	create table #tempa2_ap 
	(id int not null identity(1,1),
	idc_grado_flor nvarchar(255),
	largo decimal(20,4))

	insert into #tempa2_ap (idc_grado_flor, largo)
	select idc_grado_flor,
	apertura 
	from #temp_ap
	order by 
	idc_grado_flor,
	apertura

	select idc_grado_flor, 
	count(*) % 2 as modulo,
	id =
	case 
		when count(*) % 2 = 1 then (min(id)-1) + (count(*) / 2) + 1
		when count(*) % 2 = 0 then (min(id)-1) + (count(*) / 2)
	end into #tempa3_ap
	from #tempa2_ap
	group by idc_grado_flor
	order by idc_grado_flor

	select #tempa3_ap.idc_grado_flor,
	#tempa2_ap.largo into #tempa4_ap
	from #tempa2_ap, #tempa3_ap
	where #tempa2_ap.id = #tempa3_ap.id
	and modulo = 1
	order by #tempa3_ap.idc_grado_flor

	insert into #tempa4_ap (idc_grado_flor, largo)
	select #tempa3_ap.idc_grado_flor,
	avg(#tempa2_ap.largo)
	from #tempa2_ap, #tempa3_ap
	where #tempa2_ap.id in (#tempa3_ap.id, #tempa3_ap.id + 1)
	and modulo = 0
	group by #tempa3_ap.idc_grado_flor
	order by #tempa3_ap.idc_grado_flor

	alter table #temp_ap 
	add largo_grado decimal(20,4)

	update #temp_ap
	set largo_grado = #tempa4_ap.largo
	from #tempa4_ap
	where #temp_ap.idc_grado_flor = #tempa4_ap.idc_grado_flor

	/***********************************************************************/

	select * from #temp_ap

	drop table #temp_ap
	drop table #temp2_ap
	drop table #temp3_ap
	drop table #temp4_ap
	drop table #tempa2_ap
	drop table #tempa3_ap
	drop table #tempa4_ap
end
else
if(@accion = 'consultar_fecha_ejecucion')
begin
	select tiempo_ejecucion_regla.id_tiempo_ejecucion_regla,
	tiempo_ejecucion_regla.fecha_transaccion into #fecha
	from regla,
	tiempo_ejecucion_regla,
	tipo_transaccion,
	tiempo_ejecucion_detalle_condicion,
	condicion,
	detalle_condicion,
	tallo_clasificado
	where regla.id_regla = tiempo_ejecucion_regla.id_regla
	and tiempo_ejecucion_regla.id_tipo_transaccion = tipo_transaccion.id_tipo_transaccion
	and tipo_transaccion.nombre_tipo_transaccion = 'inicio'
	and tiempo_ejecucion_regla.id_tiempo_ejecucion_regla = tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_regla
	and regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_regla = @id_regla
	and convert(datetime,convert(nvarchar,tiempo_ejecucion_regla.fecha_transaccion,101)) = convert(datetime,convert(nvarchar,@fecha,101))

	select id_tiempo_ejecucion_regla,
	fecha_transaccion
	from #fecha
	group by id_tiempo_ejecucion_regla,
	fecha_transaccion
	order by fecha_transaccion desc

	drop table #fecha
end

