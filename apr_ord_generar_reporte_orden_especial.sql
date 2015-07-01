set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[apr_ord_generar_reporte_orden_especial]

@estado nvarchar(255),
@accion nvarchar(255)

AS

declare @dias_atras int,
@tipo_factura_corrimiento nvarchar(255),
@id_tipo_despacho int,
@id_tipo_despacho_despacho int,
@id_tipo_despacho_corrimiento int

select @dias_atras = cantidad_dias_despacho_finca from Configuracion_bd
set @tipo_factura_corrimiento = 'all'
set @id_tipo_despacho = 1
set @id_tipo_despacho_despacho = 2
set @id_tipo_despacho_corrimiento = 3

/*visualizar ordenes que teniendo valor y siendo aprobadas no han sido enviadas a la finca*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.fecha_grabacion as fecha_aprobacion,
convert(nvarchar, item_orden_sin_aprobar.fecha_grabacion, 108) as hora_grabacion,
item_orden_sin_aprobar.usuario_cobol,
'Entered' as estado,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end as precio_finca,
ciudad.id_ciudad,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura,
item_orden_sin_aprobar.fecha_grabacion as fecha_ingreso into #temp
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
tapa,
tipo_caja,
caja,
item_orden_sin_aprobar as iosa,
tipo_factura,
ciudad
where ciudad.id_ciudad = farm.id_ciudad
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and not exists
(
	select *
	from solicitud_confirmacion_orden_especial
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
)
and tipo_factura.idc_tipo_factura = '4'
group by
ciudad.id_ciudad,
farm.dias_restados_despacho_distribuidora,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
caja.idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
item_orden_sin_aprobar.fecha_grabacion,
convert(nvarchar, item_orden_sin_aprobar.fecha_grabacion, 108),
item_orden_sin_aprobar.usuario_cobol,
farm.correo,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura
having
item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)

union all
/*visualizar ordenes que teniendo valor, siendo aprobadas y teniendo confirmacion de la finca no han sido confirmadas*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
solicitud_confirmacion_orden_especial.fecha_grabacion,
convert(nvarchar, solicitud_confirmacion_orden_especial.fecha_grabacion, 108),
cuenta_interna.nombre,
'Sent to Farm' as estado,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end as precio_finca,
ciudad.id_ciudad,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura,
item_orden_sin_aprobar.fecha_grabacion
from cliente_factura,
cliente_despacho,
cuenta_interna,
orden_sin_aprobar,
vendedor,
item_orden_sin_aprobar,
transportador,
variedad_flor,
tipo_flor,
grado_flor,
farm,
tapa,
tipo_caja,
caja,
item_orden_sin_aprobar as iosa,
tipo_factura,
solicitud_confirmacion_orden_especial,
solicitud_confirmacion_orden_especial as sco,
ciudad
where ciudad.id_ciudad = farm.id_ciudad
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial < = sco.id_solicitud_confirmacion_orden_especial
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial_padre = sco.id_solicitud_confirmacion_orden_especial_padre
and solicitud_confirmacion_orden_especial.aceptada = 1
and solicitud_confirmacion_orden_especial.id_cuenta_interna = cuenta_interna.id_cuenta_interna
and not exists
(
	select *
	from confirmacion_orden_especial_cultivo
	where solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
)
and tipo_factura.idc_tipo_factura = '4'
group by
ciudad.id_ciudad,
farm.dias_restados_despacho_distribuidora,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
caja.idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
solicitud_confirmacion_orden_especial.fecha_grabacion,
item_orden_sin_aprobar.fecha_grabacion,
convert(nvarchar, solicitud_confirmacion_orden_especial.fecha_grabacion, 108),
farm.correo,
solicitud_confirmacion_orden_especial.numero_solicitud,
cuenta_interna.nombre,
solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura
having
item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = max(sco.id_solicitud_confirmacion_orden_especial)

union all

select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
confirmacion_orden_especial_cultivo.fecha_grabacion,
convert(nvarchar, confirmacion_orden_especial_cultivo.fecha_grabacion, 108),
confirmacion_orden_especial_cultivo.usuario_cobol,
'Confirmed' as estado,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end as precio_finca,
ciudad.id_ciudad,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura,
item_orden_sin_aprobar.fecha_grabacion
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
tapa,
tipo_caja,
caja,
item_orden_sin_aprobar as iosa,
tipo_factura,
solicitud_confirmacion_orden_especial,
solicitud_confirmacion_orden_especial as sco,
confirmacion_orden_especial_cultivo,
confirmacion_orden_especial_cultivo as coec,
ciudad
where ciudad.id_ciudad = farm.id_ciudad
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial < = sco.id_solicitud_confirmacion_orden_especial
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial_padre = sco.id_solicitud_confirmacion_orden_especial_padre
and solicitud_confirmacion_orden_especial.aceptada = 1
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo < = coec.id_confirmacion_orden_especial_cultivo
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo_padre = coec.id_confirmacion_orden_especial_cultivo_padre
and confirmacion_orden_especial_cultivo.aceptada = 1
and tipo_factura.idc_tipo_factura = '4'
group by
ciudad.id_ciudad,
farm.dias_restados_despacho_distribuidora,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
caja.idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
confirmacion_orden_especial_cultivo.fecha_grabacion,
item_orden_sin_aprobar.fecha_grabacion,
confirmacion_orden_especial_cultivo.usuario_cobol,
convert(nvarchar, confirmacion_orden_especial_cultivo.fecha_grabacion, 108),
solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial,
confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura
having
item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = max(sco.id_solicitud_confirmacion_orden_especial)
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo = max(coec.id_confirmacion_orden_especial_cultivo)

union all
/*visualizar ordenes que teniendo valor y siendo aprobadas no han sido enviadas a la finca*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
solicitud_confirmacion_orden_especial.fecha_grabacion as fecha_aprobacion,
convert(nvarchar, solicitud_confirmacion_orden_especial.fecha_grabacion, 108) as hora_grabacion,
cuenta_interna.nombre,
'Returned' as estado,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end as precio_finca,
ciudad.id_ciudad,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura,
item_orden_sin_aprobar.fecha_grabacion as fecha_ingreso
from cliente_factura,
cuenta_interna,
cliente_despacho,
orden_sin_aprobar,
vendedor,
item_orden_sin_aprobar,
transportador,
variedad_flor,
tipo_flor,
grado_flor,
farm,
tapa,
tipo_caja,
caja,
tipo_factura,
ciudad,
solicitud_confirmacion_orden_especial
where solicitud_confirmacion_orden_especial.id_cuenta_interna = cuenta_interna.id_cuenta_interna
and ciudad.id_ciudad = farm.id_ciudad
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.aceptada = 0
and tipo_factura.idc_tipo_factura = '4'
group by
ciudad.id_ciudad,
farm.dias_restados_despacho_distribuidora,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
caja.idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
solicitud_confirmacion_orden_especial.fecha_grabacion,
item_orden_sin_aprobar.fecha_grabacion,
convert(nvarchar, solicitud_confirmacion_orden_especial.fecha_grabacion, 108),
cuenta_interna.nombre,
farm.correo,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura

union all
/*visualizar ordenes que teniendo valor, siendo aprobadas y teniendo confirmacion de la finca no han sido confirmadas*/
select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
confirmacion_orden_especial_cultivo.fecha_grabacion,
convert(nvarchar, confirmacion_orden_especial_cultivo.fecha_grabacion, 108),
confirmacion_orden_especial_cultivo.usuario_cobol,
'Returned' as estado,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end as precio_finca,
ciudad.id_ciudad,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura,
item_orden_sin_aprobar.fecha_grabacion
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
tapa,
tipo_caja,
caja,
tipo_factura,
solicitud_confirmacion_orden_especial,
ciudad,
confirmacion_orden_especial_cultivo
where ciudad.id_ciudad = farm.id_ciudad
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.aceptada = 1
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and confirmacion_orden_especial_cultivo.aceptada = 0
and tipo_factura.idc_tipo_factura = '4'
group by
ciudad.id_ciudad,
farm.dias_restados_despacho_distribuidora,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
cliente_factura.idc_cliente_factura,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_factura.idc_tipo_factura,
tipo_factura.nombre_tipo_factura,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
caja.idc_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
confirmacion_orden_especial_cultivo.fecha_grabacion,
item_orden_sin_aprobar.fecha_grabacion,
convert(nvarchar, confirmacion_orden_especial_cultivo.fecha_grabacion, 108),
confirmacion_orden_especial_cultivo.usuario_cobol,
solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura

if(@accion = 'consultar_detalle')
begin
	select * 
	from #temp
	where estado = @estado
	order by fecha_aprobacion desc
end
else
if(@accion = 'consultar_subject')
begin
	select count(*) as cantidad 
	from #temp
	where valor_unitario < precio_mercado
	and convert(datetime,convert(nvarchar,fecha_ingreso,103)) = convert(datetime,convert(nvarchar,getdate()-1,103))
	and estado <> 'Returned'
end
else
if(@accion = 'consultar_ingresadas')
begin
	select * 
	from #temp
	where convert(datetime,convert(nvarchar,fecha_ingreso,103)) = convert(datetime,convert(nvarchar,getdate()-1,103))
	order by fecha_aprobacion desc
end

begin transaction
	drop table #temp
commit transaction;