set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_consultar_produccion_solicitada_v2]

@fecha_inicial datetime, 
@fecha_final datetime,
@id_descripcion_produccion_solicitada nvarchar(512),
@accion nvarchar(255)

as

declare @dias_restados int
set @dias_restados = 0

if(@accion = 'consultar_reporte')
begin
	create table #temp (id int)

	/*crear la insercion para los valores separados por comas*/
	declare @sql varchar(8000)
	select @sql = 'insert into #temp select '+	replace(@id_descripcion_produccion_solicitada,',',' union all select ')

	/*cargar todos los valores de la variable @id_descripcion_produccion_solicitada en la tabla temporal*/
	exec (@SQL)

	select descripcion_produccion_solicitada.id_descripcion_produccion_solicitada,
	descripcion_produccion_solicitada.comentario,
	grado_flor.id_grado_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '(' + grado_flor.idc_grado_flor + ')' as nombre_grado_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	tipo_pedido.idc_tipo_pedido as nombre_tipo_pedido,
	produccion_solicitada_rusia.cantidad_tallos,
	produccion_solicitada_rusia.fecha - @dias_restados as fecha
	from descripcion_produccion_solicitada,
	comentario_produccion_solicitada,
	produccion_solicitada_rusia,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_pedido,
	bloque
	where descripcion_produccion_solicitada.id_descripcion_produccion_solicitada = comentario_produccion_solicitada.id_descripcion_produccion_solicitada
	and produccion_solicitada_rusia.id_produccion_solicitada_rusia = comentario_produccion_solicitada.id_produccion_solicitada_rusia
	and produccion_solicitada_rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and produccion_solicitada_rusia.id_tipo_pedido = tipo_pedido.id_tipo_pedido
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and produccion_solicitada_rusia.id_bloque = bloque.id_bloque
	and descripcion_produccion_solicitada.id_descripcion_produccion_solicitada in (select id from #temp)
	and produccion_solicitada_rusia.disponible = 1
	order by produccion_solicitada_rusia.fecha,
	descripcion_produccion_solicitada.comentario,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	bloque.idc_bloque,
	tipo_pedido.nombre_tipo_pedido,
	produccion_solicitada_rusia.cantidad_tallos

	drop table #temp
end
else
if(@accion = 'consultar_pantalla')
begin
	select descripcion_produccion_solicitada.id_descripcion_produccion_solicitada,
	descripcion_produccion_solicitada.comentario + space(1) + '(' + convert(nvarchar,min(produccion_solicitada_rusia.fecha),101) + ' - ' + convert(nvarchar,max(produccion_solicitada_rusia.fecha),101) + ')' as comentario,
	min(produccion_solicitada_rusia.fecha_creacion) as fecha_creacion,
	sum(produccion_solicitada_rusia.cantidad_tallos) as cantidad_tallos,
	max(cuenta_interna.nombre) as nombre_usuario
	from descripcion_produccion_solicitada,
	comentario_produccion_solicitada,
	produccion_solicitada_rusia,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_pedido,
	bloque,
	cuenta_interna
	where descripcion_produccion_solicitada.id_descripcion_produccion_solicitada = comentario_produccion_solicitada.id_descripcion_produccion_solicitada
	and produccion_solicitada_rusia.id_produccion_solicitada_rusia = comentario_produccion_solicitada.id_produccion_solicitada_rusia
	and produccion_solicitada_rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and produccion_solicitada_rusia.id_tipo_pedido = tipo_pedido.id_tipo_pedido
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and produccion_solicitada_rusia.id_bloque = bloque.id_bloque
	and produccion_solicitada_rusia.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha_creacion,101)) between
	@fecha_inicial and @fecha_final
	and produccion_solicitada_rusia.disponible = 1
	group by descripcion_produccion_solicitada.id_descripcion_produccion_solicitada,
	descripcion_produccion_solicitada.comentario
	order by min(produccion_solicitada_rusia.fecha_creacion) desc
end
else
if(@accion = 'consultar_cobol')
begin
	select ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	grado_flor.idc_grado_flor,
	produccion_solicitada_rusia.fecha,
	sum(produccion_solicitada_rusia.cantidad_tallos) as cantidad_tallos
	from descripcion_produccion_solicitada,
	comentario_produccion_solicitada,
	produccion_solicitada_rusia,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_pedido,
	bloque
	where descripcion_produccion_solicitada.id_descripcion_produccion_solicitada = comentario_produccion_solicitada.id_descripcion_produccion_solicitada
	and produccion_solicitada_rusia.id_produccion_solicitada_rusia = comentario_produccion_solicitada.id_produccion_solicitada_rusia
	and produccion_solicitada_rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and produccion_solicitada_rusia.id_tipo_pedido = tipo_pedido.id_tipo_pedido
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and produccion_solicitada_rusia.id_bloque = bloque.id_bloque
	and produccion_solicitada_rusia.fecha between
	@fecha_inicial and @fecha_final
	group by tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.nombre_grado_flor,
	grado_flor.idc_grado_flor,
	produccion_solicitada_rusia.fecha
	order by produccion_solicitada_rusia.fecha,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.nombre_grado_flor,
	grado_flor.idc_grado_flor
end
else
if(@accion = 'consultar_fechas_comentarios')
begin
	create table #temp1 (id int)

	/*crear la insercion para los valores separados por comas*/
	declare @sql1 varchar(8000),
	@cantidad_dias int
	
	select @sql1 = 'insert into #temp1 select '+ replace(@id_descripcion_produccion_solicitada,',',' union all select ')

	/*cargar todos los valores de la variable @id_descripcion_produccion_solicitada en la tabla temporal*/
	exec ( @SQL1 )

	select @cantidad_dias = datediff(dd, min(produccion_solicitada_rusia.fecha), max(produccion_solicitada_rusia.fecha))
	from produccion_solicitada_rusia,
	comentario_produccion_solicitada,
	descripcion_produccion_solicitada
	where produccion_solicitada_rusia.id_produccion_solicitada_rusia = comentario_produccion_solicitada.id_produccion_solicitada_rusia
	and descripcion_produccion_solicitada.id_descripcion_produccion_solicitada = comentario_produccion_solicitada.id_descripcion_produccion_solicitada
	and descripcion_produccion_solicitada.id_descripcion_produccion_solicitada in (select id from #temp1)
	and produccion_solicitada_rusia.disponible = 1

	if(@cantidad_dias < 7)
	begin
		select 1 as diferencia
	end
	else
	begin
		select @cantidad_dias as diferencia
	end
	
	drop table #temp1
end