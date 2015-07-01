/****** Object:  StoredProcedure [dbo].[pbinv_copiar_inventario]    Script Date: 05/08/2008 10:19:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_copiar_inventario]

@id_temporada_año_origen int,
@id_temporada_año_destino int,
@id_item_inventario_preventa int,
@id_cuenta_interna int,
@id_farm nvarchar(255),
@id_tipo_flor nvarchar(255),
@id_variedad_flor nvarchar(255),
@id_grado_flor nvarchar(255),
@accion nvarchar(255)

AS

BEGIN

if(@id_farm is null)
set @id_farm = '%%'
if(@id_tipo_flor is null)
	set @id_tipo_flor = '%%'
if(@id_variedad_flor is null)
	set @id_variedad_flor = '%%'
if(@id_grado_flor is null)
	set @id_grado_flor = '%%'

declare @fecha_inicial datetime, 
@fecha_final datetime,
@fecha_inicial_destino datetime,
@id_inventario_preventa int,
@id_detalle_item_inventario_preventa int

/*hallar el rango de fechas de la temporada desde la que se desean copiar los datos*/
select @fecha_inicial = temporada_cubo.fecha_inicial, 
@fecha_final = temporada_cubo.fecha_final 
from temporada_año, temporada_cubo
where temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_año = temporada_cubo.id_año
and temporada_año.id_temporada_año = @id_temporada_año_origen

/*hallar la fecha inicial de la temporada en la cual se copiarán los datos*/
select @fecha_inicial_destino = temporada_cubo.fecha_inicial
from temporada_año, temporada_cubo
where temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_año = temporada_cubo.id_año
and temporada_año.id_temporada_año = @id_temporada_año_destino

if(@accion = 'consultar_origen')
begin
	/*seleccionar los productos existentes en el primer día de la temporada destino*/
	select inventario_preventa.id_farm,
	item_inventario_preventa.id_tapa,
	item_inventario_preventa.id_variedad_flor,
	item_inventario_preventa.id_grado_flor,
	item_inventario_preventa.unidades_por_pieza,
	item_inventario_preventa.id_tipo_caja into #inventario_destino
	from inventario_preventa,item_inventario_preventa,detalle_item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora = @fecha_inicial_destino

	/*seleccionar todos los productos de la temporada origen*/
	select item_inventario_preventa.id_item_inventario_preventa,
	farm.idc_farm,
	farm.id_farm,
	farm.nombre_farm,
	tipo_flor.id_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	item_inventario_preventa.unidades_por_pieza,
	item_inventario_preventa.marca into #inventario_origen
	from detalle_item_inventario_preventa, 
	item_inventario_preventa, 
	inventario_preventa,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	tipo_caja
	where detalle_item_inventario_preventa.fecha_disponible_distribuidora between
	@fecha_inicial and @fecha_final
	and detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
	and item_inventario_preventa.id_inventario_preventa = inventario_preventa.id_inventario_preventa
	and inventario_preventa.id_farm = farm.id_farm
	and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
	and item_inventario_preventa.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and tapa.id_tapa = item_inventario_preventa.id_tapa
	and tipo_caja.id_tipo_caja = item_inventario_preventa.id_tipo_caja
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and grado_flor.id_grado_flor like @id_grado_flor
	and farm.id_farm like @id_farm
	and tipo_flor.disponible = 1
	and variedad_flor.disponible = 1
	and grado_flor.disponible = 1
	and farm.disponible = 1
	and tapa.disponible = 1
	and tipo_caja.disponible = 1
	group by 
	item_inventario_preventa.id_item_inventario_preventa,
	farm.idc_farm,
	farm.id_farm,
	farm.nombre_farm,
	tipo_flor.id_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	item_inventario_preventa.unidades_por_pieza,
	item_inventario_preventa.marca
	

	/*seleccionar únicamente los productos de la temporada origen que no existan en el primer día de la temporada destino*/
	select #inventario_origen.*, 
	Item_Inventario_Preventa_Precopia.copiar_item, 
	Item_Inventario_Preventa_Precopia.no_copiar_item, 
	isnull(Item_Inventario_Preventa_Precopia.procesado,0) as procesado into #inventario_origen_precopia
	from #inventario_origen left join Item_Inventario_Preventa_Precopia
	on #inventario_origen.id_Item_Inventario_Preventa = Item_Inventario_Preventa_Precopia.id_Item_Inventario_Preventa
	and Item_Inventario_Preventa_Precopia.id_temporada_año_origen = @id_temporada_año_origen
	and Item_Inventario_Preventa_Precopia.id_temporada_año_destino = @id_temporada_año_destino
	and Item_Inventario_Preventa_Precopia.id_cuenta_interna = @id_cuenta_interna
	where not exists 
	(
		select *
		from #inventario_destino
		where #inventario_destino.id_farm = #inventario_origen.id_farm
		and #inventario_destino.id_tapa = #inventario_origen.id_tapa
		and #inventario_destino.id_tipo_caja = #inventario_origen.id_tipo_caja
		and #inventario_destino.id_variedad_flor = #inventario_origen.id_variedad_flor
		and #inventario_destino.id_grado_flor = #inventario_origen.id_grado_flor
		and #inventario_destino.unidades_por_pieza = #inventario_origen.unidades_por_pieza
	)
	
	select * 
	from #inventario_origen_precopia 
	where procesado = 0
	order  by 
	#inventario_origen_precopia.idc_farm,
	#inventario_origen_precopia.nombre_tipo_flor,
	#inventario_origen_precopia.nombre_variedad_flor,
	#inventario_origen_precopia.nombre_grado_flor,
	#inventario_origen_precopia.nombre_tipo_caja,
	#inventario_origen_precopia.nombre_tapa

	/*eliminación de tablas temporales*/
	drop table #inventario_origen
	drop table #inventario_origen_precopia
	drop table #inventario_destino
end
else
if(@accion = 'consultar_destino')
begin
	/*seleccionar todos los productos de la temporada origen*/
	select item_inventario_preventa.id_item_inventario_preventa,
	farm.idc_farm,
	farm.id_farm,
	farm.nombre_farm,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	item_inventario_preventa.unidades_por_pieza,
	item_inventario_preventa.marca
	from detalle_item_inventario_preventa, 
	item_inventario_preventa, 
	inventario_preventa,
	farm,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tapa,
	tipo_caja
	where detalle_item_inventario_preventa.fecha_disponible_distribuidora = @fecha_inicial_destino
	and detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
	and item_inventario_preventa.id_inventario_preventa = inventario_preventa.id_inventario_preventa
	and inventario_preventa.id_farm = farm.id_farm
	and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
	and item_inventario_preventa.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and tapa.id_tapa = item_inventario_preventa.id_tapa
	and tipo_caja.id_tipo_caja = item_inventario_preventa.id_tipo_caja
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and grado_flor.id_grado_flor like @id_grado_flor
	and farm.id_farm like @id_farm
	and tipo_flor.disponible = 1
	and variedad_flor.disponible = 1
	and grado_flor.disponible = 1
	and farm.disponible = 1
	and tapa.disponible = 1
	and tipo_caja.disponible = 1
	group by 
	item_inventario_preventa.id_item_inventario_preventa,
	farm.idc_farm,
	farm.id_farm,
	farm.nombre_farm,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.nombre_grado_flor,
	tapa.id_tapa,
	tapa.nombre_tapa,
	tipo_caja.id_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	item_inventario_preventa.unidades_por_pieza,
	item_inventario_preventa.marca
	order  by 
	farm.idc_farm,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	tipo_caja.nombre_tipo_caja,
	tapa.nombre_tapa
end
else
if(@accion = 'insertar')
begin
	/*hallar el id de la tabla inventario_preventa a través del id_item_inventario_preventa enviado por el usuario*/
	select @id_inventario_preventa = inventario_preventa.id_inventario_preventa 
	from inventario_preventa, 
	item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

	/*insertar registros en la tabla item_inventario_preventa*/
	insert into Item_Inventario_Preventa (id_cuenta_interna, id_inventario_preventa, id_tapa, id_variedad_flor, id_grado_flor, unidades_por_pieza, marca, id_tipo_caja)
	select cuenta_interna.id_cuenta_interna,
	@id_inventario_preventa,
	item_inventario_preventa.id_tapa,
	item_inventario_preventa.id_variedad_flor,
	item_inventario_preventa.id_grado_flor,
	item_inventario_preventa.unidades_por_pieza,
	item_inventario_preventa.marca,
	item_inventario_preventa.id_tipo_caja
	from cuenta_interna, 
	item_inventario_preventa
	where cuenta_interna.id_cuenta_interna = @id_cuenta_interna
	and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

	/*capturar el id_item_inventario_preventa devuelto por la base de datos*/
	set @id_item_inventario_preventa = scope_identity()

	/*insertar registros en la tabla detalle_item_inventario_preventa*/
	insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora)
	values (@id_item_inventario_preventa, @fecha_inicial_destino)

	/*capturar el id_detalle_item_inventario_preventa devuelto por la base de datos*/
	set @id_detalle_item_inventario_preventa = scope_identity()

	/*darle el mismo valor a la columna id_detalle_item_inventario_preventa_padre que posee el campo*/
	/*id_detalle_item_inventario_preventa debido a que se trata de un registro nuevo que no posee padre*/
	update detalle_item_inventario_preventa
	set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa
end
else
if(@accion = 'eliminar')
begin
	delete from item_inventario_preventa_precopia
end
END










