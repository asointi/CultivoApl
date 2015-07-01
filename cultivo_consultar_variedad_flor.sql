/****** Object:  StoredProcedure [dbo].[na_consultar_variedad_por_tipo_flor]    Script Date: 10/06/2007 12:08:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[cultivo_consultar_variedad_flor]

@idc_tipo_flor nvarchar(10)

AS

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