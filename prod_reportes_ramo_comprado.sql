set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_reportes_ramo_comprado]

@accion nvarchar(255),
@idc_finca_inicial nvarchar(255),
@idc_finca_final nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime

as

if(@accion = 'reporte_rango_fincas_fecha')
begin
	select finca.id_finca,
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)) as nombre_finca,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	punto_corte.idc_punto_corte,
	punto_corte.nombre_punto_corte,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) as nombre_persona,
	ltrim(rtrim(persona.apellido)) as apellido_persona,
	count(ramo_comprado.id_ramo_comprado) as cantidad_ramos,
	sum(tallos_por_ramo) as cantidad_tallos,
	convert(datetime,convert(nvarchar, ramo_comprado.fecha_lectura, 101)) as fecha
	from ramo_comprado,
	punto_corte,
	persona,
	grado_flor,
	variedad_flor,
	tipo_flor,
	etiqueta_impresa_finca_asignada,
	finca_asignada,
	finca
	where ramo_comprado.id_persona = persona.id_persona
	and ramo_comprado.id_punto_corte = punto_corte.id_punto_corte
	and ramo_comprado.id_grado_flor = grado_flor.id_grado_flor
	and ramo_comprado.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and ramo_comprado.id_etiqueta_impresa_finca_asignada = etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada
	and etiqueta_impresa_finca_asignada.id_finca = finca_asignada.id_finca
	and finca_asignada.id_finca = finca.id_finca
	and finca.idc_finca > = 
	CASE 
		WHEN @idc_finca_inicial = '' THEN '%%' 
		ELSE @idc_finca_inicial
	END	
	and finca.idc_finca < = 
	CASE 
		WHEN @idc_finca_final = '' THEN '%%' 
		ELSE @idc_finca_final
	END	
	and convert(datetime,convert(nvarchar, ramo_comprado.fecha_lectura, 101)) > = 
	CASE 
		WHEN @fecha_inicial = '' THEN '%%' 
		ELSE @fecha_inicial
	END	
	and convert(datetime,convert(nvarchar, ramo_comprado.fecha_lectura, 101)) < = 
	CASE 
		WHEN @fecha_final = '' THEN '%%' 
		ELSE @fecha_final
	END	
	group by finca.id_finca,
	finca.idc_finca,
	ltrim(rtrim(finca.nombre_finca)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	punto_corte.idc_punto_corte,
	punto_corte.nombre_punto_corte,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	convert(datetime,convert(nvarchar, ramo_comprado.fecha_lectura, 101))
end