set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_consultar_ramo_despatado_devuelto] 

@fecha datetime

as

declare @tallos_despatados_flor_comprada int,
@tallos_devueltos_flor_comprada int,
@tallos_despatados_flor_propia int,
@tallos_devueltos_flor_propia int

select @tallos_despatados_flor_comprada = sum(ramo_despatado.tallos_por_ramo)
from ramo_despatado
where convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura, 101)) = @fecha
and flor_propia = 0

select @tallos_devueltos_flor_comprada = sum(ramo_despatado.tallos_por_ramo)
from ramo_devuelto,
ramo_despatado
where ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado
and convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura, 101)) = @fecha
and flor_propia = 0

select @tallos_despatados_flor_propia = sum(ramo_despatado.tallos_por_ramo)
from ramo_despatado
where convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura, 101)) = @fecha
and flor_propia = 1

select @tallos_devueltos_flor_propia = sum(ramo_despatado.tallos_por_ramo)
from ramo_devuelto,
ramo_despatado
where ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado
and convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura, 101)) = @fecha
and flor_propia = 1

select 'Flor Propia' as 'Procedencia_Flor',
isnull(@tallos_despatados_flor_propia, 0) as tallos_despatados,
isnull(@tallos_devueltos_flor_propia, 0) as tallos_devueltos
union all
select 'Flor Comprada' as 'Procedencia_Flor',
isnull(@tallos_despatados_flor_comprada, 0) as tallos_despatados,
isnull(@tallos_devueltos_flor_comprada, 0) as tallos_devueltos