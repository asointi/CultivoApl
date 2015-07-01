set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[bouquet_editar_bouquet] 

@accion nvarchar(50),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@idc_farm nvarchar(5),
@idc_caja nvarchar(5),
@idc_tapa nvarchar(5),
@id_capuchon int,
@id_comida_bouquet int,
@id_bouquet int,
@unidades int,
@nombre_bouquet nvarchar(50),
@upc bigint,
@upc_date nvarchar(50),
@precio_miami decimal(20,4),
@precio_retail nvarchar(255),
@especificacion nvarchar(1024),
@construccion_bouquet nvarchar(1024),
@id_encabezado int

as

if(@accion = 'consultar')
begin
	select bouquet.id_bouquet,
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
	encabezado.id_encabezado,
	capuchon.nombre_capuchon,
	comida_bouquet.nombre_comida,
	bouquet.nombre_bouquet,
	convert(nvarchar,bouquet.upc) as upc,
	bouquet.upc_date,
	bouquet.precio_miami,
	bouquet.precio_retail,
	bouquet.especificacion,
	bouquet.construccion_bouquet,
	bouquet.imagen,
	isnull(item_number.numero_item, '') as numero_item
	from encabezado,
	bouquet left join item_number on bouquet.id_bouquet = item_number.id_bouquet,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	tipo_caja,
	tapa,
	capuchon,
	comida_bouquet,
	caja
	where encabezado.id_grado_flor = bouquet.id_grado_flor
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
	and capuchon.id_capuchon = bouquet.id_capuchon
	and comida_bouquet.id_comida_bouquet = bouquet.id_comida_bouquet
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = bouquet.id_caja
	and tipo_flor.idc_tipo_flor > = 
	case
		when @idc_tipo_flor = '' then '  '
		else @idc_tipo_flor
	end
	and tipo_flor.idc_tipo_flor < = 
	case
		when @idc_tipo_flor = '' then 'ZZ'
		else @idc_tipo_flor
	end
	and variedad_flor.idc_variedad_flor > = 
	case
		when @idc_variedad_flor = '' then '  '
		else @idc_variedad_flor
	end
	and variedad_flor.idc_variedad_flor < = 
	case
		when @idc_variedad_flor = '' then 'ZZ'
		else @idc_variedad_flor
	end
	and grado_flor.idc_grado_flor > = 
	case
		when @idc_grado_flor = '' then '  '
		else @idc_grado_flor
	end
	and grado_flor.idc_grado_flor < = 
	case
		when @idc_grado_flor = '' then 'ZZ'
		else @idc_grado_flor
	end
	and farm.idc_farm > = 
	case
		when @idc_farm = '' then '  '
		else @idc_farm
	end
	and farm.idc_farm < = 
	case
		when @idc_farm = '' then 'ZZ'
		else @idc_farm
	end
	and tipo_caja.idc_tipo_caja + caja.idc_caja > = 
	case
		when @idc_caja = '' then '  '
		else @idc_caja
	end
	and tipo_caja.idc_tipo_caja + caja.idc_caja  < = 
	case
		when @idc_caja = '' then 'ZZ'
		else @idc_caja
	end
	and tapa.idc_tapa > = 
	case
		when @idc_tapa = '' then '  '
		else @idc_tapa
	end
	and tapa.idc_tapa < = 
	case
		when @idc_tapa = '' then 'ZZ'
		else @idc_tapa
	end
	and capuchon.id_capuchon > = 
	case
		when @id_capuchon = 0 then 0
		else @id_capuchon
	end
	and capuchon.id_capuchon < = 
	case
		when @id_capuchon = 0 then 9999
		else @id_capuchon
	end
	and comida_bouquet.id_comida_bouquet > = 
	case
		when @id_comida_bouquet = 0 then 0
		else @id_comida_bouquet
	end
	and comida_bouquet.id_comida_bouquet < = 
	case
		when @id_comida_bouquet = 0 then 9999
		else @id_comida_bouquet
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
if(@accion = 'insertar')
begin
	begin try
		insert into bouquet 
		(
			id_grado_flor,
			id_variedad_flor,
			id_farm,
			id_tipo_caja,
			id_caja,
			id_tapa,
			unidades,
			id_capuchon,
			id_comida_bouquet,
			nombre_bouquet,
			upc,
			upc_date,
			precio_miami,
			precio_retail,
			especificacion,
			construccion_bouquet
		)
		select encabezado.id_grado_flor,
		encabezado.id_variedad_flor,
		encabezado.id_farm,
		encabezado.id_tipo_caja,
		caja.id_caja,
		encabezado.id_tapa,
		encabezado.unidades,
		@id_capuchon,
		@id_comida_bouquet,
		@nombre_bouquet,
		@upc,
		@upc_date,
		@precio_miami,
		@precio_retail,
		@especificacion,
		@construccion_bouquet
		from encabezado,
		tipo_caja,
		caja
		where encabezado.id_encabezado = @id_encabezado
		and tipo_caja.id_tipo_caja = caja.id_tipo_caja
		and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja
		and tipo_caja.id_tipo_caja = encabezado.id_tipo_caja

		select scope_identity() as id_bouquet

	end try
	begin catch
		select -1 as id_bouquet
	end catch
end
else
if(@accion = 'eliminar')
begin
	begin try
		delete from bouquet
		where id_bouquet = @id_bouquet

		select 2 as resultado
	end try
	begin catch
		select -2 as resultado
	end catch
end
else
if(@accion = 'actualizar')
begin
	update bouquet
	set nombre_bouquet = @nombre_bouquet,
	upc = @upc,
	upc_date = @upc_date,
	precio_miami = @precio_miami,
	precio_retail = @precio_retail,
	especificacion = @especificacion,
	construccion_bouquet = @construccion_bouquet,
	id_capuchon = @id_capuchon,
	id_comida_bouquet = @id_comida_bouquet
	from caja,
	tipo_caja
	where bouquet.id_bouquet = @id_bouquet
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja
	and tipo_caja.id_tipo_caja = bouquet.id_tipo_caja
end