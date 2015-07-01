set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-01-06
-- Description:	Generar informacion para G&G
-- =============================================

alter PROCEDURE [dbo].[na_generar_datos_gg]

@accion nvarchar(255),
@id_producto int,
@id_farm int,
@numero_reporte_farm int

AS

declare @dias_atras int, 
@id_tipo_despacho int,
@id_tipo_despacho_corrimiento int, 
@id_tipo_despacho_despacho int,
@tipo_factura_corrimiento nvarchar(255),
@idc_tipo_factura nvarchar(255),
@fecha_despacho_cultivo datetime,
@id_reporte_cambio_orden_pedido int,
@id_tipo_factura int,
@tipo_orden_nueva nvarchar(255),
@tipo_orden_cancelada nvarchar(255)

select @dias_atras = cantidad_dias_despacho_finca from Configuracion_bd
set @id_tipo_despacho = 1
set @id_tipo_despacho_despacho = 2
set @id_tipo_despacho_corrimiento = 3
set @idc_tipo_factura = '9'
set @fecha_despacho_cultivo = convert(datetime,convert(nvarchar, getdate(), 103))
select @id_tipo_factura = id_tipo_factura from tipo_factura
where idc_tipo_factura = @idc_tipo_factura
set @tipo_orden_nueva = 'Nuevo'
set @tipo_orden_cancelada = 'Cancelado'

if(@accion = 'carrier')
begin
	select id_transportador,
	idc_transportador,
	nombre_transportador,
	direccion_transportador,
	cuenta_transportador 
	from transportador
	order by idc_transportador
end
else
if(@accion = 'farm')
begin
	select farm.id_farm,
	idc_farm,
	id_tipo_farm,
	ciudad.id_ciudad,
	ciudad.nombre_ciudad,
	nombre_farm	 
	from farm,
	ciudad
	where farm.id_ciudad = ciudad.id_ciudad
	order by idc_farm
end
else
if(@accion = 'state')
begin
	select id_ciudad,
	idc_ciudad,
	codigo_aeropuerto,
	nombre_ciudad,
	impuesto_por_caja
	from ciudad
	order by idc_ciudad
end
else
if(@accion = 'uom')
begin
	select caja.id_caja,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_tipo_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_tipo_caja,
	tipo_caja.factor_a_full,
	tipo_caja.nombre_abreviado_tipo_caja
	from tipo_caja,
	caja
	where caja.disponible = 1
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	order by idc_tipo_caja
end
else
if(@accion = 'producto')
begin
	insert into Producto_GG
	(
	descripcion,
	idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor,
	nombre_color,
	nombre_tipo_caja,
	unidades_por_pieza,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor
	)
	select ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)) as descripcion,
	--tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + grado_flor.idc_grado_flor as descripcion,
	tipo_flor.idc_tipo_flor + ' - ' + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as idc_tipo_flor,
	variedad_flor.idc_variedad_flor + ' - ' + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as idc_variedad_flor,
	grado_flor.idc_grado_flor + ' - ' + ltrim(rtrim(grado_flor.nombre_grado_flor)) as idc_grado_flor,
	color.idc_color + ' - ' + ltrim(rtrim(color.nombre_color)) as nombre_color,
	ltrim(rtrim(max(tipo_caja.nombre_tipo_caja))) as nombre_tipo_caja,
	max(pieza.unidades_por_pieza) as unidades_por_pieza,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor
	from pieza,
	variedad_flor left join color on variedad_flor.id_color = color.id_color, 
	tipo_flor, 
	grado_flor,
	caja,
	tipo_caja
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza.id_grado_flor = grado_flor.id_grado_flor
	and pieza.id_caja = caja.id_caja
	and caja.id_tipo_caja = tipo_caja.id_tipo_caja
	and not exists
	(
		select * from Producto_GG
		where Producto_GG.id_tipo_flor = tipo_flor.id_tipo_flor
		and Producto_GG.id_variedad_flor = variedad_flor.id_variedad_flor
		and Producto_GG.id_grado_flor = grado_flor.id_grado_flor
)
	group by ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	grado_flor.idc_grado_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	color.nombre_color,
	color.idc_color,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor

	select id_producto, 
	descripcion, --ProductDesc
	idc_tipo_flor, --Category
	idc_variedad_flor, --SubTegory - Variety
	idc_grado_flor, --Grade
	nombre_color, --Color
	nombre_tipo_caja, --DefaultUOM
	unidades_por_pieza --DefaultUnitsperUOM
	from Producto_GG
	where migrado = 0	
	order by descripcion
end
else
if(@accion = 'producto_migrado')
begin
	update producto_gg
	set migrado = 1
	where id_producto = @id_producto
end
else
if(@accion = 'customer')
begin
	select cliente_factura.id_cliente_factura,
	idc_cliente_factura as nombre,
	cliente_despacho.contacto as nombre_contacto,
	cliente_despacho.direccion,
	cliente_despacho.ciudad,
	cliente_despacho.estado,
	cliente_despacho.telefono,
	replace(ltrim(rtrim(nombre)), ' ', '_') as username
	from cliente_factura, 
	cliente_despacho,
	vendedor
	where cliente_factura.idc_cliente_factura = cliente_despacho.idc_cliente_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor
	and cliente_factura.disponible = 1
	order by nombre	
end
else
if(@accion = 'customer_shipto')
begin
	select cliente_despacho.id_despacho,
	(
		select cliente_factura.idc_cliente_factura
		from cliente_factura
		where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	) as nombre,	
	cliente_despacho.idc_cliente_despacho + ' ' + ltrim(rtrim(cliente_despacho.nombre_cliente)) as personname,
	cliente_despacho.direccion,
	cliente_despacho.ciudad,
	cliente_despacho.estado,
	cliente_despacho.telefono
	from cliente_despacho
	order by nombre
end
else
if(@accion = 'tapa')
begin
	select id_tapa,
	idc_tapa,
	ltrim(rtrim(nombre_tapa)) as nombre_tapa
	from tapa
	where tapa.disponible = 1
	order by ltrim(rtrim(nombre_tapa))
end
else
if (@accion = 'ordenes_actuales')
begin
	set @tipo_factura_corrimiento = 'all'
	
	/*seleccionar las ordenes desde item_reporte_cambio_orden_pedido actuales*/
	select 
	item_reporte_cambio_orden_pedido.idc_orden_pedido,
	cliente_despacho.idc_cliente_despacho,
	cliente_factura.id_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	farm.id_farm,	
	farm.idc_farm,
	farm.nombre_farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	item_reporte_cambio_orden_pedido.unidades_por_pieza, 
	tipo_caja.nombre_tipo_caja,
	tipo_caja.factor_a_full,
	item_reporte_cambio_orden_pedido.cantidad_piezas,
	item_reporte_cambio_orden_pedido.comentario,	
	tapa.nombre_tapa,
	tapa.idc_tapa,
	item_reporte_cambio_orden_pedido.code, 
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial,
	item_reporte_cambio_orden_pedido.fecha_despacho_final,
	ciudad.id_ciudad,
	datepart(dw,item_reporte_cambio_orden_pedido.fecha_despacho_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
	item_reporte_cambio_orden_pedido.id_orden_pedido into #temp
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
	tipo_factura,
	cliente_despacho,
	cliente_factura
	where 
	(getdate() between
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial and item_reporte_cambio_orden_pedido.fecha_despacho_final
	or 
	getdate() + 6 between
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
	and item_reporte_cambio_orden_pedido.id_despacho = cliente_despacho.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
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
	forma_despacho int,
	fecha_inicial datetime,
	idc_transportador nvarchar(255),
	valor_unitario decimal(20,4),
	valor_pactado decimal(20,4),
	fecha_vuelo_finca datetime

	/*traer datos para los corrimientos de ordenes fijas por finca*/
	update #temp
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	forma_despacho = 1
	from tipo_despacho, 
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
	set id_dia_despacho = replace(id_dia_despacho + 1, 8, 1)
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
	id_dia_despacho = replace(id_dia_despacho - 1, 0, 7)
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
		set id_dia_despacho = replace(id_dia_despacho - 1, 0, 7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 0

		update #temp
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_ciudad, 
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
	set id_dia_despacho = replace(id_dia_despacho + 1, 8, 1)
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
	id_dia_despacho = replace(id_dia_despacho - 1, 0, 7)
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
		set id_dia_despacho = replace(id_dia_despacho - 1, 0, 7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 1

		update #temp
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_farm, 
		tipo_factura
		where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
		and #temp.id_farm = forma_despacho_farm.id_farm
		and #temp.id_dia_despacho = forma_despacho_farm.id_dia_despacho
		and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
		and forma_despacho = 1
		and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
	end

	/**procedimientos para calcular la fecha de despacho de la orden en la distribuidora**/
	update #temp
	set fecha_inicial = getdate()
	where datepart(dw,fecha_despacho_inicial) = datepart(dw,getdate())

	update #temp
	set fecha_inicial = getdate()+(datepart(dw,fecha_despacho_inicial)-datepart(dw,getdate()))
	where datepart(dw,getdate()) < datepart(dw,fecha_despacho_inicial)

	update #temp
	set fecha_inicial = (getdate()+(datepart(dw,fecha_despacho_inicial)-datepart(dw,getdate())))+7
	where datepart(dw,getdate()) > datepart(dw,fecha_despacho_inicial)

	/**procedimientos para calcular la fecha de vuelo de la finca**/
	update #temp
	set fecha_vuelo_finca = getdate()
	where id_dia_despacho = datepart(dw,getdate())

	update #temp
	set fecha_vuelo_finca = getdate()+(id_dia_despacho - datepart(dw,getdate()))
	where datepart(dw,getdate()) < id_dia_despacho

	update #temp
	set fecha_vuelo_finca = (getdate()+(id_dia_despacho - datepart(dw,getdate()))) + 7
	where datepart(dw,getdate()) > id_dia_despacho

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

	update #temp
	set fecha_inicial = #wk.fecha
	from #wk
	where datepart(dw, #temp.fecha_inicial) = datepart(dw, #wk.fecha)

	update #temp
	set fecha_vuelo_finca = #wk.fecha
	from #wk
	where datepart(dw, #temp.fecha_vuelo_finca) = datepart(dw, #wk.fecha)

	create table #wk1 (fecha datetime)
	DECLARE @day1 INT
	DECLARE @today1 SMALLDATETIME
	SET @today1 = CONVERT(datetime, @fecha_despacho_cultivo + 7, 110)
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

	update #temp
	set fecha_inicial = #wk1.fecha
	from #wk1
	where datepart(dw, #temp.fecha_inicial) = datepart(dw, #wk1.fecha)
	and #temp.fecha_inicial < @fecha_despacho_cultivo

	update #temp
	set fecha_vuelo_finca = #wk1.fecha
	from #wk1
	where datepart(dw, #temp.fecha_vuelo_finca) = datepart(dw, #wk1.fecha)
	and #temp.fecha_vuelo_finca < @fecha_despacho_cultivo

	update #temp
	set idc_transportador = transportador.idc_transportador
	from transportador,
	orden_pedido
	where orden_pedido.id_transportador = transportador.id_transportador
	and orden_pedido.idc_orden_pedido = #temp.idc_orden_pedido

	update #temp
	set valor_unitario = orden_pedido.valor_unitario
	from orden_pedido
	where orden_pedido.idc_orden_pedido = #temp.idc_orden_pedido

	update #temp
	set valor_pactado = valor_pactado_cultivo.valor_pactado
	from orden_pedido,
	valor_pactado_cultivo
	where orden_pedido.idc_orden_pedido = #temp.idc_orden_pedido
	and orden_pedido.id_orden_pedido = valor_pactado_cultivo.id_orden_pedido

	/**datos para ser visualizados por los usuarios**/
	select idc_orden_pedido as ShipmentID,
	idc_orden_pedido as PONumber,
	id_cliente_factura as Customer,
	nombre_cliente as CustomerName,
	idc_farm as Farm,
	nombre_tipo_flor + space(1) + nombre_variedad_flor + space(1) + nombre_grado_flor as Flower,
	--idc_tipo_flor + idc_variedad_flor + idc_grado_flor as Flower,	
	unidades_por_pieza as Units, 
	factor_a_full as UOM,
	cantidad_piezas as Boxes,
	'S' as Type,
	'Farm confirmed' as Status,
	valor_pactado as Cost,
	fecha_vuelo_finca as ShipFarm,
	idc_transportador as Carrier,
	comentario as Comments,
	case
	when datename(dw, fecha_inicial) = 'Lunes' then 'Monday'
	when datename(dw, fecha_inicial) = 'Martes' then 'Tuesday'
	when datename(dw, fecha_inicial) = 'Miércoles' then 'Wednesday'
	when datename(dw, fecha_inicial) = 'Jueves' then 'Thursday'
	when datename(dw, fecha_inicial) = 'Viernes' then 'Friday'
	when datename(dw, fecha_inicial) = 'Sábado' then 'Saturday'
	when datename(dw, fecha_inicial) = 'Domingo' then 'Sunday'
	end as ShipDate,
	valor_unitario as FOB,
	nombre_farm as FarmName,
	nombre_tipo_flor + space(1) + nombre_variedad_flor + space(1) + nombre_grado_flor as ProductDesc,
	fecha_despacho_inicial as StartingDate,
	fecha_despacho_final as ArrivalDate,
	idc_orden_pedido as PODetailID,
	fecha_despacho_final as ShipDateto,
	code as SpecialCode,
	idc_tapa + ' - ' + ltrim(rtrim(nombre_tapa)) as BrandBox
	from #temp

	/*eliminación tablas temporales*/
	drop table #temp
end
else
if(@accion = 'consultar_cambios')
begin
	select @id_reporte_cambio_orden_pedido = id_reporte_cambio_orden_pedido 
	from reporte_cambio_orden_pedido 
	where numero_reporte_farm = @numero_reporte_farm 
	and id_farm = @id_farm 
	and id_tipo_factura = @id_tipo_factura
	
	set @tipo_factura_corrimiento = 'all'
	
	/*seleccionar las ordenes desde item_reporte_cambio_orden_pedido insertadas*/
	select 
	item_reporte_cambio_orden_pedido.idc_orden_pedido,
	cliente_despacho.idc_cliente_despacho,
	cliente_factura.id_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	farm.id_farm,	
	farm.idc_farm,
	farm.nombre_farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	item_reporte_cambio_orden_pedido.unidades_por_pieza, 
	tipo_caja.nombre_tipo_caja,
	tipo_caja.factor_a_full,
	item_reporte_cambio_orden_pedido.cantidad_piezas,
	item_reporte_cambio_orden_pedido.comentario,	
	tapa.nombre_tapa,
	tapa.idc_tapa,
	item_reporte_cambio_orden_pedido.code, 
	item_reporte_cambio_orden_pedido.fecha_despacho_inicial,
	item_reporte_cambio_orden_pedido.fecha_despacho_final,
	ciudad.id_ciudad,
	datepart(dw,item_reporte_cambio_orden_pedido.fecha_despacho_inicial - @dias_atras - farm.dias_restados_despacho_distribuidora) as id_dia_despacho,
	item_reporte_cambio_orden_pedido.id_orden_pedido,
	item_reporte_cambio_orden_pedido.id_orden_pedido_padre,
	item_reporte_cambio_orden_pedido.disponible into #temp_ch
	from item_reporte_cambio_orden_pedido, 
	reporte_cambio_orden_pedido,
	farm, 
	tipo_flor,
	variedad_flor, 
	grado_flor,
	tapa,
	tipo_caja,
	ciudad,
	tipo_factura,
	cliente_despacho,
	cliente_factura
	where 
	item_reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido
	and farm.id_farm = reporte_cambio_orden_pedido.id_farm
	and reporte_cambio_orden_pedido.id_farm = @id_farm
	and variedad_flor.id_variedad_flor = item_reporte_cambio_orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = item_reporte_cambio_orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = item_reporte_cambio_orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = item_reporte_cambio_orden_pedido.id_tipo_caja
	and farm.id_ciudad = ciudad.id_ciudad
	and reporte_cambio_orden_pedido.id_reporte_cambio_orden_pedido = @id_reporte_cambio_orden_pedido
	and reporte_cambio_orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.id_tipo_factura = @id_tipo_factura
	and item_reporte_cambio_orden_pedido.id_despacho = cliente_despacho.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura

	/*********************************************************************************************************/
	/*********************************************************************************************************/
	/*****************************************Tabla #temp*****************************************************/
	/**********************************ordenes traídas desde Orden_Pedido*************************************/
	/*********************************************************************************************************/
	/*********************************************************************************************************/

	/*alterar tabla temporal para realizar cálculos de días de corrimientos*/
	alter table #temp_ch
	add id_tipo_despacho int, 
	id_tipo_despacho_aux int, 
	corrimiento bit, 
	nombre_dia_despacho nvarchar(255), 
	forma_despacho int,
	fecha_inicial datetime,
	idc_transportador nvarchar(255),
	valor_unitario decimal(20,4),
	valor_pactado decimal(20,4)

	/*traer datos para los corrimientos de ordenes fijas por finca*/
	update #temp_ch
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	forma_despacho = 1
	from tipo_despacho, 
	forma_despacho_farm, 
	dia_despacho,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and forma_despacho_farm.id_farm = #temp_ch.id_farm
	and forma_despacho_farm.id_dia_despacho = #temp_ch.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*traer datos para los corrimientos de ordenes fijas por ciudad*/
	update #temp_ch
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	id_tipo_despacho_aux = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	forma_despacho = 0
	from tipo_despacho, 
	forma_despacho_ciudad, 
	dia_despacho,
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and forma_despacho_ciudad.id_ciudad = #temp_ch.id_ciudad
	and forma_despacho_ciudad.id_dia_despacho = #temp_ch.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and #temp_ch.forma_despacho is null
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
	update #temp_ch
	set id_dia_despacho = replace(id_dia_despacho+1,8,1)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 0

	/*actualizar el día de despacho después del aumento de día del punto anterior*/
	update #temp_ch
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_ciudad, 
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
	and #temp_ch.id_ciudad = forma_despacho_ciudad.id_ciudad
	and #temp_ch.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
	and forma_despacho_ciudad.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 0
	and forma_despacho_ciudad.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
	update #temp_ch
	set id_tipo_despacho = @id_tipo_despacho,
	id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
	and forma_despacho = 0

	update #temp_ch
	set corrimiento = 1
	where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
	and forma_despacho = 0

	/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
	while(@id_tipo_despacho in (select id_tipo_despacho from #temp_ch where forma_despacho = 0))
	begin
		update #temp_ch
		set id_dia_despacho = replace(id_dia_despacho-1,0,7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 0

		update #temp_ch
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_ciudad, 
		tipo_factura
		where tipo_despacho.id_tipo_despacho = forma_despacho_ciudad.id_tipo_despacho
		and #temp_ch.id_ciudad = forma_despacho_ciudad.id_ciudad
		and #temp_ch.id_dia_despacho = forma_despacho_ciudad.id_dia_despacho
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
	update #temp_ch
	set id_dia_despacho = replace(id_dia_despacho+1,8,1)
	where id_tipo_despacho = @id_tipo_despacho
	and forma_despacho = 1

	/*actualizar el día de despacho después del aumento de día del punto anterior*/
	update #temp_ch
	set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
	nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
	id_dia_despacho = dia_despacho.id_dia_despacho
	from tipo_despacho,
	dia_despacho, 
	forma_despacho_farm, 
	tipo_factura
	where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
	and #temp_ch.id_farm = forma_despacho_farm.id_farm
	and #temp_ch.id_dia_despacho = forma_despacho_farm.id_dia_despacho
	and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
	and forma_despacho = 1
	and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento

	/*restar un día a las ordenes que aun no tengan día de despacho después de los corrimientos anteriores*/
	update #temp_ch
	set id_tipo_despacho = @id_tipo_despacho,
	id_dia_despacho = replace(id_dia_despacho-1,0,7)
	where id_tipo_despacho = @id_tipo_despacho_despacho and id_tipo_despacho_aux = @id_tipo_despacho
	and forma_despacho = 1

	update #temp_ch
	set corrimiento = 1
	where id_tipo_despacho in (@id_tipo_despacho_corrimiento, @id_tipo_despacho_despacho)
	and forma_despacho = 1

	/*realizar los corrimientos necesarios para que todas las ordenes tengan un día de despacho*/
	while(@id_tipo_despacho in (select id_tipo_despacho from #temp_ch where forma_despacho = 1))
	begin
		update #temp_ch
		set id_dia_despacho = replace(id_dia_despacho-1,0,7)
		where id_tipo_despacho = @id_tipo_despacho
		and forma_despacho = 1

		update #temp_ch
		set id_tipo_despacho = tipo_despacho.id_tipo_despacho,
		nombre_dia_despacho = dia_despacho.nombre_dia_despacho,
		id_dia_despacho = dia_despacho.id_dia_despacho
		from tipo_despacho,
		dia_despacho, 
		forma_despacho_farm, 
		tipo_factura
		where tipo_despacho.id_tipo_despacho = forma_despacho_farm.id_tipo_despacho
		and #temp_ch.id_farm = forma_despacho_farm.id_farm
		and #temp_ch.id_dia_despacho = forma_despacho_farm.id_dia_despacho
		and forma_despacho_farm.id_dia_despacho = dia_despacho.id_dia_despacho
		and forma_despacho = 1
		and forma_despacho_farm.id_tipo_factura = tipo_factura.id_tipo_factura
		and tipo_factura.idc_tipo_factura = @tipo_factura_corrimiento
	end

	/**procedimientos para calcular la fecha de vuelo**/
	update #temp_ch
	set fecha_inicial = getdate()
	where datepart(dw,fecha_despacho_inicial) = datepart(dw,getdate())

	update #temp_ch
	set fecha_inicial = getdate()+(datepart(dw,fecha_despacho_inicial)-datepart(dw,getdate()))
	where datepart(dw,getdate()) < datepart(dw,fecha_despacho_inicial)

	update #temp_ch
	set fecha_inicial = (getdate()+(datepart(dw,fecha_despacho_inicial)-datepart(dw,getdate())))+7
	where datepart(dw,getdate()) > datepart(dw,fecha_despacho_inicial)

	/**procedimientos para calcular la fecha de vuelo de la finca**/
	update #temp_ch
	set fecha_vuelo_finca = getdate()
	where id_dia_despacho = datepart(dw,getdate())

	update #temp_ch
	set fecha_vuelo_finca = getdate()+(id_dia_despacho - datepart(dw,getdate()))
	where datepart(dw,getdate()) < id_dia_despacho

	update #temp_ch
	set fecha_vuelo_finca = (getdate()+(id_dia_despacho - datepart(dw,getdate()))) + 7
	where datepart(dw,getdate()) > id_dia_despacho

	/*procedimientos para asignar fechas en la semana actual o la semana siguiente*/
	create table #wk_ch (fecha datetime)
	DECLARE @day_ch INT
	DECLARE @today_ch SMALLDATETIME
	SET @today_ch = CONVERT(datetime, @fecha_despacho_cultivo, 110)
	SET @day_ch = DATEPART(dw, @today_ch)
	insert into #wk_ch
	SELECT DATEADD(dd, 1 - @day_ch, @today_ch)
	insert into #wk_ch
	select DATEADD(dd, 2 - @day_ch, @today_ch)
	insert into #wk_ch
	select DATEADD(dd, 3 - @day_ch, @today_ch)
	insert into #wk_ch
	select DATEADD(dd, 4 - @day_ch, @today_ch)
	insert into #wk_ch
	select DATEADD(dd, 5 - @day_ch, @today_ch)
	insert into #wk_ch
	select DATEADD(dd, 6 - @day_ch, @today_ch)
	insert into #wk_ch
	select DATEADD(dd, 7 - @day_ch, @today_ch)

	update #temp_ch
	set fecha_inicial = #wk_ch.fecha
	from #wk_ch
	where datepart(dw, #temp_ch.fecha_inicial) = datepart(dw, #wk_ch.fecha)

	update #temp_ch
	set fecha_vuelo_finca = #wk_ch.fecha
	from #wk_ch
	where datepart(dw, #temp_ch.fecha_vuelo_finca) = datepart(dw, #wk_ch.fecha)

	create table #wk1_ch (fecha datetime)
	DECLARE @day1_ch INT
	DECLARE @today1_ch SMALLDATETIME
	SET @today1_ch = CONVERT(datetime, @fecha_despacho_cultivo + 7, 110)
	SET @day1_ch = DATEPART(dw, @today1_ch)
	insert into #wk1_ch
	SELECT DATEADD(dd, 1 - @day1_ch, @today1_ch)
	insert into #wk1_ch
	select DATEADD(dd, 2 - @day1_ch, @today1_ch)
	insert into #wk1_ch
	select DATEADD(dd, 3 - @day1_ch, @today1_ch)
	insert into #wk1_ch
	select DATEADD(dd, 4 - @day1_ch, @today1_ch)
	insert into #wk1_ch
	select DATEADD(dd, 5 - @day1_ch, @today1_ch)
	insert into #wk1_ch
	select DATEADD(dd, 6 - @day1_ch, @today1_ch)
	insert into #wk1_ch
	select DATEADD(dd, 7 - @day1_ch, @today1_ch)

	update #temp_ch
	set fecha_inicial = #wk1_ch.fecha
	from #wk1_ch
	where datepart(dw, #temp_ch.fecha_inicial) = datepart(dw, #wk1_ch.fecha)
	and #temp_ch.fecha_inicial < @fecha_despacho_cultivo

	update #temp_ch
	set fecha_vuelo_finca = #wk1_ch.fecha
	from #wk1_ch
	where datepart(dw, #temp_ch.fecha_vuelo_finca) = datepart(dw, #wk1_ch.fecha)
	and #temp_ch.fecha_vuelo_finca < @fecha_despacho_cultivo

	update #temp_ch
	set idc_transportador = transportador.idc_transportador
	from transportador,
	orden_pedido
	where orden_pedido.id_transportador = transportador.id_transportador
	and orden_pedido.idc_orden_pedido = #temp_ch.idc_orden_pedido

	update #temp_ch
	set valor_unitario = orden_pedido.valor_unitario
	from orden_pedido
	where orden_pedido.idc_orden_pedido = #temp_ch.idc_orden_pedido

	update #temp_ch
	set valor_pactado = valor_pactado_cultivo.valor_pactado
	from orden_pedido,
	valor_pactado_cultivo
	where orden_pedido.idc_orden_pedido = #temp_ch.idc_orden_pedido
	and orden_pedido.id_orden_pedido = valor_pactado_cultivo.id_orden_pedido

	/**datos para ser visualizados por los usuarios**/
	select idc_orden_pedido as ShipmentID,
	idc_orden_pedido as PONumber,
	id_cliente_factura as Customer,
	nombre_cliente as CustomerName,
	idc_farm as Farm,
	nombre_tipo_flor + space(1) + nombre_variedad_flor + space(1) + nombre_grado_flor as Flower,
	--idc_tipo_flor + idc_variedad_flor + idc_grado_flor as Flower,
	unidades_por_pieza as Units,
	factor_a_full as UOM,
	cantidad_piezas as Boxes,
	'S' as Type,
	case
	when disponible = 0 then 'Confirmed Cancellation'
	else 'Farm confirmed' 
	end as Status,
	valor_pactado as Cost,
	fecha_vuelo_finca as ShipFarm,
	idc_transportador as Carrier,
	comentario as Comments,
	case
	when datename(dw, fecha_inicial) = 'Lunes' then 'Monday'
	when datename(dw, fecha_inicial) = 'Martes' then 'Tuesday'
	when datename(dw, fecha_inicial) = 'Miércoles' then 'Wednesday'
	when datename(dw, fecha_inicial) = 'Jueves' then 'Thursday'
	when datename(dw, fecha_inicial) = 'Viernes' then 'Friday'
	when datename(dw, fecha_inicial) = 'Sábado' then 'Saturday'
	when datename(dw, fecha_inicial) = 'Domingo' then 'Sunday'
	end as ShipDate,
	valor_unitario as FOB,
	nombre_farm as FarmName,
	nombre_tipo_flor + space(1) + nombre_variedad_flor + space(1) + nombre_grado_flor as ProductDesc,
	fecha_despacho_inicial as StartingDate,
	fecha_despacho_final as ArrivalDate,
	idc_orden_pedido as PODetailID,
	fecha_despacho_final as ShipDateto,
	code as SpecialCode,
	idc_tapa + ' - ' + ltrim(rtrim(nombre_tapa)) as BrandBox
	from #temp_ch

	/*eliminación tablas temporales*/
	drop table #temp_ch
end

