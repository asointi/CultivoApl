SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[prod_siembras_etiquetas]

@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255)

as

select bloque.idc_bloque,
tipo_flor.idc_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
persona.idc_persona,
ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre_persona,
count(distinct detalle_area.id_sembrar_cama_bloque) as cantidad_camas,
isnull((
	select sum(unidades_por_pieza) 
	from Pieza_postcosecha
	where convert(datetime,convert(nvarchar,Pieza_postcosecha.fecha_entrada, 101)) between
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
	and Pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and Pieza_postcosecha.id_bloque = bloque.id_bloque
	and Pieza_postcosecha.id_persona = persona.id_persona
),0) as cantidad_unidades,
isnull((
	select count(Pieza_postcosecha.id_pieza_postcosecha) 
	from Pieza_postcosecha
	where convert(datetime,convert(nvarchar,Pieza_postcosecha.fecha_entrada, 101)) between
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
	and Pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and Pieza_postcosecha.id_bloque = bloque.id_bloque
	and Pieza_postcosecha.id_persona = persona.id_persona
),0) as cantidad_piezas
from bloque,
cama_bloque,
construir_cama_bloque,
sembrar_cama_bloque,
persona,
tipo_flor,
variedad_flor,
detalle_area,
area,
estado_area,
area_asignada
where bloque.id_bloque = cama_bloque.id_bloque
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and sembrar_cama_bloque.id_sembrar_cama_bloque = detalle_area.id_sembrar_cama_bloque
and detalle_area.id_area = area.id_area
and area.id_area = area_asignada.id_area
and area_asignada.id_persona = persona.id_persona
and area.id_estado_area = estado_area.id_estado_area
and estado_area.nombre_estado_area = 'Asignada'
and area_asignada.id_area_asignada in
(
	select max(area_asignada.id_area_asignada)
	from area_asignada
	group by area_asignada.id_area
)
and not exists
(
	select * from erradicar_cama_bloque
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
)
group by bloque.idc_bloque,
bloque.id_bloque,
tipo_flor.idc_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.id_variedad_flor,
persona.idc_persona,
persona.id_persona,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
ltrim(rtrim(persona.nombre)),
ltrim(rtrim(persona.apellido))
order by bloque.idc_bloque,
tipo_flor.idc_tipo_flor,
variedad_flor.idc_variedad_flor,
persona.idc_persona