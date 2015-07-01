set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_consultar_cantidad_ordenes_fijas_sin_confirmar]

as

select max(id_item_orden_sin_aprobar) as id_item_orden_sin_aprobar into #temp 
from item_orden_sin_aprobar
group by id_item_orden_sin_aprobar_padre

/*visualizar ordenes que asignandoles valor no han sido aprobadas*/
select count(*) as conteo
from orden_sin_aprobar,
item_orden_sin_aprobar,
tipo_factura
where tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and tipo_factura.idc_tipo_factura = '9'
and not exists
(
	select *
	from aprobacion_orden
	where aprobacion_orden.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and exists
(
	select *
	from #temp
	where #temp.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre is not null

drop table #temp