set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_farm_variedad_flor]

@idc_farm nvarchar(2),
@idc_tipo_flor nvarchar(2),
@idc_variedad_flor nvarchar(2),
@accion nvarchar(255)

as

if(@accion = 'insertar')
begin
	declare @conteo int

	select @conteo = count(*)
	from
	farm,
	variedad_flor,
	tipo_flor,
	farm_variedad_flor
	where farm.idc_farm = @idc_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and farm_variedad_flor.id_variedad_flor = variedad_flor.id_variedad_flor
	and farm_variedad_flor.id_farm = farm.id_farm

	insert into farm_variedad_flor (id_variedad_flor, id_farm)
	select variedad_flor.id_variedad_flor, farm.id_farm 
	from
	farm,
	variedad_flor,
	tipo_flor
	where farm.idc_farm = @idc_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
end
else
if(@accion = 'borrar')
begin
	delete from farm_variedad_flor
	where farm_variedad_flor.id_farm = 
	(
		select farm.id_farm from farm where farm.idc_farm = @idc_farm
	)
	and farm_variedad_flor.id_variedad_flor = 
	(
		select variedad_flor.id_variedad_flor
		from tipo_flor,
		variedad_flor
		where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.idc_tipo_flor = @idc_tipo_flor
		and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	)
end