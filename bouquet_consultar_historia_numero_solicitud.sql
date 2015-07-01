SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[bouquet_consultar_historia_numero_solicitud] 

@numero_solicitud int

as

declare @detalle_PO table
(
	id_detalle_po int
)

insert into @detalle_po (id_detalle_po)
select max(id_detalle_po)
from detalle_po
group by id_detalle_po_padre

select 'Solicitado' as tipo_orden,
cuenta_interna.nombre as nombre_usuario,
solicitud_confirmacion_orden_especial.fecha_grabacion as fecha_transaccion,
dbo.calcular_dia_vuelo_preventa(Item_Orden_Sin_Aprobar.fecha_inicial, farm.idc_farm) as fecha_vuelo,
Item_Orden_Sin_Aprobar.cantidad_piezas,
solicitud_confirmacion_orden_especial.observacion
from Item_Orden_Sin_Aprobar,
farm,
cuenta_interna,
solicitud_confirmacion_orden_especial
where cuenta_interna.id_cuenta_interna = solicitud_confirmacion_orden_especial.id_cuenta_interna
and Item_Orden_Sin_Aprobar.id_item_orden_sin_aprobar = Solicitud_Confirmacion_Orden_Especial.id_item_orden_sin_aprobar
and farm.id_farm = Item_Orden_Sin_Aprobar.id_farm
and farm.idc_farm = 'AM'
and solicitud_confirmacion_orden_especial.aceptada = 1
and solicitud_confirmacion_orden_especial.numero_solicitud = @numero_solicitud
union all
select 'Solicitado',
cuenta_interna.nombre,
solicitud_confirmacion_mass_market.fecha_transaccion,
detalle_solicitud_confirmacion_mass_market.fecha_vuelo,
sum(detalle_solicitud_confirmacion_mass_market.cantidad_piezas),
null
from solicitud_confirmacion_mass_market,
detalle_solicitud_confirmacion_mass_market,
cuenta_interna,
farm
where cuenta_interna.id_cuenta_interna = solicitud_confirmacion_mass_market.id_cuenta_interna
and farm.id_farm = solicitud_confirmacion_mass_market.id_farm
and solicitud_confirmacion_mass_market.numero_solicitud = detalle_solicitud_confirmacion_mass_market.numero_solicitud
and solicitud_confirmacion_mass_market.id_farm = detalle_solicitud_confirmacion_mass_market.id_farm
and farm.idc_farm = 'AM'
and solicitud_confirmacion_mass_market.numero_solicitud = @numero_solicitud
group by cuenta_interna.nombre,
solicitud_confirmacion_mass_market.fecha_transaccion,
detalle_solicitud_confirmacion_mass_market.fecha_vuelo
union all
select 'Digitado',
cuenta_interna.nombre,
solicitud_confirmacion_cultivo.fecha_transaccion,
farm_detalle_po.fecha_vuelo,
farm_detalle_po.cantidad_piezas,
solicitud_confirmacion_cultivo.observacion
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
and cuenta_interna.id_cuenta_interna = solicitud_confirmacion_cultivo.id_cuenta_interna
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and po.id_po = detalle_po.id_po
and exists
(
	select *
	from @detalle_po as dp
	where detalle_po.id_detalle_po = dp.id_detalle_po
)
--and exists
--(
--	select * 
--	from @farm_detalle_po as fdp
--	where farm_detalle_po.id_farm_detalle_po = fdp.id_farm_detalle_po
--)
and not exists
(
	select *
	from Cancela_Detalle_PO
	where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
and po.numero_solicitud = @numero_solicitud