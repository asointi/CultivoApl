set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_farm]

@idc_farm nvarchar(5),
@idc_ciudad nvarchar(5),
@nombre_farm nvarchar(255),
@tiene_variedad_flor_exclusiva nvarchar(5),
@comision_farm decimal(20,4),
@dias_restados_despacho_distribuidora int,
@terceros nvarchar(5),
@directas nvarchar(5),
@tipo_consignacion nvarchar(5)

as

declare @id_tipo_farm int, @conteo int

if(@idc_ciudad = '')
	set @idc_ciudad = null

if(@tiene_variedad_flor_exclusiva = 'X')
	set @tiene_variedad_flor_exclusiva = 1
else
	set @tiene_variedad_flor_exclusiva = 0

if(@terceros = 'X')
begin
	select @id_tipo_farm = id_tipo_farm	from tipo_farm where nombre_tipo_farm = 'Terceros'--Natural y Pruebas
	select @id_tipo_farm = id_tipo_farm	from tipo_farm where nombre_tipo_farm = 'Fixed Prices'--Fresca
end
else
if(@directas = 'X')
begin
	select @id_tipo_farm = id_tipo_farm	from tipo_farm where nombre_tipo_farm = 'Directas'
end
else
if(@terceros = '' and @directas = '' and @tipo_consignacion = '')
begin
	select @id_tipo_farm = id_tipo_farm	from tipo_farm where nombre_tipo_farm = 'Natuflora'--Natural y Pruebas
	select @id_tipo_farm = id_tipo_farm	from tipo_farm where nombre_tipo_farm = 'Consigment'--Fresca
end
else
if(@terceros = '' and @directas = '' and @tipo_consignacion = 'X')
begin
	select @id_tipo_farm = id_tipo_farm	from tipo_farm where nombre_tipo_farm = 'Natuflora BOUQUETS'--Natural y Pruebas
	select @id_tipo_farm = id_tipo_farm	from tipo_farm where nombre_tipo_farm = 'No Definida'--Fresca
end

select @conteo = count(*) from farm where idc_farm = @idc_farm

if(@conteo < 1)
begin
	insert into farm (idc_farm,id_tipo_farm,id_ciudad,nombre_farm,tiene_variedad_flor_exclusiva,comision_farm,dias_restados_despacho_distribuidora)
	select @idc_farm,
	@id_tipo_farm,
	ciudad.id_ciudad,
	@nombre_farm,
	@tiene_variedad_flor_exclusiva,
	@comision_farm,
	@dias_restados_despacho_distribuidora
	from ciudad
	where ciudad.idc_ciudad = @idc_ciudad
end
else
if(@conteo = 1)
begin
	update farm
	set nombre_farm = @nombre_farm,
	tiene_variedad_flor_exclusiva = @tiene_variedad_flor_exclusiva,
	comision_farm = @comision_farm,
	dias_restados_despacho_distribuidora = @dias_restados_despacho_distribuidora,
	id_tipo_farm = @id_tipo_farm,
	id_ciudad = ciudad.id_ciudad
	from farm, 
	ciudad
	where farm.idc_farm = @idc_farm
	and ciudad.idc_ciudad = @idc_ciudad
end

