set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[ped_editar_items_pendientes]

@fecha_despacho_cultivo datetime, 
@fecha_despacho_cultivo_final datetime, 
@idc_tipo_factura nvarchar(255),
@accion nvarchar(255),
@id_farm int,
@id_cuenta_interna int,
@id_temporada_ano int

as

declare @nombre_preventa nvarchar(25),
@nombre_doble nvarchar(25),
@nombre_so nvarchar(255),
@numero_reporte_farm int,
@id_reporte_cambio_orden_pedido int,
@conteo int,
@idc_tipo_factura_doble nvarchar(5),
@base_datos nvarchar(50)

set @nombre_preventa = 'Preventa'
set @nombre_so = 'SO'
set @base_datos = db_name()


if(@base_datos = 'BD_Nf')
begin
	set @nombre_doble = 'Preventa'
	set @idc_tipo_factura_doble = '4'
end
else
begin
	set @nombre_doble = 'Doblaje'
	set @idc_tipo_factura_doble = '7'
end

IF(@idc_tipo_factura = '9')
begin
	/*seleccionar las ordenes desde Orden_Pedido en el rango de fechas solicitado*/
	select Orden_Pedido.id_orden_pedido,
	Orden_Pedido.id_orden_pedido_padre,
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
	orden_pedido.comentario,
	ciudad.id_ciudad,
	[dbo].[calcular_dia_vuelo_orden_fija] (orden_pedido.fecha_inicial, farm.idc_farm) as fecha_despacho,	
	orden_pedido.disponible,
	farm.id_farm,
	farm.idc_farm,
	farm.nombre_farm,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	vendedor.id_vendedor,
	vendedor.idc_vendedor into #temp
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
	where 
	(
		@fecha_despacho_cultivo between
		Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final
		or 
		@fecha_despacho_cultivo + 10 between
		Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final
	)
	and farm.id_farm = Orden_Pedido.id_farm
	and farm.id_ciudad = ciudad.id_ciudad
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and orden_pedido.disponible = 1
	and cliente_despacho.id_despacho = orden_pedido.id_despacho
	and vendedor.id_vendedor = orden_pedido.id_vendedor

	/*Eliminar los items repetidos que aun no estan expirados ya que si no se hace esto,
	las ordenes no son canceladas por la aplicacion creando confusion*/
	delete from #temp
	where id_orden_pedido in
	(
		select min(id_orden_pedido)
		from #temp
		group by id_orden_pedido_padre
		having count(*) > 1
	)

	/*consultar las ultimas versiones de los cambios reportados*/
	select max(id_item_reporte_cambio_orden_pedido) AS id_item_reporte_cambio_orden_pedido INTO #ultimos_reportes
	from item_reporte_cambio_orden_pedido,
	reporte_cambio_orden_pedido, 
	tipo_factura 
	where item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido=reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	group by id_orden_pedido_padre, id_farm

	/**seleccionar las ordenes que han sido reportadas seleccionando unicamente la ultima version de cada orden**/
	select item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido,
	id_orden_pedido,
	id_orden_pedido_padre,
	idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	nombre_grado_flor,
	grado_flor.id_grado_flor,
	nombre_tapa,
	tapa.id_tapa,
	nombre_tipo_caja,
	tipo_caja.id_tipo_caja,
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial,
	fecha_despacho_final,
	[dbo].[calcular_dia_vuelo_orden_fija] (item_reporte_cambio_orden_pedido.fecha_despacho_inicial, farm.idc_farm) as fecha_despacho,
	code,
	unidades_por_pieza,
	cantidad_piezas,
	item_reporte_cambio_orden_pedido.comentario,
	ciudad.id_ciudad,
	item_reporte_cambio_orden_pedido.disponible,
	farm.id_farm,
	farm.idc_farm,
	farm.nombre_farm,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	vendedor.id_vendedor,
	vendedor.idc_vendedor into #temp2
	from item_reporte_cambio_orden_pedido, 
	reporte_cambio_orden_pedido, 
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	tipo_caja,
	farm,
	ciudad,
	tipo_factura,
	cliente_despacho,
	vendedor
	where reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and farm.id_ciudad = ciudad.id_ciudad
	and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and cliente_despacho.id_despacho = item_reporte_cambio_orden_pedido.id_despacho
	and vendedor.id_vendedor = item_reporte_cambio_orden_pedido.id_vendedor

	delete from #temp2
	where not exists
	(
		select * 
		from #ultimos_reportes
		where #temp2.id_item_reporte_cambio_orden_pedido = #ultimos_reportes.id_item_reporte_cambio_orden_pedido
	)

	/*********************************************************************/
	/**seleccionar los registros que se encuentran iguales
	entre lo ya reportado y lo faltante por reportar, esto se realiza
	debido a que las ordenes sufren cambios en su fecha de finalizacion
	pero en sus demas atributos a excepcion  del idc_orden_pedido todos
	los campos son exactamente iguales**/
	/*********************************************************************/
	select #temp2.id_orden_pedido,
	#temp2.id_orden_pedido_padre,
	#temp.fecha_final into #temp3
	from #temp,
	#temp2 
	where
	#temp.id_orden_pedido_padre = #temp2.id_orden_pedido_padre
	and #temp.id_farm = #temp2.id_farm
	and #temp.id_variedad_flor = #temp2.id_variedad_flor
	and #temp.id_grado_flor = #temp2.id_grado_flor
	and #temp.id_tapa = #temp2.id_tapa
	and #temp.id_tipo_caja = #temp2.id_tipo_caja
	and datepart(dw,#temp.fecha_despacho) = datepart(dw,#temp2.fecha_despacho)
	and rtrim(ltrim(#temp.marca)) = rtrim(ltrim(#temp2.code))
	and #temp.unidades_por_pieza = #temp2.unidades_por_pieza
	and #temp.cantidad_piezas = #temp2.cantidad_piezas
	and isnull(rtrim(ltrim(#temp.comentario)), '') = isnull(rtrim(ltrim(#temp2.comentario)), '')
	and #temp.disponible = #temp2.disponible

	/**ampliar la finalizacion de la orden encontrada en el paso anterior en la	tabla de cambios**/
	update item_reporte_cambio_orden_pedido
	set fecha_despacho_final = #temp3.fecha_final
	from #temp3
	where item_reporte_cambio_orden_pedido.id_orden_pedido = #temp3.id_orden_pedido
	and item_reporte_cambio_orden_pedido.id_orden_pedido_padre = #temp3.id_orden_pedido_padre
	and exists
	(
		select * 
		from #ultimos_reportes
		where item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido = #ultimos_reportes.id_item_reporte_cambio_orden_pedido
	)

	/**verificar ordenes nuevas o cambios desde orden pedido**/
	select id_orden_pedido,
	id_orden_pedido_padre,
	idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	id_variedad_flor,
	nombre_grado_flor,
	id_grado_flor,
	nombre_tapa,
	id_tapa,
	nombre_tipo_caja,
	id_tipo_caja,
	fecha_inicial, 
	fecha_final, 
	marca, 
	unidades_por_pieza, 
	cantidad_piezas,
	comentario,
	id_ciudad,
	fecha_despacho,
	disponible,
	id_farm,
	idc_farm,
	nombre_farm,
	id_despacho,
	idc_cliente_despacho,
	id_vendedor,
	idc_vendedor into #temp4
	from #temp
	where not exists
	(
		select *
		from #temp2
		where #temp.id_orden_pedido_padre = #temp2.id_orden_pedido_padre
		and #temp.id_farm = #temp2.id_farm
		and #temp.id_variedad_flor = #temp2.id_variedad_flor
		and #temp.id_grado_flor = #temp2.id_grado_flor
		and #temp.id_tapa = #temp2.id_tapa
		and #temp.id_tipo_caja = #temp2.id_tipo_caja
		and datepart(dw,#temp.fecha_despacho) = datepart(dw,#temp2.fecha_despacho)
		and rtrim(ltrim(#temp.marca)) = rtrim(ltrim(#temp2.code))
		and #temp.unidades_por_pieza = #temp2.unidades_por_pieza
		and #temp.cantidad_piezas = #temp2.cantidad_piezas
		and isnull(rtrim(ltrim(#temp.comentario)), '') = isnull(rtrim(ltrim(#temp2.comentario)), '')
		and #temp.disponible = #temp2.disponible
	)

	/**ordenes reportadas que no estan en las ordenes de la semana consultada se considerarán cancelaciones ya que no aparecen**/
	insert into #temp4
	(
		id_orden_pedido,
		id_orden_pedido_padre,
		idc_orden_pedido,
		nombre_tipo_flor,
		nombre_variedad_flor,
		id_variedad_flor,
		nombre_grado_flor,
		id_grado_flor,
		nombre_tapa,
		id_tapa,
		nombre_tipo_caja,
		id_tipo_caja,
		fecha_inicial, 
		fecha_final, 
		marca, 
		unidades_por_pieza, 
		cantidad_piezas,
		comentario,
		id_ciudad,
		fecha_despacho,
		disponible,
		id_farm,
		idc_farm,
		nombre_farm,
		id_despacho,
		idc_cliente_despacho,
		id_vendedor,
		idc_vendedor
	)
	select 
	id_orden_pedido,
	id_orden_pedido_padre,
	idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	id_variedad_flor,
	nombre_grado_flor,
	id_grado_flor,
	nombre_tapa,
	id_tapa,
	nombre_tipo_caja,
	id_tipo_caja,
	fecha_despacho_inicial,
	fecha_despacho_final,
	code,
	unidades_por_pieza,
	cantidad_piezas,
	comentario,
	id_ciudad,
	fecha_despacho,
	0 as disponible,
	id_farm,
	idc_farm,
	nombre_farm,
	id_despacho,
	idc_cliente_despacho,
	id_vendedor,
	idc_vendedor 
	from #temp2
	where disponible = 1
	and not exists
	(
		select *
		from #temp
		where #temp2.id_orden_pedido_padre = #temp.id_orden_pedido_padre
		and #temp2.id_farm = #temp.id_farm
		and #temp2.id_variedad_flor = #temp.id_variedad_flor
		and #temp2.id_grado_flor = #temp.id_grado_flor
		and #temp2.id_tapa = #temp.id_tapa
		and #temp2.id_tipo_caja = #temp.id_tipo_caja
		and datepart(dw,#temp2.fecha_despacho) = datepart(dw,#temp.fecha_despacho)
		and rtrim(ltrim(#temp2.code)) = rtrim(ltrim(#temp.marca))
		and #temp2.unidades_por_pieza = #temp.unidades_por_pieza
		and #temp2.cantidad_piezas = #temp.cantidad_piezas
		and isnull(rtrim(ltrim(#temp2.comentario)), '') = isnull(rtrim(ltrim(#temp.comentario)), '')
		and #temp2.disponible = #temp.disponible
	)

	/*volver negativas las piezas cuando se trate de cancelaciones*/
	update #temp4
	set cantidad_piezas = cantidad_piezas*-1
	from #temp4
	where disponible = 0

	/*asignar el current salesperson cuando la orden viene con un vendedor genérico*/
	update #temp4
	set id_vendedor = vendedor.id_vendedor,
	idc_vendedor = vendedor.idc_vendedor
	from vendedor, 
	cliente_factura, 
	cliente_despacho, 
	configuracion_bd
	where #temp4.id_vendedor = configuracion_bd.id_vendedor_global
	and #temp4.id_despacho = cliente_despacho.id_despacho
	and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor

	if(@accion = 'consultar_fincas')
	begin
		/**datos para ser visualizados por los usuarios**/
		select #temp4.idc_farm,
		rtrim(ltrim(#temp4.nombre_farm)) as nombre_farm,
		count(*) as cantidad,
		#temp4.id_farm,
		(
			select isnull(max(numero_reporte_farm), 0) + 1 
			from reporte_cambio_orden_pedido,
			farm,
			tipo_factura
			where reporte_cambio_orden_pedido.id_farm = farm.id_farm
			and farm.id_farm = #temp4.id_farm
			and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
		) as numero_reporte_esperado,
		farm.correo,
		isnull(tipo_archivo.id_tipo_archivo, 2) as id_tipo_archivo,
		isnull(tipo_archivo.nombre_tipo_archivo, 'PDF') as nombre_tipo_archivo,
		isnull(tipo_archivo.formato, '.pdf') as formato
		from #temp4,
		farm left join tipo_archivo on tipo_archivo.id_tipo_archivo = farm.id_tipo_archivo
		where #temp4.id_farm = farm.id_farm
		group by #temp4.id_farm, 
		#temp4.idc_farm, 
		#temp4.nombre_farm,
		farm.correo,
		isnull(tipo_archivo.id_tipo_archivo, 2),
		isnull(tipo_archivo.nombre_tipo_archivo, 'PDF'),
		isnull(tipo_archivo.formato, '.pdf')
		order by #temp4.idc_farm
	end
	else
	if(@accion = 'consultar_detalle_finca') 
	begin
		select idc_farm,
		nombre_farm,
		@nombre_so as tipo_factura,
		id_orden_pedido,
		convert(int,idc_orden_pedido) as idc_orden_pedido,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor,
		nombre_tapa,
		nombre_tipo_caja,
		fecha_inicial as fecha_despacho_inicial, 
		datename(dw,fecha_despacho) as nombre_dia_despacho,
		marca as code, 
		unidades_por_pieza, 
		cantidad_piezas,
		rtrim(comentario) as comentario,
		datepart(dw,fecha_despacho) as id_dia_despacho,
		disponible,
		id_farm,
		idc_cliente_despacho,
		idc_vendedor
		from #temp4 
		where id_farm = @id_farm
		order by nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor,
		code,
		nombre_tapa,
		nombre_tipo_caja,
		unidades_por_pieza,
		disponible,
		id_dia_despacho,
		cantidad_piezas
	end
	else
	if(@accion = 'insertar_reporte') 
	begin
		select @conteo = count(*) from #temp4
		
		if(@conteo <> 0)
		begin
			select @numero_reporte_farm = max(numero_reporte_farm)+1 
			from Reporte_Cambio_Orden_Pedido,
			tipo_factura,
			farm
			where Reporte_Cambio_Orden_Pedido.id_farm = farm.id_farm
			and farm.id_farm = @id_farm 
			and Reporte_Cambio_Orden_Pedido.id_tipo_factura = tipo_factura.id_tipo_factura
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
			
			if (@numero_reporte_farm is null)
			begin
				set @numero_reporte_farm = 1
			end
			
			insert into Reporte_Cambio_Orden_Pedido 
			(
				id_farm,
				id_cuenta_interna,
				id_tipo_factura,
				fecha_despacho_inicial_consultada,
				numero_reporte_farm, 
				comentario
			)
			select @id_farm,
			@id_cuenta_interna,
			tipo_factura.id_tipo_factura,
			@fecha_despacho_cultivo,
			@numero_reporte_farm,
			null
			from tipo_factura
			where tipo_factura.idc_tipo_factura = @idc_tipo_factura

			set @id_reporte_cambio_orden_pedido = scope_identity()

			/**registros a insertar en la tablas de cambios**/
			insert into Item_Reporte_Cambio_Orden_Pedido 
			(
				id_orden_pedido,
				id_orden_pedido_padre,
				idc_orden_pedido,
				id_variedad_flor,
				id_grado_flor,
				id_tapa,
				id_tipo_caja,
				code,
				unidades_por_pieza,
				cantidad_piezas,
				comentario,
				id_reporte_cambio_orden_pedido,
				fecha_despacho_inicial,
				fecha_despacho_final,
				id_dia_despacho,
				disponible,
				id_despacho,
				id_vendedor
			)
			select id_orden_pedido,
			id_orden_pedido_padre,
			idc_orden_pedido,
			id_variedad_flor,
			id_grado_flor,
			id_tapa,
			id_tipo_caja,
			marca, 
			unidades_por_pieza, 
			cantidad_piezas,
			comentario,
			@id_reporte_cambio_orden_pedido,
			fecha_inicial, 
			fecha_final,
			datepart(dw,fecha_despacho),
			disponible,
			id_despacho,
			id_vendedor
			from #temp4 
			where id_farm = @id_farm
			order by disponible

			select @numero_reporte_farm as numero_reporte_farm
		end
	end

	/*eliminación tablas temporales*/
	drop table #temp
	drop table #temp2
	drop table #temp3
	drop table #temp4
	drop table #ultimos_reportes
end
else
IF (@idc_tipo_factura = '4')
begin
	select max(id_orden_pedido) as id_orden_pedido into #ordenes
	from orden_pedido,
	tipo_factura
	where orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
	group by id_orden_pedido_padre

	/*seleccionar las ordenes desde Orden_Pedido en el rango de fechas solicitado*/
	select Orden_Pedido.id_orden_pedido,
	Orden_Pedido.id_orden_pedido_padre,
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
	ISNULL(orden_pedido.comentario, '') AS comentario,
	ciudad.id_ciudad,
	[dbo].[calcular_dia_vuelo_preventa] (orden_pedido.fecha_inicial, farm.idc_farm) as fecha_despacho, 
	orden_pedido.disponible,
	farm.id_farm,
	farm.idc_farm,
	farm.nombre_farm,
	tipo_factura.idc_tipo_factura,
	tipo_factura.id_tipo_factura,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	vendedor.id_vendedor,
	vendedor.idc_vendedor into #temp_pb
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
	where Orden_Pedido.fecha_inicial between
	@fecha_despacho_cultivo and @fecha_despacho_cultivo_final
	and farm.id_farm = Orden_Pedido.id_farm
	and farm.id_ciudad = ciudad.id_ciudad
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
	and orden_pedido.disponible = 1
	and orden_pedido.id_despacho = cliente_despacho.id_despacho
	and orden_pedido.id_vendedor = vendedor.id_vendedor
	and exists
	(
		select * 
		from #ordenes
		where #ordenes.id_orden_pedido = orden_pedido.id_orden_pedido
	)

	/*consultar las ultimas versiones de los cambios reportados*/
	select max(id_item_reporte_cambio_orden_pedido) AS id_item_reporte_cambio_orden_pedido INTO #ultimos_reportes_pb
	from item_reporte_cambio_orden_pedido,
	reporte_cambio_orden_pedido, 
	tipo_factura 
	where item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
	group by id_orden_pedido_padre, 
	id_farm

	/**seleccionar las ordenes que han sido reportadas seleccionando unicamente la ultima version de cada orden**/
	select item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido,
	id_orden_pedido,
	id_orden_pedido_padre,
	idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	variedad_flor.id_variedad_flor,
	nombre_grado_flor,
	grado_flor.id_grado_flor,
	nombre_tapa,
	tapa.id_tapa,
	nombre_tipo_caja,
	tipo_caja.id_tipo_caja,
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial,
	fecha_despacho_final,
	[dbo].[calcular_dia_vuelo_preventa] (item_reporte_cambio_orden_pedido.fecha_despacho_inicial, farm.idc_farm) as fecha_despacho,
	code,
	unidades_por_pieza,
	cantidad_piezas,
	isnull(item_reporte_cambio_orden_pedido.comentario, '') as comentario,
	ciudad.id_ciudad,
	item_reporte_cambio_orden_pedido.disponible,
	farm.id_farm,
	farm.idc_farm,
	farm.nombre_farm,
	tipo_factura.idc_tipo_factura,
	tipo_factura.id_tipo_factura,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	vendedor.id_vendedor,
	vendedor.idc_vendedor into #temp2_pb
	from item_reporte_cambio_orden_pedido, 
	reporte_cambio_orden_pedido, 
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	tipo_caja,
	farm,
	ciudad,
	tipo_factura,
	cliente_despacho,
	vendedor
	where 
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial between
	@fecha_despacho_cultivo and @fecha_despacho_cultivo_final
	and reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and farm.id_ciudad = ciudad.id_ciudad
	and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and (tipo_factura.idc_tipo_factura = @idc_tipo_factura or tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble)
	and cliente_despacho.id_despacho = item_reporte_cambio_orden_pedido.id_despacho
	and vendedor.id_vendedor = item_reporte_cambio_orden_pedido.id_vendedor

	delete from #temp2_pb
	where not exists
	(
		select * 
		from #ultimos_reportes_pb
		where #temp2_pb.id_item_reporte_cambio_orden_pedido = #ultimos_reportes_pb.id_item_reporte_cambio_orden_pedido
	)

	/**verificar ordenes nuevas o cambios desde orden pedido**/
	select id_orden_pedido,
	id_orden_pedido_padre,
	idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	id_variedad_flor,
	nombre_grado_flor,
	id_grado_flor,
	nombre_tapa,
	id_tapa,
	nombre_tipo_caja,
	id_tipo_caja,
	fecha_inicial, 
	fecha_final, 
	marca, 
	unidades_por_pieza, 
	cantidad_piezas,
	comentario,
	id_ciudad,
	fecha_despacho,
	disponible,
	id_farm,
	idc_farm,
	nombre_farm,
	idc_tipo_factura,
	id_tipo_factura,
	id_despacho,
	idc_cliente_despacho,
	id_vendedor,
	idc_vendedor into #temp4_pb
	from #temp_pb
	where not exists 
	(
		select *
		from #temp2_pb
		where
		#temp_pb.id_orden_pedido_padre = #temp2_pb.id_orden_pedido_padre
		and #temp_pb.id_farm = #temp2_pb.id_farm
		and #temp_pb.id_variedad_flor = #temp2_pb.id_variedad_flor
		and #temp_pb.id_grado_flor = #temp2_pb.id_grado_flor
		and #temp_pb.id_tapa = #temp2_pb.id_tapa
		and #temp_pb.id_tipo_caja = #temp2_pb.id_tipo_caja
		and datepart(dw,#temp_pb.fecha_despacho) = datepart(dw,#temp2_pb.fecha_despacho)
		and rtrim(ltrim(#temp_pb.marca)) = rtrim(ltrim(#temp2_pb.code))
		and #temp_pb.unidades_por_pieza = #temp2_pb.unidades_por_pieza
		and #temp_pb.cantidad_piezas = #temp2_pb.cantidad_piezas
		and isnull(rtrim(ltrim(#temp_pb.comentario)), '') = isnull(rtrim(ltrim(#temp2_pb.comentario)), '')
		and #temp_pb.disponible = #temp2_pb.disponible
		and #temp_pb.fecha_inicial = #temp2_pb.fecha_despacho_inicial
	)

	/**ordenes reportadas que no estan en las ordenes de la semana consultada se considerarán cancelaciones ya que no aparecen**/
	insert into #temp4_pb 
	(
	id_orden_pedido,
	id_orden_pedido_padre,
	idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	id_variedad_flor,
	nombre_grado_flor,
	id_grado_flor,
	nombre_tapa,
	id_tapa,
	nombre_tipo_caja,
	id_tipo_caja,
	fecha_inicial, 
	fecha_final, 
	marca, 
	unidades_por_pieza, 
	cantidad_piezas,
	comentario,
	id_ciudad,
	fecha_despacho,
	disponible,
	id_farm,
	idc_farm,
	nombre_farm,
	idc_tipo_factura,
	id_tipo_factura,
	id_despacho,
	idc_cliente_despacho,
	id_vendedor,
	idc_vendedor
	)
	select 
	id_orden_pedido,
	id_orden_pedido_padre,
	idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	id_variedad_flor,
	nombre_grado_flor,
	id_grado_flor,
	nombre_tapa,
	id_tapa,
	nombre_tipo_caja,
	id_tipo_caja,
	fecha_despacho_inicial,
	fecha_despacho_final,
	code,
	unidades_por_pieza,
	cantidad_piezas,
	comentario,
	id_ciudad,
	fecha_despacho,
	0 as disponible,
	id_farm,
	idc_farm,
	nombre_farm,
	idc_tipo_factura,
	id_tipo_factura,
	id_despacho,
	idc_cliente_despacho,
	id_vendedor,
	idc_vendedor 
	from #temp2_pb
	where disponible = 1
	and not exists 
	(
		select *
		from #temp_pb
		where #temp2_pb.id_orden_pedido_padre = #temp_pb.id_orden_pedido_padre
		and #temp2_pb.id_farm = #temp_pb.id_farm
		and #temp2_pb.id_variedad_flor = #temp_pb.id_variedad_flor
		and #temp2_pb.id_grado_flor = #temp_pb.id_grado_flor
		and #temp2_pb.id_tapa = #temp_pb.id_tapa
		and #temp2_pb.id_tipo_caja = #temp_pb.id_tipo_caja
		and datepart(dw,#temp2_pb.fecha_despacho) = datepart(dw,#temp_pb.fecha_despacho)
		and rtrim(ltrim(#temp2_pb.code)) = rtrim(ltrim(#temp_pb.marca))
		and #temp2_pb.unidades_por_pieza = #temp_pb.unidades_por_pieza
		and #temp2_pb.cantidad_piezas = #temp_pb.cantidad_piezas
		and isnull(rtrim(ltrim(#temp2_pb.comentario)), '') = isnull(rtrim(ltrim(#temp_pb.comentario)), '')
		and #temp2_pb.disponible = #temp_pb.disponible
		and #temp2_pb.fecha_despacho_inicial = #temp_pb.fecha_inicial
	)
	
	/*asignar el current salesperson cuando la orden viene con un vendedor genérico*/
	update #temp4_pb
	set id_vendedor = vendedor.id_vendedor,
	idc_vendedor = vendedor.idc_vendedor
	from vendedor, 
	cliente_factura, 
	cliente_despacho, 
	#temp4_pb, 
	configuracion_bd
	where #temp4_pb.id_vendedor = configuracion_bd.id_vendedor_global
	and #temp4_pb.id_despacho = cliente_despacho.id_despacho
	and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor

	select @id_temporada_ano = id_temporada_año_preventa from configuracion_bd

	if(@accion = 'consultar_fincas')
	begin
		/**datos para ser visualizados por los usuarios**/
		select #temp4_pb.idc_farm,
		rtrim(ltrim(#temp4_pb.nombre_farm)) as nombre_farm,
		count(*) as cantidad,
		#temp4_pb.id_farm,
		(
			select isnull(max(numero_reporte_farm), 0) + 1 
			from reporte_cambio_orden_pedido,
			farm,
			tipo_factura
			where reporte_cambio_orden_pedido.id_farm = farm.id_farm
			and farm.id_farm = #temp4_pb.id_farm
			and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
			and Reporte_Cambio_Orden_Pedido.id_temporada_año = @id_temporada_ano
		) as numero_reporte_esperado,
		farm.correo,
		isnull(tipo_archivo.id_tipo_archivo, 2) as id_tipo_archivo,
		isnull(tipo_archivo.nombre_tipo_archivo, 'PDF') as nombre_tipo_archivo,
		isnull(tipo_archivo.formato, '.pdf') as formato
		from #temp4_pb,
		farm left join tipo_archivo on tipo_archivo.id_tipo_archivo = farm.id_tipo_archivo
		where #temp4_pb.id_farm = farm.id_farm
		group by #temp4_pb.id_farm, 
		#temp4_pb.idc_farm, 
		#temp4_pb.nombre_farm,
		farm.correo,
		isnull(tipo_archivo.id_tipo_archivo, 2),
		isnull(tipo_archivo.nombre_tipo_archivo, 'PDF'),
		isnull(tipo_archivo.formato, '.pdf')
		order by #temp4_pb.idc_farm
	end
	else
	if(@accion = 'consultar_detalle_finca') 
	begin
		/*volver negativas las piezas cuando se trate de cancelaciones*/
		update #temp4_pb
		set cantidad_piezas = cantidad_piezas * -1
		from #temp4_pb
		where disponible = 0

		select idc_farm,
		nombre_farm,
		replace(Replace(idc_tipo_factura, @idc_tipo_factura, @nombre_preventa), @idc_tipo_factura_doble, @nombre_doble) as tipo_factura,
		id_orden_pedido,
		convert(int,idc_orden_pedido) as idc_orden_pedido,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor,
		nombre_tapa,
		nombre_tipo_caja,
		[dbo].[calcular_dia_vuelo_preventa] (fecha_inicial, idc_farm) as fecha_despacho_inicial, 
		datename(dw,fecha_despacho) as nombre_dia_despacho,
		marca as code, 
		unidades_por_pieza, 
		cantidad_piezas,
		rtrim(comentario) as comentario,
		datepart(dw,fecha_despacho) as id_dia_despacho,
		disponible,
		id_farm,
		idc_cliente_despacho,
		idc_vendedor
		from #temp4_pb
		where id_farm = @id_farm
		order by idc_tipo_factura, 
		fecha_despacho_inicial,
		nombre_tipo_flor,
		nombre_variedad_flor,
		nombre_grado_flor,
		code,
		nombre_tapa,
		nombre_tipo_caja,
		unidades_por_pieza,
		disponible,
		cantidad_piezas
	end
	else
	if(@accion = 'insertar_reporte') 
	begin
		select @conteo = count(*) from #temp4_pb
		
		if(@conteo <> 0)
		begin
			select @numero_reporte_farm = max(numero_reporte_farm)+1 
			from Reporte_Cambio_Orden_Pedido,
			tipo_factura,
			farm
			where Reporte_Cambio_Orden_Pedido.id_farm = farm.id_farm
			and farm.id_farm = @id_farm 
			and Reporte_Cambio_Orden_Pedido.id_tipo_factura = tipo_factura.id_tipo_factura
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
			and Reporte_Cambio_Orden_Pedido.id_temporada_año = @id_temporada_ano
			
			if (@numero_reporte_farm is null)
			begin
				set @numero_reporte_farm = 1
			end
			
			insert into Reporte_Cambio_Orden_Pedido 
			(
				id_farm,
				id_cuenta_interna,
				id_tipo_factura,
				fecha_despacho_inicial_consultada,
				numero_reporte_farm, 
				comentario,
				id_temporada_año
			)
			select @id_farm,
			@id_cuenta_interna,
			tipo_factura.id_tipo_factura,
			@fecha_despacho_cultivo,
			@numero_reporte_farm,
			null,
			@id_temporada_ano
			from tipo_factura
			where tipo_factura.idc_tipo_factura = @idc_tipo_factura

			set @id_reporte_cambio_orden_pedido = scope_identity()

			/**registros a insertar en la tablas de cambios**/
			insert into Item_Reporte_Cambio_Orden_Pedido 
			(
				id_orden_pedido,
				id_orden_pedido_padre,
				idc_orden_pedido,
				id_variedad_flor,
				id_grado_flor,
				id_tapa,
				id_tipo_caja,
				code,
				unidades_por_pieza,
				cantidad_piezas,
				comentario,
				id_reporte_cambio_orden_pedido,
				fecha_despacho_inicial,
				fecha_despacho_final,
				id_dia_despacho,
				disponible,
				id_despacho,
				id_vendedor
			)
			select id_orden_pedido,
			id_orden_pedido_padre,
			idc_orden_pedido,
			id_variedad_flor,
			id_grado_flor,
			id_tapa,
			id_tipo_caja,
			marca, 
			unidades_por_pieza, 
			cantidad_piezas,
			comentario,
			@id_reporte_cambio_orden_pedido,
			fecha_inicial, 
			fecha_final,
			datepart(dw,fecha_despacho),
			#temp4_pb.disponible,
			id_despacho,
			id_vendedor
			from #temp4_pb, 
			tipo_factura
			where id_farm = @id_farm
			and #temp4_pb.id_tipo_factura = tipo_factura.id_tipo_factura
			and tipo_factura.idc_tipo_factura = @idc_tipo_factura
			order by #temp4_pb.disponible
			
			if(@base_datos = 'BD_Fresca')
			begin
				declare @id_reporte_cambio_orden_pedido_doble int

				insert into Reporte_Cambio_Orden_Pedido 
				(
					id_farm,
					id_cuenta_interna,
					id_tipo_factura,
					fecha_despacho_inicial_consultada,
					numero_reporte_farm, 
					comentario,
					id_temporada_año
				)
				select @id_farm,
				@id_cuenta_interna,
				tipo_factura.id_tipo_factura,
				@fecha_despacho_cultivo,
				@numero_reporte_farm,
				null,
				@id_temporada_ano
				from tipo_factura
				where tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble

				set @id_reporte_cambio_orden_pedido_doble = scope_identity()

				/**registros a insertar en la tablas de cambios**/
				insert into Item_Reporte_Cambio_Orden_Pedido 
				(
					id_orden_pedido,
					id_orden_pedido_padre,
					idc_orden_pedido,
					id_variedad_flor,
					id_grado_flor,
					id_tapa,
					id_tipo_caja,
					code,
					unidades_por_pieza,
					cantidad_piezas,
					comentario,
					id_reporte_cambio_orden_pedido,
					fecha_despacho_inicial,
					fecha_despacho_final,
					id_dia_despacho,
					disponible,
					id_despacho,
					id_vendedor
				)
				select id_orden_pedido,
				id_orden_pedido_padre,
				idc_orden_pedido,
				id_variedad_flor,
				id_grado_flor,
				id_tapa,
				id_tipo_caja,
				marca, 
				unidades_por_pieza, 
				cantidad_piezas,
				comentario,
				@id_reporte_cambio_orden_pedido_doble,
				fecha_inicial, 
				fecha_final,
				datepart(dw,fecha_despacho),
				#temp4_pb.disponible,
				id_despacho,
				id_vendedor
				from #temp4_pb, 
				tipo_factura
				where id_farm = @id_farm
				and #temp4_pb.id_tipo_factura = tipo_factura.id_tipo_factura
				and tipo_factura.idc_tipo_factura = @idc_tipo_factura_doble
				order by #temp4_pb.disponible
			end

			select @numero_reporte_farm as numero_reporte_farm
		end
	end

	/*eliminación de tablas temporales*/
	drop table #temp_pb
	drop table #temp2_pb	
	drop table #temp4_pb
	drop table #ultimos_reportes_pb	
	drop table #ordenes
end