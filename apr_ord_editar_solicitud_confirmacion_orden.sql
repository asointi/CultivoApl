USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[apr_ord_editar_solicitud_confirmacion_orden]    Script Date: 19/05/2014 10:56:07 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[apr_ord_editar_solicitud_confirmacion_orden]

@id_item_orden_sin_aprobar int,
@id_cuenta_interna int,
@aprobado bit,
@observacion nvarchar(1024)

AS

declare @conteo int,
@id_solicitud_confirmacion_orden int,
@id_farm int,
@numero_solicitud int,
@id_item_orden_sin_aprobar_padre int,
@numero_solicitud_anterior int,
@id_farm_anterior int,
@perfil nvarchar(255),
@numero_solicitud_ant int,
@flor nvarchar(255),
@variedad nvarchar(255),
@grado nvarchar(255),
@tapa nvarchar(255),
@caja nvarchar(255),
@marca nvarchar(255),
@unidades int,
@piezas int,
@composicion nvarchar(1024),
@precio_finca decimal(20,4),
@dia_de_vuelo nvarchar(255),
@indicador_numero_solicitud bit,
@indicador_flor bit,
@indicador_variedad bit,
@indicador_grado bit,
@indicador_tapa bit,
@indicador_caja bit,
@indicador_marca bit,
@indicador_unidades bit,
@indicador_piezas bit,
@indicador_composicion bit,
@indicador_precio_finca bit,
@indicador_dia_de_vuelo bit,
@numero_solicitud_actual int,
@flor_actual nvarchar(255),
@variedad_actual nvarchar(255),
@grado_actual nvarchar(255),
@tapa_actual nvarchar(255),
@caja_actual nvarchar(255),
@marca_actual nvarchar(255),
@unidades_actual int,
@piezas_actual int,
@composicion_actual nvarchar(1024),
@precio_finca_actual decimal(20,4),
@dia_de_vuelo_actual nvarchar(255)

set @perfil = 'Reportes_Fincas'

select @conteo = count(*)
from aprobacion_orden,
item_orden_sin_aprobar,
solicitud_confirmacion_orden
where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden.id_aprobacion_orden = aprobacion_orden.id_aprobacion_orden
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

if(@conteo = 0)
begin
	if(@aprobado = 1)
	begin
		select @id_item_orden_sin_aprobar_padre = item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
		@id_farm_anterior = farm.id_farm
		from item_orden_sin_aprobar,
		farm
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
		and farm.id_farm = item_orden_sin_aprobar.id_farm

		select @numero_solicitud_anterior = max(solicitud_confirmacion_orden.numero_solicitud)
		from item_orden_sin_aprobar,
		aprobacion_orden,
		solicitud_confirmacion_orden,
		confirmacion_orden_cultivo,
		farm
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
		and item_orden_sin_aprobar.id_farm = farm.id_farm
		and farm.id_farm = @id_farm_anterior
		and item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
		and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
		and solicitud_confirmacion_orden.aceptada = 1
		and solicitud_confirmacion_orden.id_solicitud_confirmacion_orden = confirmacion_orden_cultivo.id_solicitud_confirmacion_orden
		and confirmacion_orden_cultivo.aceptada = 1

		select @id_farm = farm.id_farm
		from item_orden_sin_aprobar,
		aprobacion_orden,
		farm
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
		and item_orden_sin_aprobar.id_farm = farm.id_farm
		and aprobacion_orden.aceptada = 1
		and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

		select @numero_solicitud = max(solicitud_confirmacion_orden.numero_solicitud)
		from item_orden_sin_aprobar,
		aprobacion_orden,
		solicitud_confirmacion_orden,
		farm
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
		and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
		and item_orden_sin_aprobar.id_farm = farm.id_farm
		and aprobacion_orden.aceptada = 1
		and solicitud_confirmacion_orden.aceptada = 1
		and farm.id_farm = @id_farm

		if(@numero_solicitud is null)
			set @numero_solicitud = 1
		else
			set @numero_solicitud = @numero_solicitud + 1
	end
	else
	if(@aprobado = 0)
	begin
		set @numero_solicitud = 0
	end

	if(@numero_solicitud_anterior is null)
	begin
		select @numero_solicitud_ant = null,
		@flor = '',
		@variedad = '',
		@grado = '',
		@tapa = '',
		@caja = '',
		@marca = '',
		@unidades = 0,
		@piezas = 0,
		@composicion = '',
		@precio_finca = 0,
		@dia_de_vuelo = '',
		@indicador_numero_solicitud = 0,
		@indicador_flor = 0,
		@indicador_variedad = 0,
		@indicador_grado = 0,
		@indicador_tapa = 0,
		@indicador_caja = 0,
		@indicador_marca = 0,
		@indicador_unidades = 0,
		@indicador_piezas = 0,
		@indicador_composicion = 0,
		@indicador_precio_finca = 0,
		@indicador_dia_de_vuelo = 0
	end
	else
	begin
		select @numero_solicitud_actual = @numero_solicitud,
		@flor_actual = ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
		@variedad_actual = ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
		@grado_actual = ltrim(rtrim(grado_flor.nombre_grado_flor)),
		@tapa_actual = ltrim(rtrim(tapa.nombre_tapa)),
		@caja_actual = ltrim(rtrim(caja.nombre_caja)),
		@marca_actual = item_orden_sin_aprobar.code,
		@unidades_actual = item_orden_sin_aprobar.unidades_por_pieza,
		@piezas_actual = item_orden_sin_aprobar.cantidad_piezas,
		@composicion_actual = item_orden_sin_aprobar.comentario,
		@precio_finca_actual = 
		case
			when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
			else item_orden_sin_aprobar.valor_pactado_cobol
		end,
		@dia_de_vuelo_actual = convert(nvarchar, dbo.calcular_dia_vuelo_orden_fija(item_orden_sin_aprobar.fecha_inicial, farm.idc_farm), 103)
		from item_orden_sin_aprobar,
		farm,
		variedad_flor,
		grado_flor,
		tipo_flor,
		tapa,
		caja
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
		and item_orden_sin_aprobar.id_farm = farm.id_farm
		and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
		and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
		and item_orden_sin_aprobar.id_caja = caja.id_caja

		select @numero_solicitud_ant = solicitud_confirmacion_orden.numero_solicitud,
		@flor = ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
		@variedad = ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
		@grado = ltrim(rtrim(grado_flor.nombre_grado_flor)),
		@tapa = ltrim(rtrim(tapa.nombre_tapa)),
		@caja = ltrim(rtrim(caja.nombre_caja)),
		@marca = item_orden_sin_aprobar.code,
		@unidades = item_orden_sin_aprobar.unidades_por_pieza,
		@piezas = item_orden_sin_aprobar.cantidad_piezas,
		@composicion = item_orden_sin_aprobar.comentario,
		@precio_finca = 
		case
			when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
			else item_orden_sin_aprobar.valor_pactado_cobol
		end,
		@dia_de_vuelo = datename(dw, dbo.calcular_dia_vuelo_orden_fija(item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)),
		@indicador_numero_solicitud = 1,
		@indicador_flor = 
		case
			when ltrim(rtrim(tipo_flor.nombre_tipo_flor)) = @flor_actual then 0
			else 1
		end,
		@indicador_variedad = 
		case
			when ltrim(rtrim(variedad_flor.nombre_variedad_flor)) = @variedad_actual then 0
			else 1
		end,
		@indicador_grado = 
		case
			when ltrim(rtrim(grado_flor.nombre_grado_flor)) = @grado_actual then 0
			else 1
		end,
		@indicador_tapa = 
		case
			when ltrim(rtrim(tapa.nombre_tapa)) = @tapa_actual then 0
			else 1
		end,
		@indicador_caja = 
		case
			when ltrim(rtrim(caja.nombre_caja)) = @caja_actual then 0
			else 1
		end,
		@indicador_marca = 
		case
			when item_orden_sin_aprobar.code = @marca_actual then 0
			else 1
		end,
		@indicador_unidades = 
		case
			when item_orden_sin_aprobar.unidades_por_pieza = @unidades_actual then 0
			else 1
		end,
		@indicador_piezas = 
		case
			when item_orden_sin_aprobar.cantidad_piezas = @piezas_actual then 0
			else 1
		end,
		@indicador_composicion =
		case
			when item_orden_sin_aprobar.comentario = @composicion_actual then 0
			else 1
		end,		
		@indicador_precio_finca =
		case
			when 
				(
				case
					when item_orden_sin_aprobar.valor_pactado_interno is not null then item_orden_sin_aprobar.valor_pactado_interno
					else item_orden_sin_aprobar.valor_pactado_cobol
				end
				) =  @precio_finca_actual then 0
			else 1
		end,		
		@indicador_dia_de_vuelo = 
		case
			when datepart(dw, dbo.calcular_dia_vuelo_orden_fija(item_orden_sin_aprobar.fecha_inicial, farm.idc_farm)) = datepart(dw, convert(datetime,@dia_de_vuelo_actual)) then 0
			else 1
		end
		from item_orden_sin_aprobar,
		aprobacion_orden,
		solicitud_confirmacion_orden,
		farm,
		variedad_flor,
		grado_flor,
		tipo_flor,
		tapa,
		caja
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
		and aprobacion_orden.id_aprobacion_orden = solicitud_confirmacion_orden.id_aprobacion_orden
		and solicitud_confirmacion_orden.numero_solicitud = @numero_solicitud_anterior
		and item_orden_sin_aprobar.id_farm = farm.id_farm
		and farm.id_farm = @id_farm_anterior
		and item_orden_sin_aprobar.id_variedad_flor = variedad_flor.id_variedad_flor
		and item_orden_sin_aprobar.id_grado_flor = grado_flor.id_grado_flor
		and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
		and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
		and item_orden_sin_aprobar.id_tapa = tapa.id_tapa
		and item_orden_sin_aprobar.id_caja = caja.id_caja
		and item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre = @id_item_orden_sin_aprobar_padre
	end

	insert into solicitud_confirmacion_orden (id_aprobacion_orden, id_cuenta_interna, aceptada, observacion, numero_solicitud)
	select aprobacion_orden.id_aprobacion_orden, cuenta_interna.id_cuenta_interna, @aprobado, @observacion, @numero_solicitud
	from aprobacion_orden,
	item_orden_sin_aprobar,
	cuenta_interna
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = aprobacion_orden.id_item_orden_sin_aprobar
	and aprobacion_orden.aceptada = 1
	and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar	
	and cuenta_interna.id_cuenta_interna = @id_cuenta_interna	

	set @id_solicitud_confirmacion_orden = scope_identity()

	update solicitud_confirmacion_orden
	set id_solicitud_confirmacion_orden_padre = @id_solicitud_confirmacion_orden
	where id_solicitud_confirmacion_orden = @id_solicitud_confirmacion_orden

	select @numero_solicitud as numero_solicitud,
	case
		when @numero_solicitud_anterior is null then 'Nueva'
		when @numero_solicitud_anterior is not null then 'Modificada. Anula y reemplaza la número ' +  convert(nvarchar, @numero_solicitud_anterior)
	end as subject,
	case
		when @numero_solicitud_anterior is null then ''
		when @numero_solicitud_anterior is not null then 'Por favor tenga en cuenta que esta es una modificación a una orden fija ya existente y que NO ES UNA ORDEN FIJA NUEVA'
	end as nota_aclaratoria,
	'STD'+upper(farm.idc_farm)+dbo.longitud_codigo(@numero_solicitud) as codigo_referencia,
	case
		when @numero_solicitud_anterior = 0 then 1
		else @numero_solicitud_ant
	end as numero_solicitud_anterior,
	@flor as flor_anterior,
	@variedad as variedad_anterior,
	@grado as grado_anterior,
	@tapa as tapa_anterior,
	@caja as caja_anterior,
	@marca as marca_anterior,
	@unidades as unidades_anterior,
	@piezas as piezas_anterior,
	@composicion as composicion_anterior,
	@precio_finca as precio_finca_anterior,
	@dia_de_vuelo as dia_de_vuelo_anterior,
	@indicador_numero_solicitud as indicador_numero_solicitud,
	@indicador_flor as indicador_flor,
	@indicador_variedad as indicador_variedad,
	@indicador_grado as indicador_grado,
	@indicador_tapa as indicador_tapa,
	@indicador_caja as indicador_caja,
	@indicador_marca as indicador_marca,
	@indicador_unidades as indicador_unidades,
	@indicador_piezas as indicador_piezas,
	@indicador_composicion as indicador_composicion,
	@indicador_precio_finca as indicador_precio_finca,
	@indicador_dia_de_vuelo as indicador_dia_de_vuelo,
	'' as aviso_alterno
	from farm
	where farm.id_farm = @id_farm

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
	@usuario nvarchar(255)
	
	select @nombre_cliente = ltrim(rtrim(nombre_cliente)) + space(1) + '[' + idc_cliente_despacho + ']' ,
	@nombre_transportador = ltrim(rtrim(nombre_transportador)) + space(1) + '[' + idc_transportador + ']',
	@nombre_tipo_flor = ltrim(rtrim(nombre_tipo_flor)) + space(1) + '[' + idc_tipo_flor + ']',
	@nombre_variedad_flor = ltrim(rtrim(nombre_variedad_flor)) + space(1) + '[' + idc_variedad_flor + ']',
	@nombre_grado_flor = ltrim(rtrim(nombre_grado_flor)) + space(1) + '[' + idc_grado_flor + ']',
	@nombre_farm = ltrim(rtrim(nombre_farm)) + space(1) + '[' + idc_farm + ']',
	@nombre_tapa = ltrim(rtrim(nombre_tapa)) + space(1) + '[' + idc_tapa + ']',
	@nombre_tipo_caja = ltrim(rtrim(nombre_tipo_caja)) + space(1) + '[' + idc_tipo_caja + ']',
	@fecha_creacion_item = solicitud_confirmacion_orden.fecha_grabacion,
	@correo = isnull(vendedor.correo,''),
	@code = item_orden_sin_aprobar.code,
	@comentario = item_orden_sin_aprobar.comentario,
	@fecha_inicial = item_orden_sin_aprobar.fecha_inicial,
	@unidades_por_pieza = item_orden_sin_aprobar.unidades_por_pieza,
	@cantidad_piezas = item_orden_sin_aprobar.cantidad_piezas,
	@usuario = cuenta_interna.nombre
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
	aprobacion_orden,
	cuenta_interna,
	solicitud_confirmacion_orden
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
	and cuenta_interna.id_cuenta_interna = @id_cuenta_interna
	and solicitud_confirmacion_orden.id_aprobacion_orden = aprobacion_orden.id_aprobacion_orden

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
	@body1 varchar(max),
	@correo_adicional nvarchar(50)

	set @correo_adicional = ''
	
	if(@conteo = 0)
	begin
		if(@aprobado = 1)
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'No Farm Confirmed'

			set @correo_estado = @correo + ';' + @correo_estado

			set @subject1 = 'Standing Order Pending Farm Confirmation'
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
						'Last Modified by: ' + space(1) + @usuario + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item)
		end
		else
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Not Sent to Farm'

			select @correo_estado = correo + ';' + @correo_estado
			from correo_estado
			where nombre_estado = 'Without Approval'

			set @correo_estado = @correo + ';' + @correo_estado + ';' + @correo_adicional

			set @subject1 = 'Standing Order RETURNED'
			set @body1 ='Not Sent to Farm' + char(13) +
						'Last Modified by: ' + space(1) + @usuario + char(13) +
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
			where nombre_estado = 'No Farm Confirmed'

			set @correo_estado = @correo + ';' + @correo_estado

			set @subject1 = 'Standing Order Pending Farm Confirmation - Modification'
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
						'Last Modified by: ' + space(1) + @usuario + char(13) +
						'Last Modified Date: ' + space(1) + convert(nvarchar,@fecha_creacion_item)
		end
		else
		begin
			select @correo_estado = correo
			from correo_estado
			where nombre_estado = 'Not Sent to Farm'

			select @correo_estado = correo + ';' + @correo_estado
			from correo_estado
			where nombre_estado = 'Without Approval'

			set @correo_estado = @correo + ';' + @correo_estado + ';' + @correo_adicional

			set @subject1 = 'Standing Order RETURNED'
			set @body1 ='Not Sent to Farm' + char(13) +
						'Last Modified by: ' + space(1) + @usuario + char(13) +
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

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients = @correo_estado,
		@subject = @subject1,
		@profile_name = @perfil,
		@body = @body1,
		@body_format = 'TEXT' ;
end