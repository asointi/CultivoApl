set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[opc_crear_etiqueta] 

@accion nvarchar(255),
@id_cuenta_interna int, 
@numero_remision nvarchar(25),
@id_detalle_orden_pedido_cultivo int,
@id_despacho_orden_pedido_cultivo int,
@id_recibo_flor int,
@id_comprador int = null

as

if(@accion = 'insertar_numero_remision')
begin
	declare @conteo int

	select @id_recibo_flor = id_recibo_flor
	from recibo_flor
	where numero_remision = @numero_remision

	if(@id_recibo_flor is null)
	begin
		insert into recibo_flor (id_cuenta_interna, numero_remision)
		values (@id_cuenta_interna, @numero_remision)

		select @id_recibo_flor = scope_identity()
	end

	select @id_recibo_flor as id_recibo_flor
end
else
if(@accion = 'insertar_etiqueta')
begin
	declare @idc_farm nvarchar(2),
	@idc_tipo_flor nvarchar(2),
	@idc_variedad_flor nvarchar(2),
	@idc_grado_flor nvarchar(2),
	@idc_tapa nvarchar(2),
	@idc_caja nvarchar(2),
	@code nvarchar(10),
	@unidades_por_pieza int,
	@fecha_inicial datetime,
	@cantidad_piezas int,
	@user nvarchar(255),
	@fecha_actual datetime

	create table #temp
	(
		id_etiqueta int
	)

	set @user = 'etiquetasweb@natuflora.net'
	set @fecha_actual = getdate()

	if(@id_despacho_orden_pedido_cultivo = 0)
	begin
		insert into despacho_orden_pedido_cultivo (id_cuenta_interna, id_detalle_orden_pedido_cultivo, id_estado_despacho_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, fecha_estimada_recibo_flor, cantidad_piezas)
		select @id_cuenta_interna, 
		detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo, 
		estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo, 
		detalle_orden_pedido_cultivo.id_variedad_flor, 
		detalle_orden_pedido_cultivo.id_grado_flor, 
		detalle_orden_pedido_cultivo.fecha_inicial, 
		detalle_orden_pedido_cultivo.cantidad_piezas
		from detalle_orden_pedido_cultivo,
		estado_despacho_orden_pedido_cultivo
		where detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = @id_detalle_orden_pedido_cultivo
		and estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'

		set @id_despacho_orden_pedido_cultivo = scope_identity()
	end

	select @idc_farm = farm.idc_farm,
	@idc_tipo_flor = tipo_flor.idc_tipo_flor,
	@idc_variedad_flor = variedad_flor.idc_variedad_flor,
	@idc_grado_flor = grado_flor.idc_grado_flor,
	@idc_tapa = tapa.idc_tapa,
	@idc_caja = tipo_caja.idc_tipo_caja + caja.idc_caja,
	@code = detalle_orden_pedido_cultivo.marca,
	@unidades_por_pieza = detalle_orden_pedido_cultivo.unidades_por_pieza,
	@fecha_inicial = despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
	@cantidad_piezas = despacho_orden_pedido_cultivo.cantidad_piezas
	from orden_pedido_cultivo,
	detalle_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	tipo_caja,
	caja
	where orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and farm.id_farm = orden_pedido_cultivo.id_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
	and tapa.id_tapa = detalle_orden_pedido_cultivo.id_tapa
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and caja.id_caja = detalle_orden_pedido_cultivo.id_caja
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = @id_despacho_orden_pedido_cultivo

	while (@cantidad_piezas > 0)
	begin
		insert into #temp (id_etiqueta)
		exec wbl_crear_etiqueta
		@cod = '',
		@farm = @idc_farm,
		@tipo = @idc_tipo_flor,
		@variedad = @idc_variedad_flor,
		@grado = @idc_grado_flor,
		@tapa = @idc_tapa,
		@tipo_caja = @idc_caja,
		@marca = @code,
		@unidades_caja = @unidades_por_pieza,
		@usuario  = @user,
		@fecha = @fecha_inicial,
		@fecha_digita = @fecha_actual

		set @cantidad_piezas = @cantidad_piezas - 1
	end

	insert into etiqueta_orden_pedido_cultivo (codigo, id_despacho_orden_pedido_cultivo, id_recibo_flor)
	select etiqueta.codigo,
	@id_despacho_orden_pedido_cultivo,
	@id_recibo_flor
	from etiqueta,
	#temp
	where etiqueta.id_etiqueta = #temp.id_etiqueta

	select id_etiqueta from #temp

	drop table #temp
end
else
if(@accion = 'consultar_numero_remision')
begin
	select detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo,
	farm.id_farm,
	ltrim(rtrim(farm.nombre_farm)) + ' [' + farm.idc_farm + ']' as nombre_farm,
	orden_pedido_cultivo.descripcion as descripcion_pedido,
	orden_pedido_cultivo.numero_consecutivo,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	tapa.id_tapa,
	ltrim(rtrim(tapa.nombre_tapa)) + ' [' + tapa.idc_tapa + ']' as nombre_tapa,
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)) + ' [' + tipo_caja.idc_tipo_caja + caja.idc_caja + ']' as nombre_caja,
	detalle_orden_pedido_cultivo.marca,
	despacho_orden_pedido_cultivo.fecha_estimada_recibo_flor,
	detalle_orden_pedido_cultivo.unidades_por_pieza,
	despacho_orden_pedido_cultivo.cantidad_piezas,
	detalle_orden_pedido_cultivo.valor_unitario,
	detalle_orden_pedido_cultivo.comentario as comentario_detalle_pedido,
	etiqueta.* 
	from detalle_orden_pedido_cultivo,
	despacho_orden_pedido_cultivo,
	orden_pedido_cultivo,
	estado_despacho_orden_pedido_cultivo,
	etiqueta_orden_pedido_cultivo,
	etiqueta,
	recibo_flor,
	comprador,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	caja,
	tipo_caja
	where orden_pedido_cultivo.id_orden_pedido_cultivo = detalle_orden_pedido_cultivo.id_orden_pedido_cultivo
	and detalle_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_detalle_orden_pedido_cultivo
	and farm.id_farm = orden_pedido_cultivo.id_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = despacho_orden_pedido_cultivo.id_variedad_flor
	and grado_flor.id_grado_flor = despacho_orden_pedido_cultivo.id_grado_flor
	and tapa.id_tapa = detalle_orden_pedido_cultivo.id_tapa
	and caja.id_caja = detalle_orden_pedido_cultivo.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and comprador.id_comprador = orden_pedido_cultivo.id_comprador
	and comprador.id_comprador = @id_comprador
	and estado_despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo = despacho_orden_pedido_cultivo.id_estado_despacho_orden_pedido_cultivo
	and estado_despacho_orden_pedido_cultivo.nombre_estado_orden_pedido = 'Reprogramada'
	and despacho_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo = etiqueta_orden_pedido_cultivo.id_despacho_orden_pedido_cultivo
	and recibo_flor.id_recibo_flor = etiqueta_orden_pedido_cultivo.id_recibo_flor
	and etiqueta.codigo = etiqueta_orden_pedido_cultivo.codigo
	and recibo_flor.numero_remision = @numero_remision
end