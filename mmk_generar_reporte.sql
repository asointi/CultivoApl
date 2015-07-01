USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[mmk_generar_reporte]    Script Date: 10/10/2014 4:12:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[mmk_generar_reporte] 

@fecha_inicial datetime,
@fecha_final datetime,
@idc_cliente_despacho nvarchar(255),
@accion nvarchar(25)

as

declare @idc_farm nvarchar(5)

set @idc_farm = 'AM'

select Pedido_PEPR.idc_pedido_pepr,
Pedido_PEPR.fecha_pedido as fecha_vuelo,
Pedido_PEPR.cantidad_piezas,
Pedido_PEPR.cantidad_piezas * tipo_caja.factor_a_full as fulles,
Pedido_PEPR.numero_solicitud into #resultado_finca
from bd_cultivo.bd_cultivo.dbo.Pedido_PEPR,
bd_cultivo.bd_cultivo.dbo.cliente_despacho,
bd_cultivo.bd_cultivo.dbo.caja,
bd_cultivo.bd_cultivo.dbo.tipo_caja,
bd_cultivo.bd_cultivo.dbo.tipo_pedido,
bd_cultivo.bd_cultivo.dbo.catalogo
where Pedido_PEPR.fecha_pedido between
@fecha_inicial and @fecha_final
and cliente_despacho.id_cliente_despacho = Pedido_PEPR.id_cliente_despacho
and Cliente_Despacho.idc_cliente_despacho = @idc_cliente_despacho
and caja.id_caja = Pedido_PEPR.id_caja 
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and tipo_pedido.id_tipo_pedido = Pedido_PEPR.id_tipo_pedido
and tipo_pedido.idc_tipo_pedido not in ('0','1')
and catalogo.id_catalogo = Pedido_PEPR.id_catalogo
and catalogo.nombre_catalogo = 'BOUQUETERA'
and pedido_PEPR.pedido_confirmado = 1

select convert(datetime, convert(nvarchar, solicitud_confirmacion_orden_especial.fecha_grabacion, 103)) as fecha_solicitud,
solicitud_confirmacion_orden_especial.numero_solicitud into #fecha_solicitud
from item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
dbo.farm
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and farm.id_farm = item_orden_sin_aprobar.id_farm
and farm.idc_farm = @idc_farm
and solicitud_confirmacion_orden_especial.aceptada = 1
and exists
(
	select *
	from #resultado_finca
	where #resultado_finca.numero_solicitud = solicitud_confirmacion_orden_especial.numero_solicitud
	and #resultado_finca.numero_solicitud > 0
)
union all
select convert(datetime, convert(nvarchar, solicitud_confirmacion_mass_market.fecha_transaccion, 103)),
solicitud_confirmacion_mass_market.numero_solicitud
from solicitud_confirmacion_mass_market,
farm
where farm.id_farm = solicitud_confirmacion_mass_market.id_farm
and farm.idc_farm = @idc_farm
and exists
(
	select *
	from #resultado_finca
	where #resultado_finca.numero_solicitud = solicitud_confirmacion_mass_market.numero_solicitud
	and #resultado_finca.numero_solicitud > 0
)
union all
select convert(datetime, convert(nvarchar, Solicitud_Confirmacion_Cultivo.fecha_transaccion, 103)),
Solicitud_Confirmacion_Cultivo.numero_solicitud
from Solicitud_Confirmacion_Cultivo,
farm_detalle_po,
farm
where farm.id_farm = Farm_Detalle_PO.id_farm
and Farm_Detalle_PO.id_farm_detalle_po = Solicitud_Confirmacion_Cultivo.id_farm_detalle_po
and farm.idc_farm = @idc_farm
and exists
(
	select *
	from #resultado_finca
	where #resultado_finca.numero_solicitud = Solicitud_Confirmacion_Cultivo.numero_solicitud
	and #resultado_finca.numero_solicitud > 0
)

alter table #resultado_finca
add fecha_solicitud datetime

update #resultado_finca
set fecha_solicitud = #fecha_solicitud.fecha_solicitud
from #fecha_solicitud
where #fecha_solicitud.numero_solicitud = #resultado_finca.numero_solicitud

alter table #resultado_finca
add tipo_orden nvarchar(255)

update #resultado_finca
set tipo_orden = 'Manuales'
where numero_solicitud = 0

update #resultado_finca
set tipo_orden = 'De hoy para hoy'
where datediff(dd, fecha_solicitud, fecha_vuelo) = 0

update #resultado_finca
set tipo_orden = 'De hoy para mañana'
where datediff(dd, fecha_solicitud, fecha_vuelo) = 1

update #resultado_finca
set tipo_orden = 'Normales'
where datediff(dd, fecha_solicitud, fecha_vuelo) > 1

update #resultado_finca
set tipo_orden = 'Error'
where tipo_orden is null

select fecha_vuelo,
tipo_orden,
sum(cantidad_piezas) as cantidad_piezas, 
sum(fulles) as fulles into #resultado
from #resultado_finca
group by fecha_vuelo,
tipo_orden

if(@accion = 'Reporte_pivote')
begin
	select fecha_vuelo,
	[Manuales], [De hoy para hoy],[De hoy para mañana],[Normales]
	from 
	(select fecha_vuelo, tipo_orden, cantidad_piezas
	from #resultado) as sourcetable
	pivot
	(
	sum(cantidad_piezas)
	for tipo_orden in ([Manuales], [De hoy para hoy],[De hoy para mañana],[Normales])
	) as pivottable
end
else
if(@accion = 'Reporte_grafico')
begin
	declare @conteo int

	select @conteo = datediff(dd, @fecha_inicial, @fecha_final)

	create table #fechas (fecha datetime)

	while(@conteo > 0)
	begin
		insert into #fechas	(fecha)
		select dateadd(dd, @conteo, @fecha_inicial)

		set @conteo = @conteo - 1
	end

	insert into #fechas	(fecha)
	values (@fecha_inicial)

	select fecha_vuelo,
	tipo_orden,
	cantidad_piezas, 
	fulles 
	from #resultado
	union all
	select fecha,
	'Manuales',
	0,
	0
	from #fechas
	where not exists
	(
		select *
		from #resultado
		where #fechas.fecha = #resultado.fecha_vuelo
	)

	drop table #fechas
end

drop table #resultado_finca
drop table #fecha_solicitud
drop table #resultado