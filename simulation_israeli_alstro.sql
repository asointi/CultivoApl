alter PROCEDURE [dbo].[simulation_israeli_alstro]

@accion nvarchar(50),
@id_imagen_1 int,
@id_imagen_2 int,
@id_cuenta_interna int,
@imagen_1 image,
@imagen_2 image,
@id_variedad_flor int,
@id_dia int,
@id_florero_1 int,
@id_florero_2 int

AS

declare  @conteo int

if(@accion = 'consultar_florero')
begin
	select id_florero, nombre_florero 
	from florero
	where nombre_florero like 'TREATMENT%'
	ORDER BY ID_FLORERO
end
else
if(@accion = 'consultar_simulacion')
begin
	select variedad_flor.id_variedad_flor,
	ltrim(rtrim(nombre_variedad_flor)) as nombre_variedad_flor
	from simulacion,
	variedad_flor
	where variedad_flor.id_variedad_flor = simulacion.id_variedad_flor
	and variedad_flor.id_variedad_flor = 7379
	order by nombre_variedad_flor
end
else
if(@accion = 'consultar_simulacion_dia')
begin
	select dia.id_dia,
	dia.nombre_dia + ' ' + left(convert(nvarchar, dia.fecha_astromelia, 6), 6) as nombre_dia
	from simulacion,
	variedad_flor,
	florero,
	florero_simulacion,
	imagen_florero_simulacion,
	dia,
	cuenta_interna
	where variedad_flor.id_variedad_flor = simulacion.id_variedad_flor
	and simulacion.id_simulacion = florero_simulacion.id_simulacion
	and florero.id_florero = florero_simulacion.id_florero
	and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
	and florero_simulacion.id_simulacion = imagen_florero_simulacion.id_simulacion
	and dia.id_dia = imagen_florero_simulacion.id_dia
	and imagen_florero_simulacion.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and variedad_flor.id_variedad_flor = @id_variedad_flor
	group by
	dia.id_dia,
	dia.nombre_dia,
	dia.fecha_astromelia 
	order by dia.id_dia
end
else
if(@accion = 'consultar_simulacion_imagen')
begin
	select imagen_florero_simulacion.id_imagen_florero_simulacion,
	florero.id_florero,
	florero.nombre_florero,
	(
		select i.imagen
		from imagen_florero_simulacion as i
		where imagen_florero_simulacion.id_imagen_florero_simulacion = i.id_imagen_florero_simulacion
	) as imagen,
	imagen_florero_simulacion.fecha_transaccion,
	cuenta_interna.nombre as nombre_cuenta,
	florero_simulacion.descripcion into #temp
	from simulacion,
	variedad_flor,
	florero,
	florero_simulacion,
	imagen_florero_simulacion,
	dia,
	cuenta_interna
	where variedad_flor.id_variedad_flor = simulacion.id_variedad_flor
	and simulacion.id_simulacion = florero_simulacion.id_simulacion
	and florero.id_florero = florero_simulacion.id_florero
	and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
	and florero_simulacion.id_simulacion = imagen_florero_simulacion.id_simulacion
	and dia.id_dia = imagen_florero_simulacion.id_dia
	and imagen_florero_simulacion.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and variedad_flor.id_variedad_flor = @id_variedad_flor
	and dia.id_dia = @id_dia
	group by imagen_florero_simulacion.id_imagen_florero_simulacion,
	florero.id_florero,
	florero.nombre_florero,
	imagen_florero_simulacion.fecha_transaccion,
	cuenta_interna.nombre,
	florero_simulacion.descripcion
	order by florero.id_florero,
	imagen_florero_simulacion.id_imagen_florero_simulacion

	select 	id_florero,
	nombre_florero,
	max(nombre_cuenta) as nombre_cuenta,
	max(fecha_transaccion) as fecha_transaccion,
	max(descripcion) as descripcion,
	min(id_imagen_florero_simulacion) as id_imagen_1,
	(
		select t.imagen 
		from #temp as t
		where t.id_florero = #temp.id_florero
		and t.id_imagen_florero_simulacion = min(#temp.id_imagen_florero_simulacion)
	) as imagen1,
	max(id_imagen_florero_simulacion) as id_imagen_2,
	(
		select t.imagen 
		from #temp as t
		where t.id_florero = #temp.id_florero
		and t.id_imagen_florero_simulacion = max(#temp.id_imagen_florero_simulacion)
	) as imagen2
	from #temp
	group by id_florero,
	nombre_florero
	order by id_florero

	drop table #temp
end
else
if(@accion = 'modificar_imagen')
begin
	select @conteo = count(*)
	from imagen_florero_simulacion
	where dbo.compara_imagenes(imagen, datalength(imagen)) = dbo.compara_imagenes(@imagen_1, datalength(@imagen_1))
	and imagen_florero_simulacion.id_imagen_florero_simulacion = @id_imagen_1

	if(@conteo = 0)
	begin
		update imagen_florero_simulacion
		set imagen = @imagen_1,
		fecha_transaccion = getdate(),
		id_cuenta_interna = @id_cuenta_interna
		where imagen_florero_simulacion.id_imagen_florero_simulacion = @id_imagen_1
	end

	set @conteo = null

	select @conteo = count(*)
	from imagen_florero_simulacion
	where dbo.compara_imagenes(imagen, datalength(imagen)) = dbo.compara_imagenes(@imagen_2, datalength(@imagen_2))
	and imagen_florero_simulacion.id_imagen_florero_simulacion = @id_imagen_2

	if(@conteo = 0)
	begin
		update imagen_florero_simulacion
		set imagen = @imagen_2,
		fecha_transaccion = getdate(),
		id_cuenta_interna = @id_cuenta_interna
		where imagen_florero_simulacion.id_imagen_florero_simulacion = @id_imagen_2
	end
end
else
if(@accion = 'consultar_simulacion_pagina_publica')
begin
	select dia.id_dia,
	dia.nombre_dia + ' ' + left(convert(nvarchar, dia.fecha_astromelia, 6), 6) as nombre_dia,
	imagen_florero_simulacion.id_imagen_florero_simulacion,
	florero.id_florero,
	florero.nombre_florero,
	(
		select i.imagen
		from imagen_florero_simulacion as i
		where imagen_florero_simulacion.id_imagen_florero_simulacion = i.id_imagen_florero_simulacion
	) as imagen,
	imagen_florero_simulacion.fecha_transaccion,
	cuenta_interna.nombre as nombre_cuenta,
	florero_simulacion.descripcion into #temp2
	from simulacion,
	variedad_flor,
	florero,
	florero_simulacion,
	imagen_florero_simulacion,
	dia,
	cuenta_interna
	where variedad_flor.id_variedad_flor = simulacion.id_variedad_flor
	and simulacion.id_simulacion = florero_simulacion.id_simulacion
	and florero.id_florero = florero_simulacion.id_florero
	and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
	and florero_simulacion.id_simulacion = imagen_florero_simulacion.id_simulacion
	and dia.id_dia = imagen_florero_simulacion.id_dia
	and imagen_florero_simulacion.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and variedad_flor.id_variedad_flor = @id_variedad_flor
	and florero.id_florero = @id_florero_1
	group by imagen_florero_simulacion.id_imagen_florero_simulacion,
	florero.id_florero,
	florero.nombre_florero,
	imagen_florero_simulacion.fecha_transaccion,
	cuenta_interna.nombre,
	florero_simulacion.descripcion,
	dia.id_dia,
	dia.nombre_dia,
	dia.fecha_astromelia

	union all

	select dia.id_dia,
	dia.nombre_dia + ' ' + left(convert(nvarchar, dia.fecha_astromelia, 6), 6) as nombre_dia,
	imagen_florero_simulacion.id_imagen_florero_simulacion,
	florero.id_florero,
	florero.nombre_florero,
	(
		select i.imagen
		from imagen_florero_simulacion as i
		where imagen_florero_simulacion.id_imagen_florero_simulacion = i.id_imagen_florero_simulacion
	) as imagen,
	imagen_florero_simulacion.fecha_transaccion,
	cuenta_interna.nombre as nombre_cuenta,
	florero_simulacion.descripcion 
	from simulacion,
	variedad_flor,
	florero,
	florero_simulacion,
	imagen_florero_simulacion,
	dia,
	cuenta_interna
	where variedad_flor.id_variedad_flor = simulacion.id_variedad_flor
	and simulacion.id_simulacion = florero_simulacion.id_simulacion
	and florero.id_florero = florero_simulacion.id_florero
	and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
	and florero_simulacion.id_simulacion = imagen_florero_simulacion.id_simulacion
	and dia.id_dia = imagen_florero_simulacion.id_dia
	and imagen_florero_simulacion.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and variedad_flor.id_variedad_flor = @id_variedad_flor
	and florero.id_florero = @id_florero_2
	group by imagen_florero_simulacion.id_imagen_florero_simulacion,
	florero.id_florero,
	florero.nombre_florero,
	imagen_florero_simulacion.fecha_transaccion,
	cuenta_interna.nombre,
	florero_simulacion.descripcion,
	dia.id_dia,
	dia.nombre_dia,
	dia.fecha_astromelia
	order by dia.id_dia,
	florero.id_florero,
	imagen_florero_simulacion.id_imagen_florero_simulacion

	select id_dia, 
	id_florero, 
	min(id_imagen_florero_simulacion) as id_imagen_1, 
	max(id_imagen_florero_simulacion) as id_imagen_2 into #temp3
	from #temp2
	group by id_dia, 
	id_florero 
	order by id_dia, 
	id_florero

	alter table #temp3
	add imagen_1 image,
	imagen_2 image

	update #temp3
	set imagen_1 = #temp2.imagen
	from #temp2
	where #temp2.id_imagen_florero_simulacion = #temp3.id_imagen_1

	update #temp3
	set imagen_2 = #temp2.imagen
	from #temp2
	where #temp2.id_imagen_florero_simulacion = #temp3.id_imagen_2

	select id_dia,
	nombre_dia,
	MAX(nombre_cuenta) as nombre_cuenta,
	max(fecha_transaccion) as fecha_transaccion,
	max(descripcion) as descripcion,
	(
		select top 1 florero.nombre_florero 
		from florero
		where florero.id_florero = @id_florero_1
	) as florero_1,
	(
	select id_imagen_1 
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_1
	) as id_imagen_1_florero_1,
	(
	select id_imagen_2
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_1
	) as id_imagen_2_florero_1,
	(
	select imagen_1
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_1
	) as imagen_1_florero_1,
	(
	select imagen_2
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_1
	) as imagen_2_florero_1,
	(
		select top 1 florero.nombre_florero 
		from florero
		where florero.id_florero = @id_florero_2
	) as florero_2,
	(
	select id_imagen_1 
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_2

	) as id_imagen_1_florero_2,
	(
	select id_imagen_2
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_2
	) as id_imagen_2_florero_2,
	(
	select imagen_1
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_2
	) as imagen_1_florero_2,
	(
	select imagen_2
	from #temp3
	where #temp3.id_dia = #temp2.id_dia
	and #temp3.id_florero = @id_florero_2
	) as imagen_2_florero_2
	from #temp2
	group by id_dia,
	nombre_dia

	drop table #temp2
	drop table #temp3
end