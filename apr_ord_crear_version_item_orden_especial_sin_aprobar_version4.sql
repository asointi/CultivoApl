/****** Object:  StoredProcedure [dbo].[apr_ord_crear_version_item_orden_especial_sin_aprobar_version2]    Script Date: 06/03/2014 11:15:55 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2014/03/10
-- Description:	Inserta nuevas versiones de órdenes canceladas
-- =============================================

create PROCEDURE [dbo].[apr_ord_crear_version_item_orden_especial_sin_aprobar_version4] 

@id_item_orden_sin_aprobar int,
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
@valor_pactado_orden_especial decimal(20,4), 
@usuario_cobol nvarchar(255),
@box_charges decimal(20,4), 
@precio_mercado decimal(20,4),
@observacion nvarchar(1024)

as

declare @id_item_orden_sin_aprobar_padre int,
@id_orden_sin_aprobar int,
@id_orden_sin_aprobar_aux int,
@conteo int

select @id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
@id_orden_sin_aprobar_aux = orden_sin_aprobar.id_orden_sin_aprobar
from item_orden_sin_aprobar,
orden_sin_aprobar
where orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

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
	valor_pactado_cobol,
	usuario_cobol,
	box_charges, 
	precio_mercado,
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
@valor_pactado_orden_especial,
@usuario_cobol,
@box_charges, 
@precio_mercado,
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

declare @correo_adicional nvarchar(50),
@body1 nvarchar(max),
@subject1 NVARCHAR(1024),
@nombre_base_datos nvarchar(255),
@correo_estado nvarchar(1024),
@correo nvarchar(1024),
@perfil nvarchar(255)

set @nombre_base_datos = DB_NAME()

if(@nombre_base_datos = 'BD_NF')
begin
	set @correo_adicional = ''	
end
else
begin
	set @correo_adicional = ''
end

select @correo_estado = correo
from correo_estado
where nombre_estado = 'Not Sent to Farm'

select @correo_estado = @correo_estado + ';' + correo
from correo_estado
where nombre_estado = 'No Farm Confirmed'

set @correo_estado = @correo_estado + ';' + @correo_adicional

select @correo = ltrim(rtrim(vendedor.correo))
from vendedor,
item_orden_sin_aprobar,
orden_sin_aprobar,
cliente_despacho,
cliente_factura
where orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

set @correo_estado = @correo_estado + ';' + @correo

set @subject1 = 'Special Order Modified and Confirmed'

select @body1 = 'Sent to Farm' + char(13) +
'Last Modified by: ' + space(1) + @usuario_cobol + char(13) +
'Last Modified Date: ' + space(1) + convert(nvarchar,item_orden_sin_aprobar.fecha_grabacion) + char(13) +
'Description: ' + space(1) + @observacion + char(13) + char(13) +

'Ship to: ' + space(1) + ltrim(rtrim(cliente_despacho.nombre_cliente)) + ' [' + ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) + ']' + char(13) +
'Carrier: ' + space(1) + ltrim(rtrim(transportador.nombre_transportador)) + ' [' + transportador.idc_transportador + ']' + char(13) +
'Flower Type: ' + space(1) + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' + char(13) +
'Flower Variety: ' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' + char(13) +
'Flower Grade: ' + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' + char(13) +
'Farm: ' + space(1) + ltrim(rtrim(farm.nombre_farm)) + ' [' + farm.idc_farm + ']' + char(13) +
'Lid: ' + space(1) + ltrim(rtrim(tapa.nombre_tapa)) + ' [' + tapa.idc_tapa + ']' + char(13) +
'Box Type: ' + space(1) + ltrim(rtrim(caja.nombre_caja)) + ' [' + tipo_caja.idc_tipo_caja + caja.idc_caja + ']' + char(13) +
'Code: ' + space(1) + item_orden_sin_aprobar.code + char(13) + 
'Comment: ' + space(1) + item_orden_sin_aprobar.comentario + char(13) +
'Initial Date: ' + space(1) + convert(nvarchar,item_orden_sin_aprobar.fecha_inicial,101) + char(13) +
'Pack: ' + space(1) + convert(nvarchar,item_orden_sin_aprobar.unidades_por_pieza) + char(13) +
'Pieces: ' + space(1) + convert(nvarchar,item_orden_sin_aprobar.cantidad_piezas) + char(13)
from item_orden_sin_aprobar,
orden_sin_aprobar,
cliente_despacho,
transportador,
tipo_flor,
variedad_flor,
grado_flor,
farm,
tapa,
tipo_caja,
caja
where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and transportador.id_transportador = item_orden_sin_aprobar.id_transportador
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = item_orden_sin_aprobar.id_variedad_flor
and grado_flor.id_grado_flor = item_orden_sin_aprobar.id_grado_flor
and farm.id_farm = item_orden_sin_aprobar.id_farm
and tapa.id_tapa = item_orden_sin_aprobar.id_tapa
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and caja.id_caja = item_orden_sin_aprobar.id_caja

set @perfil = 'Reportes_Fincas'

EXEC msdb.dbo.sp_send_dbmail 
@recipients = @correo_estado,
@subject = @subject1,
@profile_name = @perfil,
@body = @body1,
@body_format = 'TEXT';

select @id_item_orden_sin_aprobar as id_item_orden_sin_aprobar