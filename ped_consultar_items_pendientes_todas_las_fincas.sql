/****** Object:  StoredProcedure [dbo].[ped_consultar_items_pendientes]    Script Date: 04/23/2008 13:06:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[ped_consultar_items_pendientes_todas_las_fincas]

AS
BEGIN

declare @dias_atras int, 
@id_tipo_despacho int,
@id_tipo_despacho_corrimiento int, 
@id_tipo_despacho_despacho int,
@idc_tipo_factura_doble nvarchar(255),
@nombre_preventa nvarchar(255),
@nombre_doble nvarchar(255),
@nombre_so nvarchar(255),
@tipo_factura_corrimiento nvarchar(255),
@idc_tipo_factura nvarchar(255),
@fecha_despacho_cultivo datetime

select @dias_atras = cantidad_dias_despacho_finca from Configuracion_bd
set @id_tipo_despacho = 1
set @id_tipo_despacho_despacho = 2
set @id_tipo_despacho_corrimiento = 3
set @idc_tipo_factura = '9'
set @idc_tipo_factura_doble = '7'
set @nombre_preventa = 'Preventa'
set @nombre_doble = 'Doblaje'
set @nombre_so = 'SO'

set @fecha_despacho_cultivo = convert(datetime, convert(nvarchar , getdate(), 103))

IF(@idc_tipo_factura = '9')
begin
	set @tipo_factura_corrimiento = 'all'

	/*seleccionar las ordenes desde Orden_Pedido en el rango de fechas solicitado*/
	select 
	Orden_Pedido.id_orden_pedido,
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
	datepart(dw,orden_pedido.fecha_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
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
	/*********************************************************************************************************/
	/*********************************************************************************************************/
	/*****************************************Tabla #temp*****************************************************/
	/**********************************ordenes traídas desde Orden_Pedido*************************************/
	/*********************************************************************************************************/
	/*********************************************************************************************************/

	/*alterar tabla temporal para realizar cálculos de días de corrimientos*/
	alter table #temp
	add id_tipo_despacho int, 
	id_tipo_despacho_aux int, 
	corrimiento bit, 
	nombre_dia_despacho nvarchar(255), 
	forma_despacho int

	/*traer datos para los corrimientos de ordenes fijas por finca*/
	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	forma_despacho = 1
	from tipo_despacho, 
	#temp, 
	forma_despacho_farm, 
	dia_despacho,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and forma_despacho_farm.id_farm = #temp.id_farm
	and forma_despacho_farm.id_dia_despacho = #temp.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*traer datos para los corrimientos de ordenes fijas por ciudad*/
	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	forma_despacho = 0
	from tipo_despacho, 
	#temp, 
	forma_despacho_ciudad, 
	dia_despacho,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and forma_despacho_ciudad.id_ciudad = #temp.id_ciudad
	and forma_despacho_ciudad.id_dia_despacho = #temp.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and #temp.forma_despacho is null
	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/
	/*********************CORRIMIENTOS POR CIUDAD*********************/
	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/

	/*aumentar un dia a las ordenes*/
	update #temp
	set id_dia_despacho = replace(id_dia_despacho+1,8,1)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 0

	/*actualizar el día de despacho después del aumento de día del punto anterior*/
	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_ciudad, 
	#temp,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 0
	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
	
	/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
	update #temp
	set id_tipo_despacho = @id_tipo_despacho,
	id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
	and forma_despacho = 0

	update #temp
	set corrimiento = 1
	where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
	and forma_despacho = 0

	/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
	while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 0))
	begin
		update #temp
		set id_dia_despacho = replace(id_dia_despacho-1,0,7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 0

		update #temp
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_ciudad, 
		#temp,
		tipo_factura
		where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
		and #temp.id_ciudad = forma_despacho_ciudad.id_ciudad
		and #temp.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
		and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
		and forma_despacho = 0
		and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
	end

	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/
	/*********************CORRIMIENTOS POR FINCA**********************/
	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/

	/*aumentar un dia a las ordenes*/
	update #temp
	set id_dia_despacho = replace(id_dia_despacho+1,8,1)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 1

	/*actualizar el día de despacho después del aumento de día del punto anterior*/
	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_farm, 
	#temp,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and #temp.id_farm = forma_despacho_farm.id_farm
	and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 1
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
	update #temp
	set id_tipo_despacho = @id_tipo_despacho,
	id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
	and forma_despacho = 1

	update #temp
	set corrimiento = 1
	where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
	and forma_despacho = 1

	/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
	while(@id_tipo_despacho in (select id_tipo_despacho from #temp where forma_despacho = 1))
	begin
		update #temp
		set id_dia_despacho = replace(id_dia_despacho-1,0,7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 1

		update #temp
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_farm, 
		#temp,
		tipo_factura
		where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
		and #temp.id_farm = forma_despacho_farm.id_farm
		and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
		and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
		and forma_despacho = 1
		and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
	end

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
	select id_orden_pedido,
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
	fecha_despacho_inicial,
	fecha_despacho_final,
	datepart(dw,item_reporte_cambio_orden_pedido.fecha_despacho_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
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
	and exists
	(
		select * from #ultimos_reportes
		where item_reporte_cambio_orden_pedido.id_item_reporte_cambio_orden_pedido = #ultimos_reportes.id_item_reporte_cambio_orden_pedido
	)

	/*********************************************************************************************************/
	/*********************************************************************************************************/
	/*****************************************Tabla #temp2****************************************************/
	/*************************ordenes traídas desde Reporte_Cambio_Orden_Pedido*******************************/
	/*********************************************************************************************************/
	/*********************************************************************************************************/

	/*alterar tabla temporal para realizar cálculos de días de corrimientos*/
	alter table #temp2
	add id_tipo_despacho int, 
	id_tipo_despacho_aux int, 
	corrimiento bit, 
	nombre_dia_despacho nvarchar(255), 
	forma_despacho integer

	/*traer datos para los corrimientos de ordenes fijas por finca*/
	update #temp2
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	forma_despacho = 1
	from tipo_despacho, 
	#temp2, 
	forma_despacho_farm, 
	dia_despacho,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and forma_despacho_farm.id_farm = #temp2.id_farm
	and forma_despacho_farm.id_dia_despacho = #temp2.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*traer datos para los corrimientos de ordenes fijas por ciudad*/
	update #temp2
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	forma_despacho = 0
	from tipo_despacho, 
	#temp2, 
	forma_despacho_ciudad, 
	dia_despacho,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and forma_despacho_ciudad.id_ciudad = #temp2.id_ciudad
	and forma_despacho_ciudad.id_dia_despacho = #temp2.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and #temp2.forma_despacho is null
	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura  = @tipo_factura_corrimiento

	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/
	/*********************CORRIMIENTOS POR CIUDAD*********************/
	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/

	/*aumentar un dia a las ordenes*/
	update #temp2
	set id_dia_despacho = replace(id_dia_despacho+1,8,1)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 0

	/*actualizar el día de despacho después del aumento de día del punto anterior*/
	update #temp2
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_ciudad, 
	#temp2,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp2.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp2.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 0
	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
	update #temp2
	set id_tipo_despacho = @id_tipo_despacho,
	id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
	and forma_despacho = 0

	update #temp2
	set corrimiento = 1
	where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
	and forma_despacho = 0

	/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
	while(@id_tipo_despacho in (select id_tipo_despacho from #temp2 where forma_despacho = 0))
	begin
		update #temp2
		set id_dia_despacho = replace(id_dia_despacho-1,0,7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 0

		update #temp2
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_ciudad, 
		#temp2,
		tipo_factura
		where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
		and #temp2.id_ciudad = forma_despacho_ciudad.id_ciudad
		and #temp2.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
		and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
		and forma_despacho = 0
		and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
	end

	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/
	/*********************CORRIMIENTOS POR FINCA**********************/
	/*****************************************************************/
	/*****************************************************************/
	/*****************************************************************/

	/*aumentar un dia a las ordenes*/
	update #temp2
	set id_dia_despacho = replace(id_dia_despacho+1,8,1)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 1

	/*actualizar el día de despacho después del aumento de día del punto anterior*/
	update #temp2
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_farm, 
	#temp2,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and #temp2.id_farm = forma_despacho_farm.id_farm
	and #temp2.id_dia_despacho = forma_despacho_farm.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 1
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
	update #temp2
	set id_tipo_despacho = @id_tipo_despacho,
	id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho_despacho 
	and id_tipo_despacho_aux = @id_tipo_despacho
	and forma_despacho = 1

	update #temp2
	set corrimiento = 1
	where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
	and forma_despacho = 1

	/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
	while(@id_tipo_despacho in (select id_tipo_despacho from #temp2 where forma_despacho = 1))
	begin
		update #temp2
		set id_dia_despacho = replace(id_dia_despacho-1,0,7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 1

		update #temp2
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_farm, 
		#temp2,
		tipo_factura
		where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
		and #temp2.id_farm = forma_despacho_farm.id_farm
		and #temp2.id_dia_despacho = forma_despacho_farm.id_dia_despacho
		and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
		and forma_despacho = 1
		and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
	end
	
	/*********************************************************************/
	/**seleccionar los registros que se encuentran iguales
	entre lo ya reportado y lo faltante por reportar, esto se realiza
	debido a que las ordenes sufren cambios en su fecha de finalizacion
	pero en sus demas atributos a excepcion  del idc_orden_pedido todos
	los campos son exactamente iguales**/
	/*********************************************************************/
	select #temp2.id_orden_pedido,
	#temp2.id_orden_pedido_padre,
	#temp.fecha_inicial,
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
	and #temp.id_dia_despacho = #temp2.id_dia_despacho
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
		select * from #ultimos_reportes
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
	id_tipo_despacho,
	id_dia_despacho,
	nombre_dia_despacho,
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
	and #temp.id_dia_despacho = #temp2.id_dia_despacho
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
		id_tipo_despacho,
		id_dia_despacho,
		nombre_dia_despacho,
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
	id_tipo_despacho,
	id_dia_despacho,
	nombre_dia_despacho,
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
		and #temp2.id_dia_despacho = #temp.id_dia_despacho
		and rtrim(ltrim(#temp2.code)) = rtrim(ltrim(#temp.marca))
		and #temp2.unidades_por_pieza = #temp.unidades_por_pieza
		and #temp2.cantidad_piezas = #temp.cantidad_piezas
		and isnull(rtrim(ltrim(#temp2.comentario)), '') = isnull(rtrim(ltrim(#temp.comentario)), '')
		and #temp2.disponible = #temp.disponible
	)

	/**procedimientos para calcular la fecha de vuelo**/
	update #temp4
	set fecha_inicial = getdate()
	from #temp4
	where datepart(dw,fecha_inicial) = datepart(dw,getdate())

	update #temp4
	set fecha_inicial = getdate()+(datepart(dw,fecha_inicial)-datepart(dw,getdate()))
	from #temp4
	where datepart(dw,getdate()) < datepart(dw,fecha_inicial)

	update #temp4
	set fecha_inicial = (getdate()+(datepart(dw,fecha_inicial)-datepart(dw,getdate())))+7
	from #temp4
	where datepart(dw,getdate()) > datepart(dw,fecha_inicial)

	/*volver negativas las piezas cuando se trate de cancelaciones*/
	update #temp4
	set cantidad_piezas = cantidad_piezas*-1
	from #temp4
	where disponible = 0

	/*procedimientos para asignar fechas en la semana actual o la semana siguiente*/
	create table #wk (fecha datetime)
	DECLARE @day INT
	DECLARE @today SMALLDATETIME
	SET @today = CONVERT(datetime, @fecha_despacho_cultivo, 110)
	SET @day = DATEPART(dw, @today)
	insert into #wk
	SELECT DATEADD(dd, 1 - @day, @today)
	insert into #wk
	select DATEADD(dd, 2 - @day, @today)
	insert into #wk
	select DATEADD(dd, 3 - @day, @today)
	insert into #wk
	select DATEADD(dd, 4 - @day, @today)
	insert into #wk
	select DATEADD(dd, 5 - @day, @today)
	insert into #wk
	select DATEADD(dd, 6 - @day, @today)
	insert into #wk
	select DATEADD(dd, 7 - @day, @today)

	update #temp4
	set fecha_inicial = #wk.fecha
	from #temp4, #wk
	where datepart(dw, #temp4.fecha_inicial)=datepart(dw, #wk.fecha)

	create table #wk1 (fecha datetime)
	DECLARE @day1 INT
	DECLARE @today1 SMALLDATETIME
	SET @today1 = CONVERT(datetime, @fecha_despacho_cultivo+7, 110)
	SET @day1 = DATEPART(dw, @today1)
	insert into #wk1
	SELECT DATEADD(dd, 1 - @day1, @today1)
	insert into #wk1
	select DATEADD(dd, 2 - @day1, @today1)
	insert into #wk1
	select DATEADD(dd, 3 - @day1, @today1)
	insert into #wk1
	select DATEADD(dd, 4 - @day1, @today1)
	insert into #wk1
	select DATEADD(dd, 5 - @day1, @today1)
	insert into #wk1
	select DATEADD(dd, 6 - @day1, @today1)
	insert into #wk1
	select DATEADD(dd, 7 - @day1, @today1)

	update #temp4
	set fecha_inicial = #wk1.fecha
	from #temp4, 
	#wk1
	where datepart(dw, #temp4.fecha_inicial)=datepart(dw, #wk1.fecha)
	and #temp4.fecha_inicial<@fecha_despacho_cultivo

	/*asignar el current salesperson cuando la orden viene con un vendedor genérico*/
	update #temp4
	set id_vendedor = vendedor.id_vendedor,
	idc_vendedor = vendedor.idc_vendedor
	from vendedor, 
	cliente_factura, 
	cliente_despacho, 
	#temp4, 
	configuracion_bd
	where #temp4.id_vendedor = configuracion_bd.id_vendedor_global
	and #temp4.id_despacho = cliente_despacho.id_despacho
	and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor

	/**datos para ser visualizados por los usuarios**/
	select 
	idc_farm,
	nombre_farm,
	@nombre_so as tipo_factura,
	id_orden_pedido,
	convert(nvarchar,left(convert(int,idc_orden_pedido),len(convert(int,idc_orden_pedido))-2)) + '-' + right(convert(int,idc_orden_pedido),2) as idc_orden_pedido,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tapa,
	nombre_tipo_caja,
	fecha_inicial as fecha_despacho_inicial, 
	nombre_dia_despacho,
	marca as code, 
	unidades_por_pieza, 
	cantidad_piezas,
	rtrim(comentario) as comentario,
	id_dia_despacho,
	disponible,
	id_farm,
	idc_cliente_despacho,
	idc_vendedor
	from #temp4 
	order by 
	idc_farm,
	nombre_farm,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	code,
	nombre_tapa,
	nombre_tipo_caja,
	unidades_por_pieza,
	disponible,
	id_dia_despacho,
	cantidad_piezas

	/*eliminación tablas temporales*/
	drop table #temp
	drop table #temp2
	drop table #temp3
	drop table #temp4
	drop table #wk
	drop table #wk1
end
END