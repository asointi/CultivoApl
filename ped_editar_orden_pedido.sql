set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[ped_editar_orden_pedido]

@accion nvarchar(50),
@fecha_inicial datetime,
@fecha_final datetime,
@idc_tipo_factura nvarchar(255),
@id_farm int,
@id_orden_pedido int,
@valor_unitario_cultivo decimal(20,4)	

as

if (@accion = 'seleccionar_farms')
begin
	if (@idc_tipo_factura = '9')
	begin
		select 
		farm.id_farm,
		farm.idc_farm,
		farm.nombre_farm,
		'[' + farm.idc_farm + '] '+ ltrim(rtrim(farm.nombre_farm)) + ' (' + convert(nvarchar,count(Orden_Pedido.id_orden_pedido)) + ')' as nombre_farm_num_ordenes
		from Orden_Pedido, 
		farm, 
		tipo_factura
		where (@fecha_inicial between Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final)
		and farm.id_farm = Orden_Pedido.id_farm
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and orden_pedido.disponible = 1
		group by farm.id_farm, farm.idc_farm, farm.nombre_farm
		order by farm.nombre_farm
	end
	else if(@idc_tipo_factura = '4')
	begin
		select 
		farm.id_farm,
		farm.idc_farm,
		farm.nombre_farm,
		'[' + farm.idc_farm + '] '+ ltrim(rtrim(farm.nombre_farm)) + ' (' + convert(nvarchar,count(Orden_Pedido.id_orden_pedido)) + ')' as nombre_farm_num_ordenes
		from Orden_Pedido, 
		farm, 
		tipo_factura
		where (Orden_Pedido.fecha_inicial between @fecha_inicial and @fecha_final)
		and farm.id_farm = Orden_Pedido.id_farm
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and orden_pedido.disponible = 1
		group by farm.id_farm, farm.idc_farm, farm.nombre_farm
		order by farm.nombre_farm
	end
end
else if (@accion = 'seleccionar')
begin
	if (@idc_tipo_factura = '9')
	begin
		select 
		Orden_Pedido.id_orden_pedido,
		Orden_Pedido.idc_orden_pedido,
		tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.nombre_grado_flor,
		grado_flor.id_grado_flor,
		tapa.nombre_tapa,
		tapa.id_tapa,
		tipo_caja.nombre_tipo_caja,
		tipo_caja.id_tipo_caja,
		orden_pedido.fecha_inicial, 
		orden_pedido.fecha_final, 
		orden_pedido.marca, 
		orden_pedido.unidades_por_pieza, 
		orden_pedido.cantidad_piezas,
		farm.id_farm,
		farm.idc_farm,
		farm.nombre_farm,
		cliente_despacho.id_despacho,
		cliente_despacho.idc_cliente_despacho,
		vendedor.id_vendedor,
		vendedor.idc_vendedor,
		orden_pedido.valor_unitario_cultivo 
		from Orden_Pedido, 
		tipo_flor,
		variedad_flor, 
		grado_flor,
		tapa,
		tipo_caja,
		farm,	
		cliente_despacho,
		vendedor,
		ciudad,
		tipo_factura
		where (@fecha_inicial between
		Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final)
		and orden_pedido.id_farm = @id_farm
		and farm.id_farm = Orden_Pedido.id_farm
		and farm.id_ciudad = ciudad.id_ciudad
		and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
		and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
		and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
		and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
		and tapa.id_tapa = orden_pedido.id_tapa
		and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and orden_pedido.disponible = 1
		and cliente_despacho.id_despacho = orden_pedido.id_despacho
		and vendedor.id_vendedor = orden_pedido.id_vendedor
		order by id_orden_pedido
	end
	else if (@idc_tipo_factura = '4')
	begin
		select 
		Orden_Pedido.id_orden_pedido,
		Orden_Pedido.idc_orden_pedido,
		tipo_flor.nombre_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.id_variedad_flor,
		grado_flor.nombre_grado_flor,
		grado_flor.id_grado_flor,
		tapa.nombre_tapa,
		tapa.id_tapa,
		tipo_caja.nombre_tipo_caja,
		tipo_caja.id_tipo_caja,
		orden_pedido.fecha_inicial, 
		orden_pedido.fecha_final, 
		orden_pedido.marca, 
		orden_pedido.unidades_por_pieza, 
		orden_pedido.cantidad_piezas,
		farm.id_farm,
		farm.idc_farm,
		farm.nombre_farm,
		cliente_despacho.id_despacho,
		cliente_despacho.idc_cliente_despacho,
		vendedor.id_vendedor,
		vendedor.idc_vendedor,
		orden_pedido.valor_unitario_cultivo
		from Orden_Pedido, 
		farm, 
		tipo_flor,
		variedad_flor, 
		grado_flor,
		tapa,
		tipo_caja,
		ciudad,
		tipo_factura,
		cliente_despacho,
		vendedor
		where (Orden_Pedido.fecha_inicial between
		@fecha_inicial and @fecha_final)
		and orden_pedido.id_farm = @Id_farm
		and farm.id_farm = Orden_Pedido.id_farm
		and farm.id_ciudad = ciudad.id_ciudad
		and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
		and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
		and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
		and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
		and tapa.id_tapa = orden_pedido.id_tapa
		and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and orden_pedido.disponible = 1
		and cliente_despacho.id_despacho = orden_pedido.id_despacho
		and vendedor.id_vendedor = orden_pedido.id_vendedor
		order by id_orden_pedido
	end
end
else if (@accion = 'modificar')
begin
	update Orden_pedido
	set valor_unitario_cultivo = @valor_unitario_cultivo
	where id_orden_pedido = @id_orden_pedido
end





