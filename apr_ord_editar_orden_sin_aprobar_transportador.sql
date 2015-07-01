set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/07/29
-- Description:	Inserta nuevas versiones de órdenes canceladas cuando se cambia el transportador
-- =============================================

create PROCEDURE [dbo].[apr_ord_editar_orden_sin_aprobar_transportador] 

@idc_transportador nvarchar(20),
@idc_orden_pedido_anterior nvarchar(20),
@idc_orden_pedido_nueva nvarchar(20)

as

declare @id_item_orden_sin_aprobar int,
@id_item_orden_sin_aprobar_padre int,
@id_transportador int,
@id_orden_sin_aprobar int,
@id_variedad_flor int,
@id_grado_flor int,
@id_farm int,
@id_tapa int,
@code nvarchar(255),
@comentario nvarchar(1024),
@fecha_inicial datetime,
@fecha_final datetime,
@unidades_por_pieza int,
@cantidad_piezas int,
@valor_unitario decimal(20,4),
@id_caja int,
@valor_pactado_cobol decimal(20,4),
@box_charges decimal(20,4),
@precio_mercado decimal(20,4),
@valor_pactado_interno decimal(20,4),
@observacion nvarchar(1024),
@numero_factura nvarchar(255),
@fecha_factura datetime,
@observacion_aprobacion_orden nvarchar(1024),
@aceptada_aprobacion_orden bit,
@id_aprobacion_orden int,
@aceptada_solicitud_confirmacion_orden bit,
@observacion_solicitud_confirmacion_orden nvarchar(1024),
@numero_solicitud_solicitud_confirmacion_orden int,
@id_solicitud_confirmacion_orden int,
@observacion_confirmacion_orden_cultivo nvarchar(1024),
@aceptada_confirmacion_orden_cultivo bit,
@id_confirmacion_orden_cultivo int

select @id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
@id_transportador = transportador.id_transportador,
@id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar,
@id_variedad_flor = item_orden_sin_aprobar.id_variedad_flor,
@id_grado_flor = item_orden_sin_aprobar.id_grado_flor,
@id_farm = item_orden_sin_aprobar.id_farm,
@id_tapa = item_orden_sin_aprobar.id_tapa,
@code = item_orden_sin_aprobar.code,
@comentario = item_orden_sin_aprobar.comentario,
@fecha_inicial = item_orden_sin_aprobar.fecha_inicial,
@fecha_final = item_orden_sin_aprobar.fecha_final,
@unidades_por_pieza = item_orden_sin_aprobar.unidades_por_pieza,
@cantidad_piezas = item_orden_sin_aprobar.cantidad_piezas,
@valor_unitario = item_orden_sin_aprobar.valor_unitario,
@id_caja = item_orden_sin_aprobar.id_caja,
@valor_pactado_cobol = item_orden_sin_aprobar.valor_pactado_cobol,
@box_charges = item_orden_sin_aprobar.box_charges,
@precio_mercado = item_orden_sin_aprobar.precio_mercado,
@valor_pactado_interno = item_orden_sin_aprobar.valor_pactado_interno,
@observacion = item_orden_sin_aprobar.observacion,
@numero_factura = item_orden_sin_aprobar.numero_factura,
@fecha_factura = item_orden_sin_aprobar.fecha_factura,
@observacion_aprobacion_orden = aprobacion_orden.observacion,
@aceptada_aprobacion_orden = aprobacion_orden.aceptada,
@aceptada_solicitud_confirmacion_orden = solicitud_confirmacion_orden.aceptada,
@observacion_solicitud_confirmacion_orden = solicitud_confirmacion_orden.observacion,
@numero_solicitud_solicitud_confirmacion_orden = solicitud_confirmacion_orden.numero_solicitud,
@observacion_confirmacion_orden_cultivo = confirmacion_orden_cultivo.observacion,
@aceptada_confirmacion_orden_cultivo = confirmacion_orden_cultivo.aceptada
from orden_sin_aprobar,
item_orden_sin_aprobar,
aprobacion_orden,
solicitud_confirmacion_orden,
confirmacion_orden_cultivo,
orden_confirmada,
orden_pedido,
transportador
where orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
and confirmacion_orden_cultivo.id_confirmacion_orden_cultivo = orden_confirmada.id_confirmacion_orden_cultivo
and orden_pedido.id_orden_pedido = orden_confirmada.id_orden_pedido
and orden_pedido.idc_orden_pedido = @idc_orden_pedido_anterior
and transportador.idc_transportador = @idc_transportador

insert into item_orden_sin_aprobar 
(
	id_item_orden_sin_aprobar_padre,
	id_transportador,
	id_orden_sin_aprobar,
	id_variedad_flor,
	id_grado_flor,
	id_farm,
	id_tapa,
	code,
	comentario,
	fecha_inicial,
	fecha_final,
	unidades_por_pieza,
	cantidad_piezas,
	valor_unitario,
	fecha_grabacion,
	usuario_cobol,
	id_caja,
	valor_pactado_cobol,
	box_charges,
	precio_mercado,
	valor_pactado_interno,
	observacion,
	numero_factura,
	fecha_factura
)
values
(
	@id_item_orden_sin_aprobar_padre,
	@id_transportador,
	@id_orden_sin_aprobar,
	@id_variedad_flor,
	@id_grado_flor,
	@id_farm,
	@id_tapa,
	@code,
	@comentario,
	@fecha_inicial,
	@fecha_final,
	@unidades_por_pieza,
	@cantidad_piezas,
	@valor_unitario,
	getdate(),
	'USUARIO SQL',
	@id_caja,
	@valor_pactado_cobol,
	@box_charges,
	@precio_mercado,
	@valor_pactado_interno,
	@observacion,
	@numero_factura,
	@fecha_factura
)

set @id_item_orden_sin_aprobar = scope_identity()

insert into aprobacion_orden 
(
	id_item_orden_sin_aprobar,
	fecha_aprobacion,
	usuario_cobol,
	observacion,
	aceptada
)
values
(
	@id_item_orden_sin_aprobar,
	getdate(),
	'USUARIO SQL',
	@observacion_aprobacion_orden,
	@aceptada_aprobacion_orden
)

set @id_aprobacion_orden = scope_identity()

update aprobacion_orden
set id_aprobacion_orden_padre = @id_aprobacion_orden
where id_aprobacion_orden = @id_aprobacion_orden

insert into solicitud_confirmacion_orden
(
	id_aprobacion_orden,
	id_cuenta_interna,
	fecha_grabacion,
	aceptada,
	observacion,
	numero_solicitud
)
values
(
	@id_aprobacion_orden,
	1,
	getdate(),
	@aceptada_solicitud_confirmacion_orden,
	@observacion_solicitud_confirmacion_orden,
	@numero_solicitud_solicitud_confirmacion_orden
)

set @id_solicitud_confirmacion_orden = scope_identity()

update solicitud_confirmacion_orden
set id_solicitud_confirmacion_orden_padre = @id_solicitud_confirmacion_orden
where id_solicitud_confirmacion_orden = @id_solicitud_confirmacion_orden

insert into confirmacion_orden_cultivo 
(
	id_solicitud_confirmacion_orden,
	fecha_grabacion,
	observacion,
	usuario_cobol,
	aceptada
)
values
(
	@id_solicitud_confirmacion_orden,
	getdate(),
	@observacion_confirmacion_orden_cultivo,
	'USUARIO SQL',
	@aceptada_confirmacion_orden_cultivo
)

set @id_confirmacion_orden_cultivo = scope_identity()

update confirmacion_orden_cultivo 
set id_confirmacion_orden_cultivo_padre = @id_confirmacion_orden_cultivo
where id_confirmacion_orden_cultivo = @id_confirmacion_orden_cultivo 

insert into orden_confirmada (id_orden_pedido, id_confirmacion_orden_cultivo)
select orden_pedido.id_orden_pedido,
@id_confirmacion_orden_cultivo
from orden_pedido
where orden_pedido.idc_orden_pedido = @idc_orden_pedido_nueva