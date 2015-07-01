set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[apr_ord_consultar_comentarios]

@id_item_orden_sin_aprobar int

as

declare @id_item_orden_sin_aprobar_padre int

select @id_item_orden_sin_aprobar_padre = id_item_orden_sin_aprobar_padre 
from item_orden_sin_aprobar
where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

select item_orden_sin_aprobar.fecha_grabacion,
convert(nvarchar,item_orden_sin_aprobar.fecha_grabacion, 108) as hora_grabacion,
item_orden_sin_aprobar.usuario_cobol as usuario,
'Entered' as estado,
isnull(item_orden_sin_aprobar.observacion, '') as observacion
from item_orden_sin_aprobar
where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre

union all

/*visualizar ordenes que teniendo valor y siendo aprobadas no han sido enviadas a la finca*/
select aprobacion_orden.fecha_aprobacion,
convert(nvarchar,aprobacion_orden.fecha_aprobacion, 108) as hora_grabacion,
aprobacion_orden.usuario_cobol,
case
	when aprobacion_orden.aceptada = 1 then 'Approved' 
	when aprobacion_orden.aceptada = 0 then 'Not Approved' 
end as estado,
isnull(aprobacion_orden.observacion, '')
from item_orden_sin_aprobar,
aprobacion_orden
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre

union all

/*visualizar ordenes que teniendo valor, siendo aprobadas y teniendo confirmacion de la finca no han sido confirmadas*/
select solicitud_confirmacion_orden.fecha_grabacion,
convert(nvarchar,solicitud_confirmacion_orden.fecha_grabacion, 108) as hora_grabacion,
cuenta_interna.nombre,
case
	when solicitud_confirmacion_orden.aceptada = 1 then 'Sent to Farm'
	when solicitud_confirmacion_orden.aceptada = 0 then 'Not Sent to Farm' 
end as estado,
case
	when solicitud_confirmacion_orden.aceptada = 1 then 'STD'+upper(farm.idc_farm)+ dbo.longitud_codigo(solicitud_confirmacion_orden.numero_solicitud)
	when solicitud_confirmacion_orden.aceptada = 0 then isnull(solicitud_confirmacion_orden.observacion, '')
end
from cuenta_interna,
item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden,
farm
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
and solicitud_confirmacion_orden.id_cuenta_interna = cuenta_interna.id_cuenta_interna
and item_orden_sin_aprobar.id_farm = farm.id_farm

union all

/*visualizar ordenes que teniendo valor, siendo aprobadas y teniendo confirmacion de la finca no han sido confirmadas*/
select confirmacion_orden_cultivo.fecha_grabacion,
convert(nvarchar,confirmacion_orden_cultivo.fecha_grabacion, 108) as hora_grabacion,
confirmacion_orden_cultivo.usuario_cobol,
case
	when confirmacion_orden_cultivo.aceptada = 1 then 'Farm Confirmed'
	when confirmacion_orden_cultivo.aceptada = 0 then 'Not Farm Confirmed' 
end as estado,
isnull(confirmacion_orden_cultivo.observacion, '')
from item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden,
confirmacion_orden_cultivo
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
and confirmacion_orden_cultivo.id_solicitud_confirmacion_orden = solicitud_confirmacion_orden.id_solicitud_confirmacion_orden
order by fecha_grabacion desc