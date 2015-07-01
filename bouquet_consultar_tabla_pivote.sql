SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bouquet_consultar_tabla_pivote] 

as

declare @detalle_po table
(
	id_detalle_po int
)

declare @farm_detalle_po table
(
	id_farm_detalle_po int
)

insert into @detalle_po (id_detalle_po)
select max(id_detalle_po)
from detalle_po
group by id_detalle_po_padre

select transportador.idc_transportador as carrier_code,
ltrim(rtrim(Transportador.nombre_transportador)) as carrier_name,
cliente_despacho.idc_cliente_despacho as customer_code,
po.po_number,
po.fecha_despacho_miami as miami_ship_date,
po.numero_solicitud as num_sol,
tapa.idc_tapa as lid_code,
tapa.nombre_tapa as lid_name,
detalle_po.cantidad_piezas as ?_pieces,
detalle_po.marca as code,
detalle_po.ethyblock_sachet,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as box_name,
tipo_caja.factor_a_full as ?_fulls,
tipo_flor.idc_tipo_flor as flower_code,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as flower_name,
variedad_flor.idc_variedad_flor as variety_code,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as variety_name,
grado_flor.idc_grado_flor as grade_code,
ltrim(rtrim(Grado_Flor.nombre_grado_flor)) as grade_name,
farm.idc_farm as farm_code,
ltrim(rtrim(farm.nombre_farm)) as farm_name,
case
	when solicitud_confirmacion_cultivo.aceptada = 1 then Farm_Detalle_PO.cantidad_piezas
	when solicitud_confirmacion_cultivo.aceptada = 0 then Farm_Detalle_PO.cantidad_piezas *-1
end as ?_requested_pieces,
Farm_Detalle_PO.fecha_vuelo as flight_date,
solicitud_confirmacion_cultivo.fecha_transaccion as request_date,
case	
	when solicitud_confirmacion_cultivo.farm_price is null then solicitud_confirmacion_cultivo.farm_price_maximo
	else solicitud_confirmacion_cultivo.farm_price
end as ?_farm_price,
solicitud_confirmacion_cultivo.observacion as shipped_observation,
case
	when confirmacion_bouquet_cultivo.aceptada = 1 then confirmacion_bouquet_cultivo.cantidad_piezas
	when confirmacion_bouquet_cultivo.aceptada = 0 then confirmacion_bouquet_cultivo.cantidad_piezas * -1
end as ?_confirmed_pieces,
confirmacion_bouquet_cultivo.observacion as confirmation_observation,
confirmacion_bouquet_cultivo.idc_pedido_pepr as pepr
from po left join Detalle_PO on 
(
po.id_po = detalle_po.id_po
and exists
(
	select *
	from @detalle_po as dp
	where detalle_po.id_detalle_po = dp.id_detalle_po
)
and not exists
(
	select *
	from cancela_detalle_po
	where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
)
left join version_bouquet on version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
left join bouquet on bouquet.id_bouquet = Version_Bouquet.id_bouquet
left join variedad_flor on variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
left join grado_flor on grado_flor.id_grado_flor = bouquet.id_grado_flor
left join tapa on tapa.id_tapa = detalle_po.id_tapa
left join caja on caja.id_caja = version_bouquet.id_caja
left join tipo_caja on tipo_caja.id_tipo_caja = caja.id_tipo_caja
left join tipo_flor on (tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor)
left join farm_detalle_po on 
(
detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and exists
(
	select * 
	from @farm_detalle_po as fdp
	where farm_detalle_po.id_farm_detalle_po = fdp.id_farm_detalle_po
)
)
left join farm on farm.id_farm = farm_detalle_po.id_farm
left join solicitud_confirmacion_cultivo on farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
left join confirmacion_bouquet_cultivo on solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = confirmacion_bouquet_cultivo.id_solicitud_confirmacion_cultivo,
cliente_despacho,
Transportador
where cliente_despacho.id_despacho = po.id_despacho
and transportador.id_transportador = po.id_transportador