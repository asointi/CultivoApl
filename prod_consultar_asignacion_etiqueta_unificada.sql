set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[prod_consultar_asignacion_etiqueta_unificada]

@id_etiqueta_impresa int

as

select count(*) as asignacion
from caracteristica_tipo_flor, 
Variedad_Flor, 
Tipo_Flor, 
Bloque, 
Persona,
punto_corte,
etiqueta,
etiqueta_impresa,
area_asignada,
area,
estado_area,
detalle_area,
sembrar_cama_bloque,
construir_cama_bloque,
cama_bloque,
cama,
nave
where etiqueta.id_persona = persona.id_persona
and etiqueta.id_bloque = bloque.id_bloque
and etiqueta.id_variedad_flor = variedad_flor.id_variedad_flor
and etiqueta.id_punto_corte = punto_corte.id_punto_corte
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = caracteristica_tipo_flor.id_tipo_flor
and etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa
and persona.id_persona = dbo.Area_Asignada.id_persona
and dbo.Area_Asignada.id_area = dbo.Area.id_area
and dbo.Area.id_estado_area = estado_area.id_estado_area
and dbo.Estado_Area.nombre_estado_area = 'Asignada'
and dbo.Area.id_area = dbo.Detalle_Area.id_area
and detalle_area.id_sembrar_cama_bloque = dbo.Sembrar_Cama_Bloque.id_sembrar_cama_bloque
and not exists
(
	select * 
	from erradicar_cama_bloque
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
and dbo.Sembrar_Cama_Bloque.id_variedad_flor = dbo.Variedad_Flor.id_variedad_flor