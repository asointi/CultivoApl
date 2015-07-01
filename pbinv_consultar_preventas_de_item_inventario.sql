/****** Object:  StoredProcedure [dbo].[pbinv_consultar_preventas_de_item_inventario]    Script Date: 01/23/2008 08:00:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[pbinv_consultar_preventas_de_item_inventario]

@id_item_inventario_preventa int,
@fecha_inicial datetime,
@accion nvarchar(255),
@id_farm nvarchar(255),
@id_tipo_flor nvarchar(255),
@id_variedad_flor nvarchar(255),
@id_grado_flor nvarchar(255)

as
begin

if(@id_variedad_flor = '-1')
	set @id_variedad_flor = '%%'

if(@id_grado_flor = '-1')
	set @id_grado_flor = '%%'

if(@id_tipo_flor = '-1')
	set @id_tipo_flor = '%%'

if(@id_farm = '-1')
	set @id_farm = '%%'


if(@id_item_inventario_preventa <> -1)
begin
	declare @id_tapa int,
	@id_variedad_flor_aux int,
	@id_grado_flor_aux int,
	@id_farm_aux int,
	@id_tipo_caja int,
	@unidades_por_pieza int,
	@cantidad_piezas int

	select @id_farm_aux = inventario_preventa.id_farm,
	@id_variedad_flor_aux = item_inventario_preventa.id_variedad_flor,
	@id_grado_flor_aux = item_inventario_preventa.id_grado_flor,
	@id_tapa = item_inventario_preventa.id_tapa,
	@id_tipo_caja = item_inventario_preventa.id_tipo_caja,
	@unidades_por_pieza = item_inventario_preventa.unidades_por_pieza,
	@cantidad_piezas = sum(detalle_item_inventario_preventa.cantidad_piezas)
	from inventario_preventa, item_inventario_preventa, detalle_item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
	and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa in
	(select max(id_detalle_item_inventario_preventa) from detalle_item_inventario_preventa group by id_detalle_item_inventario_preventa_padre)
	and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
	group by
	inventario_preventa.id_farm,
	item_inventario_preventa.id_variedad_flor,
	item_inventario_preventa.id_grado_flor,
	item_inventario_preventa.id_tapa,
	item_inventario_preventa.id_tipo_caja,
	item_inventario_preventa.unidades_por_pieza

	select 
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	farm.idc_farm,
	farm.nombre_farm,
	orden_pedido.unidades_por_pieza,
	orden_pedido.marca,
	orden_pedido.valor_unitario,
	orden_pedido.fecha_inicial,
	orden_pedido.fecha_creacion_orden,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	vendedor.nombre,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente,
	orden_pedido.comentario,
	sum(cantidad_piezas) as cantidad_piezas into #temp
	from orden_pedido,vendedor, cliente_despacho, variedad_flor, grado_flor, tipo_flor, farm, tapa, tipo_caja
	where orden_pedido.id_vendedor = vendedor.id_vendedor
	and orden_pedido.id_despacho = cliente_despacho.id_despacho
	and orden_pedido.id_tapa = tapa.id_tapa
	and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
	and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
	and orden_pedido.id_farm = farm.id_farm
	and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
	and orden_pedido.unidades_por_pieza = @unidades_por_pieza
	and variedad_flor.id_variedad_flor = @id_variedad_flor_aux
	and grado_flor.id_grado_flor = @id_grado_flor_aux
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and farm.id_farm = @id_farm_aux
	and tapa.id_tapa = @id_tapa
	and tipo_caja.id_tipo_caja = @id_tipo_caja
	and orden_pedido.disponible = 1
	and orden_pedido.id_tipo_factura = 2
	and orden_pedido.id_orden_pedido in
	(select max(id_orden_pedido) from orden_pedido group by id_orden_pedido_padre)
	and orden_pedido.fecha_inicial >= @fecha_inicial
	group by
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	farm.idc_farm,
	farm.nombre_farm,
	orden_pedido.unidades_por_pieza,
	orden_pedido.marca,
	orden_pedido.valor_unitario,
	orden_pedido.fecha_inicial,
	orden_pedido.fecha_creacion_orden,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	vendedor.nombre,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente,
	orden_pedido.comentario

	update #temp
	set id_vendedor = vendedor.id_vendedor,
	idc_vendedor = vendedor.idc_vendedor,
	nombre = vendedor.nombre
	from #temp, vendedor, cliente_despacho, cliente_factura, configuracion_bd
	where #temp.id_despacho = cliente_despacho.id_despacho
	and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor
	and #temp.id_vendedor = configuracion_bd.id_vendedor_global

	if(@accion = 'producto')
	begin
		select idc_tipo_flor,
		nombre_tipo_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		idc_grado_flor,
		nombre_grado_flor,
		idc_tapa,
		nombre_tapa,
		idc_tipo_caja,
		nombre_tipo_caja,
		idc_farm,
		nombre_farm,
		unidades_por_pieza,
		@cantidad_piezas  as inventario,
		sum(cantidad_piezas) as facturado,
		@cantidad_piezas - sum(cantidad_piezas) as saldo
		from #temp
		group by
		idc_tipo_flor,
		nombre_tipo_flor,
		idc_variedad_flor,
		nombre_variedad_flor,
		idc_grado_flor,
		nombre_grado_flor,
		idc_tapa,
		nombre_tapa,
		idc_tipo_caja,
		nombre_tipo_caja,
		idc_farm,
		nombre_farm,
		unidades_por_pieza
	end
	else
	if(@accion = 'preventa')
	begin
		select 
		marca,
		valor_unitario,
		fecha_inicial,
		fecha_creacion_orden,
		idc_vendedor,
		nombre as nombre_vendedor,
		idc_cliente_despacho,
		nombre_cliente,
		comentario,
		cantidad_piezas
		from #temp
		order by 
		fecha_creacion_orden,
		nombre_vendedor,
		nombre_cliente,
		fecha_inicial
	end
	drop table #temp
end
else
if(@id_item_inventario_preventa = -1)
begin
	select farm.id_farm,
	farm.nombre_farm,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	item_inventario_preventa.unidades_por_pieza,
	null as marca,
	null as precio,
	null as fecha,
	null as fecha_creacion_orden,
	sum(detalle_item_inventario_preventa.cantidad_piezas) as inventario,
	null as facturado,
	null as id_vendedor,
	null as nombre_vendedor,
	null as id_despacho,
	null as idc_cliente_despacho,
	null as nombre_cliente,
	null as comentario into #temp2
	from inventario_preventa,item_inventario_preventa,detalle_item_inventario_preventa,farm, tapa, tipo_flor,variedad_flor,grado_flor,tipo_caja
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
	and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa in
	(select max(id_detalle_item_inventario_preventa) from detalle_item_inventario_preventa group by id_detalle_item_inventario_preventa_padre)
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora > = @fecha_inicial
	and inventario_preventa.id_farm = farm.id_farm
	and item_inventario_preventa.id_tapa = tapa.id_tapa
	and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
	and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and grado_flor.id_grado_flor like @id_grado_flor
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and farm.id_farm like @id_farm
	and item_inventario_preventa.id_tipo_caja = tipo_caja.id_tipo_caja
	group by
	farm.id_farm,
	farm.nombre_farm,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	item_inventario_preventa.unidades_por_pieza

	union 

	select farm.id_farm,
	farm.nombre_farm,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	orden_pedido.unidades_por_pieza,
	orden_pedido.marca,
	orden_pedido.valor_unitario as precio,
	orden_pedido.fecha_inicial as fecha,
	orden_pedido.fecha_creacion_orden,
	null as inventario,
	sum(orden_pedido.cantidad_piezas) as facturado,
	vendedor.id_vendedor,
	vendedor.nombre as nombre_vendedor,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente,
	orden_pedido.comentario 
	from orden_pedido, vendedor, cliente_despacho,farm,tapa,tipo_flor,variedad_flor,grado_flor,tipo_caja
	where orden_pedido.id_orden_pedido in
	(select max(id_orden_pedido) from orden_pedido group by id_orden_pedido_padre)
	and orden_pedido.fecha_inicial > = @fecha_inicial
	and orden_pedido.disponible = 1
	and orden_pedido.id_tipo_factura = 2
	and vendedor.id_vendedor = orden_pedido.id_vendedor
	and cliente_despacho.id_despacho = orden_pedido.id_despacho
	and farm.id_farm = orden_pedido.id_farm
	and tapa.id_tapa = orden_pedido.id_tapa
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and grado_flor.id_grado_flor like @id_grado_flor
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and farm.id_farm like @id_farm
	and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
	group by
	farm.id_farm,
	farm.nombre_farm,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	orden_pedido.unidades_por_pieza,
	orden_pedido.marca,
	orden_pedido.valor_unitario,
	orden_pedido.fecha_inicial,
	orden_pedido.fecha_creacion_orden,
	vendedor.id_vendedor,
	vendedor.nombre,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente, 
	orden_pedido.comentario 


	if(@accion = 'producto')
	begin
		select nombre_farm,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor,
		nombre_tipo_caja,
		nombre_tapa,
		unidades_por_pieza,
		isnull(sum(inventario),0) as inventario,
		isnull(sum(facturado),0) as facturado,
		isnull(sum(inventario) - sum(facturado),0) as saldo
		from #temp2
		group by 
		nombre_farm,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor,
		nombre_tipo_caja,
		nombre_tapa,
		unidades_por_pieza
		order by 
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor,
		nombre_tipo_caja,
		nombre_tapa,
		unidades_por_pieza
	end
	else
	if(@accion = 'preventa')
	begin
		update #temp2
		set id_vendedor = vendedor.id_vendedor,
		nombre_vendedor = vendedor.nombre
		from #temp2, vendedor, cliente_despacho, cliente_factura, configuracion_bd
		where #temp2.id_despacho = cliente_despacho.id_despacho
		and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
		and cliente_factura.id_vendedor = vendedor.id_vendedor
		and #temp2.id_vendedor = configuracion_bd.id_vendedor_global

		select fecha_creacion_orden,
		nombre_vendedor,
		idc_cliente_despacho,
		nombre_cliente,
		fecha as fecha_inicial,
		marca,
		sum(facturado) as cantidad_piezas,
		precio as valor_unitario,
		comentario
		from #temp2
		where facturado is not null
		group by 
		fecha_creacion_orden,
		nombre_vendedor,
		idc_cliente_despacho,
		nombre_cliente,
		fecha,
		marca,
		precio,
		comentario
		order by 
		fecha_creacion_orden,
		nombre_vendedor,
		nombre_cliente,
		fecha
	end
	drop table #temp2
end
end