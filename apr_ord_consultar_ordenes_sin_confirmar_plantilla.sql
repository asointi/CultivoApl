set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[apr_ord_consultar_ordenes_sin_confirmar_plantilla]

as

set language spanish

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
select item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
vendedor.id_vendedor,
vendedor.idc_vendedor,
vendedor.nombre as nombre_vendedor,
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
tipo_factura.idc_tipo_factura,
case
	when tipo_factura.idc_tipo_factura = '9' then 'Orden Fija'
	when tipo_factura.idc_tipo_factura = '4' then 'Orden Especial'
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
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.fecha_final,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
aprobacion_orden.fecha_aprobacion,
convert(nvarchar, aprobacion_orden.fecha_aprobacion, 108) as hora_transaccion,
aprobacion_orden.usuario_cobol,
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
	orden_confirmada,
	confirmacion_orden_cultivo,
	solicitud_confirmacion_orden,
	aprobacion_orden
	where orden_pedido.id_orden_pedido = orden_confirmada.id_orden_pedido
	and orden_confirmada.id_confirmacion_orden_cultivo = confirmacion_orden_cultivo.id_confirmacion_orden_cultivo
	and confirmacion_orden_cultivo.id_solicitud_confirmacion_orden = solicitud_confirmacion_orden.id_solicitud_confirmacion_orden
	and solicitud_confirmacion_orden.id_aprobacion_orden = aprobacion_orden.id_aprobacion_orden
	and aprobacion_orden.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre
	order by orden_confirmada.id_orden_confirmada desc
),0) as idc_orden_pedido,
farm.correo as correo_aprobacion,
case
	when item_orden_sin_aprobar.valor_unitario > = item_orden_sin_aprobar.precio_mercado then 1
	when item_orden_sin_aprobar.valor_unitario < item_orden_sin_aprobar.precio_mercado then 0
end as comparacion_precios,
item_orden_sin_aprobar.observacion as observacion_procurement into #temp
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
tipo_factura,
aprobacion_orden,
aprobacion_orden as ao
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden < = ao.id_aprobacion_orden
and aprobacion_orden.id_aprobacion_orden_padre = ao.id_aprobacion_orden_padre
and aprobacion_orden.aceptada = 1
and farm.id_ciudad = ciudad.id_ciudad
and not exists
(
	select *
	from solicitud_confirmacion_orden
	where aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
)
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
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora),
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
aprobacion_orden.fecha_aprobacion,
convert(nvarchar, aprobacion_orden.fecha_aprobacion, 108),
aprobacion_orden.usuario_cobol,
aprobacion_orden.id_aprobacion_orden,
farm.correo,
item_orden_sin_aprobar.valor_unitario,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
item_orden_sin_aprobar.valor_pactado_cobol,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.observacion,
item_orden_sin_aprobar.valor_pactado_interno
having
item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)
and aprobacion_orden.id_aprobacion_orden = max(ao.id_aprobacion_orden)

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
aprobacion_orden,
solicitud_confirmacion_orden
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and exists
(
	select *
	from #temp
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = #temp.id_item_orden_sin_aprobar_padre
	and item_orden_sin_aprobar.id_farm = #temp.id_farm
)
and solicitud_confirmacion_orden.aceptada = 1
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre

update #temp
set tipo_orden = 'Modificada'
from #modificadas
where #modificadas.id_item_orden_sin_aprobar_padre = #temp.id_item_orden_sin_aprobar_padre

update #temp
set tipo_orden = 'Nueva'
where tipo_orden is null

/*alterar tabla temporal para realizar c�lculos de d�as de corrimientos*/
alter table #temp
add id_tipo_despacho int, 
id_tipo_despacho_aux int, 
corrimiento bit, 
nombre_dia_despacho nvarchar(255), 
forma_despacho int,
fecha_vuelo1 datetime

/*traer datos para los corrimientos de ordenes fijas por finca*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 1
from tipo_despacho, 
forma_despacho_farm, 
dia_despacho,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and forma_despacho_farm.id_farm = #temp.id_farm
and forma_despacho_farm.id_dia_despacho = #temp.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*traer datos para los corrimientos de ordenes fijas por ciudad*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 0
from tipo_despacho, 
forma_despacho_ciudad, 
dia_despacho,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and forma_despacho_ciudad.id_ciudad = #temp.id_ciudad
and forma_despacho_ciudad.id_dia_despacho = #temp.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and #temp.forma_despacho is null
and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*********************CORRIMIENTOS POR CIUDAD*********************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

/*aumentar un dia a las ordenes*/
update #temp
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 0

/*actualizar el d�a de despacho despu�s del aumento de d�a del punto anterior*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_ciudad, 
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 0
and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un d�a a las ordenes que aun no tengan d�a de despacho despu�s de los corrimientos anteriores*/
update #temp
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho-1,0,7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 0

update #temp
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 0

/*realizar los corrimientos necesarios para que todas las ordenes tengan un d�a de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 0))
begin
	update #temp
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 0

	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_ciudad, 
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 0
	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
end

/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*********************CORRIMIENTOS POR FINCA**********************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

/*aumentar un dia a las ordenes*/
update #temp
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 1

/*actualizar el d�a de despacho despu�s del aumento de d�a del punto anterior*/
update #temp
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_farm, 
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and #temp.id_farm = forma_despacho_farm.id_farm
and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 1
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un d�a a las ordenes que aun no tengan d�a de despacho despu�s de los corrimientos anteriores*/
update #temp
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho-1,0,7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 1

update #temp
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 1

/*realizar los corrimientos necesarios para que todas las ordenes tengan un d�a de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 1))
begin
	update #temp
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 1

	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_farm, 
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and #temp.id_farm = forma_despacho_farm.id_farm
	and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 1
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
end

update #temp
set nombre_dia_despacho = 
case
	when nombre_dia_despacho = 'Lunes' then 'Monday'
	when nombre_dia_despacho = 'Martes' then 'Tuesday'
	when nombre_dia_despacho = 'Mi�rcoles' then 'Wednesday'
	when nombre_dia_despacho = 'Jueves' then 'Thursday'
	when nombre_dia_despacho = 'Viernes' then 'Friday'
	when nombre_dia_despacho = 'S�bado' then 'Saturday'
	when nombre_dia_despacho = 'Domingo' then 'Sunday'
end

/**procedimientos para calcular la fecha de vuelo**/
update #temp
set fecha_vuelo1 = fecha_inicial-7
where datepart(dw,fecha_inicial) = id_dia_despacho

update #temp
set fecha_vuelo1 = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho)
where datepart(dw,fecha_inicial) > id_dia_despacho

update #temp
set fecha_vuelo1 = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho + 7)
where datepart(dw,fecha_inicial) < id_dia_despacho

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

select max(solicitud_confirmacion_orden.numero_solicitud) as numero_solicitud_anterior,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre into #solicitudes_anteriores
from #temp,
item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden
where #temp.id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre
and #temp.id_farm = item_orden_sin_aprobar.id_farm
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre	

update #temp
set numero_solicitud_anterior = #solicitudes_anteriores.numero_solicitud_anterior,
tipo_orden = 'Modificada. Anula y reemplaza la n�mero ' +  convert(nvarchar, #solicitudes_anteriores.numero_solicitud_anterior)
from #solicitudes_anteriores
where #solicitudes_anteriores.id_item_orden_sin_aprobar_padre = #temp.id_item_orden_sin_aprobar_padre
and tipo_orden = 'Modificada'

select id_item_orden_sin_aprobar as ID,
fecha_aprobacion as "Fecha Grabacion",
nombre_vendedor as Vendedor,
idc_cliente_despacho as "Codigo Cliente",
nombre_cliente as Cliente,
valor_unitario as "Sell Price",
fecha_inicial as "Fecha Miami",
nombre_farm as Finca,
nombre_dia_despacho as "Fecha Vuelo",
idc_tipo_flor+idc_variedad_flor+idc_grado_flor as "Codigo Flor Cobol",
nombre_tipo_flor as "Tipo Flor",
nombre_variedad_flor as "Variedad Flor",
nombre_grado_flor as "Grado Flor",
unidades_por_pieza as "Unidades por Pieza",
cantidad_piezas as "Cantidad Piezas",
nombre_caja as Caja,
precio_finca as "Precio Finca",
unidades_por_pieza * cantidad_piezas * precio_finca as Total,
comentario as "Comentario Farm",
observacion_procurement as "Comentario Procurement"
from #temp
order by id_item_orden_sin_aprobar

drop table #solicitudes_anteriores
drop table #temp
drop table #modificadas