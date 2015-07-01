set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-01-06
-- Description:	Generar informacion para G&G
-- =============================================

alter PROCEDURE [dbo].[na_crear_productos_gg]

@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_tipo_caja nvarchar(255),
@unidades_por_pieza int

as

insert into Producto_GG
(
	descripcion,
	idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	nombre_color,
	nombre_tipo_caja,
	unidades_por_pieza,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor
)
select top 1 ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_flor.idc_tipo_flor + ' - ' + ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor + ' - ' + ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.idc_grado_flor + ' - ' + ltrim(rtrim(grado_flor.nombre_grado_flor)),
color.idc_color + ' - ' + ltrim(rtrim(color.nombre_color)),
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
@unidades_por_pieza,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor
from variedad_flor,
tipo_flor, 
grado_flor,
caja,
tipo_caja,
color
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and caja.id_tipo_caja = tipo_caja.id_tipo_caja
and variedad_flor.id_color = color.id_color
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and tipo_caja.idc_tipo_caja = @idc_tipo_caja