set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv2_consultar_inventario]

@id_temporada_año int

AS

select inventario_preventa.id_inventario_preventa,
farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
item_inventario_preventa.id_item_inventario_preventa,
tapa.id_tapa,
tapa.idc_tapa,
ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
item_inventario_preventa.unidades_por_pieza,
item_inventario_preventa.marca,
item_inventario_preventa.controla_saldos,
item_inventario_preventa.empaque_principal,
item_inventario_preventa.precio_finca into #empaque_principal
from inventario_preventa,
item_inventario_preventa,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
tipo_caja
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and inventario_preventa.id_temporada_año = @id_temporada_año
and farm.id_farm = inventario_preventa.id_farm
and tapa.id_tapa = item_inventario_preventa.id_tapa
and tipo_caja.id_tipo_caja = item_inventario_preventa.id_tipo_caja
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
and item_inventario_preventa.empaque_principal = 1

select inventario_preventa.id_inventario_preventa,
farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
item_inventario_preventa.id_item_inventario_preventa,
tapa.id_tapa,
tapa.idc_tapa,
ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
item_inventario_preventa.unidades_por_pieza,
item_inventario_preventa.marca,
item_inventario_preventa.controla_saldos,
item_inventario_preventa.empaque_principal,
item_inventario_preventa.precio_finca into #empaque_no_principal
from inventario_preventa,
item_inventario_preventa,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
tipo_caja
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and inventario_preventa.id_temporada_año = @id_temporada_año
and farm.id_farm = inventario_preventa.id_farm
and tapa.id_tapa = item_inventario_preventa.id_tapa
and tipo_caja.id_tipo_caja = item_inventario_preventa.id_tipo_caja
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
and item_inventario_preventa.empaque_principal = 0

select * 
from #empaque_principal
order by idc_farm,
nombre_tipo_flor,
nombre_variedad_flor,
nombre_grado_flor

select #empaque_principal.id_item_inventario_preventa as id_empaque_principal,
#empaque_no_principal.id_item_inventario_preventa,
#empaque_no_principal.id_tipo_caja,
#empaque_no_principal.idc_tipo_caja,
#empaque_no_principal.nombre_tipo_caja,
#empaque_no_principal.unidades_por_pieza
from #empaque_principal,
#empaque_no_principal
where #empaque_principal.id_farm = #empaque_no_principal.id_farm
and #empaque_principal.id_tipo_flor = #empaque_no_principal.id_tipo_flor
and #empaque_principal.id_variedad_flor = #empaque_no_principal.id_variedad_flor
and #empaque_principal.id_grado_flor = #empaque_no_principal.id_grado_flor
and #empaque_principal.id_tapa = #empaque_no_principal.id_tapa

select #empaque_principal.id_item_inventario_preventa as id_empaque_principal,
#empaque_principal.id_inventario_preventa,
detalle_item_inventario_preventa.id_detalle_item_inventario_preventa,
Fecha_Inventario.id_fecha_inventario,
Fecha_Inventario.fecha,
detalle_item_inventario_preventa.cantidad_piezas
from #empaque_principal,
detalle_item_inventario_preventa,
Fecha_Inventario
where #empaque_principal.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and fecha_inventario.fecha = detalle_item_inventario_preventa.fecha_disponible_distribuidora
and Fecha_Inventario.id_temporada_año = @id_temporada_año

select id_fecha_inventario,
fecha
from Fecha_Inventario
where id_temporada_año = @id_temporada_año
order by fecha

drop table #empaque_principal
drop table #empaque_no_principal