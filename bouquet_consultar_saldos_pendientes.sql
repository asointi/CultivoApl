/****** Object:  StoredProcedure [dbo].[wl_editar_wishlist]    Script Date: 10/06/2007 13:08:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bouquet_consultar_saldos_pendientes]

@fecha_vuelo datetime

as

declare @idc_farm nvarchar(2)

set @idc_farm = 'AM'

declare @farm_detalle_po table
(
  id_farm_detalle_po int
)

declare @detalle_po table
(
  id_detalle_po int
)

declare @special_order table
(
  id_farm int,
  cantidad_piezas int,
  fecha_vuelo datetime,
  numero_solicitud int,
  nombre_cuenta nvarchar(50),
  fecha_grabacion datetime
)

declare @digitado table
(
  id_farm int,
  numero_solicitud int,
  cantidad_piezas int
)

declare @saldos_por_descontar table
(
  numero_consecutivo int,
  cantidad_piezas int
)

insert into @farm_detalle_po (id_farm_detalle_po)
select max(id_farm_detalle_po)
from farm_detalle_po
group by id_farm_detalle_po_padre

insert into @detalle_po (id_detalle_po)
select max(id_detalle_po)
from detalle_po
group by id_detalle_po_padre

insert into @special_order (id_farm,cantidad_piezas,fecha_vuelo,numero_solicitud,nombre_cuenta,fecha_grabacion)
select farm.id_farm,
Item_Orden_Sin_Aprobar.cantidad_piezas,
dbo.calcular_dia_vuelo_preventa(Item_Orden_Sin_Aprobar.fecha_inicial, farm.idc_farm) as fecha_vuelo,
solicitud_confirmacion_orden_especial.numero_solicitud,
cuenta_interna.nombre as nombre_cuenta,
solicitud_confirmacion_orden_especial.fecha_grabacion
from Item_Orden_Sin_Aprobar,
farm,
cuenta_interna,
solicitud_confirmacion_orden_especial
where cuenta_interna.id_cuenta_interna = solicitud_confirmacion_orden_especial.id_cuenta_interna
and Item_Orden_Sin_Aprobar.id_item_orden_sin_aprobar = Solicitud_Confirmacion_Orden_Especial.id_item_orden_sin_aprobar
and farm.id_farm = Item_Orden_Sin_Aprobar.id_farm
and farm.idc_farm = @idc_farm
and Item_Orden_Sin_Aprobar.fecha_inicial > = @fecha_vuelo
and solicitud_confirmacion_orden_especial.aceptada = 1

select id_farm,
sum(cantidad_piezas) as cantidad_piezas,
sum(cantidad_piezas) as cantidad_piezas_saldo,
numero_solicitud,
convert(nvarchar,numero_solicitud) as po_number,
nombre_cuenta,
fecha_grabacion,
fecha_vuelo into #ordenes_originales
from @special_order
where fecha_vuelo > = @fecha_vuelo
group by id_farm,
numero_solicitud,
nombre_cuenta,
fecha_grabacion,
fecha_vuelo
union all
select farm.id_farm,
sum(detalle_solicitud_confirmacion_mass_market.cantidad_piezas),
sum(detalle_solicitud_confirmacion_mass_market.cantidad_piezas),
solicitud_confirmacion_mass_market.numero_solicitud,
solicitud_confirmacion_mass_market.po_number,
cuenta_interna.nombre,
solicitud_confirmacion_mass_market.fecha_transaccion,
detalle_solicitud_confirmacion_mass_market.fecha_vuelo
from solicitud_confirmacion_mass_market,
detalle_solicitud_confirmacion_mass_market,
cuenta_interna,
farm
where cuenta_interna.id_cuenta_interna = solicitud_confirmacion_mass_market.id_cuenta_interna
and farm.id_farm = solicitud_confirmacion_mass_market.id_farm
and solicitud_confirmacion_mass_market.numero_solicitud = detalle_solicitud_confirmacion_mass_market.numero_solicitud
and solicitud_confirmacion_mass_market.id_farm = detalle_solicitud_confirmacion_mass_market.id_farm
and farm.idc_farm = @idc_farm
and detalle_solicitud_confirmacion_mass_market.fecha_vuelo > = @fecha_vuelo
group by farm.id_farm,
solicitud_confirmacion_mass_market.numero_solicitud,
solicitud_confirmacion_mass_market.po_number,
cuenta_interna.nombre,
solicitud_confirmacion_mass_market.fecha_transaccion,
detalle_solicitud_confirmacion_mass_market.fecha_vuelo

insert into @digitado (id_farm,numero_solicitud,cantidad_piezas)
select farm.id_farm,
po.numero_solicitud,
sum(farm_detalle_po.cantidad_piezas)
from po,
detalle_po,
farm,
farm_detalle_po,
solicitud_confirmacion_cultivo
where po.id_po = detalle_po.id_po
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
and farm.id_farm = farm_detalle_po.id_farm
and farm.idc_farm = @idc_farm
and exists
(
	select *
	from @detalle_po as dp
	where detalle_po.id_detalle_po = dp.id_detalle_po
)
and exists
(
	select * 
	from @farm_detalle_po as fdp
	where farm_detalle_po.id_farm_detalle_po = fdp.id_farm_detalle_po
)
and not exists
(
	select *
	from Cancela_Detalle_PO
	where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
and exists
(
	select * 
	from #ordenes_originales
	where #ordenes_originales.numero_solicitud = po.numero_solicitud
)
group by farm.id_farm,
po.numero_solicitud

update #ordenes_originales
set cantidad_piezas_saldo = cantidad_piezas_saldo - isnull(d.cantidad_piezas, 0)
from @digitado as d
where d.id_farm = #ordenes_originales.id_farm
and #ordenes_originales.numero_solicitud = d.numero_solicitud

insert into @saldos_por_descontar (numero_consecutivo,cantidad_piezas)
select numero_consecutivo,
sum(cantidad_piezas)
from bd_cultivo.bd_cultivo.dbo.Descontar_Piezas_Numero_Consecutivo
group by numero_consecutivo

update #ordenes_originales
set cantidad_piezas_saldo = cantidad_piezas_saldo - isnull(sd.cantidad_piezas ,0)
from @saldos_por_descontar as sd
where sd.numero_consecutivo = #ordenes_originales.numero_solicitud

select numero_solicitud,
cantidad_piezas,
cantidad_piezas_saldo as saldo,
po_number,
nombre_cuenta as usuario_envia,
convert(datetime, convert(nvarchar, fecha_grabacion, 103)) as fecha_envio_solicitud,
convert(nvarchar, convert(time, fecha_grabacion)) as hora_envio_solicitud,
fecha_vuelo
from #ordenes_originales
where cantidad_piezas_saldo <> 0
and numero_solicitud > 0
order by fecha_grabacion

drop table #ordenes_originales