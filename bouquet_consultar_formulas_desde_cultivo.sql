SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2014/08/20
-- Description:	Trae informacion de recetas de solicitudes de Bouquets desde las comercializadoras
-- =============================================

create PROCEDURE [dbo].[bouquet_consultar_formulas_desde_cultivo] 

@id_solicitud_confirmacion_cultivo_aux int,
@idc_farm_aux nvarchar(2)

as

select max(id_detalle_po) as id_detalle_po into #detalle_po
from detalle_po
group by id_detalle_po_padre

select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
from farm_detalle_po
group by id_farm_detalle_po_padre

select id_solicitud_confirmacion_cultivo,
sum(cantidad_piezas) as cantidad_piezas into #confirmacion_bouquet
from bd_cultivo.bd_cultivo.dbo.confirmacion_bouquet
group by id_solicitud_confirmacion_cultivo
union all
select Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo,
sum(Confirmacion_Bouquet_Cultivo.cantidad_piezas) as cantidad_piezas
from Confirmacion_Bouquet_Cultivo
group by Confirmacion_Bouquet_Cultivo.id_solicitud_confirmacion_cultivo

select id_grado_flor,
id_variedad_flor,
max(costo_unitario) as valor,
count(id_cotizacion_bouquet) as cantidad_cotizaciones into #cotizacion
from bd_cultivo.bd_cultivo.dbo.cotizacion_bouquet
where convert(datetime, convert(nvarchar, getdate(), 103)) between
fecha_inicial and fecha_final
group by id_grado_flor,
id_variedad_flor

select solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo,
detalle_version_bouquet.unidades,
formula_bouquet.id_formula_bouquet,
formula_bouquet.nombre_formula_bouquet,
formula_bouquet.especificacion_bouquet,
formula_bouquet.construccion_bouquet,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tipo_flor_cultivo.idc_tipo_flor,
ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor_cultivo.idc_variedad_flor,
ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor_cultivo.idc_grado_flor,
ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_grado_flor,
(
	select observacion_detalle_formula_bouquet.observacion
	from observacion_detalle_formula_bouquet
	where detalle_formula_bouquet.id_detalle_formula_bouquet = observacion_detalle_formula_bouquet.id_detalle_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = observacion_detalle_formula_bouquet.id_detalle_version_bouquet
) as observacion,
detalle_formula_bouquet.cantidad_tallos,
isnull((
	select valor
	from #cotizacion
	where #cotizacion.id_grado_flor = grado_flor_cultivo.id_grado_flor_cultivo
	and #cotizacion.id_variedad_flor = variedad_flor_cultivo.id_variedad_flor_cultivo
), 0) as valor_cotizacion,
isnull((
	select cantidad_cotizaciones
	from #cotizacion
	where #cotizacion.id_grado_flor = grado_flor_cultivo.id_grado_flor_cultivo
	and #cotizacion.id_variedad_flor = variedad_flor_cultivo.id_variedad_flor_cultivo
), 0) as cantidad_cotizaciones,
isnull((
	select variedad_restringida_cliente.id_variedad_restringida_cliente 
	from variedad_restringida_cliente
	where cliente_despacho.id_despacho = variedad_restringida_cliente.id_despacho
	and variedad_flor_cultivo.id_variedad_flor_cultivo = variedad_restringida_cliente.id_variedad_flor_cultivo
	and variedad_restringida_cliente.fecha_transaccion < = solicitud_confirmacion_cultivo.fecha_transaccion
	and not exists
	(
		select *
		from cancela_variedad_restringida_cliente
		where variedad_restringida_cliente.id_variedad_restringida_cliente = cancela_variedad_restringida_cliente.id_variedad_restringida_cliente
		and cancela_variedad_restringida_cliente.fecha_transaccion < = solicitud_confirmacion_cultivo.fecha_transaccion
	)
), 0) as restriccion_por_cliente,
isnull((
	select variedad_restringida_cliente.observacion 
	from variedad_restringida_cliente
	where cliente_despacho.id_despacho = variedad_restringida_cliente.id_despacho
	and variedad_flor_cultivo.id_variedad_flor_cultivo = variedad_restringida_cliente.id_variedad_flor_cultivo
	and variedad_restringida_cliente.fecha_transaccion < = solicitud_confirmacion_cultivo.fecha_transaccion
	and not exists
	(
		select *
		from cancela_variedad_restringida_cliente
		where variedad_restringida_cliente.id_variedad_restringida_cliente = cancela_variedad_restringida_cliente.id_variedad_restringida_cliente
		and cancela_variedad_restringida_cliente.fecha_transaccion < = solicitud_confirmacion_cultivo.fecha_transaccion
	)
), '') as observacion_restriccion_por_cliente,
(
	select t.idc_tipo_flor
	from sustitucion_detalle_formula_bouquet,
	tipo_flor_cultivo as t,
	variedad_flor_cultivo as v,
	grado_flor_cultivo as g
	where detalle_formula_bouquet.id_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
	and t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
	and t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
	and v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
	and g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
) as idc_tipo_flor_sustitucion,
(
	select ltrim(rtrim(t.nombre_tipo_flor))
	from sustitucion_detalle_formula_bouquet,
	tipo_flor_cultivo as t,
	variedad_flor_cultivo as v,
	grado_flor_cultivo as g
	where detalle_formula_bouquet.id_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
	and t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
	and t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
	and v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
	and g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
) as nombre_tipo_flor_sustitucion,
(
	select v.idc_variedad_flor
	from sustitucion_detalle_formula_bouquet,
	variedad_flor_cultivo as v
	where detalle_formula_bouquet.id_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
	and v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
) as idc_variedad_flor_sustitucion,
(
	select ltrim(rtrim(v.nombre_variedad_flor))
	from sustitucion_detalle_formula_bouquet,
	variedad_flor_cultivo as v
	where detalle_formula_bouquet.id_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
	and v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
) as nombre_variedad_flor_sustitucion,
(
	select g.idc_grado_flor
	from sustitucion_detalle_formula_bouquet,
	grado_flor_cultivo as g
	where detalle_formula_bouquet.id_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
	and g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
) as idc_grado_flor_sustitucion,
(
	select ltrim(rtrim(g.nombre_grado_flor))
	from sustitucion_detalle_formula_bouquet,
	grado_flor_cultivo as g
	where detalle_formula_bouquet.id_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
	and g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
) as nombre_grado_flor_sustitucion
from version_bouquet,
detalle_po,
po,
farm_detalle_po,
solicitud_confirmacion_cultivo,
detalle_version_bouquet,
formula_bouquet,
detalle_formula_bouquet,
formula_unica_bouquet,
tipo_flor_cultivo,
variedad_flor_cultivo,
grado_flor_cultivo,
farm,
cliente_despacho
where po.id_po = detalle_po.id_po
and cliente_despacho.id_despacho = po.id_despacho
and farm.id_farm = farm_detalle_po.id_farm
and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po
and solicitud_confirmacion_cultivo.aceptada = 1
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
and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo > = 
case
	when @id_solicitud_confirmacion_cultivo_aux = 0 then 1
	else @id_solicitud_confirmacion_cultivo_aux
end
and solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo < = 
case
	when @id_solicitud_confirmacion_cultivo_aux = 0 then 99999999
	else @id_solicitud_confirmacion_cultivo_aux
end
and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet 
and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
and farm.idc_farm > = 
case
	when @idc_farm_aux = '' then '  '
	else @idc_farm_aux
end
and farm.idc_farm < = 
case
	when @idc_farm_aux = '' then 'ZZ'
	else @idc_farm_aux
end
order by solicitud_confirmacion_cultivo.id_solicitud_confirmacion_cultivo

drop table #cotizacion
drop table #detalle_po
drop table #farm_detalle_po
drop table #confirmacion_bouquet