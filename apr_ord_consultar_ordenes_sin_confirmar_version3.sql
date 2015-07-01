set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[apr_ord_consultar_ordenes_sin_confirmar_version3]

@id_vendedor int,
@id_farm int,
@idc_tipo_factura nvarchar(1)

as

create table #numero_solicitud
(
	id_item_orden_sin_aprobar_padre int,
	numero_solicitud int null,
	tipo_orden int,
	usuario_cobol nvarchar(50) null
)

select max(id_item_orden_sin_aprobar) as id_item_orden_sin_aprobar into #ordenes
from item_orden_sin_aprobar
group by id_item_orden_sin_aprobar_padre

if(@idc_tipo_factura = '9')
begin
	insert into #numero_solicitud(id_item_orden_sin_aprobar_padre, numero_solicitud, tipo_orden)
	select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
	max(solicitud_confirmacion_orden.numero_solicitud),
	1
	from item_orden_sin_aprobar,
	aprobacion_orden,
	orden_sin_aprobar,
	solicitud_confirmacion_orden,
	tipo_factura
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
	and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
	and solicitud_confirmacion_orden.aceptada = 1
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre

	insert into #numero_solicitud(id_item_orden_sin_aprobar_padre, numero_solicitud, tipo_orden, usuario_cobol)
	select item_orden_sin_aprobar.id_item_orden_sin_aprobar, 
	null, 
	2,
	aprobacion_orden.usuario_cobol
	from item_orden_sin_aprobar,
	aprobacion_orden,
	orden_sin_aprobar,
	tipo_factura
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
	and aprobacion_orden.aceptada = 1
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and not exists
	(
		select *
		from solicitud_confirmacion_orden
		where aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
	) 
end
else
if(@idc_tipo_factura = '4')
begin
	insert into #numero_solicitud(id_item_orden_sin_aprobar_padre, numero_solicitud, tipo_orden)
	select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
	max(solicitud_confirmacion_orden_especial.numero_solicitud),
	1
	from item_orden_sin_aprobar,
	solicitud_confirmacion_orden_especial,
	orden_sin_aprobar,
	tipo_factura
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
	and solicitud_confirmacion_orden_especial.aceptada = 1
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre

	insert into #numero_solicitud(id_item_orden_sin_aprobar_padre, numero_solicitud, tipo_orden, usuario_cobol)
	select item_orden_sin_aprobar.id_item_orden_sin_aprobar, 
	null, 
	2,
	item_orden_sin_aprobar.usuario_cobol
	from item_orden_sin_aprobar,
	orden_sin_aprobar,
	tipo_factura
	where orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and not exists
	(
		select *
		from solicitud_confirmacion_orden_especial
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
	) 
end

/*visualizar ordenes que teniendo valor y siendo aprobadas no han sido enviadas a la finca*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar,
(
	select usuario_cobol
	from #numero_solicitud	
	where #numero_solicitud.id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	and #numero_solicitud.tipo_orden = 2
) as usuario_cobol,
(
	select numero_solicitud
	from #numero_solicitud	
	where #numero_solicitud.id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre	 
	and #numero_solicitud.tipo_orden = 1
) as numero_solicitud_anterior,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.observacion as observacion_procurement,
vendedor.id_vendedor,
vendedor.idc_vendedor,
'[' + vendedor.idc_vendedor + ']' + space(1) + ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
'[' + cliente_despacho.idc_cliente_despacho + ']' + space(1) + ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
tipo_factura.idc_tipo_factura,
case
	when tipo_factura.idc_tipo_factura = '9' then 'Orden Fija'
	when tipo_factura.idc_tipo_factura = '4' then 'Orden Especial'
end as nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
ltrim(rtrim(ciudad.nombre_ciudad)) as nombre_ciudad,
farm.id_farm,
farm.idc_farm,
'[' + farm.idc_farm + ']' + ' ' + ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
farm.correo as correo_aprobacion,
case
	when len(farm.correo) > 7 then 1
	else 0
end as contiene_mail,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.nombre_tipo_caja,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
item_orden_sin_aprobar.valor_pactado_cobol,
item_orden_sin_aprobar.formula_ramo_bouquet into #temp
from cliente_factura,
cliente_despacho,
orden_sin_aprobar,
vendedor,
item_orden_sin_aprobar,
transportador,
variedad_flor,
tipo_flor,
grado_flor,
farm,
tipo_farm,
ciudad,
tapa,
tipo_caja,
caja,
tipo_factura
where tipo_factura.idc_tipo_factura = @idc_tipo_factura
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_transportador = transportador.id_transportador
and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and item_orden_sin_aprobar.id_farm = farm.id_farm
and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
and item_orden_sin_aprobar.id_caja = caja.id_caja
and farm.id_ciudad = ciudad.id_ciudad
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and exists
(
	select *
	from #ordenes
	where #ordenes.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and exists
(
	select *
	from #numero_solicitud
	where #numero_solicitud.id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	and #numero_solicitud.tipo_orden = 2
)
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.observacion,
vendedor.id_vendedor,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
tipo_factura.idc_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
ltrim(rtrim(grado_flor.nombre_grado_flor)),
ltrim(rtrim(ciudad.nombre_ciudad)),
farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
farm.correo,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.nombre_tipo_caja,
tipo_caja.idc_tipo_caja,
caja.idc_caja,
ltrim(rtrim(caja.nombre_caja)),
item_orden_sin_aprobar.valor_pactado_cobol,
item_orden_sin_aprobar.formula_ramo_bouquet

select id_farm,
nombre_farm,
idc_farm
from #temp
group by id_farm,
nombre_farm,
idc_farm
order by idc_farm 

select id_vendedor,
nombre_vendedor
from #temp
group by id_vendedor,
nombre_vendedor

select *,
case
	when numero_solicitud_anterior is null then 'Nueva'
	else 'Modificada. Anula y reemplaza la número ' +  convert(nvarchar, numero_solicitud_anterior)
end as tipo_orden
from #temp
where id_vendedor > =
case
	when @id_vendedor = 0 THEN 1
	else @id_vendedor
end
and id_vendedor < =
case
	when @id_vendedor = 0 THEN 99999
	else @id_vendedor
end
and id_farm > =
case
	when @id_farm = 0 THEN 1
	else @id_farm
end
and id_farm < =
case
	when @id_farm = 0 THEN 99999
	else @id_farm
end
order by id_item_orden_sin_aprobar

drop table #temp
drop table #ordenes
drop table #numero_solicitud