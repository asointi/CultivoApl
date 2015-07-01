set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_eliminar_pieza_postcosecha]

@fecha_inicial datetime,
@fecha_final datetime

as

select id_pieza_postcosecha into #temp
from pieza_postcosecha
where convert(nvarchar, fecha_entrada, 101) > = @fecha_inicial 
and convert(nvarchar, fecha_entrada, 101) < = @fecha_final
and not exists
(
	select *
	from entrada
	where pieza_postcosecha.id_pieza_postcosecha = entrada.id_pieza_postcosecha
)

delete from salida_pieza
where salida_pieza.id_pieza_postcosecha 
in
(
	select id_pieza_postcosecha 
	from #temp
)

delete from pieza_postcosecha
where pieza_postcosecha.id_pieza_postcosecha
in
(
	select id_pieza_postcosecha 
	from #temp
)

drop table #temp
