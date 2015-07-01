set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_consultar_ordenes_sin_confirmar_version3]

@id_vendedor int,
@id_farm int,
@id_despacho int,
@accion  nvarchar(50)

as

declare @dias_atras int,
@tipo_factura_corrimiento nvarchar(10),
@id_tipo_despacho int,
@id_tipo_despacho_despacho int,
@id_tipo_despacho_corrimiento int

select @dias_atras = cantidad_dias_despacho_finca from Configuracion_bd
set @tipo_factura_corrimiento = 'all'
set @id_tipo_despacho = 1
set @id_tipo_despacho_despacho = 2
set @id_tipo_despacho_corrimiento = 3

/*visualizar ordenes que teniendo valor y siendo aprobadas no han sido enviadas a la finca*/
select 
aprobacion_orden.usuario_cobol,
(
	select max(sco.numero_solicitud)
	from item_orden_sin_aprobar as iosa,
	aprobacion_orden as ao,
	solicitud_confirmacion_orden as sco
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
	and farm.id_farm = iosa.id_farm
	and iosa.id_item_orden_sin_aprobar = ao.id_item_orden_sin_aprobar
	and ao.id_aprobacion_orden = sco.id_aprobacion_orden
	group by iosa.id_item_orden_sin_aprobar_padre	
) as numero_solicitud_anterior,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
datepart(dw,item_orden_sin_aprobar.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario as Miami_FOB_Price,
item_orden_sin_aprobar.box_charges,
item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza as Charges_per_unit,
item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza) as Subtotal_3,
(item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) * (farm.comision_farm / 100) as Comission,
(item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) - ((item_orden_sin_aprobar.valor_unitario - (item_orden_sin_aprobar.box_charges / item_orden_sin_aprobar.unidades_por_pieza)) * (farm.comision_farm / 100)) as Subtotal_5,
item_orden_sin_aprobar.valor_pactado_cobol as Farm_price,
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol 
end as precio_finca,
item_orden_sin_aprobar.valor_pactado_cobol,
item_orden_sin_aprobar.observacion as observacion_procurement,
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
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
ltrim(rtrim(ciudad.nombre_ciudad)) as nombre_ciudad,
ciudad.impuesto_por_caja as Freight_per_full_box,
ciudad.impuesto_por_caja * tipo_caja.factor_a_full as Freight_per_specific_box,
(ciudad.impuesto_por_caja * tipo_caja.factor_a_full) / item_orden_sin_aprobar.unidades_por_pieza as Freight_per_unit,
farm.id_farm,
farm.idc_farm,
'[' + farm.idc_farm + ']' + ' ' + ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
farm.comision_farm as Valor_comision,
farm.correo as correo_aprobacion,
case
	when len(farm.correo) > 7 then 1
	else 0
end as contiene_mail,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.nombre_tipo_caja,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
ltrim(rtrim(caja.nombre_caja)) as nombre_caja into #temp
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
aprobacion_orden
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
and aprobacion_orden.aceptada = 1
and farm.id_ciudad = ciudad.id_ciudad
and not exists
(
	select *
	from solicitud_confirmacion_orden
	where aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
)
group by
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.comentario,
item_orden_sin_aprobar.fecha_inicial,
item_orden_sin_aprobar.unidades_por_pieza,
item_orden_sin_aprobar.cantidad_piezas,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.valor_pactado_interno,
item_orden_sin_aprobar.valor_pactado_cobol,
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.observacion,
item_orden_sin_aprobar.box_charges,
aprobacion_orden.usuario_cobol,
vendedor.id_vendedor,
vendedor.idc_vendedor,
vendedor.nombre,
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
ciudad.impuesto_por_caja,
farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
farm.correo,
farm.dias_restados_despacho_distribuidora,
farm.comision_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
tipo_caja.factor_a_full,
caja.idc_caja,
ltrim(rtrim(caja.nombre_caja))
having
item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)

/*alterar tabla temporal para realizar cálculos de días de corrimientos*/
alter table #temp
add id_tipo_despacho int, 
id_tipo_despacho_aux int, 
corrimiento bit, 
nombre_dia_despacho nvarchar(255), 
forma_despacho int,
fecha_vuelo1 datetime
--
--/*traer datos para los corrimientos de ordenes fijas por finca*/
--update #temp
--set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
--id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
--nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
--forma_despacho = 1
--from tipo_despacho, 
--forma_despacho_farm, 
--dia_despacho,
--tipo_factura
--where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
--and forma_despacho_farm.id_farm = #temp.id_farm
--and forma_despacho_farm.id_dia_despacho = #temp.id_dia_despacho
--and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
--and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
--and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
--
--/*traer datos para los corrimientos de ordenes fijas por ciudad*/
--update #temp
--set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
--id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
--nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
--forma_despacho = 0
--from tipo_despacho, 
--forma_despacho_ciudad, 
--dia_despacho,
--tipo_factura
--where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
--and forma_despacho_ciudad.id_ciudad = #temp.id_ciudad
--and forma_despacho_ciudad.id_dia_despacho = #temp.id_dia_despacho
--and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
--and #temp.forma_despacho is null
--and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
--and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
--
--/*****************************************************************/
--/*****************************************************************/
--/*****************************************************************/
--/*********************CORRIMIENTOS POR CIUDAD*********************/
--/*****************************************************************/
--/*****************************************************************/
--/*****************************************************************/
--
--/*aumentar un dia a las ordenes*/
--update #temp
--set id_dia_despacho = replace(id_dia_despacho+1,8,1)
--where id_tipo_despacho = @id_tipo_despacho
--and forma_despacho = 0
--
--/*actualizar el día de despacho después del aumento de día del punto anterior*/
--update #temp
--set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
--nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
--id_dia_despacho = dia_despacho.id_dia_despacho
--from tipo_despacho,
--dia_despacho, 
--forma_despacho_ciudad, 
--tipo_factura
--where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
--and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
--and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
--and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
--and forma_despacho = 0
--and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
--and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
--
--/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
--update #temp
--set id_tipo_despacho = @id_tipo_despacho,
--id_dia_despacho = replace(id_dia_despacho-1,0,7)
--where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
--and forma_despacho = 0
--
--update #temp
--set corrimiento = 1
--where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
--and forma_despacho = 0
--
--/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
--while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 0))
--begin
--	update #temp
--	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
--	where id_tipo_despacho = @id_tipo_despacho
--	and forma_despacho = 0
--
--	update #temp
--	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
--	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
--	id_dia_despacho = dia_despacho.id_dia_despacho
--	from tipo_despacho,
--	dia_despacho, 
--	forma_despacho_ciudad, 
--	tipo_factura
--	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
--	and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
--	and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
--	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
--	and forma_despacho = 0
--	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
--	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
--end
--
--/*****************************************************************/
--/*****************************************************************/
--/*****************************************************************/
--/*********************CORRIMIENTOS POR FINCA**********************/
--/*****************************************************************/
--/*****************************************************************/
--/*****************************************************************/
--
--/*aumentar un dia a las ordenes*/
--update #temp
--set id_dia_despacho = replace(id_dia_despacho+1,8,1)
--where id_tipo_despacho = @id_tipo_despacho
--and forma_despacho = 1
--
--/*actualizar el día de despacho después del aumento de día del punto anterior*/
--update #temp
--set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
--nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
--id_dia_despacho = dia_despacho.id_dia_despacho
--from tipo_despacho,
--dia_despacho, 
--forma_despacho_farm, 
--tipo_factura
--where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
--and #temp.id_farm = forma_despacho_farm.id_farm
--and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
--and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
--and forma_despacho = 1
--and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
--and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
--
--/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
--update #temp
--set id_tipo_despacho = @id_tipo_despacho,
--id_dia_despacho = replace(id_dia_despacho-1,0,7)
--where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
--and forma_despacho = 1
--
--update #temp
--set corrimiento = 1
--where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
--and forma_despacho = 1
--
--/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
--while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 1))
--begin
--	update #temp
--	set id_dia_despacho = replace(id_dia_despacho-1,0,7)
--	where id_tipo_despacho = @id_tipo_despacho
--	and forma_despacho = 1
--
--	update #temp
--	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
--	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
--	id_dia_despacho = dia_despacho.id_dia_despacho
--	from tipo_despacho,
--	dia_despacho, 
--	forma_despacho_farm, 
--	tipo_factura
--	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
--	and #temp.id_farm = forma_despacho_farm.id_farm
--	and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
--	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
--	and forma_despacho = 1
--	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
--	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
--end
--
--update #temp
--set nombre_dia_despacho = 
--case
--	when nombre_dia_despacho = 'Lunes' then 'Monday'
--	when nombre_dia_despacho = 'Martes' then 'Tuesday'
--	when nombre_dia_despacho = 'Miércoles' then 'Wednesday'
--	when nombre_dia_despacho = 'Jueves' then 'Thursday'
--	when nombre_dia_despacho = 'Viernes' then 'Friday'
--	when nombre_dia_despacho = 'Sábado' then 'Saturday'
--	when nombre_dia_despacho = 'Domingo' then 'Sunday'
--end

/**procedimientos para calcular la fecha de vuelo**/
--update #temp
--set fecha_vuelo1 = fecha_inicial-7
--where datepart(dw,fecha_inicial) = id_dia_despacho

--update #temp
--set fecha_vuelo1 = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho)
--where datepart(dw,fecha_inicial) > id_dia_despacho
--
--update #temp
--set fecha_vuelo1 = fecha_inicial-(datepart(dw,fecha_inicial) - id_dia_despacho + 7)
--where datepart(dw,fecha_inicial) < id_dia_despacho

if(@accion = 'consultar_ordenes_pendientes')
begin
	select *,
	'Fecha inicial: ' + convert(nvarchar,fecha_vuelo1, 103) as fecha_vuelo,
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
