set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[apr_ord_editar_confirmacion_orden_cultivo_cambio_finca]

@id_item_orden_sin_aprobar int

as

declare @idc_tipo_factura nvarchar(1),
@id_item_orden_sin_aprobar_nuevo int

insert into item_orden_sin_aprobar 
(
	id_item_orden_sin_aprobar_padre,
	id_transportador, 
	id_orden_sin_aprobar, 
	id_variedad_flor, 
	id_grado_flor, 
	id_farm, 
	id_tapa, 
	id_caja, 
	code, 
	comentario, 
	fecha_inicial, 
	fecha_final, 
	unidades_por_pieza, 
	cantidad_piezas, 
	valor_unitario, 
	valor_pactado_cobol,
	usuario_cobol,
	box_charges, 
	precio_mercado,
	observacion,
	valor_pactado_interno
)
select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
item_orden_sin_aprobar.id_transportador, 
item_orden_sin_aprobar.id_orden_sin_aprobar, 
item_orden_sin_aprobar.id_variedad_flor, 
item_orden_sin_aprobar.id_grado_flor, 
item_orden_sin_aprobar.id_farm, 
item_orden_sin_aprobar.id_tapa, 
item_orden_sin_aprobar.id_caja, 
item_orden_sin_aprobar.code, 
item_orden_sin_aprobar.comentario, 
item_orden_sin_aprobar.fecha_inicial, 
item_orden_sin_aprobar.fecha_final, 
item_orden_sin_aprobar.unidades_por_pieza, 
item_orden_sin_aprobar.cantidad_piezas, 
item_orden_sin_aprobar.valor_unitario, 
item_orden_sin_aprobar.valor_pactado_cobol,
'USUARIO SQL',
item_orden_sin_aprobar.box_charges, 
item_orden_sin_aprobar.precio_mercado,
item_orden_sin_aprobar.observacion,
item_orden_sin_aprobar.valor_pactado_interno
from item_orden_sin_aprobar
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

set @id_item_orden_sin_aprobar_nuevo = scope_identity()

select @idc_tipo_factura = tipo_factura.idc_tipo_factura
from orden_sin_aprobar,
tipo_factura,
item_orden_sin_aprobar
where tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar_nuevo

declare @id_aprobacion_orden int,
@id_solicitud_confirmacion_orden int,
@id_confirmacion_orden_cultivo int

if(@idc_tipo_factura = '9')
begin
	select @id_solicitud_confirmacion_orden = solicitud_confirmacion_orden.id_solicitud_confirmacion_orden
	from item_orden_sin_aprobar,
	aprobacion_orden, 
	solicitud_confirmacion_orden
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
	and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

	insert into confirmacion_orden_cultivo (id_solicitud_confirmacion_orden, usuario_cobol, aceptada)
	values (@id_solicitud_confirmacion_orden, 'USUARIO SQL', 0)

	set @id_confirmacion_orden_cultivo = scope_identity()

	update confirmacion_orden_cultivo
	set id_confirmacion_orden_cultivo_padre = @id_confirmacion_orden_cultivo
	where id_confirmacion_orden_cultivo = @id_confirmacion_orden_cultivo

	insert into aprobacion_orden (id_item_orden_sin_aprobar, usuario_cobol, aceptada)
	select item_orden_sin_aprobar.id_item_orden_sin_aprobar, 'USUARIO SQL', 1
	from item_orden_sin_aprobar
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar_nuevo

	set @id_aprobacion_orden = scope_identity()

	update aprobacion_orden
	set id_aprobacion_orden_padre = @id_aprobacion_orden
	where id_aprobacion_orden = @id_aprobacion_orden
end
else
if(@idc_tipo_factura = '4')
begin
	select @id_solicitud_confirmacion_orden = solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial
	from item_orden_sin_aprobar,
	solicitud_confirmacion_orden_especial
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

	insert into confirmacion_orden_especial_cultivo (id_solicitud_confirmacion_orden_especial, usuario_cobol, aceptada)
	values (@id_solicitud_confirmacion_orden, 'USUARIO SQL', 0)

	set @id_confirmacion_orden_cultivo = scope_identity()

	update confirmacion_orden_especial_cultivo
	set id_confirmacion_orden_especial_cultivo_padre = @id_confirmacion_orden_cultivo
	where id_confirmacion_orden_especial_cultivo = @id_confirmacion_orden_cultivo
end

select @id_item_orden_sin_aprobar_nuevo as id_item_orden_sin_aprobar_nuevo