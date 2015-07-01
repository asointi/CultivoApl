/****** Object:  StoredProcedure [dbo].[na_consultar_grado_por_tipo_flor]    Script Date: 10/06/2007 12:00:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[cultivo_consultar_grado_flor]

@idc_tipo_flor nvarchar(10)

AS

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