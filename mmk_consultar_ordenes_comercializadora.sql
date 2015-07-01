set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[mmk_consultar_ordenes_comercializadora] 

@fecha_vuelo datetime

as

declare @fecha datetime

set @fecha = @fecha_vuelo

exec bd_fresca.bd_fresca.dbo.mmk_consultar_ordenes_especiales
@fecha_vuelo = @fecha

select tipo_orden,
codigo_tipo_orden,
idc_farm,
nombre_cuenta,
fecha_grabacion,
cantidad_piezas,
fecha_vuelo,
numero_solicitud,
numero_po into #resultado
from bd_fresca.bd_fresca.dbo.pedido_pepr_temp
where bouquet = 1

select numero_solicitud,
sum(cantidad_piezas) as cantidad_piezas into #cancelacion
from cancelacion_pedido_pepr,
distribuidora
where distribuidora.id_distribuidora = cancelacion_pedido_pepr.id_distribuidora
and distribuidora.nombre_distribuidora = 'FRESCA FARMS'
group by numero_solicitud

select tipo_orden,
codigo_tipo_orden,
idc_farm,
nombre_cuenta,
fecha_grabacion,
cantidad_piezas - 
isnull((
	select cantidad_piezas
	from #cancelacion
	where #cancelacion.numero_solicitud = #resultado.numero_solicitud
), 0) as cantidad_piezas,
fecha_vuelo,
numero_solicitud,
numero_po 
from #resultado

drop table #cancelacion
drop table #resultado