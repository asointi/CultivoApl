set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[apr_ord_generar_reporte_ordenes_especiales_confirmadas]

@accion nvarchar(255),
@id_farm int

as

declare @dias_atras int,
@tipo_factura_corrimiento nvarchar(255),
@id_tipo_despacho int,
@id_tipo_despacho_despacho int,
@id_tipo_despacho_corrimiento int

set @id_tipo_despacho = 1
set @id_tipo_despacho_despacho = 2
set @id_tipo_despacho_corrimiento = 3

select @dias_atras = cantidad_dias_despacho_finca from Configuracion_bd
select @dias_atras = @dias_atras + cantidad_dias_despacho_finca_preventa from configuracion_bd

select @tipo_factura_corrimiento = 
case
	when corrimiento_preventa_activo = 0 then 'all'
	else '4'
end
from configuracion_bd

select temporada_cubo.fecha_inicial,
temporada_cubo.fecha_final into #fechas_ordenes_especiales
from temporada_cubo,
temporada_año,
tipo_venta
where temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_año = temporada_cubo.id_año
and tipo_venta.id_tipo_venta = temporada_año.id_tipo_venta
and tipo_venta.id_tipo_venta = 2

/*ordenes confirmadas*/
select vendedor.idc_vendedor,
vendedor.nombre as nombre_vendedor,
cliente_factura.idc_cliente_factura,
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
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
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
confirmacion_orden_especial_cultivo.fecha_grabacion as fecha_aprobacion,
confirmacion_orden_especial_cultivo.usuario_cobol,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end as precio_finca,
item_orden_sin_aprobar.valor_pactado_cobol,
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
item_orden_sin_aprobar.observacion as observacion_procurement,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura,
(
	select #fechas_ordenes_especiales.fecha_inicial
	from #fechas_ordenes_especiales
	where item_orden_sin_aprobar.fecha_inicial between
	#fechas_ordenes_especiales.fecha_inicial and #fechas_ordenes_especiales.fecha_final
) as fecha_inicio_temporada
into #temp_pb
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
solicitud_confirmacion_orden_especial,
solicitud_confirmacion_orden_especial as sco,
confirmacion_orden_especial_cultivo,
confirmacion_orden_especial_cultivo as coc
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
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial < = sco.id_solicitud_confirmacion_orden_especial
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial_padre = sco.id_solicitud_confirmacion_orden_especial_padre
and solicitud_confirmacion_orden_especial.aceptada = 1
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo < = coc.id_confirmacion_orden_especial_cultivo
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo_padre = coc.id_confirmacion_orden_especial_cultivo_padre
and confirmacion_orden_especial_cultivo.aceptada = 1
and farm.id_ciudad = ciudad.id_ciudad
group by
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
vendedor.idc_vendedor,
vendedor.id_vendedor,
vendedor.nombre,
cliente_factura.idc_cliente_factura,
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
confirmacion_orden_especial_cultivo.fecha_grabacion,
confirmacion_orden_especial_cultivo.usuario_cobol,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol
end,
item_orden_sin_aprobar.valor_pactado_cobol,
farm.correo,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.observacion,
solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial,
confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.numero_factura,
item_orden_sin_aprobar.fecha_factura
having
item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = max(sco.id_solicitud_confirmacion_orden_especial)
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo = max(coc.id_confirmacion_orden_especial_cultivo)

delete from #temp_pb
where fecha_inicio_temporada is null

/*alterar tabla temporal para realizar cálculos de días de corrimientos*/
alter table #temp_pb
add id_tipo_despacho int, 
id_tipo_despacho_aux int, 
corrimiento bit, 
nombre_dia_despacho nvarchar(255), 
forma_despacho int

/*traer datos para los corrimientos de ordenes fijas por finca*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 1
from tipo_despacho, 
forma_despacho_farm, 
dia_despacho,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and forma_despacho_farm.id_farm = #temp_pb.id_farm
and forma_despacho_farm.id_dia_despacho = #temp_pb.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*traer datos para los corrimientos de ordenes fijas por ciudad*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
forma_despacho = 0
from tipo_despacho, 
forma_despacho_ciudad, 
dia_despacho,
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and forma_despacho_ciudad.id_ciudad = #temp_pb.id_ciudad
and forma_despacho_ciudad.id_dia_despacho = #temp_pb.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and #temp_pb.forma_despacho is null
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
update #temp_pb
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 0

/*actualizar el día de despacho después del aumento de día del punto anterior*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_ciudad, 
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
and #temp_pb.id_ciudad = forma_despacho_ciudad.id_ciudad
and #temp_pb.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 0
and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
update #temp_pb
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho-1,0,7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 0

update #temp_pb
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 0

/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp_pb where forma_despacho = 0))
begin
	update #temp_pb
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 0

	update #temp_pb
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_ciudad, 
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp_pb.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp_pb.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
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
update #temp_pb
set id_dia_despacho = replace(id_dia_despacho+1,8,1)
where id_tipo_despacho = @id_tipo_despacho
and forma_despacho = 1

/*actualizar el día de despacho después del aumento de día del punto anterior*/
update #temp_pb
set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
id_dia_despacho = dia_despacho.id_dia_despacho
from tipo_despacho,
dia_despacho, 
forma_despacho_farm, 
tipo_factura
where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
and #temp_pb.id_farm = forma_despacho_farm.id_farm
and #temp_pb.id_dia_despacho = forma_despacho_farm.id_dia_despacho
and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
and forma_despacho = 1
and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
update #temp_pb
set id_tipo_despacho = @id_tipo_despacho,
id_dia_despacho = replace(id_dia_despacho-1,0,7)
where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
and forma_despacho = 1

update #temp_pb
set corrimiento = 1
where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
and forma_despacho = 1

/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
while(@id_tipo_despacho in (select id_tipo_despacho from #temp_pb where forma_despacho = 1))
begin
	update #temp_pb
	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 1

	update #temp_pb
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_farm, 
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and #temp_pb.id_farm = forma_despacho_farm.id_farm
	and #temp_pb.id_dia_despacho = forma_despacho_farm.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 1
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
end

alter table #temp_pb
add fecha_despacho_finca datetime

/*cambiar la semana de la orden según la fecha que presenta y el dia de despacho hallado*/
update #temp_pb
set fecha_despacho_finca = fecha_inicial - 7
where datepart(dw,fecha_inicial) = id_dia_despacho

update #temp_pb
set fecha_despacho_finca = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho)
where datepart(dw,fecha_inicial) > id_dia_despacho

update #temp_pb
set fecha_despacho_finca = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho + 7)
where datepart(dw,fecha_inicial) < id_dia_despacho

update #temp_pb
set nombre_dia_despacho = convert(nvarchar,fecha_despacho_finca, 103)

if(@accion = 'consultar_detalle')
begin
	select * 
	from #temp_pb
	where datediff(dd, fecha_aprobacion, fecha_despacho_finca) > = 7
	and fecha_despacho_finca = convert(datetime, convert(nvarchar, dateadd(dd, 2,getdate()), 103))
	and fecha_inicial > = CONVERT(datetime, convert(nvarchar, getdate(), 103))
	and id_farm = @id_farm
	order by fecha_aprobacion desc
end
if(@accion = 'consultar_fincas')
begin
	select id_farm,
	idc_farm,
	nombre_farm
	from #temp_pb
	where datediff(dd, fecha_aprobacion, fecha_despacho_finca) > = 7
	and fecha_despacho_finca = convert(datetime, convert(nvarchar, dateadd(dd, 2,getdate()), 103))
	and fecha_inicial > = CONVERT(datetime, convert(nvarchar, getdate(), 103))
	group by id_farm,
	idc_farm,
	nombre_farm
	order by id_farm
end

drop table #temp_pb
drop table #fechas_ordenes_especiales