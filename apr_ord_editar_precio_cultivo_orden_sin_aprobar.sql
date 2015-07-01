/****** Object:  StoredProcedure [dbo].[wbl_editar_usuarios]    Script Date: 10/06/2007 12:37:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[apr_ord_editar_precio_cultivo_orden_sin_aprobar]

@id_item_orden_sin_aprobar int,
@valor_pactado decimal(20,4),
@usuario_cobol nvarchar(255),
@observacion nvarchar(255),
@aprobado int

AS

declare @conteo int,
@id_precio_cultivo_orden_sin_aprobar int,
@nombre_base_datos nvarchar(50)

set @nombre_base_datos = DB_NAME()

select @conteo = count(*)
from precio_cultivo_orden_sin_aprobar
where precio_cultivo_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

if(@conteo = 0)
begin
	insert into precio_cultivo_orden_sin_aprobar (id_item_orden_sin_aprobar, valor_pactado, usuario_cobol, aceptada, observacion)
	values (@id_item_orden_sin_aprobar, @valor_pactado, @usuario_cobol, convert(bit,@aprobado), @observacion)

	set @id_precio_cultivo_orden_sin_aprobar = scope_identity()

	update precio_cultivo_orden_sin_aprobar
	set id_precio_cultivo_orden_sin_aprobar_padre = @id_precio_cultivo_orden_sin_aprobar
	where id_precio_cultivo_orden_sin_aprobar = @id_precio_cultivo_orden_sin_aprobar

	select @id_precio_cultivo_orden_sin_aprobar as id_precio_cultivo_orden_sin_aprobar

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
	@cantidad_piezas int,
	@observacion_rechazo nvarchar(1024)
	
	select @nombre_cliente = ltrim(rtrim(nombre_cliente)) + space(1) + '[' + idc_cliente_despacho + ']' ,
	@nombre_transportador = ltrim(rtrim(nombre_transportador)) + space(1) + '[' + idc_transportador + ']',
	@nombre_tipo_flor = ltrim(rtrim(nombre_tipo_flor)) + space(1) + '[' + idc_tipo_flor + ']',
	@nombre_variedad_flor = ltrim(rtrim(nombre_variedad_flor)) + space(1) + '[' + idc_variedad_flor + ']',
	@nombre_grado_flor = ltrim(rtrim(nombre_grado_flor)) + space(1) + '[' + idc_grado_flor + ']',
	@nombre_farm = ltrim(rtrim(nombre_farm)) + space(1) + '[' + idc_farm + ']',
	@nombre_tapa = ltrim(rtrim(nombre_tapa)) + space(1) + '[' + idc_tapa + ']',
	@nombre_tipo_caja = ltrim(rtrim(nombre_tipo_caja)) + space(1) + '[' + idc_tipo_caja + ']',
	@fecha_creacion_item = precio_cultivo_orden_sin_aprobar.fecha_grabacion,
	@correo = vendedor.correo,
	@code = item_orden_sin_aprobar.code,
	@comentario = item_orden_sin_aprobar.comentario,
	@fecha_inicial = item_orden_sin_aprobar.fecha_inicial,
	@unidades_por_pieza = item_orden_sin_aprobar.unidades_por_pieza,
	@cantidad_piezas = item_orden_sin_aprobar.cantidad_piezas,
	@observacion_rechazo = precio_cultivo_orden_sin_aprobar.observacion
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
	precio_cultivo_orden_sin_aprobar
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
	and precio_cultivo_orden_sin_aprobar.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor

	select @conteo = count(*)
	from item_orden_sin_aprobar,
	precio_cultivo_orden_sin_aprobar,
	aprobacion_orden,
	solicitud_confirmacion_orden,
	confirmacion_orden_cultivo,
	orden_confirmada,
	orden_pedido
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = precio_cultivo_orden_sin_aprobar.id_item_orden_sin_aprobar
	and precio_cultivo_orden_sin_aprobar.id_precio_cultivo_orden_sin_aprobar = aprobacion_orden.id_precio_cultivo_orden_sin_aprobar
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
	@body1 varchar(2048)

	if(@conteo = 0)
	begin
		if(@aprobado = 1)
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Without Approval'

			set @correo_estado = @correo + ';' + @correo_estado

			set @subject1 = 'Order Pending Approval'
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
						'Farm Price: ' + space(1) + convert(nvarchar,@valor_pactado) + char(13) +
						'Last Modified by: ' + space(1) + @usuario_cobol + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item)
		end
		else
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Without farm price'
			
			set @correo_estado = @correo + ';' + @correo_estado

			set @subject1 = 'Order RETURNED'
			set @body1 ='Without Farm Price' + char(13) +
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
						'Pieces: ' + space(1) + convert(nvarchar,@cantidad_piezas) + char(13) +
						'Farm Price: ' + space(1) + convert(nvarchar,@valor_pactado) + char(13)
		end
	end
	else
	begin
		if(@aprobado = 1)
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Without Approval'

			set @correo_estado = @correo + ';' + @correo_estado

			set @subject1 = 'Order Pending Approval - S.O. Modification'
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
						'Farm Price: ' + space(1) + convert(nvarchar,@valor_pactado) + char(13) +
						'Last Modified by: ' + space(1) + @usuario_cobol + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item)
		end
		else
		begin
			declare @correo_adicional nvarchar(50)

			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Without farm price'
			
			if(@nombre_base_datos = 'BD_NF')
			begin
				set @correo_adicional = 'richard@nflowers.com;facturasmia@nflowers.com'	
			end
			else
			begin
				set @correo_adicional = 'invoicesmiami@frescafarms.com'
			end

			set @correo_estado = @correo + ';' + @correo_estado + ';' + @correo_adicional

			set @subject1 = 'Order RETURNED'
			set @body1 ='Without Farm Price' + char(13) +
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
						'Pieces: ' + space(1) + convert(nvarchar,@cantidad_piezas) + char(13) +
						'Farm Price: ' + space(1) + convert(nvarchar,@valor_pactado) + char(13)
		end
	end

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @correo_estado,
		@subject = @subject1,
		@body = @body1,
		@body_format = 'TEXT' ;
end