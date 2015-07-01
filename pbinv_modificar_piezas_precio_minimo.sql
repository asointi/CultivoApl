SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pbinv_modificar_piezas_precio_minimo]

@id_farm int, 
@id_tipo_flor int,
@id_variedad_flor int,
@id_grado_flor int,
@id_temporada_ano int,
@id_item_inventario_preventa int,
@precio_finca decimal(20,4),
@cantidad_piezas int,
@fecha datetime,
@accion nvarchar(50)

as

Declare @conteo int,
@fecha_inicial datetime,
@fecha_final datetime,
@nombre_tipo_caja nvarchar(50),
@id_tipo_caja nvarchar(10),
@nombre_tipo_caja_aux nvarchar(50),
@id int

if(@accion = 'consultar')
begin
	select @fecha_inicial = temporada_cubo.fecha_inicial,
	@fecha_final = temporada_cubo.fecha_final 
	from temporada_año,
	temporada_cubo,
	año,
	temporada
	where año.id_año = temporada_año.id_año
	and temporada.id_temporada = temporada_año.id_temporada
	and año.id_año = temporada_cubo.id_año
	and temporada.id_temporada = temporada_cubo.id_temporada
	and temporada_año.id_temporada_año = @id_temporada_ano

	declare @query nvarchar(1025),
	@fecha_formateada nvarchar(20),
	@fecha_formateada_saldo nvarchar(20),
	@cantidad_items int

	SELECT identity(int,1,1) as id1,
	fecha,
	'[' + convert(nvarchar, fecha, 103) + ']' as fecha_formateada,
	'[' + 'S' + convert(nvarchar, fecha, 103) + ']' as fecha_formateada_saldo INTO #FECHAS
	FROM fecha_inventario
	WHERE id_temporada_año = @id_temporada_ano
	order by fecha 

	select max(id_orden_pedido) as id_orden_pendiente into #ordenes
	from orden_pedido 
	where Orden_Pedido.id_tipo_factura = 2 
	and Orden_Pedido.disponible = 1 
	group by id_orden_pedido_padre

	select item_inventario_preventa.id_item_inventario_preventa,
	farm.idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	farm.id_farm,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	tapa.id_tapa,
	Tapa.nombre_tapa,
	tapa.idc_tapa,
	tipo_caja.id_tipo_caja,
	ltrim(rtrim(Tipo_Caja.nombre_tipo_caja)) as nombre_tipo_caja,
	ltrim(rtrim(Tipo_FLor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(Variedad_Flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(Grado_Flor.nombre_grado_flor)) as nombre_grado_flor,
	item_inventario_preventa.unidades_por_pieza, 
	marca,
	item_inventario_preventa.precio_finca,
	item_inventario_preventa.precio_minimo,
	item_inventario_preventa.empaque_principal,
	item_inventario_preventa.controla_saldos,
	detalle_item_inventario_preventa.fecha_disponible_distribuidora,
	detalle_item_inventario_preventa.cantidad_piezas,
	(
		select count(d.id_detalle_item_inventario_preventa)
		from detalle_item_inventario_preventa as d
		where item_inventario_preventa.id_item_inventario_preventa = d.id_item_inventario_preventa
	) as cantidad into #resultado
	from detalle_item_inventario_preventa, 
	item_inventario_preventa, 
	Inventario_Preventa, 
	Tapa, 
	Tipo_Caja, 
	Variedad_Flor, 
	Grado_Flor, 
	Tipo_Flor, 
	Farm,
	temporada_año
	where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
	and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
	and inventario_preventa.id_temporada_año = temporada_año.id_temporada_año
	and temporada_año.id_temporada_año = @id_temporada_ano
	and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
	and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
	and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
	and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
	and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and Inventario_Preventa.id_farm = farm.id_farm
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora in 
	(
		select fecha_inventario.fecha
		from fecha_inventario
		where temporada_año.id_temporada_año = fecha_inventario.id_temporada_año
	)
	and tipo_flor.id_tipo_flor > =
	CASE 
		WHEN @id_tipo_flor = 0 THEN 1
		else @id_tipo_flor
	end
	and tipo_flor.id_tipo_flor < =
	CASE 
		WHEN @id_tipo_flor = 0 THEN 99999
		else @id_tipo_flor
	end
	and variedad_flor.id_variedad_flor > =
	CASE 
		WHEN @id_variedad_flor = 0 THEN 1
		else @id_variedad_flor
	end
	and variedad_flor.id_variedad_flor < =
	CASE 
		WHEN @id_variedad_flor = 0 THEN 99999
		else @id_variedad_flor
	end
	and grado_flor.id_grado_flor > =
	CASE 
		WHEN @id_grado_flor = 0 THEN 1
		else @id_grado_flor
	end
	and grado_flor.id_grado_flor < =
	CASE 
		WHEN @id_grado_flor = 0 THEN 99999
		else @id_grado_flor
	end
	and farm.id_farm > =
	CASE 
		WHEN @id_farm = 0 THEN 1
		else @id_farm
	end
	and farm.id_farm < =
	CASE 
		WHEN @id_farm = 0 THEN 99999
		else @id_farm
	end

	select IDENTITY(INT,1,1) as id,
	id_item_inventario_preventa,
	idc_farm,
	id_farm,
	nombre_farm,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	nombre_tapa,
	idc_tapa,
	id_tipo_caja,
	nombre_tipo_caja,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	marca,
	precio_finca,
	precio_minimo,
	empaque_principal,
	controla_saldos,
	fecha_disponible_distribuidora as fecha,
	0 as sold,
	0 as available,
	0 as units,
	'' as p,
	'' as c into #pantalla
	from #resultado
	where empaque_principal = 1
	group by id_item_inventario_preventa,
	idc_farm,
	id_farm,
	nombre_farm,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	nombre_tapa,
	idc_tapa,
	id_tipo_caja,
	nombre_tipo_caja,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	unidades_por_pieza,
	marca,
	precio_finca,
	precio_minimo,
	empaque_principal,
	controla_saldos,
	fecha_disponible_distribuidora

	SELECT farm.id_farm, 
	tapa.id_tapa, 
	variedad_flor.id_variedad_flor, 
	grado_flor.id_grado_flor, 
	Orden_Pedido.fecha_inicial,
	orden_pedido.id_tipo_caja,
	Orden_Pedido.unidades_por_pieza,
	Orden_Pedido.marca,
	orden_pedido.cantidad_piezas,
	sum(Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as unidades_total into #orden_pedido
	FROM Orden_Pedido, 
	Variedad_Flor, 
	Tipo_Flor, 
	Grado_Flor, 
	Farm,
	Tapa
	WHERE orden_pedido.fecha_inicial between
	@fecha_inicial and @fecha_final
	and Orden_Pedido.id_tapa = Tapa.id_tapa
	and Orden_Pedido.id_farm = Farm.id_farm
	and Orden_Pedido.id_grado_flor = Grado_Flor.id_grado_flor 
	and Tipo_Flor.id_tipo_flor = Grado_Flor.id_tipo_flor
	and Orden_Pedido.id_variedad_flor = Variedad_Flor.id_variedad_flor
	and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and Orden_Pedido.id_tipo_factura = 2 
	and Orden_Pedido.disponible = 1 
	and exists
	(
		select *
		from #ordenes
		where #ordenes.id_orden_pendiente = orden_pedido.id_orden_pedido
	)
	group by farm.id_farm, 
	tapa.id_tapa, 
	variedad_flor.id_variedad_flor, 
	grado_flor.id_grado_flor, 
	Orden_Pedido.fecha_inicial,
	orden_pedido.id_tipo_caja,
	Orden_Pedido.unidades_por_pieza,
	Orden_Pedido.marca,
	orden_pedido.cantidad_piezas

	alter table #fechas 
	add fecha_inicial datetime,
	fecha_final datetime,
	id int

	update #fechas
	set id = id1

	set @id = 1
	select @conteo = count(*) from #fechas

	while (@conteo > 0)
	begin
		update #fechas
		set fecha_final = (select dateadd(dd, -1, fecha) from #fechas where id = @id + 1),
		fecha_inicial = @fecha_inicial
		where id = @id

		if(@conteo = 1)
		begin
			update #fechas
			set fecha_final = @fecha_final,
			fecha_inicial = fecha
			where id = @id
		end

		set @conteo = @conteo - 1
		set @id = @id + 1
	end

	insert into #fechas (id, fecha, fecha_formateada, fecha_formateada_saldo, fecha_inicial, fecha_final)
	SELECT 0 as id,
	temporada_cubo.fecha_inicial as fecha,
	'[' + convert(nvarchar, temporada_cubo.fecha_inicial, 103) + ']' as fecha_formateada,
	'[' + 'S' + convert(nvarchar, temporada_cubo.fecha_inicial, 103) + ']' as fecha_formateada_saldo,
	temporada_cubo.fecha_inicial,
	temporada_cubo.fecha_final
	FROM temporada_cubo,
	temporada_año,
	temporada,
	año
	WHERE temporada_año.id_temporada_año = @id_temporada_ano
	and temporada.id_temporada = temporada_año.id_temporada
	and año.id_año = temporada_año.id_año
	and temporada.id_temporada = temporada_cubo.id_temporada
	and año.id_año = temporada_cubo.id_año

	select cantidad,
	id_item_inventario_preventa into #rango_fecha
	from #resultado
	where #resultado.empaque_principal = 1
	group by #resultado.cantidad,
	#resultado.id_item_inventario_preventa

	set @conteo = 1
	
	select @cantidad_items = count(*) from #fechas where id > 0

	while (@conteo < = @cantidad_items)
	begin
		select id_item_inventario_preventa,
		sum(cantidad_piezas) as cantidad_piezas,
		(
			select sum(unidades_total)
			from #orden_pedido
			where #resultado.id_farm = #orden_pedido.id_farm
			and #resultado.id_variedad_flor = #orden_pedido.id_variedad_flor
			and #resultado.id_grado_flor = #orden_pedido.id_grado_flor
			and #resultado.id_tapa = #orden_pedido.id_tapa
			and #orden_pedido.fecha_inicial between
			#fechas.fecha_inicial and #fechas.fecha_final
		)/ #resultado.unidades_por_pieza as cantidad_piezas_vendidas into #data
		from #resultado,
		#fechas
		where fecha_disponible_distribuidora = #fechas.fecha
		and #fechas.id = @conteo
		and #resultado.empaque_principal = 1
		and #resultado.cantidad > 1
		group by #resultado.id_item_inventario_preventa,
		#resultado.id_farm,
		#resultado.id_variedad_flor,
		#resultado.id_grado_flor,
		#resultado.id_tapa,
		#resultado.unidades_por_pieza,
		#fechas.fecha_inicial,
		#fechas.fecha_final
		union all
		select id_item_inventario_preventa,
		sum(cantidad_piezas) as cantidad_piezas,
		(
			select sum(unidades_total)
			from #orden_pedido
			where #resultado.id_farm = #orden_pedido.id_farm
			and #resultado.id_variedad_flor = #orden_pedido.id_variedad_flor
			and #resultado.id_grado_flor = #orden_pedido.id_grado_flor
			and #resultado.id_tapa = #orden_pedido.id_tapa
			and #orden_pedido.fecha_inicial between
			#fechas.fecha_inicial and #fechas.fecha_final
		)/ #resultado.unidades_por_pieza as cantidad_piezas_vendidas
		from #resultado,
		#fechas
		where #fechas.id = 0
		and #resultado.empaque_principal = 1
		and #resultado.cantidad = 1
		group by #resultado.id_item_inventario_preventa,
		#resultado.id_farm,
		#resultado.id_variedad_flor,
		#resultado.id_grado_flor,
		#resultado.id_tapa,
		#resultado.unidades_por_pieza,
		#fechas.fecha_inicial,
		#fechas.fecha_final

		delete from #fechas where id = 0

		select @fecha_formateada = fecha_formateada,
		@fecha_formateada_saldo = fecha_formateada_saldo
		from #fechas
		where id = @conteo

		set @query = null
		set @query = 'ALTER TABLE #pantalla ADD '+ @fecha_formateada + ' int, ' + @fecha_formateada_saldo + ' int'

		exec (@query)

		set @query = null
		set @query = 'update #pantalla set ' + @fecha_formateada + ' = #data.cantidad_piezas, ' + @fecha_formateada_saldo + ' = #data.cantidad_piezas_vendidas from #data where #pantalla.id_item_inventario_preventa = #data.id_item_inventario_preventa' 

		exec (@query)

		set @conteo = @conteo + 1
		
		drop table #data
	end

	select identity(int,1,1) as id,
	id_tipo_caja into #tipo_caja
	from #resultado
	where empaque_principal = 0
	group by id_tipo_caja
	order by id_tipo_caja

	select id_item_inventario_preventa,
	id_farm,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	fecha_disponible_distribuidora into #empaque_principal
	from #resultado
	where empaque_principal = 1	

	select id_farm,
	id_variedad_flor,
	id_grado_flor,
	id_tapa,
	fecha_disponible_distribuidora,
	id_tipo_caja,
	unidades_por_pieza into #empaque_total
	from #resultado

	select #empaque_principal.id_item_inventario_preventa,
	#empaque_total.id_tipo_caja * -1 as id_tipo_caja,
	#empaque_total.unidades_por_pieza into #comparacion_tipo_caja
	from #empaque_principal,
	#empaque_total
	where #empaque_principal.id_farm = #empaque_total.id_farm
	and #empaque_principal.id_variedad_flor = #empaque_total.id_variedad_flor
	and #empaque_principal.id_grado_flor = #empaque_total.id_grado_flor
	and #empaque_principal.id_tapa = #empaque_total.id_tapa
	and #empaque_principal.fecha_disponible_distribuidora = #empaque_total.fecha_disponible_distribuidora
	group by #empaque_principal.id_item_inventario_preventa,
	#empaque_total.id_tipo_caja,
	#empaque_total.unidades_por_pieza

	select #resultado.id_item_inventario_preventa,
	sum(#orden_pedido.cantidad_piezas) as cantidad_piezas,
	#orden_pedido.unidades_por_pieza,
	#orden_pedido.id_farm,
	#orden_pedido.id_tapa,
	#orden_pedido.id_variedad_flor,
	#orden_pedido.id_grado_flor,
	#orden_pedido.id_tipo_caja into #items_prevendidos
	from #orden_pedido,
	#resultado
	where #orden_pedido.id_farm = #resultado.id_farm
	and #orden_pedido.id_tapa = #resultado.id_tapa
	and #orden_pedido.id_variedad_flor = #resultado.id_variedad_flor
	and #orden_pedido.id_grado_flor = #resultado.id_grado_flor
	and #orden_pedido.id_tipo_caja = #resultado.id_tipo_caja
	and #orden_pedido.unidades_por_pieza = #resultado.unidades_por_pieza
	group by #resultado.id_item_inventario_preventa,
	#orden_pedido.unidades_por_pieza,
	#orden_pedido.id_farm,
	#orden_pedido.id_tapa,
	#orden_pedido.id_variedad_flor,
	#orden_pedido.id_grado_flor,
	#orden_pedido.id_tipo_caja

	set @conteo = 1
	select  @cantidad_items = count(*) from #tipo_caja

	while (@conteo < = @cantidad_items)
	begin
		select @nombre_tipo_caja = 'ZZ' + convert(nvarchar,#tipo_caja.ID_TIPO_CAJA) + ltrim(rtrim(nombre_tipo_caja)),
		@nombre_tipo_caja_aux = 'TT' + convert(nvarchar,#tipo_caja.ID_TIPO_CAJA) + ltrim(rtrim(nombre_tipo_caja)),
		@id_tipo_caja = #tipo_caja.ID_TIPO_CAJA * -1
		from tipo_caja,
		#tipo_caja
		where tipo_caja.id_tipo_caja = #tipo_caja.id_tipo_caja
		and #tipo_caja.id = @conteo
		order by ltrim(rtrim(nombre_tipo_caja))

		set @query = 'ALTER TABLE #pantalla ADD '+ @nombre_tipo_caja + ' int'
		exec (@query)

		set @query = 'ALTER TABLE #pantalla ADD '+ @nombre_tipo_caja_aux + ' int'
		exec (@query)

		set @query = 'UPDATE #pantalla Set '+ @nombre_tipo_caja + ' = ' + @id_tipo_caja + ', ' +
		@nombre_tipo_caja_aux + ' = ' + @id_tipo_caja
		exec (@query)

		set @query = 'UPDATE #pantalla Set '+ @nombre_tipo_caja + ' = convert(nvarchar,#comparacion_tipo_caja.unidades_por_pieza) 
		from #comparacion_tipo_caja ' + 
		' where ' + @nombre_tipo_caja + ' = convert(nvarchar, #comparacion_tipo_caja.id_tipo_caja) ' +
		' and #pantalla.id_item_inventario_preventa = #comparacion_tipo_caja.id_item_inventario_preventa'
		exec (@query)

		set @query = 'UPDATE #pantalla Set '+ @nombre_tipo_caja + ' = null where ' + @nombre_tipo_caja + ' < 0' 
		exec (@query)

		set @query = 'UPDATE #pantalla Set '+ @nombre_tipo_caja_aux + ' = convert(nvarchar,#items_prevendidos.cantidad_piezas) 
		from #items_prevendidos ' + 
		' where ' + @nombre_tipo_caja_aux + ' = convert(nvarchar, #items_prevendidos.id_tipo_caja * -1) ' +
		' and #pantalla.id_item_inventario_preventa = #items_prevendidos.id_item_inventario_preventa' +
		' and #pantalla.unidades_por_pieza = #items_prevendidos.unidades_por_pieza' +
		' and #pantalla.id_farm = #items_prevendidos.id_farm' +
		' and #pantalla.id_tapa = #items_prevendidos.id_tapa' +
		' and #pantalla.id_variedad_flor = #items_prevendidos.id_variedad_flor' +
		' and #pantalla.id_grado_flor = #items_prevendidos.id_grado_flor'

		exec (@query)

		set @query = 'UPDATE #pantalla Set '+ @nombre_tipo_caja_aux + ' = null where ' + @nombre_tipo_caja_aux + ' < 0' 
		exec (@query)

		set @conteo = @conteo + 1
	end

	SELECT MAX(ID) AS ID INTO #MAXIMOS_ID
	FROM #PANTALLA
	group by id_item_inventario_preventa

	select id_item_inventario_preventa INTO #ITEM_A_BORRAR
	from #pantalla
	group by id_item_inventario_preventa
	having count(*) > 1

	DELETE FROM #PANTALLA
	WHERE id_item_inventario_preventa in
	(
		select id_item_inventario_preventa 
		from #ITEM_A_BORRAR
	)
	and id not in
	(
		SELECT ID 
		from #MAXIMOS_ID
	)

	select * 
	from #pantalla
	order by nombre_farm,
	nombre_tipo_flor, 
	nombre_variedad_flor, 
	nombre_grado_flor,
	nombre_tapa

	drop table #fechas
	drop table #resultado
	drop table #pantalla
	drop table #ordenes
	drop table #orden_pedido
	drop table #tipo_caja
	drop table #comparacion_tipo_caja
	drop table #empaque_principal
	drop table #empaque_total
	drop table #items_prevendidos
	drop table #MAXIMOS_ID
	drop table #ITEM_A_BORRAR
	drop table #rango_fecha
end
else
if(@accion = 'actualizar_precio')
begin
	update item_inventario_preventa
	set precio_finca = @precio_finca
	where id_item_inventario_preventa  = @id_item_inventario_preventa
end
else
if(@accion = 'actualizar_cantidad_piezas')
begin
	select @conteo = count(*)
	from item_inventario_preventa,
	detalle_item_inventario_preventa
	where item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora = @fecha

	if(@conteo > 0)
	begin
		update detalle_item_inventario_preventa
		set cantidad_piezas = @cantidad_piezas
		where id_item_inventario_preventa  = @id_item_inventario_preventa
		and fecha_disponible_distribuidora = @fecha
	end
	else
	begin
		declare @id_detalle_item_inventario_preventa int

		insert into detalle_item_inventario_preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, cantidad_piezas_adicionales_finca, cantidad_piezas_ofertadas_finca)
		values (@id_item_inventario_preventa, @fecha, @cantidad_piezas, 0, 0)

		set @id_detalle_item_inventario_preventa = scope_identity()

		update detalle_item_inventario_preventa
		set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
		where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa
	end
end