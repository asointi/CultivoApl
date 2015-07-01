set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[ped_consultar_farms_reportadas]

@idc_tipo_factura nvarchar(255),
@id_farm int,
@numero_reporte_farm int,
@id_cuenta_interna int,
@id_temporada_ano int

AS

declare @fecha_transaccion datetime 

select top 1 @fecha_transaccion = fecha_transaccion 
from reporte_cambio_orden_pedido,
tipo_factura,
farm
where reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @idc_tipo_factura
and dbo.Reporte_Cambio_Orden_Pedido.id_farm = farm.id_farm
and farm.id_farm = @id_farm
and reporte_cambio_orden_pedido.numero_reporte_farm = @numero_reporte_farm
order by reporte_cambio_orden_pedido.fecha_transaccion

select reporte_cambio_orden_pedido.fecha_despacho_inicial_consultada,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
reporte_cambio_orden_pedido.numero_reporte_farm,
temporada_año.id_año,
temporada_año.id_temporada into #temp
from Reporte_Cambio_Orden_Pedido left join temporada_año on Reporte_Cambio_Orden_Pedido.id_temporada_año = temporada_año.id_temporada_año,
tipo_factura,
farm
where dbo.Reporte_Cambio_Orden_Pedido.id_tipo_factura = dbo.Tipo_Factura.id_tipo_factura
and dbo.Farm.id_farm = dbo.Reporte_Cambio_Orden_Pedido.id_farm
and dbo.Tipo_Factura.idc_tipo_factura = @idc_tipo_factura
and dbo.Reporte_Cambio_Orden_Pedido.fecha_transaccion > = @fecha_transaccion
and dbo.Reporte_Cambio_Orden_Pedido.id_cuenta_interna = @id_cuenta_interna
group by reporte_cambio_orden_pedido.fecha_despacho_inicial_consultada,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
reporte_cambio_orden_pedido.numero_reporte_farm,
temporada_año.id_año,
temporada_año.id_temporada

alter table #temp 
add fecha_inicial_temporada datetime,
fecha_final_temporada datetime

update #temp
set fecha_inicial_temporada = temporada_cubo.fecha_inicial,
fecha_final_temporada = temporada_cubo.fecha_final
from temporada_cubo
where temporada_cubo.id_año = #temp.id_año
and temporada_cubo.id_temporada = #temp.id_temporada

select * 
from #temp
order by idc_farm,
nombre_farm,
numero_reporte_farm

drop table #temp