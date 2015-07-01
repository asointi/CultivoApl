USE [BD_Nf]
GO
/****** Object:  StoredProcedure [dbo].[wbl_ordenes_fijas_dia_finca]    Script Date: 10/06/2007 12:20:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[wbl_ordenes_fijas_dia_finca]
@id_dia_despacho integer, @id_farm integer
AS
BEGIN

select 
item_reporte_cambio_orden_pedido.id_orden_pedido, 
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
tipo_caja.id_tipo_caja,
datepart(dw,item_reporte_cambio_orden_pedido.fecha_despacho_inicial -3-farm.dias_restados_despacho_distribuidora) as dia_semana,
item_reporte_cambio_orden_pedido.code, 
item_reporte_cambio_orden_pedido.unidades_por_pieza, 
item_reporte_cambio_orden_pedido.cantidad_piezas,
item_reporte_cambio_orden_pedido.comentario,
ciudad.id_ciudad,
ciudad.nombre_ciudad,
Tipo_Despacho.id_tipo_despacho,
Tipo_Despacho.nombre_tipo_despacho,
dia_despacho.id_dia_despacho,
dia_despacho.nombre_dia_despacho,
farm.nombre_farm into #temp
from 
item_reporte_cambio_orden_pedido,
reporte_cambio_orden_pedido,
farm, 
tipo_flor,
variedad_flor, 
grado_flor,
tapa,
tipo_caja,
ciudad,
forma_despacho_ciudad,
tipo_despacho,
dia_despacho
where 
item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
and farm.id_farm = reporte_cambio_orden_pedido.id_farm
and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
and farm.id_ciudad = ciudad.id_ciudad
and forma_despacho_ciudad.id_ciudad = ciudad.id_ciudad
and tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and dia_despacho.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
and datepart(dw,item_reporte_cambio_orden_pedido.fecha_despacho_inicial -3-farm.dias_restados_despacho_distribuidora) = forma_despacho_ciudad.id_dia_despacho
and item_reporte_cambio_orden_pedido.disponible = 1
and farm.id_farm = @id_farm
and item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido in 
(select max(id_item_reporte_cambio_orden_pedido) from item_reporte_cambio_orden_pedido group by id_orden_pedido)

update #temp
set id_dia_despacho = id_dia_despacho+1
where nombre_tipo_despacho = 'Sin Despacho'

update #temp
set id_dia_despacho = replace(id_dia_despacho,8,1)

update #temp
set nombre_tipo_despacho = tipo_despacho.nombre_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho
from tipo_despacho,dia_despacho, forma_despacho_ciudad, #temp
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho

declare @sin_despacho nvarchar(255)
set @sin_despacho = 'Sin Despacho'

while(@sin_despacho in (select nombre_tipo_despacho from #temp))
begin
	update #temp
	set id_dia_despacho = id_dia_despacho-1
	where nombre_tipo_despacho = 'Sin Despacho'

	update #temp
	set id_dia_despacho = replace(id_dia_despacho,0,7)

	update #temp
	set nombre_tipo_despacho = tipo_despacho.nombre_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho
	from tipo_despacho,dia_despacho, forma_despacho_ciudad, #temp
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
end

select tipo_caja.id_tipo_caja, caja.id_caja into #temp2
from producto_farm, caja, tipo_caja
where id_farm = @id_farm
and caja.id_caja=producto_farm.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
group by tipo_caja.id_tipo_caja, caja.id_caja


select #temp2.id_tipo_caja, count(#temp2.id_tipo_caja) as conteo_cajas into #temp3
from #temp2
group by #temp2.id_tipo_caja

alter table #temp
add conteo_cajas integer

update #temp
set conteo_cajas = #temp3.conteo_cajas
from #temp, #temp3
where #temp.id_tipo_caja = #temp3.id_tipo_caja

select
id_tipo_caja,
conteo_cajas,
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
order by id_dia_despacho, nombre_tipo_flor,nombre_variedad_flor,nombre_grado_flor

drop table #temp
drop table #temp2
drop table #temp3

END

