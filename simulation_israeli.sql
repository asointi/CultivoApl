alter PROCEDURE [dbo].[simulation_israeli]

@accion nvarchar(50),
@id_imagen_florero_simulacion int,
@id_cuenta_interna int,
@imagen image,
@id_variedad_flor int,
@id_dia int

AS

declare  @conteo int

if(@accion = 'consultar_simulacion')
begin
	select variedad_flor.id_variedad_flor,
	ltrim(rtrim(nombre_variedad_flor)) as nombre_variedad_flor
	from simulacion,
	variedad_flor
	where variedad_flor.id_variedad_flor = simulacion.id_variedad_flor
	and variedad_flor.id_variedad_flor <> 7379
	order by nombre_variedad_flor
end
else
if(@accion = 'consultar_simulacion_dia')
begin
	select dia.id_dia,
	dia.nombre_dia + ' ' + left(convert(nvarchar, dia.fecha, 6), 6) as nombre_dia
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
	dia.fecha 
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
	and dia.id_dia = @id_dia
	group by imagen_florero_simulacion.id_imagen_florero_simulacion,
	florero.id_florero,
	florero.nombre_florero,
	imagen_florero_simulacion.fecha_transaccion,
	cuenta_interna.nombre,
	florero_simulacion.descripcion
	order by florero.id_florero
end
else
if(@accion = 'modificar_imagen')
begin
	select @conteo = count(*)
	from imagen_florero_simulacion
	where dbo.compara_imagenes(imagen, datalength(imagen)) = dbo.compara_imagenes(@imagen, datalength(@imagen))
	and imagen_florero_simulacion.id_imagen_florero_simulacion = @id_imagen_florero_simulacion

	if(@conteo = 0)
	begin
		update imagen_florero_simulacion
		set imagen = @imagen,
		fecha_transaccion = getdate(),
		id_cuenta_interna = @id_cuenta_interna
		where imagen_florero_simulacion.id_imagen_florero_simulacion = @id_imagen_florero_simulacion
	end
end
else
if(@accion = 'consultar_simulacion_pagina_publica')
begin
	select dia.id_dia,
	dia.nombre_dia + ' ' + left(convert(nvarchar, dia.fecha, 6), 6) as nombre_dia,
	(
		select imagen_florero_simulacion.id_imagen_florero_simulacion
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'ESPECIAL'
	) as id_imagen_especial,
	(
		select imagen_florero_simulacion.imagen
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'ESPECIAL'
	) as 'ESPECIAL',
	(
		select imagen_florero_simulacion.id_imagen_florero_simulacion
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'CON PLASTICO'
	) as id_imagen_con_plastico,
	(
		select imagen_florero_simulacion.imagen
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'CON PLASTICO'
	) as 'CON PLASTICO',
	(
		select imagen_florero_simulacion.id_imagen_florero_simulacion
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'CON PAPEL'
	) as id_imagen_con_papel,
	(
		select imagen_florero_simulacion.imagen
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'CON PAPEL'
	) as 'CON PAPEL',
	(
		select imagen_florero_simulacion.id_imagen_florero_simulacion
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'SIN FUMIGACION CON PAPEL'
	) as id_imagen_sin_fumigacion_con_papel,
	(
		select imagen_florero_simulacion.imagen
		from imagen_florero_simulacion,
		florero_simulacion,
		simulacion,
		florero
		where simulacion.id_simulacion = florero_simulacion.id_simulacion 
		and florero.id_florero = florero_simulacion.id_florero
		and florero_simulacion.id_florero = imagen_florero_simulacion.id_florero
		and florero_simulacion.id_simulacion =  imagen_florero_simulacion.id_simulacion
		and imagen_florero_simulacion.id_dia = dia.id_dia
		and simulacion.id_variedad_flor = @id_variedad_flor
		and florero.nombre_florero = 'SIN FUMIGACION CON PAPEL'
	) as 'SIN FUMIGACION CON PAPEL'
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
	group by dia.id_dia,
	dia.nombre_dia,
	dia.fecha
	order by dia.id_dia,
	dia.nombre_dia
end