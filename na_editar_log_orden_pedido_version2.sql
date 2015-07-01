USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[na_editar_log_orden_pedido_version2]    Script Date: 11/12/2014 10:14:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_editar_log_orden_pedido_version2]

@idc_orden_pedido nvarchar(20),
@usuario_cobol nvarchar(50),
@accion nvarchar(50),
@fecha_inicial datetime,
@fecha_final datetime,
@observacion nvarchar(1024)

as

if(@accion = 'insertar')
begin
	insert into log_orden_pedido (usuario_cobol, idc_orden_pedido, observacion)
	values (@usuario_cobol, @idc_orden_pedido, @observacion)

	declare @nombre_cliente nvarchar(100),
	@nombre_transportador nvarchar(100),
	@nombre_tipo_flor nvarchar(100),
	@nombre_variedad_flor nvarchar(100),
	@nombre_grado_flor nvarchar(100),
	@nombre_farm nvarchar(100),
	@nombre_tapa nvarchar(100),
	@nombre_tipo_caja nvarchar(100),
	@code nvarchar(20),
	@comentario nvarchar(512),
	@fecha_inicial_orden datetime,
	@unidades_por_pieza int,
	@cantidad_piezas int,
	@correo_vendedor nvarchar(100),
	@correo_adicional nvarchar(512),
	@subject1 nvarchar(512),
	@body1 nvarchar(max),
	@perfil nvarchar(100)

	select @nombre_cliente = ltrim(rtrim(cliente_despacho.nombre_cliente)) + space(1) + '[' + ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) + ']',
	@nombre_transportador = ltrim(rtrim(transportador.nombre_transportador)) + space(1) + '[' + ltrim(rtrim(transportador.idc_transportador)) + ']',
	@nombre_tipo_flor = ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + ltrim(rtrim(tipo_flor.idc_tipo_flor)) + ']',
	@nombre_variedad_flor = ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + ltrim(rtrim(variedad_flor.idc_variedad_flor)) + ']',
	@nombre_grado_flor = ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + ltrim(rtrim(grado_flor.idc_grado_flor)) + ']',
	@nombre_farm = ltrim(rtrim(farm.nombre_farm)) + space(1) + '[' + ltrim(rtrim(farm.idc_farm)) + ']',
	@nombre_tapa = ltrim(rtrim(tapa.nombre_tapa)) + space(1) + '[' + ltrim(rtrim(tapa.idc_tapa)) + ']',
	@nombre_tipo_caja = ltrim(rtrim(tipo_caja.nombre_tipo_caja)) + space(1) + '[' + ltrim(rtrim(tipo_caja.idc_tipo_caja)) + ']',
	@code = orden_pedido.marca,
	@comentario = isnull(orden_pedido.comentario, ''),
	@fecha_inicial_orden  = 
	case
		when orden_pedido.fecha_inicial = convert(datetime, '1999/01/01') then orden_pedido.fecha_para_aprobar
		else orden_pedido.fecha_inicial
	end,
	@unidades_por_pieza  = orden_pedido.unidades_por_pieza,
	@cantidad_piezas = orden_pedido.cantidad_piezas,
	@correo_vendedor = vendedor.correo
	from orden_pedido,
	cliente_despacho,
	transportador,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	tapa,
	cliente_factura,
	vendedor,
	tipo_caja
	where convert(int,idc_orden_pedido) = convert(int,@idc_orden_pedido)
	and cliente_despacho.id_despacho = orden_pedido.id_despacho
	and transportador.id_transportador = orden_pedido.id_transportador
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and farm.id_farm = orden_pedido.id_farm
	and tapa.id_tapa = orden_pedido.id_tapa
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja

	set @perfil = 'Reportes_Fincas'

	/*Correos configurados para Fresca*/
	/*en Natural NO hay correos adicionales*/
	--set @correo_adicional = 'karen@frescafarms.com;julia@frescafarms.com;dpineros@natuflora.net'

	set @subject1 = 'Order CANCELED'
	set @body1 ='SO Number: ' + space(1) + @idc_orden_pedido + char(13) +  
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
				'Initial Date: ' + space(1) + convert(nvarchar,@fecha_inicial_orden,101) + char(13) +
				'Pack: ' + space(1) + convert(nvarchar,@unidades_por_pieza) + char(13) +
				'Pieces: ' + space(1) + convert(nvarchar,@cantidad_piezas) + char(13) +
				'Canceled by: ' + space(1) + @usuario_cobol + char(13) +
				'Observation: ' + space(1) + @observacion

	EXEC msdb.dbo.sp_send_dbmail 
	@recipients = @correo_vendedor,
	@blind_copy_recipients = @correo_adicional,
	@subject = @subject1,
	@profile_name = @perfil,
	@body = @body1,
	@body_format = 'HTML';

	select 1 as resultado
end
else
if(@accion = 'consultar')
begin
	select log_orden_pedido.id_log_orden_pedido,
	log_orden_pedido.idc_orden_pedido,
	log_orden_pedido.usuario_cobol,
	log_orden_pedido.fecha_transaccion,
	log_orden_pedido.observacion
	from log_orden_pedido
	where convert(int,idc_orden_pedido) > =
	case
		when @idc_orden_pedido = '' then 0 
		else convert(int,@idc_orden_pedido)
	end
	and convert(int,idc_orden_pedido) < =
	case
		when @idc_orden_pedido = '' then 999999999 
		else convert(int,@idc_orden_pedido)
	end
	and convert(datetime,convert(nvarchar, fecha_transaccion, 101)) between
	@fecha_inicial and @fecha_final
	order by log_orden_pedido.fecha_transaccion
end