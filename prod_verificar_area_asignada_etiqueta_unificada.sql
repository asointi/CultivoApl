set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[prod_verificar_area_asignada_etiqueta_unificada]

@id_etiqueta_impresa int

AS

select isnull(etiqueta.id_area, 0) as area_asignada into #temp
from etiqueta_impresa,
etiqueta
where etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
and etiqueta_impresa.id_etiqueta_impresa = @id_etiqueta_impresa
union all
select 0

select top 1 * from #temp

drop table #temp