set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_consultar_ordenes_especiales_rechazadas]

@idc_vendedor nvarchar(255),
@estado nvarchar(255),
@con_historia int = null

as

declare @fecha datetime
set @fecha = convert(nvarchar, getdate(), 103)

select max(id_item_orden_sin_aprobar) as id_item_orden_sin_aprobar into #item_orden_sin_aprobar
from item_orden_sin_aprobar
group by id_item_orden_sin_aprobar_padre

create table #temp
(
	id_item_orden_sin_aprobar int,
	idc_vendedor nvarchar(5),
	nombre_vendedor nvarchar(100),
	idc_cliente_despacho nvarchar(20),
	nombre_cliente nvarchar(100),
	idc_transportador nvarchar(20),
	idc_tipo_flor nvarchar(5),
	nombre_tipo_flor nvarchar(50),
	idc_variedad_flor nvarchar(5),
	nombre_variedad_flor nvarchar(50),
	idc_grado_flor nvarchar(5),
	nombre_grado_flor nvarchar(50),
	idc_farm nvarchar(5),
	nombre_farm nvarchar(50),
	idc_tapa nvarchar(5),
	idc_caja nvarchar(5),
	idc_tipo_caja nvarchar(5),
	code nvarchar(10),
	fecha_inicial datetime,
	unidades_por_pieza int,
	cantidad_piezas int,
	valor_unitario decimal(20,4),
	precio_finca decimal(20,4),
	fecha_grabacion datetime,
	hora_grabacion nvarchar(10),
	usuario_cobol nvarchar(50),
	estado nvarchar(50),
	idc_orden_pedido nvarchar(5),
	observacion nvarchar(1024),
	precio_mercado decimal(20,4),
	comentario nvarchar(1024),
	observacion_procurement_vendedor nvarchar(1024),
	valor_pactado_interno DECIMAL(20,4)
)

insert into #temp
(
	id_item_orden_sin_aprobar,
	idc_vendedor,
	nombre_vendedor,
	idc_cliente_despacho,
	nombre_cliente,
	idc_transportador,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_farm,
	nombre_farm,
	idc_tapa,
	idc_caja,
	idc_tipo_caja,
	code,
	fecha_inicial,
	unidades_por_pieza,
	cantidad_piezas,
	valor_unitario,
	precio_finca,
	fecha_grabacion,
	hora_grabacion,
	usuario_cobol,
	estado,
	idc_orden_pedido,
	observacion,
	precio_mercado,
	comentario,
	observacion_procurement_vendedor,
	valor_pactado_interno
)
select item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
transportador.idc_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
tipo_caja.idc_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
null as precio_finca,
solicitud_confirmacion_orden_especial.fecha_grabacion,
convert(nvarchar,solicitud_confirmacion_orden_especial.fecha_grabacion, 108) as hora_grabacion,
cuenta_interna.nombre as usuario_cobol,
'Not Sent to Farm' as estado,
'' as idc_orden_pedido,
solicitud_confirmacion_orden_especial.observacion,
item_orden_sin_aprobar.precio_mercado,
isnull(item_orden_sin_aprobar.comentario, '') as comentario,
isnull(item_orden_sin_aprobar.observacion, '') as observacion_procurement_vendedor,
item_orden_sin_aprobar.valor_pactado_interno
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
tipo_farm,
ciudad,
tapa,
tipo_caja,
caja,
tipo_factura,
solicitud_confirmacion_orden_especial
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
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
and item_orden_sin_aprobar.id_caja = caja.id_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.aceptada = 0
and solicitud_confirmacion_orden_especial.id_cuenta_interna = cuenta_interna.id_cuenta_interna
and not exists
(
	select *
	from confirmacion_orden_especial_cultivo
	where solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
)
and tipo_factura.idc_tipo_factura = '4'
and exists
(
	select * 
	from #item_orden_sin_aprobar
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = #item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and item_orden_sin_aprobar.fecha_inicial > =
case
	when @con_historia = 0 then @fecha
	when @con_historia is null then @fecha
	when @con_historia = 1 then convert(datetime, '19900101')
end

insert into #temp
(
	id_item_orden_sin_aprobar,
	idc_vendedor,
	nombre_vendedor,
	idc_cliente_despacho,
	nombre_cliente,
	idc_transportador,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_farm,
	nombre_farm,
	idc_tapa,
	idc_caja,
	idc_tipo_caja,
	code,
	fecha_inicial,
	unidades_por_pieza,
	cantidad_piezas,
	valor_unitario,
	precio_finca,
	fecha_grabacion,
	hora_grabacion,
	usuario_cobol,
	estado,
	idc_orden_pedido,
	observacion,
	precio_mercado,
	comentario,
	observacion_procurement_vendedor,
	valor_pactado_interno
)
select item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
transportador.idc_transportador,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
tipo_caja.idc_tipo_caja,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
null as precio_finca,
confirmacion_orden_especial_cultivo.fecha_grabacion,
convert(nvarchar,confirmacion_orden_especial_cultivo.fecha_grabacion, 108),
confirmacion_orden_especial_cultivo.usuario_cobol,
'No Farm Confirmed' as estado,
'' as idc_orden_pedido,
confirmacion_orden_especial_cultivo.observacion,
item_orden_sin_aprobar.precio_mercado,
isnull(item_orden_sin_aprobar.comentario, '') as comentario,
isnull(item_orden_sin_aprobar.observacion, '') as observacion_procurement_vendedor,
item_orden_sin_aprobar.valor_pactado_interno
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
tipo_factura,
solicitud_confirmacion_orden_especial,
confirmacion_orden_especial_cultivo
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
and tipo_farm.id_tipo_farm = farm.id_tipo_farm
and ciudad.id_ciudad = farm.id_ciudad
and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
and item_orden_sin_aprobar.id_caja = caja.id_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.aceptada = 1
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and confirmacion_orden_especial_cultivo.aceptada = 0
and tipo_factura.idc_tipo_factura = '4'
and exists
(
	select * 
	from #item_orden_sin_aprobar
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = #item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and not exists
(
	select *
	from orden_especial_confirmada
	where confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo = orden_especial_confirmada.id_confirmacion_orden_especial_cultivo
)
and item_orden_sin_aprobar.fecha_inicial > =
case
	when @con_historia = 0 then @fecha
	when @con_historia is null then @fecha
	when @con_historia = 1 then convert(datetime, '19900101')
end

select * 
from #temp
where idc_vendedor > = 
case
	when @idc_vendedor = '' THEN '   '
	else @idc_vendedor
end
and idc_vendedor < = 
case
	when @idc_vendedor = '' THEN 'ZZZ'
	else @idc_vendedor
end
order by fecha_grabacion desc

drop table #temp
drop table #item_orden_sin_aprobar