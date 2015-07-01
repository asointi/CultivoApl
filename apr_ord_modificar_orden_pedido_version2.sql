set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/07/28
-- Description:	Inserta modificaciones de OFPV guardando el historial de las aprobaciones
-- =============================================

alter PROCEDURE [dbo].[apr_ord_modificar_orden_pedido_version2] 

@idc_orden_pedido int,
@idc_cliente_despacho nvarchar(255),
@idc_tipo_factura nvarchar(255),
@idc_transportador nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_farm nvarchar(255),
@idc_tapa nvarchar(255),
@idc_caja nvarchar(255),
@code nvarchar(255),
@comentario nvarchar(1024),
@fecha_inicial datetime, 
@fecha_final datetime,
@unidades_por_pieza int, 
@cantidad_piezas int, 
@valor_unitario decimal(20,4), 
@usuario_cobol nvarchar(255),
@box_charges decimal(20,4), 
@precio_mercado decimal(20,4),
@valor_pactado decimal(20,4),
@observacion nvarchar(1024) 

as

declare @id_item_orden_sin_aprobar_padre int,
@id_orden_sin_aprobar int,
@id_orden_sin_aprobar_aux int,
@id_item_orden_sin_aprobar int,
@conteo int,
@id_orden_pedido_padre int,
@id_orden_pedido int

select @id_orden_pedido_padre = orden_pedido.id_orden_pedido_padre
from orden_pedido
where orden_pedido.idc_orden_pedido = @idc_orden_pedido

select @id_orden_pedido = max(orden_pedido.id_orden_pedido)
from orden_pedido,
orden_confirmada
where orden_pedido.id_orden_pedido = orden_confirmada.id_orden_pedido
and orden_pedido.id_orden_pedido_padre = @id_orden_pedido_padre

select @id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
@id_orden_sin_aprobar_aux = orden_sin_aprobar.id_orden_sin_aprobar
from orden_pedido,
orden_confirmada,
confirmacion_orden_cultivo,
solicitud_confirmacion_orden,
aprobacion_orden,
item_orden_sin_aprobar,
orden_sin_aprobar
where orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
and confirmacion_orden_cultivo.id_confirmacion_orden_cultivo = orden_confirmada.id_confirmacion_orden_cultivo
and orden_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
and orden_pedido.id_orden_pedido = @id_orden_pedido

select @conteo = count(*)
from orden_sin_aprobar,
tipo_factura,
cliente_despacho
where cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = @id_orden_sin_aprobar_aux
and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
and tipo_factura.idc_tipo_factura = @idc_tipo_factura

if(@conteo = 0)
begin
	insert into orden_sin_aprobar (id_despacho, id_tipo_factura)
	select cliente_despacho.id_despacho,
	tipo_factura.id_tipo_factura
	from cliente_despacho,
	tipo_factura
	where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura

	set @id_orden_sin_aprobar = scope_identity()
end
else
begin
	set @id_orden_sin_aprobar = @id_orden_sin_aprobar_aux
end

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
	usuario_cobol,
	box_charges,
	precio_mercado,
	valor_pactado_cobol,
	observacion
)
select @id_item_orden_sin_aprobar_padre,
transportador.id_transportador,
@id_orden_sin_aprobar,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
farm.id_farm,
tapa.id_tapa,
caja.id_caja,
@code,
@comentario,
@fecha_inicial, 
@fecha_final,
@unidades_por_pieza, 
@cantidad_piezas, 
@valor_unitario, 
@usuario_cobol,
@box_charges, 
@precio_mercado,
@valor_pactado,
@observacion
from transportador,
variedad_flor,
tipo_flor,
grado_flor,
farm,
tapa,
tipo_caja,
caja
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and transportador.idc_transportador = @idc_transportador
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and variedad_flor.idc_variedad_flor = @idc_variedad_flor
and tipo_flor.idc_tipo_flor = @idc_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and grado_flor.idc_grado_flor = @idc_grado_flor
and farm.idc_farm = @idc_farm
and tapa.idc_tapa = @idc_tapa
and tipo_caja.idc_tipo_caja + caja.idc_caja = @idc_caja

set @id_item_orden_sin_aprobar = scope_identity()

select @id_item_orden_sin_aprobar as id_item_orden_sin_aprobar

declare @correo nvarchar(255),
@correo_estado nvarchar(1024),
@fecha_creacion_item datetime,
@nombre_cliente nvarchar(255),
@nombre_transportador nvarchar(255),
@nombre_tipo_flor nvarchar(255),
@nombre_variedad_flor nvarchar(255),
@nombre_grado_flor nvarchar(255),
@nombre_farm nvarchar(255),
@nombre_tapa nvarchar(255),
@nombre_tipo_caja nvarchar(255)

select @nombre_cliente = ltrim(rtrim(nombre_cliente)) + space(1) + '[' + idc_cliente_despacho + ']' from cliente_despacho where idc_cliente_despacho = @idc_cliente_despacho
select @nombre_transportador = ltrim(rtrim(nombre_transportador)) + space(1) + '[' + idc_transportador + ']' from transportador where idc_transportador = @idc_transportador
select @nombre_tipo_flor = ltrim(rtrim(nombre_tipo_flor)) + space(1) + '[' + idc_tipo_flor + ']' from tipo_flor where idc_tipo_flor = @idc_tipo_flor
select @nombre_variedad_flor = ltrim(rtrim(nombre_variedad_flor)) + space(1) + '[' + idc_variedad_flor + ']' 
from variedad_flor, tipo_flor 
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor 
and variedad_flor.idc_variedad_flor = @idc_variedad_flor 
select @nombre_grado_flor = ltrim(rtrim(nombre_grado_flor)) + space(1) + '[' + idc_grado_flor + ']' 
from grado_flor, tipo_flor 
where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor 
and tipo_flor.idc_tipo_flor = @idc_tipo_flor 
and grado_flor.idc_grado_flor = @idc_grado_flor 
select @nombre_farm = ltrim(rtrim(nombre_farm)) + space(1) + '[' + idc_farm + ']' from farm where idc_farm = @idc_farm
select @nombre_tapa = ltrim(rtrim(nombre_tapa)) + space(1) + '[' + idc_tapa + ']' from tapa where idc_tapa = @idc_tapa
select @nombre_tipo_caja = ltrim(rtrim(nombre_tipo_caja)) + space(1) + '[' + idc_tipo_caja + ']' 
from tipo_caja, caja 
where tipo_caja.id_tipo_caja = caja.id_tipo_caja
and idc_tipo_caja + idc_caja = @idc_caja

select @fecha_creacion_item = fecha_grabacion from item_orden_sin_aprobar
where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

select @correo = correo 
from vendedor,
cliente_factura,
cliente_despacho
where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
and cliente_factura.id_vendedor = vendedor.id_vendedor

select @correo_estado = correo
from correo_estado
where nombre_estado = 'Without Approval'

set @correo_estado = @correo + ';' + @correo_estado

declare @subject1 varchar(200),
@body1 varchar(2048)
set @subject1 = 'Standing Order Pending Approval - Modification'
set @body1 = 'SO Number Modified: ' + space(1) + convert(nvarchar,@idc_orden_pedido) + char(13) +
			'Ship to: ' + space(1) + @nombre_cliente + char(13) +
			'Carrier: ' + space(1) + @nombre_transportador + char(13) +
			'Flower Type: ' + space(1) + @nombre_tipo_flor + char(13) +
			'Flower Variety: ' + space(1) + @nombre_variedad_flor + char(13) +
			'Flower Grade: ' + space(1) + @nombre_grado_flor + char(13) +
			'Farm: ' + space(1) + @nombre_farm + char(13) +
			'Lid: ' + space(1) + @nombre_tapa + char(13) +
			'Box Type: ' + space(1) + @nombre_tipo_caja + char(13) +
			'Code: ' + space(1) + @code + char(13) +
			'Comment: ' + space(1) + @comentario + char(13) +
			'Initial Date: ' + space(1) + convert(nvarchar,@fecha_inicial,101) + char(13) +
			'Pack: ' + space(1) + convert(nvarchar,@unidades_por_pieza) + char(13) +
			'Pieces: ' + space(1) + convert(nvarchar,@cantidad_piezas) + char(13) +
			'Created by: ' + space(1) + @usuario_cobol + char(13) +
			'Creation Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item)
	EXEC msdb.dbo.sp_send_dbmail @recipients = @correo_estado,
	@subject = @subject1,
	@body = @body1,
	@body_format = 'TEXT' ;