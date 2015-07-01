set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consulta_orden_pedido_version6]

@fecha_inicial nvarchar(15),
@fecha_final nvarchar(15),
@idc_cliente_inicial nvarchar(20),
@idc_cliente_final nvarchar(20),
@idc_orden_pedido nvarchar(20),
@idc_farm_inicial nvarchar(3),
@idc_farm_final nvarchar(3)

as

select orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.idc_farm,
farm.nombre_farm,
tapa.idc_tapa,
tapa.nombre_tapa,
transportador.idc_transportador,
transportador.nombre_transportador,
orden_pedido.fecha_inicial,
orden_pedido.fecha_final,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.cantidad_piezas,
orden_pedido.valor_unitario,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
orden_pedido.comentario,
0 as con_version,
tipo_factura.idc_tipo_factura,
orden_pedido.fecha_creacion_orden,
orden_pedido.disponible,
color.idc_color,
color.nombre_color,
color.prioridad_color as orden_color,
(
	select valor_pactado
	from valor_pactado_cultivo
	where id_valor_pactado_cultivo in
	(
		select max(id_valor_pactado_cultivo)
		from valor_pactado_cultivo
		group by id_orden_pedido
	)
	and valor_pactado_cultivo.id_orden_pedido = orden_pedido.id_orden_pedido
) as valor_pactado_cultivo,
(
	select o.idc_orden_pedido
	from orden_pedido as o,
	orden_pedido as op
	where o.id_orden_pedido = op.id_orden_pedido_padre
	and op.id_orden_pedido = orden_pedido.id_orden_pedido 
) as idc_orden_pedido_padre 
into #temp
from orden_pedido, 
tipo_factura, 
tipo_flor, 
variedad_flor, 
color,
grado_flor, 
farm, 
tapa, 
transportador, 
tipo_caja, 
cliente_despacho
where 
tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and variedad_flor.id_color = color.id_color
and
(
	case 
		when @fecha_inicial = '' then convert(datetime, '1990/01/01')
		else convert(datetime,@fecha_inicial)
	end between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or 
	case 
		when @fecha_inicial = '' then convert(datetime, '1990/01/01') + 6
		else convert(datetime,@fecha_inicial) + 6
	end between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or 
	orden_pedido.fecha_inicial between
	case 
		when @fecha_inicial = '' then convert(datetime, '1990/01/01')
		else convert(datetime,@fecha_inicial)
	end 
	and 
	case 
		when @fecha_final = '' then convert(datetime, '2100/01/01')
		else convert(datetime,@fecha_final)
	end
)
and cliente_despacho.idc_cliente_despacho > = 
case 
	when @idc_cliente_inicial = '' then '%%'
	else @idc_cliente_inicial
end
and cliente_despacho.idc_cliente_despacho < = 
case 
	when @idc_cliente_final = '' then 'ZZZZZZZZZZ'
	else @idc_cliente_final
end
and farm.idc_farm > = 
case 
	when @idc_farm_inicial = '' then '%%'
	else @idc_farm_inicial
end
and farm.idc_farm < = 
case 
	when @idc_farm_final = '' then 'ZZZZZZZZZZ'
	else @idc_farm_final
end
and CONVERT(INT,orden_pedido.idc_orden_pedido) > = 
case 
	when @idc_orden_pedido = '' then 0
	else CONVERT(INT,@idc_orden_pedido)
end
and CONVERT(INT,orden_pedido.idc_orden_pedido) < = 
case 
	when @idc_orden_pedido = '' then 999999999999
	else CONVERT(INT,@idc_orden_pedido)
end

select id_orden_pedido_padre, 
max(id_orden_pedido) as id_orden_pedido, 
count(*) as cantidad into #temp2
from orden_pedido, 
tipo_factura
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
group by id_orden_pedido_padre

update #temp
set con_version = 1
from #temp, 
#temp2
where #temp.id_orden_pedido = #temp2.id_orden_pedido
and #temp2.cantidad > 1

alter table #temp
add id_item_orden_sin_aprobar int,
idc_caja nvarchar(2),
observacion_procurement nvarchar(1024),
precio_finca decimal(20,2)

create table #pendiente
(
	id_item_orden_sin_aprobar int
)

insert into #pendiente (id_item_orden_sin_aprobar)
select item_orden_sin_aprobar.id_item_orden_sin_aprobar
from item_orden_sin_aprobar,
item_orden_sin_aprobar as iosa
where item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and not exists
(
	select * 
	from aprobacion_orden
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
)
and not exists
(
	select * 
	from solicitud_confirmacion_orden_especial
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
)
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar
having item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)

insert into #pendiente (id_item_orden_sin_aprobar)
select item_orden_sin_aprobar.id_item_orden_sin_aprobar
from item_orden_sin_aprobar,
item_orden_sin_aprobar as iosa,
aprobacion_orden,
aprobacion_orden as ao
where item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden < = ao.id_aprobacion_orden
and aprobacion_orden.id_aprobacion_orden_padre = ao.id_aprobacion_orden_padre
and aprobacion_orden.aceptada = 1
and not exists
(
	select *
	from solicitud_confirmacion_orden
	where aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
)
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar,
aprobacion_orden.id_aprobacion_orden
having item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)
and aprobacion_orden.id_aprobacion_orden = max(ao.id_aprobacion_orden)

insert into #pendiente (id_item_orden_sin_aprobar)
select item_orden_sin_aprobar.id_item_orden_sin_aprobar
from item_orden_sin_aprobar,
item_orden_sin_aprobar as iosa,
aprobacion_orden,
aprobacion_orden as ao,
solicitud_confirmacion_orden,
solicitud_confirmacion_orden as sco
where item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden < = ao.id_aprobacion_orden
and aprobacion_orden.id_aprobacion_orden_padre = ao.id_aprobacion_orden_padre
and aprobacion_orden.aceptada = 1
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden < = sco.id_solicitud_confirmacion_orden
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden_padre = sco.id_solicitud_confirmacion_orden_padre
and solicitud_confirmacion_orden.aceptada = 1
and not exists
(
	select *
	from confirmacion_orden_cultivo
	where solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
)
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar,
aprobacion_orden.id_aprobacion_orden,
solicitud_confirmacion_orden.id_solicitud_confirmacion_orden
having item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)
and aprobacion_orden.id_aprobacion_orden = max(ao.id_aprobacion_orden)
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = max(sco.id_solicitud_confirmacion_orden)

insert into #pendiente (id_item_orden_sin_aprobar)
select item_orden_sin_aprobar.id_item_orden_sin_aprobar
from item_orden_sin_aprobar,
item_orden_sin_aprobar as iosa,
solicitud_confirmacion_orden_especial,
solicitud_confirmacion_orden_especial as sco
where item_orden_sin_aprobar.id_item_orden_sin_aprobar < = iosa.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial < = sco.id_solicitud_confirmacion_orden_especial
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial_padre = sco.id_solicitud_confirmacion_orden_especial_padre
and solicitud_confirmacion_orden_especial.aceptada = 1
and not exists
(
	select *
	from confirmacion_orden_especial_cultivo
	where solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
)
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial
having item_orden_sin_aprobar.id_item_orden_sin_aprobar = max(iosa.id_item_orden_sin_aprobar)
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = max(sco.id_solicitud_confirmacion_orden_especial)

alter table #pendiente
add id_item_orden_sin_aprobar_padre int

update #pendiente
set id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre
from item_orden_sin_aprobar
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = #pendiente.id_item_orden_sin_aprobar

select max(orden_pedido.id_orden_pedido) as id_orden_pedido,
orden_pedido.id_orden_pedido_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
(
	select max(iosa.id_item_orden_sin_aprobar)
	from item_orden_sin_aprobar as iosa
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
	group by iosa.id_item_orden_sin_aprobar_padre
) as id_item_orden_sin_aprobar into #ordenes_pendientes
from orden_pedido,
orden_confirmada,
confirmacion_orden_cultivo,
solicitud_confirmacion_orden,
aprobacion_orden,
item_orden_sin_aprobar,
#pendiente
where orden_pedido.id_orden_pedido = orden_confirmada.id_orden_pedido
and orden_confirmada.id_confirmacion_orden_cultivo = confirmacion_orden_cultivo.id_confirmacion_orden_cultivo
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = #pendiente.id_item_orden_sin_aprobar_padre
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
orden_pedido.id_orden_pedido_padre
union all
select max(orden_pedido.id_orden_pedido) as id_orden_pedido,
orden_pedido.id_orden_pedido_padre,
item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
(
	select max(iosa.id_item_orden_sin_aprobar)
	from item_orden_sin_aprobar as iosa
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = iosa.id_item_orden_sin_aprobar_padre
	group by iosa.id_item_orden_sin_aprobar_padre
) as id_item_orden_sin_aprobar
from orden_pedido,
orden_especial_confirmada,
confirmacion_orden_especial_cultivo,
solicitud_confirmacion_orden_especial,
item_orden_sin_aprobar,
#pendiente
where orden_pedido.id_orden_pedido = orden_especial_confirmada.id_orden_pedido
and orden_especial_confirmada.id_confirmacion_orden_especial_cultivo = confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = #pendiente.id_item_orden_sin_aprobar_padre
group by item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
orden_pedido.id_orden_pedido_padre

/*Se realiza un subquery con el fin de verificar que no existan ordenes mayores,
lo cual ocurre cuando se crea una OFPV sin pasar por aprobacion, lo anterior se da
con el cambio de transportador*/

select orden_pedido.id_orden_pedido_padre,
max(orden_pedido.id_orden_pedido) as id_orden_pedido into #ordenes_cambio_transportador
from orden_pedido,
#ordenes_pendientes
where orden_pedido.id_orden_pedido_padre = #ordenes_pendientes.id_orden_pedido_padre
and not exists
(
	select *
	from orden_confirmada
	where orden_pedido.id_orden_pedido = orden_confirmada.id_orden_pedido
)
group by orden_pedido.id_orden_pedido_padre

update #ordenes_pendientes
set id_orden_pedido = #ordenes_cambio_transportador.id_orden_pedido
from #ordenes_cambio_transportador
where #ordenes_cambio_transportador.id_orden_pedido_padre = #ordenes_pendientes.id_orden_pedido_padre

drop table #ordenes_cambio_transportador

update #temp
set id_item_orden_sin_aprobar = #ordenes_pendientes.id_item_orden_sin_aprobar
from #ordenes_pendientes
where #ordenes_pendientes.id_orden_pedido = #temp.id_orden_pedido

update #temp
set id_item_orden_sin_aprobar = 0
where id_item_orden_sin_aprobar is null

update #temp
set idc_caja = tipo_caja.idc_tipo_caja + caja.idc_caja,
observacion_procurement = item_orden_sin_aprobar.observacion,
precio_finca =
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol 
end
from caja,
tipo_caja,
item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden,
confirmacion_orden_cultivo,
orden_confirmada,
orden_pedido
where item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
and confirmacion_orden_cultivo.id_confirmacion_orden_cultivo = orden_confirmada.id_confirmacion_orden_cultivo
and orden_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
and orden_pedido.id_orden_pedido = #temp.id_orden_pedido

update #temp
set idc_caja = tipo_caja.idc_tipo_caja + caja.idc_caja,
observacion_procurement = item_orden_sin_aprobar.observacion,
precio_finca =
case
	when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
	else item_orden_sin_aprobar.valor_pactado_cobol 
end
from caja,
tipo_caja,
item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
confirmacion_orden_especial_cultivo,
orden_especial_confirmada,
orden_pedido
where item_orden_sin_aprobar.id_caja = caja.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial = confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial
and confirmacion_orden_especial_cultivo.id_confirmacion_orden_especial_cultivo = orden_especial_confirmada.id_confirmacion_orden_especial_cultivo
and orden_especial_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
and orden_pedido.id_orden_pedido = #temp.id_orden_pedido

update #temp
set idc_caja = ''
where idc_caja is null

select * from #temp

drop table #temp
drop table #temp2
drop table #pendiente
drop table #ordenes_pendientes
