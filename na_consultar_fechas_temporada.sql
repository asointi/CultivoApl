set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_consultar_fechas_temporada]

@id_temporada_año int

as

select temporada_año.id_temporada_año,
temporada.nombre_temporada,
temporada_cubo.fecha_inicial,
temporada_cubo.fecha_final 
from temporada_cubo, 
temporada, 
año, 
temporada_año
where temporada_cubo.id_temporada = temporada.id_temporada
and temporada_cubo.id_año = año.id_año
and temporada_año.id_año = año.id_año
and temporada_año.id_temporada = temporada.id_temporada
and temporada_año.id_temporada_año = @id_temporada_año
