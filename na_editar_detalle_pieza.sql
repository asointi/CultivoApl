set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_detalle_pieza]

@accion nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_pieza nvarchar(255),
@cantidad_tallos int

AS

if(@accion = 'insertar')
begin
	insert into detalle_pieza (id_pieza, id_variedad_flor, id_grado_flor, cantidad_tallos)
	select pieza.id_pieza, variedad_flor.id_variedad_flor, grado_flor.id_grado_flor, @cantidad_tallos
	from variedad_flor,
	grado_flor,
	tipo_flor,
	pieza
	where tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and pieza.idc_pieza = @idc_pieza
end
else
if(@accion = 'consultar')
begin
	select tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	sum(detalle_pieza.cantidad_tallos) as cantidad_tallos
	from detalle_pieza,
	pieza,
	variedad_flor,
	tipo_flor,
	grado_flor
	where pieza.idc_pieza = @idc_pieza
	and pieza.id_pieza = detalle_pieza.id_pieza
	and detalle_pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and detalle_pieza.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	group by tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor
	order by tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor
end