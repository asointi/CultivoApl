set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_camas_por_operario]

as

/*Consulta utilizada para mostrar los operarios que estám asignados a cada cama.
El reporte que muestra esta información es: Cultivo_Siembras_Camas_Por_Operario.rdl*/
select bloque.idc_bloque,
nave.numero_nave,
cama.numero_cama,
persona.idc_persona,
ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre_persona,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + tipo_flor.idc_tipo_flor as nombre_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + variedad_flor.idc_variedad_flor as nombre_variedad_flor
from sembrar_cama_bloque left join persona on sembrar_cama_bloque.id_persona = persona.id_persona,
construir_cama_bloque,
cama_bloque,
bloque,
cama,
nave,
tipo_flor,
variedad_flor
where bloque.id_bloque = cama_bloque.id_bloque
and cama.id_cama = cama_bloque.id_cama
and nave.id_nave = cama_bloque.id_nave
and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
and cama_bloque.id_nave = construir_cama_bloque.id_nave
and cama_bloque.id_cama = construir_cama_bloque.id_cama
and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and tipo_flor.id_tipo_flor in (77,78)
and not exists
(
	select * from erradicar_cama_bloque
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque
)
and not exists
(
	select * from destruir_cama_bloque
	where construir_cama_bloque.id_construir_cama_bloque = destruir_cama_bloque.id_construir_cama_bloque
)
group by
bloque.idc_bloque,
nave.numero_nave,
cama.numero_cama,
persona.idc_persona,
ltrim(rtrim(persona.nombre)),
ltrim(rtrim(persona.apellido)),
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
tipo_flor.idc_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
variedad_flor.idc_variedad_flor
order by bloque.idc_bloque,
nave.numero_nave,
cama.numero_cama