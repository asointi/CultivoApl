set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_ramo_cultivo_comercializadora]

@fecha_inicial datetime,
@fecha_final datetime,
@id_tipo_flor int,
@id_variedad_flor_natural int,
@id_variedad_flor_fresca int,
@accion nvarchar(50)

as

if(@accion = 'consultar_tipo_flor_fresca')
begin
	select id_tipo_flor,
	idc_tipo_flor,
	ltrim(rtrim(nombre_tipo_flor)) + ' [' + idc_tipo_flor + ']' as nombre_tipo_flor
	from bd_fresca.bd_fresca.dbo.tipo_flor
	where disponible = 1
	order by nombre_tipo_flor
end
else
if(@accion = 'consultar_variedad_flor_fresca')
begin
	select id_variedad_flor,
	idc_variedad_flor,
	ltrim(rtrim(nombre_variedad_flor)) + ' [' + idc_variedad_flor + ']' as nombre_variedad_flor
	from bd_fresca.bd_fresca.dbo.tipo_flor,
	bd_fresca.bd_fresca.dbo.variedad_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = @id_tipo_flor
	and variedad_flor.disponible = 1
	order by nombre_variedad_flor
end
else
if(@accion = 'consultar_tipo_flor_natural')
begin
	select id_tipo_flor,
	idc_tipo_flor,
	ltrim(rtrim(nombre_tipo_flor)) + ' [' + idc_tipo_flor + ']' as nombre_tipo_flor
	from bd_nf.bd_nf.dbo.tipo_flor
	where disponible = 1
	order by nombre_tipo_flor
end
else
if(@accion = 'consultar_variedad_flor_natural')
begin
	select id_variedad_flor,
	idc_variedad_flor,
	ltrim(rtrim(nombre_variedad_flor)) + ' [' + idc_variedad_flor + ']' as nombre_variedad_flor
	from bd_nf.bd_nf.dbo.tipo_flor,
	bd_nf.bd_nf.dbo.variedad_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = @id_tipo_flor
	and variedad_flor.disponible = 1
	order by nombre_variedad_flor
end