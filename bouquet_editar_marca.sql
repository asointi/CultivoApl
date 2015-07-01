set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[bouquet_editar_marca] 

@accion nvarchar(50),
@code nvarchar(5),
@id_marca int,
@id_encabezado int,
@id_bouquet int,
@id_marca_encabezado_bouquet int

as

declare @conteo int

if(@accion = 'consultar_marca')
begin
	select marca.id_marca,
	marca.code
	from marca
	order by marca.code
end
else
if(@accion = 'insertar_marca')
begin
	select @conteo = count(*)
	from marca
	where code = ltrim(rtrim(@code))

	if(@conteo = 0)
	begin
		insert into marca (code)
		values (ltrim(rtrim(@code)))

		select scope_identity() as id_marca
	end
	else
	begin
		select -1 as id_marca
	end
end
else
if(@accion = 'actualizar_marca')
begin
	select @conteo = count(*)
	from marca
	where code = ltrim(rtrim(@code))

	if(@conteo = 0)
	begin
		update marca 
		set code = ltrim(rtrim(@code))

		select 2 as resultado
	end
	else
	begin
		select -2 as resultado
	end
end
else
if(@accion = 'eliminar_marca')
begin
	begin try 
		delete from marca
		where id_marca = @id_marca

		select 3 as resultado
	end try
	begin catch
		select -3 as resultado
	end catch
end
else
if(@accion = 'insertar_marca_encabezado_bouquet')
begin
	begin try
		insert into marca_encabezado_bouquet (id_marca, id_grado_flor, id_variedad_flor, id_farm, id_tipo_caja, id_tapa, unidades, id_bouquet)
		select @id_marca, 
		encabezado.id_grado_flor, 
		encabezado.id_variedad_flor, 
		encabezado.id_farm, 
		encabezado.id_tipo_caja, 
		encabezado.id_tapa, 
		encabezado.unidades, 
		bouquet.id_bouquet
		from encabezado,
		bouquet
		where encabezado.id_encabezado = @id_encabezado
		and bouquet.id_bouquet = @id_bouquet
		and encabezado.id_grado_flor = bouquet.id_grado_flor
		and encabezado.id_variedad_flor = bouquet.id_variedad_flor
		and encabezado.id_farm = bouquet.id_farm
		and encabezado.id_tipo_caja = bouquet.id_tipo_caja
		and encabezado.id_tapa = bouquet.id_tapa
		and encabezado.unidades = bouquet.unidades


		select scope_identity() as id_marca_encabezado_bouquet
	end try
	begin catch
		select -4 as id_marca_encabezado_bouquet
	end catch
end
else
if(@accion = 'consultar_marca_encabezado_bouquet')
begin
	select marca.id_marca,
	marca.code,
	encabezado.id_encabezado,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	farm.idc_farm,
	farm.nombre_farm,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	encabezado.unidades,
	bouquet.id_bouquet,
	bouquet.nombre_bouquet,
	bouquet.upc,
	bouquet.upc_date,
	bouquet.precio_miami,
	bouquet.precio_retail,
	bouquet.especificacion,
	bouquet.construccion_bouquet,
	bouquet.imagen,
	marca_encabezado_bouquet.id_marca_encabezado_bouquet
	from marca,
	encabezado,
	bouquet,
	marca_encabezado_bouquet,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	tipo_caja,
	tapa,
	caja
	where marca.id_marca = marca_encabezado_bouquet.id_marca
	and bouquet.id_bouquet = marca_encabezado_bouquet.id_bouquet
	and encabezado.id_grado_flor = marca_encabezado_bouquet.id_grado_flor
	and encabezado.id_variedad_flor = marca_encabezado_bouquet.id_variedad_flor
	and encabezado.id_farm = marca_encabezado_bouquet.id_farm
	and encabezado.id_tipo_caja = marca_encabezado_bouquet.id_tipo_caja
	and encabezado.id_tapa = marca_encabezado_bouquet.id_tapa
	and encabezado.unidades = marca_encabezado_bouquet.unidades
	and encabezado.id_grado_flor = bouquet.id_grado_flor
	and encabezado.id_variedad_flor = bouquet.id_variedad_flor
	and encabezado.id_farm = bouquet.id_farm
	and encabezado.id_tipo_caja = bouquet.id_tipo_caja
	and encabezado.id_tapa = bouquet.id_tapa
	and encabezado.unidades = bouquet.unidades
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = encabezado.id_variedad_flor
	and grado_flor.id_grado_flor = encabezado.id_grado_flor
	and farm.id_farm = encabezado.id_farm
	and tipo_caja.id_tipo_caja = encabezado.id_tipo_caja
	and tapa.id_tapa = encabezado.id_tapa
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = bouquet.id_caja
	and marca.id_marca > = 
	case
		when @id_marca = 0 then 0
		else @id_marca
	end
	and marca.id_marca < = 
	case
		when @id_marca = 0 then 999999
		else @id_marca
	end
	and encabezado.id_encabezado > = 
	case
		when @id_encabezado = 0 then 0
		else @id_encabezado
	end
	and encabezado.id_encabezado < = 
	case
		when @id_encabezado = 0 then 9999999
		else @id_encabezado
	end
	and bouquet.id_bouquet > = 
	case
		when @id_bouquet = 0 then 0
		else @id_bouquet
	end
	and bouquet.id_bouquet < = 
	case
		when @id_bouquet = 0 then 9999999
		else @id_bouquet
	end
end
else
if(@accion = 'eliminar_marca_encabezado_bouquet')
begin
	delete from marca_encabezado_bouquet
	where marca_encabezado_bouquet.id_marca_encabezado_bouquet = @id_marca_encabezado_bouquet
end
else
if(@accion = 'actualizar_marca_encabezado_bouquet')
begin
	begin try
		update marca_encabezado_bouquet
		set id_bouquet = bouquet.id_bouquet,
		id_marca = @id_marca,
		id_grado_flor = encabezado.id_grado_flor,
		id_variedad_flor = encabezado.id_variedad_flor,
		id_farm = encabezado.id_farm,
		id_tipo_caja = encabezado.id_tipo_caja,
		id_tapa = encabezado.id_tapa,
		unidades = encabezado.unidades
		from encabezado,
		bouquet
		where marca_encabezado_bouquet.id_marca_encabezado_bouquet = @id_marca_encabezado_bouquet
		and encabezado.id_encabezado = @id_encabezado
		and bouquet.id_bouquet = @id_bouquet
		and encabezado.id_grado_flor = bouquet.id_grado_flor
		and encabezado.id_variedad_flor = bouquet.id_variedad_flor
		and encabezado.id_farm = bouquet.id_farm
		and encabezado.id_tipo_caja = bouquet.id_tipo_caja
		and encabezado.id_tapa = bouquet.id_tapa
		and encabezado.unidades = bouquet.unidades

		select 5 as resultado
	end try
	begin catch
		select -5 as resultado
	end catch
end