set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_consultar_camas_asignadas_reporte_diario]

as

declare @fecha datetime,
@conteo int

set @fecha = getdate()

select tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
bloque.idc_bloque,
pieza_postcosecha.idc_pieza_postcosecha,
punto_corte.idc_punto_corte,
punto_corte.nombre_punto_corte,
pieza_postcosecha.unidades_por_pieza,
persona.idc_persona,
ltrim(rtrim(persona.nombre)) as nombre_persona,
ltrim(rtrim(persona.apellido)) as apellido_persona,
ltrim(rtrim(persona.identificacion)) as identificacion,
persona.id_persona,
pieza_postcosecha.fecha_entrada
from pieza_postcosecha,
persona,
tipo_flor,
variedad_flor,
bloque,
punto_corte
where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza_postcosecha.id_bloque = bloque.id_bloque
and pieza_postcosecha.id_punto_corte = punto_corte.id_punto_corte
and persona.id_persona = pieza_postcosecha.id_persona
and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada, 101)) = convert(datetime,convert(nvarchar,@fecha, 101))
and not exists
(
	select *
	from area_asignada,
	area,
	estado_area,
	detalle_area,
	sembrar_cama_bloque,
	construir_cama_bloque,
	cama_bloque,
	cama,
	nave,
	bloque,
	tipo_flor,
	variedad_flor
	where persona.id_persona = dbo.Area_Asignada.id_persona
	and dbo.Area_Asignada.id_area = dbo.Area.id_area
	and dbo.Area.id_estado_area = estado_area.id_estado_area
	and dbo.Estado_Area.nombre_estado_area = 'Asignada'
	and dbo.Area.id_area = dbo.Detalle_Area.id_area
	and detalle_area.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
	and not exists
	(
	 select * from erradicar_cama_bloque
	 where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
	)
	and area_asignada.id_area_asignada in
	(
		select max(area_asignada.id_area_asignada)
		from area_asignada
		group by area_asignada.id_area
	)
	and dbo.Sembrar_Cama_Bloque.id_construir_cama_bloque = dbo.Construir_Cama_Bloque.id_construir_cama_bloque
	and dbo.Construir_Cama_Bloque.id_cama = dbo.Cama_Bloque.id_cama 
	AND dbo.Construir_Cama_Bloque.id_bloque = dbo.Cama_Bloque.id_bloque 
	AND dbo.Construir_Cama_Bloque.id_nave = dbo.Cama_Bloque.id_nave
	and dbo.Cama_Bloque.id_cama = dbo.Cama.id_cama
	and dbo.Cama_Bloque.id_bloque = dbo.Bloque.id_bloque
	and dbo.Cama_Bloque.id_nave = dbo.Nave.id_nave
	and dbo.Variedad_Flor.id_tipo_flor = dbo.Tipo_Flor.id_tipo_flor
	and dbo.Sembrar_Cama_Bloque.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor
)