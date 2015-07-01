/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_programacion_poda]

@accion nvarchar(255),
@nombre_año int,
@id_año_fiesta int,
@nombre_fiesta nvarchar(50),
@id_fiesta int,
@fecha datetime, 
@id_cuenta_interna int,
@id_programacion_fiesta int,
@cantidad_camas int,
@id_bloque int,
@id_variedad_flor int,
@id_programacion_poda int

as

declare @conteo int,
@id_año_fiesta_aux int

/********************************************************/
/********************************************************/
/********************************************************/
/********************Tabla Año_Fiesta********************/
if(@accion = 'consultar_año')
begin
	select id_año_fiesta,
	nombre_año
	from año_fiesta
	order by nombre_año
end
else
if(@accion = 'insertar_año')
begin
	select @conteo = count(*)
	from año_fiesta
	where nombre_año = @nombre_año

	if(@conteo = 0)
	begin
		insert into año_fiesta (nombre_año)
		values (@nombre_año)
	end
end
else
if(@accion = 'actualizar_año')
begin
	select @conteo = count(*)
	from año_fiesta
	where nombre_año = @nombre_año

	if(@conteo = 0)
	begin
		update año_fiesta 
		set nombre_año = @nombre_año
		where id_año_fiesta = @id_año_fiesta
	end
end
else
if(@accion = 'eliminar_año')
begin
	select @conteo = count(*)
	from año_fiesta,
	programacion_fiesta
	where año_fiesta.id_año_fiesta = programacion_fiesta.id_año_fiesta
	and año_fiesta.id_año_fiesta = @id_año_fiesta

	if(@conteo = 0)
	begin
		delete from año_fiesta 
		where id_año_fiesta = @id_año_fiesta
	end
end
else
/********************************************************/
/********************************************************/
/********************************************************/
/**********************Tabla Fiesta**********************/
if(@accion = 'consultar_fiesta')
begin
	select id_fiesta,
	nombre_fiesta
	from fiesta
	order by nombre_fiesta
end
else
if(@accion = 'insertar_fiesta')
begin
	select @conteo = count(*)
	from fiesta
	where nombre_fiesta = @nombre_fiesta

	if(@conteo = 0)
	begin
		insert into fiesta (nombre_fiesta)
		values (@nombre_fiesta)
	end
end
else
if(@accion = 'actualizar_fiesta')
begin
	select @conteo = count(*)
	from fiesta
	where nombre_fiesta = @nombre_fiesta

	if(@conteo = 0)
	begin
		update fiesta 
		set nombre_fiesta = @nombre_fiesta
		where id_fiesta = @id_fiesta
	end
end
else
if(@accion = 'eliminar_fiesta')
begin
	select @conteo = count(*)
	from fiesta,
	programacion_fiesta
	where fiesta.id_fiesta = programacion_fiesta.id_fiesta
	and fiesta.id_fiesta = @id_fiesta

	if(@conteo = 0)
	begin
		delete from fiesta 
		where id_fiesta = @id_fiesta
	end
end
/********************************************************/
/********************************************************/
/********************************************************/
/**************Tabla Programacion_Fiesta*****************/
if(@accion = 'consultar_programacion_fiesta')
begin
	select programacion_fiesta.id_programacion_fiesta,
	año_fiesta.id_año_fiesta,
	año_fiesta.nombre_año,
	fiesta.id_fiesta,
	fiesta.nombre_fiesta,
	programacion_fiesta.fecha,
	convert(nvarchar,año_fiesta.nombre_año) + ' - ' + fiesta.nombre_fiesta + ' (' + convert(nvarchar,programacion_fiesta.fecha,101) + ')' as nombre_programacion_fiesta
	from fiesta,
	año_fiesta,
	programacion_fiesta,
	cuenta_interna
	where año_fiesta.id_año_fiesta = programacion_fiesta.id_año_fiesta
	and fiesta.id_fiesta = programacion_fiesta.id_fiesta
	and cuenta_interna.id_cuenta_interna = programacion_fiesta.id_cuenta_interna
	order by programacion_fiesta.fecha desc
end
else
if(@accion = 'insertar_programacion_fiesta')
begin
	insert into programacion_fiesta (id_año_fiesta, id_fiesta, fecha, id_cuenta_interna)
	values (@id_año_fiesta, @id_fiesta, @fecha, @id_cuenta_interna)
end
else
if(@accion = 'actualizar_programacion_fiesta')
begin
	update programacion_fiesta
	set fecha = @fecha
	where programacion_fiesta.id_programacion_fiesta = @id_programacion_fiesta
end
else
if(@accion = 'eliminar_programacion_fiesta')
begin
	select @conteo = count(*)
	from programacion_poda,
	programacion_fiesta
	where programacion_fiesta.id_año_fiesta = programacion_poda.id_año_fiesta
	and programacion_fiesta.id_fiesta = programacion_poda.id_fiesta
	and programacion_fiesta.id_programacion_fiesta = @id_programacion_fiesta

	if(@conteo = 0)
	begin
		delete from programacion_fiesta 
		where id_programacion_fiesta = @id_programacion_fiesta
	end
end
/********************************************************/
/********************************************************/
/********************************************************/
/**************Tabla programacion_poda******************/
if(@accion = 'consultar_programacion_poda')
begin
	select programacion_poda.id_programacion_poda,
	programacion_fiesta.id_programacion_fiesta,
	año_fiesta.id_año_fiesta,
	año_fiesta.nombre_año,
	fiesta.id_fiesta,
	fiesta.nombre_fiesta,
	programacion_fiesta.fecha,
	cuenta_interna.nombre as nombre_cuenta_interna,
	bloque.id_bloque,
	bloque.idc_bloque,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	programacion_poda.cantidad_camas,
	programacion_poda.fecha_transaccion
	from fiesta,
	año_fiesta,
	programacion_fiesta,
	programacion_poda,
	variedad_flor,
	tipo_flor,
	cuenta_interna,
	bloque
	where año_fiesta.id_año_fiesta = programacion_fiesta.id_año_fiesta
	and fiesta.id_fiesta = programacion_fiesta.id_fiesta
	and cuenta_interna.id_cuenta_interna = programacion_fiesta.id_cuenta_interna
	and programacion_fiesta.id_año_fiesta = programacion_poda.id_año_fiesta
	and programacion_fiesta.id_fiesta = programacion_poda.id_fiesta
	and programacion_fiesta.id_programacion_fiesta = @id_programacion_fiesta
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = programacion_poda.id_variedad_flor
	and bloque.id_bloque = programacion_poda.id_bloque
	order by bloque.idc_bloque,
	nombre_tipo_flor,
	nombre_variedad_flor
end
else
if(@accion = 'insertar_programacion_poda')
begin
	insert into programacion_poda (id_bloque, id_cuenta_interna, id_año_fiesta, id_fiesta, id_variedad_flor, cantidad_camas)
	select @id_bloque, 
	@id_cuenta_interna, 
	programacion_fiesta.id_año_fiesta, 
	programacion_fiesta.id_fiesta, 
	@id_variedad_flor, 
	@cantidad_camas
	from programacion_fiesta
	where programacion_fiesta.id_programacion_fiesta = @id_programacion_fiesta
end
else
if(@accion = 'eliminar_programacion_poda')
begin
	delete from programacion_poda
	where programacion_poda.id_programacion_poda = @id_programacion_poda
end
else
if(@accion = 'consultar_cantidad_camas')
begin
	select @id_año_fiesta_aux = año_fiesta.id_año_fiesta
	from año_fiesta,
	fiesta,
	programacion_fiesta
	where año_fiesta.id_año_fiesta = programacion_fiesta.id_año_fiesta
	and fiesta.id_fiesta = programacion_fiesta.id_fiesta
	and programacion_fiesta.id_programacion_fiesta = @id_programacion_fiesta

	select bloque.id_bloque,
	bloque.idc_bloque,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	count(distinct sembrar_cama_bloque.id_sembrar_cama_bloque) as cantidad_camas into #camas
	from bloque,
	cama,
	nave,
	cama_bloque,
	construir_cama_bloque,
	sembrar_cama_bloque,
	variedad_flor,
	tipo_flor
	where bloque.id_bloque = cama_bloque.id_bloque
	and cama.id_cama = cama_bloque.id_cama
	and nave.id_nave = cama_bloque.id_nave
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama_bloque.id_nave = construir_cama_bloque.id_nave
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and variedad_flor.id_variedad_flor = sembrar_cama_bloque.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
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
	group by bloque.id_bloque,
	bloque.idc_bloque,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor))
	order by bloque.idc_bloque,
	nombre_tipo_flor,
	nombre_variedad_flor

	alter table #camas
	add camas_programadas int

	select bloque.id_bloque,
	variedad_flor.id_variedad_flor,
	sum(cantidad_camas) as cantidad_camas into #podas
	from programacion_fiesta,
	año_fiesta,
	programacion_poda,
	fiesta,
	bloque,
	variedad_flor
	where año_fiesta.id_año_fiesta = @id_año_fiesta_aux
	and año_fiesta.id_año_fiesta = programacion_fiesta.id_año_fiesta
	and programacion_fiesta.id_fiesta = programacion_poda.id_fiesta
	and programacion_fiesta.id_año_fiesta = programacion_poda.id_año_fiesta
	and fiesta.id_fiesta = programacion_fiesta.id_fiesta
	and bloque.id_bloque = programacion_poda.id_bloque
	and variedad_flor.id_variedad_flor = programacion_poda.id_variedad_flor
	group by bloque.id_bloque,
	variedad_flor.id_variedad_flor

	update #camas
	set camas_programadas = #podas.cantidad_camas
	from #podas
	where #podas.id_bloque = #camas.id_bloque
	and #podas.id_variedad_flor = #camas.id_variedad_flor

	select id_bloque,
	idc_bloque,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	cantidad_camas as camas_sembradas,
	camas_programadas,
	cantidad_camas - isnull(camas_programadas, 0) as camas_disponibles
	from #camas
	order by idc_bloque,
	idc_variedad_flor

	drop table #camas
	drop table #podas
end