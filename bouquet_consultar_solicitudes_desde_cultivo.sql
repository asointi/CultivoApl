USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[bouquet_consultar_solicitudes_desde_cultivo]    Script Date: 12/9/2014 8:55:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2014/08/20
-- Description:	Trae informacion de solicitudes de Bouquets desde las comercializadoras
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_consultar_solicitudes_desde_cultivo] 

@idc_farm_aux nvarchar(2)

as

set @idc_farm_aux = 'AM'

select max(id_detalle_po) as id_detalle_po into #detalle_po
from detalle_po
group by id_detalle_po_padre

select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
from farm_detalle_po
group by id_farm_detalle_po_padre

select id_solicitud_confirmacion_cultivo,
sum(cantidad_piezas) as cantidad_piezas into #confirmacion_bouquet
from bd_cultivo.bd_cultivo.dbo.confirmacion_bouquet
where transmitida = 0
group by id_solicitud_confirmacion_cultivo
union all
select Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo,
sum(Confirmacion_Bouquet_Cultivo.cantidad_piezas) as cantidad_piezas
from Confirmacion_Bouquet_Cultivo
group by Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo

select solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
isnull(caja.idc_caja_cultivo, '') as idc_caja,
isnull((
	select sum(detalle_version_bouquet.unidades)
	from detalle_version_bouquet
	where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
), 0) as unidades,
case
	when solicitud_confirmacion_cultivo.farm_price is null then solicitud_confirmacion_cultivo.farm_price_maximo
	else solicitud_confirmacion_cultivo.farm_price
end as farm_price,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente_despacho,
po.po_number,
case
	when datediff(dd, solicitud_confirmacion_cultivo.fecha_transaccion, farm_detalle_po.fecha_vuelo) < 2 then dateadd(yyyy, 100, farm_detalle_po.fecha_vuelo)
	else farm_detalle_po.fecha_vuelo
end as fecha_vuelo,	
detalle_po.cantidad_piezas,
detalle_po.cantidad_piezas -
isnull((
	select sum(cantidad_piezas)
	from #confirmacion_bouquet
	where solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = #confirmacion_bouquet.id_solicitud_confirmacion_cultivo
), 0) as saldo,
detalle_po.marca,
detalle_po.ethyblock_sachet,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
po.numero_solicitud,
convert(datetime, convert(nvarchar, solicitud_confirmacion_cultivo.fecha_transaccion, 103)) as fecha_envio_solicitud,
convert(nvarchar, convert(time, solicitud_confirmacion_cultivo.fecha_transaccion)) as hora_envio_solicitud,
cuenta_interna.cuenta as cuenta_envio_solicitud,
cuenta_interna.nombre as nombre_cuenta_envio_solicitud,
tapa.idc_tapa_cultivo as idc_tapa,
isnull((
	select sum(detalle_version_bouquet.precio_miami)
	from detalle_version_bouquet
	where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
), 0) as precio_miami_pieza,
detalle_po.fecha_transaccion as fecha_creacion,
case
	when bouquet.imagen is null then 0
	else 1
end as imagen
from bouquet,
tipo_flor,
variedad_flor,
grado_flor,
version_bouquet,
caja,
tipo_caja,
detalle_po,
po,
cliente_despacho,
tapa,
farm_detalle_po,
farm,
solicitud_confirmacion_cultivo,
cuenta_interna
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
and grado_flor.id_grado_flor = bouquet.id_grado_flor
and bouquet.id_bouquet = version_bouquet.id_bouquet
and caja.id_caja = version_bouquet.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and po.id_po = detalle_po.id_po
and cliente_despacho.id_despacho = po.id_despacho
and tapa.id_tapa = detalle_po.id_tapa
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and farm.id_farm = farm_detalle_po.id_farm
and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
and solicitud_confirmacion_cultivo.aceptada = 1
and cuenta_interna.id_cuenta_interna = solicitud_confirmacion_cultivo.id_cuenta_interna
and exists
(
	select *
	from #detalle_po
	where #detalle_po.id_detalle_po = detalle_po.id_detalle_po
)
and exists
(
	select *
	from #farm_detalle_po
	where #farm_detalle_po.id_farm_detalle_po = farm_detalle_po.id_farm_detalle_po
)
and not exists
(
	select *
	from #confirmacion_bouquet
	where solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo = #confirmacion_bouquet.id_solicitud_confirmacion_cultivo
	and detalle_po.cantidad_piezas = #confirmacion_bouquet.cantidad_piezas
)
and not exists
(
	select *
	from cancela_detalle_po
	where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
)
and farm.idc_farm = @idc_farm_aux
order by solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo

drop table #detalle_po
drop table #farm_detalle_po
drop table #confirmacion_bouquet