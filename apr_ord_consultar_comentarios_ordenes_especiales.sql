set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[apr_ord_consultar_comentarios_ordenes_especiales]

@id_item_orden_sin_aprobar int

as

declare @id_item_orden_sin_aprobar_padre int

select @id_item_orden_sin_aprobar_padre = id_item_orden_sin_aprobar_padre 
from item_orden_sin_aprobar
where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

create table #temp
(
	ID_item_orden_sin_aprobar int,
	ID_solicitud_confirmacion_orden_especial int,
	ORDEN int,
	fecha_grabacion datetime,
	hora_grabacion nvarchar(255),
	usuario nvarchar(255),
	estado nvarchar(255),
	observacion nvarchar(1024)
)

insert into #temp
(
	ID_item_orden_sin_aprobar,
	ID_solicitud_confirmacion_orden_especial,
	ORDEN,
	fecha_grabacion,
	hora_grabacion,
	usuario,
	estado,
	observacion
)
select item_orden_sin_aprobar.ID_item_orden_sin_aprobar,
0 AS ID_solicitud_confirmacion_orden_especial,
1 AS ORDEN,
item_orden_sin_aprobar.fecha_grabacion,
convert(nvarchar,item_orden_sin_aprobar.fecha_grabacion, 108) as hora_grabacion,
item_orden_sin_aprobar.usuario_cobol as usuario,
'Entered' as estado,
isnull(item_orden_sin_aprobar.observacion, '') as observacion 
from item_orden_sin_aprobar,
orden_sin_aprobar,
tipo_factura
where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'

union all

/*visualizar ordenes que teniendo valor, siendo aprobadas y teniendo confirmacion de la finca no han sido confirmadas*/
select item_orden_sin_aprobar.ID_item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial.ID_solicitud_confirmacion_orden_especial,
2 AS ORDEN,
solicitud_confirmacion_orden_especial.fecha_grabacion,
convert(nvarchar,solicitud_confirmacion_orden_especial.fecha_grabacion, 108) as hora_grabacion,
cuenta_interna.nombre,
case
	when solicitud_confirmacion_orden_especial.aceptada = 1 then 'Sent to Farm'
	when solicitud_confirmacion_orden_especial.aceptada = 0 then 'Not Sent to Farm' 
end as estado,
case
	when solicitud_confirmacion_orden_especial.aceptada = 1 then 'SPC'+upper(farm.idc_farm)+ dbo.longitud_codigo(solicitud_confirmacion_orden_especial.numero_solicitud)
	when solicitud_confirmacion_orden_especial.aceptada = 0 then isnull(solicitud_confirmacion_orden_especial.observacion, '')
end
from cuenta_interna,
item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
farm
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
and solicitud_confirmacion_orden_especial.id_cuenta_interna = cuenta_interna.id_cuenta_interna
and item_orden_sin_aprobar.id_farm = farm.id_farm

union all

/*visualizar ordenes que teniendo valor, siendo aprobadas y teniendo confirmacion de la finca no han sido confirmadas*/
select item_orden_sin_aprobar.ID_item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial.ID_solicitud_confirmacion_orden_especial,
3 AS ORDEN,
confirmacion_orden_especial_cultivo.fecha_grabacion,
convert(nvarchar,confirmacion_orden_especial_cultivo.fecha_grabacion, 108) as hora_grabacion,
confirmacion_orden_especial_cultivo.usuario_cobol,
case
	when confirmacion_orden_especial_cultivo.aceptada = 1 then 'Farm Confirmed'
	when confirmacion_orden_especial_cultivo.aceptada = 0 then 'Not Farm Confirmed' 
end as estado,
isnull(confirmacion_orden_especial_cultivo.observacion, '')
from item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
confirmacion_orden_especial_cultivo
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
and confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial = solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial
order by item_orden_sin_aprobar.ID_item_orden_sin_aprobar DESC,
ID_solicitud_confirmacion_orden_especial DESC,
ORDEN DESC

UPDATE #TEMP
SET ESTADO = ESTADO + ' - Retrned to Procrment'
where ESTADO = 'Entered'
and usuario = 'USUARIO SQL'

UPDATE #TEMP
SET usuario = ''
where usuario = 'USUARIO SQL'

delete from #temp
where estado = 'Sent to Farm'
and usuario = 'Super Administrador'

select * from #temp

drop table #temp