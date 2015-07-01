set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[bouquet_editar_encabezado] 

@accion nvarchar(50),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@idc_farm nvarchar(5),
@idc_tipo_caja nvarchar(5),
@idc_tapa nvarchar(5),
@unidades int,
@id_encabezado int

as

if(@accion = 'consultar')
begin
	select encabezado.id_encabezado,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	farm.idc_farm,
	farm.nombre_farm,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	encabezado.unidades 
	from encabezado,
	tipo_flor,
	grado_flor,
	variedad_flor,
	farm,
	tipo_caja,
	tapa
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = encabezado.id_variedad_flor
	and grado_flor.id_grado_flor = encabezado.id_grado_flor
	and farm.id_farm = encabezado.id_farm
	and tipo_caja.id_tipo_caja = encabezado.id_tipo_caja
	and tapa.id_tapa = encabezado.id_tapa
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
	and tipo_caja.idc_tipo_caja > = 
	case
		when @idc_tipo_caja = '' then '  '
		else @idc_tipo_caja
	end
	and tipo_caja.idc_tipo_caja < = 
	case
		when @idc_tipo_caja = '' then 'ZZ'
		else @idc_tipo_caja
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
	order by tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,	
	grado_flor.idc_grado_flor,
	farm.idc_farm,
	tipo_caja.idc_tipo_caja,
	encabezado.unidades 	
end
else
if(@accion = 'insertar')
begin
	begin try
		insert into encabezado (id_grado_flor, id_variedad_flor, id_farm, id_tipo_caja, id_tapa, unidades)
		select grado_flor.id_grado_flor, 
		variedad_flor.id_variedad_flor, 
		farm.id_farm, 
		tipo_caja.id_tipo_caja, 
		tapa.id_tapa, 
		@unidades
		from tipo_flor,
		variedad_flor,
		grado_flor,
		farm,
		tipo_caja,
		tapa
		where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
		and grado_flor.idc_grado_flor = @idc_grado_flor
		and farm.idc_farm = @idc_farm
		and tipo_caja.idc_tipo_caja = @idc_tipo_caja 
		and tapa.idc_tapa = @idc_tapa

		select scope_identity() as id_encabezado
	end try
	begin catch
		select -1 as id_encabezado
	end catch
end
else
if(@accion = 'eliminar')
begin
	begin try
		delete from encabezado
		where id_encabezado = @id_encabezado

		select 2 as resultado
	end try
	begin catch
		select -2 as resultado
	end catch
end