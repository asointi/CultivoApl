/****** Object:  StoredProcedure [dbo].[awb_consultar_tablero_guias]    Script Date: 10/06/2007 10:54:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[awb_consultar_tablero_guias]

AS

declare @flying nvarchar(2),
@arriving nvarchar(2),
@warehouse nvarchar(2)

set @flying = '6'
set @arriving = '8'
set @warehouse = 'A'

select g.id_guia,
g.idc_guia,
g.id_ciudad,
g.id_aerolinea,
g.id_estado_guia,
g.id_dia_guia,
g.id_mes_guia,
g.fecha_guia,
g.fecha_cambio_estado,
g.numero_vuelo,
g.fecha_salida,
g.fecha_llegada,
g.fecha_llamada_terminal,
g.fecha_llamada_pq,
g.fecha_paso_pq,
g.nota_pq,
g.vuelos_adelante_para_pq,
g.fecha_transaccion,
g.valor_impuesto,
g.valor_flete,
[dbo].[formato_fecha] (g.fecha_salida, 'puntual') as fecha_salida_formato,
[dbo].[formato_fecha] (g.fecha_llegada, 'puntual') as fecha_llegada_formato,
[dbo].[formato_fecha] (g.fecha_llamada_terminal, 'puntual') as fecha_llamada_terminal_formato,
[dbo].[formato_fecha] (g.fecha_llamada_pq, 'puntual') as fecha_llamada_pq_formato,
[dbo].[formato_fecha] (g.fecha_paso_pq, 'puntual') as fecha_paso_pq_formato,
g.fecha_guia as awb_date,
[dbo].[formato_fecha] (g.fecha_guia, 'general') as awb_date_formato,
RIGHT(g.idc_guia,4) as awb_number,
LEFT(g.idc_guia,3) as idc_airline,
(
	select codigo_aeropuerto 
	from ciudad 
	where id_ciudad = g.id_ciudad
) as idc_ciudad,
a.nombre_aerolinea,
(
	select max(fecha_transaccion)
	from fecha_estado_guia,
	estado_guia
	where g.id_guia = fecha_estado_guia.id_guia
	and fecha_estado_guia.id_estado_guia = estado_guia.id_estado_guia
	and estado_guia.idc_estado_guia = @flying
) as fecha_flying,
[dbo].[formato_fecha] (
	(
		select max(fecha_transaccion)
		from fecha_estado_guia,
		estado_guia
		where g.id_guia = fecha_estado_guia.id_guia
		and fecha_estado_guia.id_estado_guia = estado_guia.id_estado_guia
		and estado_guia.idc_estado_guia = @flying
	), 
	'puntual'
) as fecha_flying_formato,
(
	select max(fecha_transaccion)
	from fecha_estado_guia,
	estado_guia
	where g.id_guia = fecha_estado_guia.id_guia
	and fecha_estado_guia.id_estado_guia = estado_guia.id_estado_guia
	and estado_guia.idc_estado_guia = @arriving
) as fecha_arriving,
[dbo].[formato_fecha] (
	(
		select max(fecha_transaccion)
		from fecha_estado_guia,
		estado_guia
		where g.id_guia = fecha_estado_guia.id_guia
		and fecha_estado_guia.id_estado_guia = estado_guia.id_estado_guia
		and estado_guia.idc_estado_guia = @arriving
	), 
	'puntual'
) as fecha_arriving_formato,
(
	select max(fecha_transaccion)
	from fecha_estado_guia,
	estado_guia
	where g.id_guia = fecha_estado_guia.id_guia
	and fecha_estado_guia.id_estado_guia = estado_guia.id_estado_guia
	and estado_guia.idc_estado_guia = @warehouse
) as fecha_warehouse,
[dbo].[formato_fecha] (
	(
		select max(fecha_transaccion)
		from fecha_estado_guia,
		estado_guia
		where g.id_guia = fecha_estado_guia.id_guia
		and fecha_estado_guia.id_estado_guia = estado_guia.id_estado_guia
		and estado_guia.idc_estado_guia = @warehouse
	), 
	'puntual'
) as fecha_warehouse_formato,
isnull((
	select count(pieza.id_pieza)
	from pieza 
	where pieza.id_guia = g.id_guia
),0) as cantidad_piezas,
isnull((
	select sum(tipo_caja.factor_a_full)
	from pieza,
	caja,
	tipo_caja
 	where pieza.id_guia = g.id_guia
	and pieza.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
),0) as nombre_terminal into #temp
from guia as g, 
aerolinea as a
where id_estado_guia <> 
(
	select id_estado_guia 
	from estado_guia 
	where upper(nombre_estado_guia) = 'CLOSED'
)
and g.id_aerolinea = a.id_aerolinea    		
order by fecha_guia DESC

select * from #temp
where cantidad_piezas > 0

drop table #temp