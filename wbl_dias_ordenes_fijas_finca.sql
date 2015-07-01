/****** Object:  StoredProcedure [dbo].[wbl_dias_ordenes_fijas_finca]    Script Date: 12/05/2007 08:33:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_dias_ordenes_fijas_finca]

@id_farm integer, 
@idc_tipo_factura nvarchar(255)

AS

select max(id_item_reporte_cambio_orden_pedido) as id_item_reporte_cambio_orden_pedido into #ordenes_reportadas
from item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido, 
tipo_factura
where reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and id_farm = @id_farm 
and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @idc_tipo_factura
group by id_orden_pedido_padre

select datename(dw, [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)) as nombre_dia_despacho,
datepart(dw, [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)) as id_dia_despacho
from item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido,
farm,
tipo_factura
where (getdate() between
item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final
or getdate() + 6 between
item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final)
and item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and farm.id_farm = reporte_cambio_orden_pedido.id_farm
and item_reporte_cambio_orden_pedido.disponible = 1
and farm.id_farm = @id_farm
and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @idc_tipo_factura
and exists
(
	select *
	from #ordenes_reportadas 
	where item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido = #ordenes_reportadas.id_item_reporte_cambio_orden_pedido 
)
group by datename(dw, [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)),
datepart(dw, [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm))
order by id_dia_despacho

drop table #ordenes_reportadas