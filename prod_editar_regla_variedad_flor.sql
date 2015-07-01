set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_regla_variedad_flor]

@accion nvarchar(255),
@id_variedad_flor int,
@id_punto_corte int,
@id_regla int,
@id_clasificadora nvarchar(255)

as

if (@id_clasificadora is null)
	set @id_clasificadora = '%%'

if(@accion = 'consultar')
begin
	select regla.id_regla,
	clasificadora.nombre_clasificadora,
	regla.nombre_regla
	from clasificadora,
	regla
	where regla.id_variedad_flor is null
	and clasificadora.id_clasificadora = regla.id_clasificadora
	and clasificadora.id_clasificadora like @id_clasificadora
	order by clasificadora.nombre_clasificadora,
	regla.nombre_regla
end
else
if(@accion = 'modificar')
begin
	update regla
	set id_variedad_flor = @id_variedad_flor,
	id_punto_corte = @id_punto_corte
	where regla.id_regla = @id_regla
end
else
if(@accion = 'consultar_detalle')
begin
	select regla.id_regla,
	regla.nombre_regla,
	clasificadora.nombre_clasificadora,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	punto_corte.nombre_punto_corte
	from clasificadora,
	regla,
	variedad_flor,
	tipo_flor,
	punto_corte
	where regla.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and regla.id_punto_corte = punto_corte.id_punto_corte
	and regla.disponible = 1
	and regla.id_clasificadora = clasificadora.id_clasificadora
	and clasificadora.id_clasificadora like @id_clasificadora
	order by clasificadora.nombre_clasificadora,
	regla.nombre_regla
end