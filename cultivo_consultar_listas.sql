/****** Object:  StoredProcedure [dbo].[na_consultar_todos_tipo_flor]    Script Date: 10/06/2007 12:07:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[cultivo_consultar_listas]

@accion nvarchar(255),
@idc_tipo_flor nvarchar(10)

AS

if(@accion = 'tipo_flor')
begin
	SELECT id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	compone_bouquet_rosa
	FROM tipo_flor_cultivo
	WHERE disponible = 1
	ORDER BY nombre_tipo_flor
end
else
if(@accion = 'color')
begin
	SELECT id_color_cultivo as id_color,
	idc_color,
	nombre_color 
	FROM color_cultivo
	order by nombre_color
end
else
if(@accion = 'capuchon')
begin
	SELECT id_capuchon,
	idc_capuchon,
	descripcion,
	descripcion as nombre_capuchon,
	ancho_superior,
	ancho_inferior,
	alto,
	decorado,
	disponible
	FROM capuchon_cultivo 
	ORDER BY nombre_capuchon
end
else
if(@accion = 'variedad_flor')
begin
	SELECT tipo_flor_cultivo.id_tipo_flor,
	tipo_flor_cultivo.idc_tipo_flor,
	tipo_flor_cultivo.nombre_tipo_flor,
	tipo_flor_cultivo.compone_bouquet_rosa,
	variedad_flor_cultivo.id_variedad_flor,
	variedad_flor_cultivo.idc_variedad_flor,
	variedad_flor_cultivo.nombre_variedad_flor,
	color_cultivo.id_color_cultivo as id_color,
	color_cultivo.idc_color,
	color_cultivo.nombre_color
	FROM variedad_flor_cultivo left join color_cultivo on variedad_flor_cultivo.id_color_cultivo = color_cultivo.id_color_cultivo,
	tipo_flor_cultivo
	where tipo_flor_cultivo.id_tipo_flor = variedad_flor_cultivo.id_tipo_flor
	and tipo_flor_cultivo.idc_tipo_flor > = 
	case
		when @idc_tipo_flor is null then '  '
		else @idc_tipo_flor
	end
	and tipo_flor_cultivo.idc_tipo_flor < = 
	case
		when @idc_tipo_flor is null then 'ZZ'
		else @idc_tipo_flor
	end
	and variedad_flor_cultivo.disponible = 1
	ORDER BY variedad_flor_cultivo.nombre_variedad_flor
end
else
if(@accion = 'grado_flor')
begin
	SELECT tipo_flor_cultivo.id_tipo_flor,
	tipo_flor_cultivo.idc_tipo_flor,
	tipo_flor_cultivo.nombre_tipo_flor,
	tipo_flor_cultivo.compone_bouquet_rosa,
	grado_flor_cultivo.id_grado_flor,
	grado_flor_cultivo.idc_grado_flor,
	grado_flor_cultivo.nombre_grado_flor,
	grado_flor_cultivo.descripcion,
	grado_flor_cultivo.medidas
	FROM grado_flor_cultivo, 
	tipo_flor_cultivo
	where grado_flor_cultivo.disponible = 1
	and tipo_flor_cultivo.id_tipo_flor = grado_flor_cultivo.id_tipo_flor
	and tipo_flor_cultivo.idc_tipo_flor > = 
	case
		when @idc_tipo_flor is null then '  '
		else @idc_tipo_flor
	end
	and tipo_flor_cultivo.idc_tipo_flor < = 
	case
		when @idc_tipo_flor is null then 'ZZ'
		else @idc_tipo_flor
	end
	ORDER BY grado_flor_cultivo.nombre_grado_flor
end