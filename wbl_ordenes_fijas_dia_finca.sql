/****** Object:  StoredProcedure [dbo].[wbl_ordenes_fijas_dia_finca]    Script Date: 12/05/2007 08:32:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[wbl_ordenes_fijas_dia_finca]

@id_dia_despacho int, 
@id_farm int, 
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

select item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido,
item_reporte_cambio_orden_pedido.id_orden_pedido,
tipo_flor.nombre_tipo_flor,
tipo_flor.idc_tipo_flor,
variedad_flor.nombre_variedad_flor,
variedad_flor.idc_variedad_flor,
grado_flor.nombre_grado_flor,
grado_flor.idc_grado_flor,
tapa.nombre_tapa,
tapa.idc_tapa,
tipo_caja.nombre_tipo_caja,
tipo_caja.idc_tipo_caja,
item_reporte_cambio_orden_pedido.code, 
item_reporte_cambio_orden_pedido.unidades_por_pieza, 
item_reporte_cambio_orden_pedido.cantidad_piezas,
item_reporte_cambio_orden_pedido.comentario,
ciudad.id_ciudad,
datename(dw, [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)) as nombre_dia_despacho,
datepart(dw, [dbo].[calcular_dia_vuelo_orden_fija] (item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)) as id_dia_despacho,
farm.nombre_farm,
farm.id_farm into #temp
from 
item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido,
farm, 
tipo_flor,
variedad_flor, 
grado_flor,
tapa,
tipo_caja,
tipo_factura
where (getdate() between
item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final
or getdate()+6 between
item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final)
and item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and farm.id_farm = reporte_cambio_orden_pedido.id_farm
and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
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

select id_item_reporte_cambio_orden_pedido,
UPPER(nombre_dia_despacho) as dia,
idc_tipo_flor,
nombre_tipo_flor,
idc_variedad_flor,
nombre_variedad_flor,
idc_grado_flor,
nombre_grado_flor,
idc_tapa,
nombre_tapa,
idc_tipo_caja,
nombre_tipo_caja,
code, 
unidades_por_pieza, 
cantidad_piezas
from #temp 
where id_dia_despacho = @id_dia_despacho
order by id_dia_despacho, 
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor

drop table #temp
drop table #ordenes_reportadas