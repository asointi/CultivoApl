set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_consultar_fechas_temporada]

@id_temporada_a�o int

as

select temporada_a�o.id_temporada_a�o,
temporada.nombre_temporada,
temporada_cubo.fecha_inicial,
temporada_cubo.fecha_final 
from temporada_cubo, 
temporada, 
a�o, 
temporada_a�o
where temporada_cubo.id_temporada = temporada.id_temporada
and temporada_cubo.id_a�o = a�o.id_a�o
and temporada_a�o.id_a�o = a�o.id_a�o
and temporada_a�o.id_temporada = temporada.id_temporada
and temporada_a�o.id_temporada_a�o = @id_temporada_a�o
