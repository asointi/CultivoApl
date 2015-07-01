set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[mmk_consultar_ordenes_especiales] 

@fecha_vuelo datetime

as

declare @fecha_vuelo_minima datetime

set @fecha_vuelo_minima = dateadd(dd, -15, @fecha_vuelo)

select farm.idc_farm,
cuenta_interna.nombre as nombre_cuenta,
solicitud_confirmacion_orden_especial.fecha_grabacion,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.fecha_inicial,
solicitud_confirmacion_orden_especial.numero_solicitud,
isnull(item_orden_sin_aprobar.numero_po, '') as numero_po into #ordenes
from solicitud_confirmacion_orden_especial,
item_orden_sin_aprobar,
farm,
cuenta_interna
where solicitud_confirmacion_orden_especial.aceptada = 1
and solicitud_confirmacion_orden_especial.numero_solicitud > 0
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and farm.id_farm = item_orden_sin_aprobar.id_farm
and farm.idc_farm = 'AM'
and cuenta_interna.id_cuenta_interna = solicitud_confirmacion_orden_especial.id_cuenta_interna
and item_orden_sin_aprobar.fecha_inicial > = @fecha_vuelo_minima
and not exists
(
	select *
	from confirmacion_orden_especial_cultivo
	where solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
	and confirmacion_orden_especial_cultivo.aceptada = 0
)

select farm.idc_farm,
cuenta_interna.nombre as nombre_cuenta,
solicitud_confirmacion_cultivo.fecha_transaccion,
farm_detalle_po.cantidad_piezas,
farm_detalle_po.fecha_vuelo,
isnull(po.numero_solicitud, 0) as numero_solicitud,
po.po_number as numero_po,
1 as bouquet into #pedidos_bouquet
from solicitud_confirmacion_cultivo,
farm_detalle_po,
farm,
cuenta_interna,
detalle_po,
po
where farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
and farm.id_farm = farm_detalle_po.id_farm
and farm.idc_farm = 'AM'
and solicitud_confirmacion_cultivo.aceptada = 1
--and solicitud_confirmacion_cultivo.numero_solicitud > 0
and cuenta_interna.id_cuenta_interna = solicitud_confirmacion_cultivo.id_cuenta_interna
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and po.id_po = detalle_po.id_po
and farm_detalle_po.fecha_vuelo > = @fecha_vuelo
and not exists
(
	select *
	from confirmacion_bouquet_cultivo
	where solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo
	and confirmacion_bouquet_cultivo.aceptada = 0
)

drop table pedido_pepr_temp

create table pedido_pepr_temp
(
	tipo_orden nvarchar(25),
	codigo_tipo_orden nvarchar(5),
	idc_farm nvarchar(5),
	nombre_cuenta nvarchar(50),
	fecha_grabacion datetime,
	cantidad_piezas int,
	fecha_vuelo datetime,
	numero_solicitud int,
	numero_po nvarchar(50),
	bouquet bit
)

insert into pedido_pepr_temp
(
	tipo_orden,
	codigo_tipo_orden,
	idc_farm,
	nombre_cuenta,
	fecha_grabacion,
	cantidad_piezas,
	fecha_vuelo,
	numero_solicitud,
	numero_po,
	bouquet
)
select 'Orden Especial' as tipo_orden,
'4' as codigo_tipo_orden,
idc_farm,
nombre_cuenta,
fecha_grabacion,
cantidad_piezas,
dbo.calcular_dia_vuelo_preventa(fecha_inicial, idc_farm) as fecha_vuelo,
numero_solicitud,
numero_po,
1 as bouquet
from #ordenes
where DBO.calcular_dia_vuelo_preventa(fecha_inicial, idc_farm) > = @fecha_vuelo
union all
select 'Mass Market' as tipo_orden,
'4' as codigo_tipo_orden,
farm.idc_farm,
cuenta_interna.nombre as nombre_cuenta,
solicitud_confirmacion_mass_market.fecha_transaccion,
detalle_solicitud_confirmacion_mass_market.cantidad_piezas,
detalle_solicitud_confirmacion_mass_market.fecha_vuelo,
solicitud_confirmacion_mass_market.numero_solicitud,
solicitud_confirmacion_mass_market.po_number,
1 as bouquet
from solicitud_confirmacion_mass_market,
detalle_solicitud_confirmacion_mass_market,
cuenta_interna,
farm
where cuenta_interna.id_cuenta_interna = solicitud_confirmacion_mass_market.id_cuenta_interna
and farm.id_farm = solicitud_confirmacion_mass_market.id_farm
and solicitud_confirmacion_mass_market.numero_solicitud = detalle_solicitud_confirmacion_mass_market.numero_solicitud
and solicitud_confirmacion_mass_market.id_farm = detalle_solicitud_confirmacion_mass_market.id_farm
and farm.idc_farm = 'AM'
and detalle_solicitud_confirmacion_mass_market.fecha_vuelo > = @fecha_vuelo
union all
select 'Pedido Bouquet' as tipo_orden,
'4' as codigo_tipo_orden,
idc_farm,
nombre_cuenta,
fecha_transaccion,
cantidad_piezas,
fecha_vuelo,
numero_solicitud,
numero_po,
bouquet
from #pedidos_bouquet

drop table #ordenes
drop table #pedidos_bouquet