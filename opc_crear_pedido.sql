set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[opc_crear_pedido] 

@accion nvarchar(50),
@id_cuenta_interna int, 
@id_farm int, 
@descripcion nvarchar(1024), 
@id_comprador int,
@id_orden_pedido_cultivo int, 
@id_variedad_flor int, 
@id_grado_flor int, 
@id_tapa int, 
@id_caja int, 
@marca nvarchar(5), 
@fecha_inicial datetime, 
@fecha_final datetime, 
@unidades_por_pieza int, 
@cantidad_piezas int, 
@valor_unitario decimal(20,4), 
@comentario nvarchar(1024)

as

if(@accion = 'consultar_comprador')
begin
	select id_comprador,
	nombre_comprador 
	from comprador
	order by nombre_comprador
end
else
if(@accion = 'insertar_pedido')
begin
	declare @numero_consecutivo int

	select @numero_consecutivo  = orden_pedido_cultivo.numero_consecutivo 
	from comprador,
	proveedor,
	orden_pedido_cultivo
	where proveedor.nombre_proveedor = 'Genérico'
	and comprador.id_comprador = orden_pedido_cultivo.id_comprador
	and comprador.id_comprador = @id_comprador
	and proveedor.id_proveedor = orden_pedido_cultivo.id_proveedor

	if(@numero_consecutivo is null)
	begin
		set @numero_consecutivo = 1
	end
	else
	begin
		set @numero_consecutivo = @numero_consecutivo +1 
	end

	insert into orden_pedido_cultivo (id_cuenta_interna, id_comprador, id_proveedor, id_farm, descripcion, numero_consecutivo)
	select @id_cuenta_interna, 
	@id_comprador, 
	proveedor.id_proveedor, 
	@id_farm, 
	@descripcion, 
	@numero_consecutivo
	from proveedor
	where proveedor.nombre_proveedor = 'Genérico'
	
	set @id_orden_pedido_cultivo = scope_identity() 

	select @id_orden_pedido_cultivo as id_orden_pedido_cultivo,
	@numero_consecutivo as numero_consecutivo
end
else
if(@accion = 'insertar_detalle_pedido')
begin
	insert into detalle_orden_pedido_cultivo (id_orden_pedido_cultivo, id_variedad_flor, id_grado_flor, id_tapa, id_caja, marca, fecha_inicial, fecha_final, unidades_por_pieza, cantidad_piezas, valor_unitario, comentario)
	values (@id_orden_pedido_cultivo, @id_variedad_flor, @id_grado_flor, @id_tapa, @id_caja, @marca, @fecha_inicial, @fecha_final, @unidades_por_pieza, @cantidad_piezas, @valor_unitario, @comentario)

	select scope_identity() as id_detalle_orden_pedido_cultivo
end
else
if(@accion = 'consultar_productos')
begin
	select tipo_flor.id_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	tapa.id_tapa,
	tapa.idc_tapa + ' [' + ltrim(rtrim(tapa.nombre_tapa)) + ']' as nombre_tapa,
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)) + ' [' + tipo_caja.idc_tipo_caja + caja.idc_caja + '] (' + ltrim(rtrim(caja.medida)) + ')' as nombre_caja,
	detalle_producto_farm.unidades_por_pieza
	from detalle_producto_farm,
	farm,
	grado_flor,
	tipo_flor,
	tapa,
	caja,
	tipo_caja
	where tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and farm.id_farm = detalle_producto_farm.id_farm
	and farm.id_farm = @id_farm
	and grado_flor.id_grado_flor = detalle_producto_farm.id_grado_flor
	and tipo_flor.id_tipo_flor = detalle_producto_farm.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tapa.id_tapa = detalle_producto_farm.id_tapa
	and caja.id_caja = detalle_producto_farm.id_caja
	and tipo_flor.disponible = 1
	and grado_flor.disponible = 1
	and tapa.disponible = 1
	and caja.disponible = 1
	group by tipo_flor.id_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	grado_flor.idc_grado_flor,
	tapa.id_tapa,
	ltrim(rtrim(tapa.nombre_tapa)),
	tapa.idc_tapa,
	caja.id_caja,
	ltrim(rtrim(caja.nombre_caja)),
	tipo_caja.idc_tipo_caja,
	ltrim(rtrim(caja.medida)),
	caja.idc_caja,
	detalle_producto_farm.unidades_por_pieza
end