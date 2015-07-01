SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[na_editar_farm_variedad_flor_version2]

@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_farm nvarchar(5),
@accion nvarchar(50)

as

declare @id_farm int,
@id_variedad_flor int

select @id_farm = farm.id_farm
from farm
where farm.idc_farm = @idc_farm

select @id_variedad_flor = variedad_flor.id_variedad_flor
from variedad_flor,
tipo_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor

if(@accion = 'consultar')
begin
	select farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor
	from variedad_flor,
	farm_variedad_flor,
	farm,
	tipo_flor
	where variedad_flor.id_variedad_flor = farm_variedad_flor.id_variedad_flor
	and farm.id_farm = farm_variedad_flor.id_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
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
	order by farm.idc_farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor
end
else
if(@accion = 'insertar')
begin
	declare @conteo int
	
	select @conteo = count(*)
	from farm_variedad_flor
	where farm_variedad_flor.id_farm = @id_farm
	and farm_variedad_flor.id_variedad_flor = @id_variedad_flor
	
	if(@conteo = 0)
	begin
		insert into farm_variedad_flor (id_farm, id_variedad_flor)
		values (@id_farm, @id_variedad_flor)

		select 1 as resultado
	end
	else
	if(@conteo = 0)
	begin
		select -1 as resultado
	end
end
else
if(@accion = 'eliminar')
begin
	delete from farm_variedad_flor
	where id_farm = @id_farm
	and id_variedad_flor = @id_variedad_flor
end