set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_condicion_grado_flor]

@accion nvarchar(255),
@id_grado_flor nvarchar(255),
@id_condicion int,
@id_clasificadora nvarchar(255),
@nombre_tipo_apertura_rosematic nvarchar(255)

as

if (@id_clasificadora is null)
	set @id_clasificadora = '%%'

if (@id_grado_flor is null)
	set @id_grado_flor = '%%'

if(@accion = 'consultar')
begin
	select condicion.id_condicion,
	clasificadora.nombre_clasificadora,
	regla.nombre_regla,
	condicion.nombre_condicion
	from clasificadora,
	regla,
	condicion
	where condicion.id_grado_flor is null
	and regla.id_regla = condicion.id_regla
	and clasificadora.id_clasificadora = regla.id_clasificadora
	and clasificadora.id_clasificadora like @id_clasificadora
	order by clasificadora.nombre_clasificadora,
	regla.nombre_regla,
	condicion.nombre_condicion
end
else
if(@accion = 'modificar')
begin
	update condicion
	set id_grado_flor = convert(int,@id_grado_flor),
	id_tipo_apertura_rosematic = tipo_apertura_rosematic.id_tipo_apertura_rosematic
	from tipo_apertura_rosematic
	where condicion.id_condicion = @id_condicion
	and tipo_apertura_rosematic.nombre_tipo_apertura_rosematic = @nombre_tipo_apertura_rosematic
end
else
if(@accion = 'consultar_detalle')
begin
	select condicion.id_condicion,
	clasificadora.nombre_clasificadora,
	regla.nombre_regla + space(1) + '(' + punto_corte.nombre_punto_corte + ')' as nombre_regla,
	condicion.nombre_condicion,
	tipo_apertura_rosematic.nombre_tipo_apertura_rosematic,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '(' + grado_flor.idc_grado_flor + ')' as nombre_grado_flor
	from clasificadora,
	regla,
	condicion,
	grado_flor,
	tipo_flor,
	tipo_apertura_rosematic,
	punto_corte
	where regla.id_regla = condicion.id_regla
	and regla.id_punto_corte = punto_corte.id_punto_corte
	and clasificadora.id_clasificadora = regla.id_clasificadora
	and condicion.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_apertura_rosematic.id_tipo_apertura_rosematic = condicion.id_tipo_apertura_rosematic
	and clasificadora.id_clasificadora like @id_clasificadora
	and grado_flor.id_grado_flor like @id_grado_flor
	order by clasificadora.nombre_clasificadora,
	regla.nombre_regla,
	condicion.nombre_condicion
end

