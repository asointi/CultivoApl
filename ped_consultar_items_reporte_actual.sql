set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[ped_consultar_items_reporte_actual]

@id_farm int, 
@idc_tipo_factura nvarchar(255)

AS

set language spanish

declare @idc_tipo_factura_doble nvarchar(255),
@nombre_preventa nvarchar(255),
@nombre_doble nvarchar(255)

set @idc_tipo_factura_doble = '7'
set @nombre_preventa = 'Preventa'
set @nombre_doble = 'Doblaje'

IF (@idc_tipo_factura = '9')
begin
	select max(id_orden_pedido) as id_orden_pedido into #orden_pedido
	from orden_pedido
	group by id_orden_pedido_padre

	/*seleccionar las ordenes desde item_reporte_cambio_orden_pedido actuales*/
	select item_reporte_cambio_orden_pedido.id_orden_pedido,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	tapa.nombre_tapa,
	tipo_caja.nombre_tipo_caja,
	item_reporte_cambio_orden_pedido.code, 
	item_reporte_cambio_orden_pedido.unidades_por_pieza, 
	item_reporte_cambio_orden_pedido.cantidad_piezas,
	item_reporte_cambio_orden_pedido.comentario,
	[dbo].[calcular_dia_vuelo_orden_fija] (item_reporte_cambio_orden_pedido.fecha_despacho_inicial, farm.idc_farm) as fecha_vuelo,
	farm.nombre_farm,
	farm.id_farm,
	tipo_farm.codigo as tipo_farm,
	(
		select top 1 valor_pactado_cultivo.valor_pactado
		from valor_pactado_cultivo,
		orden_pedido
		where valor_pactado_cultivo.id_orden_pedido = orden_pedido.id_orden_pedido
		and orden_pedido.id_orden_pedido_padre = item_reporte_cambio_orden_pedido.id_orden_pedido_padre
		and exists
		(
			select *
			from #orden_pedido
			where orden_pedido.id_orden_pedido = #orden_pedido.id_orden_pedido
		)
		order by valor_pactado_cultivo.fecha desc
	) as farm_price into #temp
	from item_reporte_cambio_orden_pedido,
	reporte_cambio_orden_pedido,
	farm, 
	tipo_farm,
	tipo_flor,
	variedad_flor, 
	grado_flor,
	tapa,
	tipo_caja,
	ciudad,
	tipo_factura
	where tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and (getdate() between
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final
	or 
	getdate()+10 between
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final)
	and item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
	and farm.id_ciudad = ciudad.id_ciudad
	and item_reporte_cambio_orden_pedido.disponible = 1
	and farm.id_farm = @id_farm
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido in 
	(
		select max(id_item_reporte_cambio_orden_pedido) 
		from item_reporte_cambio_orden_pedido,
		reporte_cambio_orden_pedido, 
		tipo_factura
		where reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
		and id_farm = @id_farm 
		and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		group by id_orden_pedido_padre,
		id_farm
	)

	/**datos para ser visualizados por los usuarios**/
	select nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	nombre_tipo_caja,
	fecha_vuelo,
	datepart(dw,fecha_vuelo) as id_dia_despacho,
	datename(dw,fecha_vuelo) as nombre_dia_despacho,
	code, 
	unidades_por_pieza, 
	sum(cantidad_piezas) as cantidad_piezas,
	comentario,
	nombre_farm,
	case
		when tipo_farm = 'F' then isnull(farm_price,0)
		else null
	end as farm_price
	from #temp 
	group by
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	nombre_tipo_caja,
	fecha_vuelo,
	code, 
	unidades_por_pieza, 
	comentario,
	nombre_farm,
	isnull(farm_price,0),
	tipo_farm
	order by id_dia_despacho, 
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor

	/*eliminación tablas temporales*/
	drop table #temp
	drop table #orden_pedido
end
else
IF (@idc_tipo_factura = '4')
begin
	/*seleccionar las ordenes desde item_reporte_cambio_orden_pedido actuales*/
	select item_reporte_cambio_orden_pedido.id_orden_pedido,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.nombre_grado_flor,
	grado_flor.idc_grado_flor,
	tapa.nombre_tapa,
	tapa.idc_tapa,
	tipo_caja.nombre_tipo_caja,
	tipo_caja.idc_tipo_caja,
	item_reporte_cambio_orden_pedido.code, 
	item_reporte_cambio_orden_pedido.unidades_por_pieza, 
	item_reporte_cambio_orden_pedido.cantidad_piezas,
	item_reporte_cambio_orden_pedido.comentario,
	[dbo].[calcular_dia_vuelo_preventa] (item_reporte_cambio_orden_pedido.fecha_despacho_inicial, farm.idc_farm) as fecha_vuelo,
	farm.nombre_farm,
	farm.id_farm,
	tipo_factura.idc_tipo_factura into #temp_pb
	from 
	item_reporte_cambio_orden_pedido,
	reporte_cambio_orden_pedido,
	farm, 
	tipo_flor,
	variedad_flor, 
	grado_flor,
	tapa,
	tipo_caja,
	ciudad,
	tipo_factura
	where item_reporte_cambio_orden_pedido.fecha_despacho_inicial between
	getdate() and getdate()+60
	and item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
	and farm.id_ciudad = ciudad.id_ciudad
	and item_reporte_cambio_orden_pedido.disponible = 1
	and farm.id_farm = @id_farm
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
	and item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido in 
	(
		select max(id_item_reporte_cambio_orden_pedido) 
		from item_reporte_cambio_orden_pedido,
		reporte_cambio_orden_pedido, 
		tipo_factura
		where reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
		and id_farm = @id_farm 
		and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
		and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
		group by id_orden_pedido_padre,
		id_farm
	)

	/**datos para ser visualizados por los usuarios**/
	select replace(Replace(idc_tipo_factura, @idc_tipo_factura, @nombre_preventa), @idc_tipo_factura_doble, @nombre_doble) as tipo_factura,
	idc_tipo_flor,
	nombre_tipo_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	idc_grado_flor,
	nombre_grado_flor,
	idc_tapa,
	nombre_tapa,
	idc_tipo_caja,
	rtrim(ltrim(nombre_tipo_caja)) as nombre_tipo_caja,
	code, 
	unidades_por_pieza, 
	sum(cantidad_piezas) as cantidad_piezas,
	comentario,
	nombre_farm,
	fecha_vuelo as fecha_despacho_inicial,
	datename(dw,fecha_vuelo) as nombre_dia_despacho
	from #temp_pb
	where fecha_vuelo > = getdate()
	group by idc_tipo_factura,
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
	fecha_vuelo,
	code, 
	unidades_por_pieza, 
	comentario,
	nombre_farm
	order by idc_tipo_factura,
	fecha_despacho_inicial, 
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor

	/*eliminación de tablas temporales*/
	drop table #temp_pb
end