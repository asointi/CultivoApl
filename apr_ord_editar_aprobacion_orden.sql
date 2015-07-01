set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[apr_ord_editar_aprobacion_orden]

@id_item_orden_sin_aprobar int,
@usuario_cobol nvarchar(255),
@observacion nvarchar(255),
@aprobado int

AS

declare @conteo int,
@id_aprobacion_orden int,
@perfil nvarchar(255)

set @perfil = 'Notificaciones SQL'

select @conteo = count(*)
from aprobacion_orden,
item_orden_sin_aprobar
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

if(@conteo = 0)
begin
	insert into aprobacion_orden (id_item_orden_sin_aprobar, usuario_cobol, aceptada, observacion)
	select item_orden_sin_aprobar.id_item_orden_sin_aprobar, @usuario_cobol, convert(bit,@aprobado), @observacion
	from item_orden_sin_aprobar
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar	

	set @id_aprobacion_orden = scope_identity()

	update aprobacion_orden
	set id_aprobacion_orden_padre = @id_aprobacion_orden
	where id_aprobacion_orden = @id_aprobacion_orden

	select @id_aprobacion_orden as id_aprobacion_orden

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
	@nombre_tipo_caja nvarchar(255),
	@code nvarchar(255),
	@comentario nvarchar(255),
	@fecha_inicial datetime,
	@unidades_por_pieza int,
	@cantidad_piezas int
	
	select @nombre_cliente = ltrim(rtrim(nombre_cliente)) + space(1) + '[' + idc_cliente_despacho + ']' ,
	@nombre_transportador = ltrim(rtrim(nombre_transportador)) + space(1) + '[' + idc_transportador + ']',
	@nombre_tipo_flor = ltrim(rtrim(nombre_tipo_flor)) + space(1) + '[' + idc_tipo_flor + ']',
	@nombre_variedad_flor = ltrim(rtrim(nombre_variedad_flor)) + space(1) + '[' + idc_variedad_flor + ']',
	@nombre_grado_flor = ltrim(rtrim(nombre_grado_flor)) + space(1) + '[' + idc_grado_flor + ']',
	@nombre_farm = ltrim(rtrim(nombre_farm)) + space(1) + '[' + idc_farm + ']',
	@nombre_tapa = ltrim(rtrim(nombre_tapa)) + space(1) + '[' + idc_tapa + ']',
	@nombre_tipo_caja = ltrim(rtrim(nombre_tipo_caja)) + space(1) + '[' + idc_tipo_caja + ']',
	@fecha_creacion_item = aprobacion_orden.fecha_aprobacion,
	@correo = vendedor.correo,
	@code = item_orden_sin_aprobar.code,
	@comentario = item_orden_sin_aprobar.comentario,
	@fecha_inicial = item_orden_sin_aprobar.fecha_inicial,
	@unidades_por_pieza = item_orden_sin_aprobar.unidades_por_pieza,
	@cantidad_piezas = item_orden_sin_aprobar.cantidad_piezas
	from item_orden_sin_aprobar,
	orden_sin_aprobar,
	cliente_despacho,
	cliente_factura,
	vendedor,
	transportador,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	tapa,
	tipo_caja,
	caja,
	aprobacion_orden
	where tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
	and orden_sin_aprobar.id_despacho = cliente_despacho.id_despacho
	and item_orden_sin_aprobar.id_transportador = transportador.id_transportador
	and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
	and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and item_orden_sin_aprobar.id_farm = farm.id_farm
	and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
	and item_orden_sin_aprobar.id_caja = caja.id_caja
	and aprobacion_orden.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor
	
	select @conteo = count(*)
	from item_orden_sin_aprobar,
	aprobacion_orden,
	solicitud_confirmacion_orden,
	confirmacion_orden_cultivo,
	orden_confirmada,
	orden_pedido
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
	and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
	and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
	and confirmacion_orden_cultivo.id_confirmacion_orden_cultivo = orden_confirmada.id_confirmacion_orden_cultivo
	and orden_confirmada.id_orden_pedido = orden_pedido.id_orden_pedido
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = 
	(
		select id_item_orden_sin_aprobar_padre
		from item_orden_sin_aprobar
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
	)

	declare @subject1 varchar(200),
	@body1 varchar(2048),
	@correo_adicional nvarchar(50)

	set @correo_adicional = 'stefano@frescafarms.com'

	if(@conteo = 0)
	begin
		if(@aprobado = 1)
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Not Sent to Farm'

			set @correo_estado = @correo + ';' + @correo_estado

			set @subject1 = 'Standing Order pending to be sent to farm'
			set @body1 = 'Ship to: ' + space(1) + @nombre_cliente + char(13) +
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
						'Last Modified by: ' + space(1) + @usuario_cobol + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item)
		end
		else
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Without Approval'

			set @correo_estado = @correo + ';' + @correo_estado + ';' + @correo_adicional

			set @subject1 = 'Standing Order RETURNED'
			set @body1 ='Without Approval' + char(13) +
						'Last Modified by: ' + space(1) + @usuario_cobol + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item) + char(13) +
						'Description: ' + space(1) + @observacion + char(13) + char(13) +

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
						'Pieces: ' + space(1) + convert(nvarchar,@cantidad_piezas) + char(13)
			set @perfil = 'Reportes_Fincas'
		end
	end
	else
	begin
		if(@aprobado = 1)
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Not Sent to Farm'

			set @correo_estado = @correo + ';' + @correo_estado

			set @subject1 = 'Standing Order pending to be sent to farm - Modification'
			set @body1 = 'Ship to: ' + space(1) + @nombre_cliente + char(13) +
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
						'Last Modified by: ' + space(1) + @usuario_cobol + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item)
		end
		else
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Without Approval'

			set @correo_estado = @correo + ';' + @correo_estado + ';' + @correo_adicional

			set @subject1 = 'Standing Order RETURNED'
			set @body1 ='Without Approval' + char(13) +
						'Last Modified by: ' + space(1) + @usuario_cobol + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item) + char(13) +
						'Description: ' + space(1) + @observacion + char(13) + char(13) +

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
						'Pieces: ' + space(1) + convert(nvarchar,@cantidad_piezas) + char(13)

			set @perfil = 'Reportes_Fincas'
		end
	end
		EXEC msdb.dbo.sp_send_dbmail @recipients = @correo_estado,
		@subject = @subject1,
		@profile_name = @perfil,
		@body = @body1,
		@body_format = 'TEXT' ;
end

