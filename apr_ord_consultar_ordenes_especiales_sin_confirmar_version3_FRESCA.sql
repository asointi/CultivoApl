set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[apr_ord_consultar_ordenes_especiales_sin_confirmar_version3]

@id_vendedor int,
@id_farm int,
@id_despacho int,
@accion  nvarchar(255)

as

/*visualizar ordenes que teniendo valor y siendo aprobadas no han sido enviadas a la finca*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
vendedor.id_vendedor,
vendedor.idc_vendedor,
vendedor.nombre as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
convert(nvarchar,tipo_factura.idc_tipo_factura) as idc_tipo_factura,
case 
	when tipo_factura.idc_tipo_factura = '4' then 'Orden Especial'
	else tipo_factura.nombre_tipo_factura
end as nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
ciudad.id_ciudad,
ltrim(rtrim(ciudad.nombre_ciudad)) as nombre_ciudad,
farm.id_farm,
farm.idc_farm,
'[' + farm.idc_farm + ']' + ' ' + ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
convert(nvarchar, dbo.calcular_dia_vuelo_preventa(item_orden_sin_aprobar.fecha_inicial, farm.idc_farm), 103) as nombre_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.fecha_grabacion as fecha_aprobacion,
convert(nvarchar, item_orden_sin_aprobar.fecha_grabacion, 108) as hora_transaccion,
item_orden_sin_aprobar.usuario_cobol,
'Not Sent to Farm' as estado,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol 
end as precio_finca,
item_orden_sin_aprobar.valor_pactado_cobol,
0 as contiene_mail,
isnull((
	select top 1 orden_pedido.idc_orden_pedido
	from orden_pedido,
	orden_especial_confirmada,
	confirmacion_orden_especial_cultivo,
	solicitud_confirmacion_orden_especial
	where orden_pedido.id_orden_pedido = orden_especial_confirmada.id_orden_pedido
	and orden_especial_confirmada.id_confirmacion_orden_especial_cultivo = confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo
	and confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial = solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial
	and solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre
	order by orden_especial_confirmada.id_orden_especial_confirmada desc
),0) as idc_orden_pedido,
farm.correo as correo_aprobacion,
case
	when item_orden_sin_aprobar.valor_unitario > = item_orden_sin_aprobar.precio_mercado then 1
	when item_orden_sin_aprobar.valor_unitario < item_orden_sin_aprobar.precio_mercado then 0
end as comparacion_precios,
item_orden_sin_aprobar.observacion as observacion_procurement,
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
ciudad,
tapa,
tipo_caja,
caja,
item_orden_sin_aprobar as iosa,
tipo_factura
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and farm.id_ciudad = ciudad.id_ciudad
and not exists
(
	select *
	from solicitud_confirmacion_orden_especial
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
)
and tipo_factura.idc_tipo_factura = '4'
group by
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
vendedor.id_vendedor,
vendedor.nombre,
cliente_factura.id_cliente_factura,
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
convert(nvarchar,tipo_factura.idc_tipo_factura),
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
ciudad.id_ciudad,
ltrim(rtrim(ciudad.nombre_ciudad)),
farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
caja.idc_caja,
ltrim(rtrim(caja.nombre_caja)),
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.fecha_grabacion,
convert(nvarchar, item_orden_sin_aprobar.fecha_grabacion, 108),
item_orden_sin_aprobar.usuario_cobol,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
item_orden_sin_aprobar.valor_pactado_cobol,
farm.correo,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.observacion,
item_orden_sin_aprobar.valor_pactado_interno,
item_orden_sin_aprobar.formula_ramo_bouquet 
having
item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)

alter table #temp
add tipo_orden nvarchar(255)

update #temp
set contiene_mail = 1
from farm
where #temp.id_farm = farm.id_farm
and farm.correo is not null
and len(farm.correo) > 7

select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
count(*) as cantidad into #modificadas
from item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and exists
(
	select *
	from #temp
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = #temp.id_item_orden_sin_aprobar_padre
	and item_orden_sin_aprobar.id_farm = #temp.id_farm
)
and solicitud_confirmacion_orden_especial.aceptada = 1
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre

update #temp
set tipo_orden = 'Modificada'
from #modificadas
where #modificadas.id_item_orden_sin_aprobar_padre = #temp.id_item_orden_sin_aprobar_padre

update #temp
set tipo_orden = 'Nueva'
where tipo_orden is null

if(@accion = 'consultar_ordenes_pendientes')
begin
	alter table #temp
	add Miami_FOB_Price decimal(20,4),
	Box_charges decimal(20,4), 
	Charges_per_unit decimal(20,4), 
	Subtotal_3 decimal(20,4),
	Valor_comision decimal(20,4),
	Comission decimal(20,4),
	Subtotal_5 decimal(20,4), 
	Freight_per_full_box decimal(20,4),
	Freight_per_specific_box decimal(20,4),
	Freight_per_unit decimal(20,4),
	Farm_price decimal(20,4),
	numero_solicitud_anterior int

	update #temp
	set Miami_FOB_Price = item_orden_sin_aprobar.valor_unitario,
	Box_charges = item_orden_sin_aprobar.box_charges,
	Charges_per_unit = item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza,
	Subtotal_3 = item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza),
	Valor_comision = farm.comision_farm,
	Comission = (item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) * (farm.comision_farm / 100),
	Subtotal_5 = (item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) - ((item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) * (farm.comision_farm / 100)),
	Freight_per_full_box = ciudad.impuesto_por_caja,
	Freight_per_specific_box = ciudad.impuesto_por_caja * tipo_caja.factor_a_full,
	Freight_per_unit = (ciudad.impuesto_por_caja * tipo_caja.factor_a_full) / item_orden_sin_aprobar.unidades_por_pieza,
	Farm_price = item_orden_sin_aprobar.valor_pactado_cobol 
	from item_orden_sin_aprobar,
	orden_sin_aprobar,
	cliente_factura,
	cliente_despacho,
	farm,
	ciudad,
	caja,
	tipo_caja
	where item_orden_sin_aprobar.id_farm = farm.id_farm
	and ciudad.id_ciudad = farm.id_ciudad
	and item_orden_sin_aprobar.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = #temp.id_item_orden_sin_aprobar

	select max(solicitud_confirmacion_orden_especial.numero_solicitud) as numero_solicitud_anterior,
	item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre into #solicitudes_anteriores
	from #temp,
	item_orden_sin_aprobar,
	solicitud_confirmacion_orden_especial
	where #temp.id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre
	and #temp.id_farm = item_orden_sin_aprobar.id_farm
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
	group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre

	update #temp
	set numero_solicitud_anterior = #solicitudes_anteriores.numero_solicitud_anterior,
	tipo_orden = 'Modificada. Anula y reemplaza la número ' +  convert(nvarchar, #solicitudes_anteriores.numero_solicitud_anterior)
	from #solicitudes_anteriores
	where #solicitudes_anteriores.id_item_orden_sin_aprobar_padre = #temp.id_item_orden_sin_aprobar_padre
	and tipo_orden = 'Modificada'

	update #temp
	set numero_solicitud_anterior = 3,
	tipo_orden = 'Modificada. Anula y reemplaza la número ' +  '3'
	where #temp.id_item_orden_sin_aprobar_padre = 24334
	
	select *,
	'' as fecha_vuelo 
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
	and id_despacho > =
	case
		when @id_despacho = 0 THEN 1
		else @id_despacho
	end
	and id_despacho < =
	case
		when @id_despacho = 0 THEN 999999
		else @id_despacho
	end
	order by id_item_orden_sin_aprobar

	drop table #solicitudes_anteriores
end
else
if(@accion = 'consultar_vendedor')
begin
	select id_vendedor,
	'[' + idc_vendedor + ']' + space(1) + ltrim(rtrim(nombre_vendedor)) as nombre
	from #temp
	where id_farm > =
	case
		when @id_farm = 0 THEN 1
		else @id_farm
	end
	and id_farm < =
	case
		when @id_farm = 0 THEN 99999
		else @id_farm
	end
	group by id_vendedor,
	ltrim(rtrim(nombre_vendedor)),
	idc_vendedor
	order by idc_vendedor
end
else
if(@accion = 'consultar_farm')
begin
	select id_farm,
	nombre_farm as nombre
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
	group by id_farm,
	nombre_farm
	order by nombre_farm
end
else
if(@accion = 'consultar_cliente')
begin
	select id_despacho,
	idc_cliente_despacho
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
	group by id_despacho,
	idc_cliente_despacho
	order by idc_cliente_despacho
end

drop table #temp
drop table #modificadas