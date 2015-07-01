/****** Object:  StoredProcedure [dbo].[ext_customer_shipment_menu]    Script Date: 10/06/2007 11:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[mapeo_consultar_mapeo_comercializadora]

@accion nvarchar(50)

as

if(@accion = 'variedad_flor')
begin
	select tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	1 as disponible into #variedad_flor
	from variedad_flor,
	tipo_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.disponible = 1

	update #variedad_flor
	set disponible = 0
	from mapeo_variedad_flor_natuflora
	where #variedad_flor.id_variedad_flor = mapeo_variedad_flor_natuflora.id_variedad_flor

	select id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor into #tipo_flor_cultivo
	from bd_cultivo.bd_cultivo.dbo.tipo_flor

	select id_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor into #variedad_flor_cultivo
	from bd_cultivo.bd_cultivo.dbo.variedad_flor

	select variedad_flor.id_variedad_flor into #usados_natuflora
	from mapeo_variedad_flor_natuflora,
	variedad_flor,
	tipo_flor,
	#tipo_flor_cultivo as t,
	#variedad_flor_cultivo as v
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = mapeo_variedad_flor_natuflora.id_variedad_flor
	and t.id_tipo_flor = v.id_tipo_flor
	and v.id_variedad_flor = mapeo_variedad_flor_natuflora.id_variedad_flor_natuflora
		
	update #variedad_flor
	set disponible = 0
	from #usados_natuflora
	where #variedad_flor.id_variedad_flor = #usados_natuflora.id_variedad_flor

	select id_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	ltrim(rtrim(nombre_variedad_flor)) + ' [' + idc_variedad_flor + ']' as nombre_variedad_flor,
	disponible
	from #variedad_flor
	order by nombre_variedad_flor

	drop table #variedad_flor
	drop table #usados_natuflora
	drop table #tipo_flor_cultivo
	drop table #variedad_flor_cultivo
end
else
if(@accion = 'grado_flor')
begin
	select tipo_flor.id_tipo_flor,
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	case
		when mapeo_grado_flor_natuflora.id_grado_flor is null then 1
		else 0
	end as disponible,
	grado_flor.orden into #grado_flor
	from grado_flor left join mapeo_grado_flor_natuflora on grado_flor.id_grado_flor = mapeo_grado_flor_natuflora.id_grado_flor,
	tipo_flor
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and grado_flor.disponible = 1

	select grado_flor.id_grado_flor into #grados_usados_natuflora
	from mapeo_grado_flor_natuflora,
	grado_flor,
	tipo_flor,
	bd_cultivo.bd_cultivo.dbo.tipo_flor as t,
	bd_cultivo.bd_cultivo.dbo.grado_flor as g
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and grado_flor.id_grado_flor = mapeo_grado_flor_natuflora.id_grado_flor
	and t.id_tipo_flor = g.id_tipo_flor
	and g.id_grado_flor = mapeo_grado_flor_natuflora.id_grado_flor_natuflora
		
	update #grado_flor
	set disponible = 0
	from #grados_usados_natuflora
	where #grado_flor.id_grado_flor = #grados_usados_natuflora.id_grado_flor

	select id_tipo_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	disponible,
	orden
	from #grado_flor
	order by orden

	drop table #grado_flor
	drop table #grados_usados_natuflora
end