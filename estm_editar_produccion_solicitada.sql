set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_editar_produccion_solicitada]

@fecha datetime,
@id_cuenta_interna int, 
@id_bloque int, 
@id_variedad_flor nvarchar(255), 
@cantidad_tallos int, 
@id_grado_flor int,
@id_tipo_pedido int,
@id_produccion_solicitada_rusia int,
@id_descripcion_produccion_solicitada int,
@accion nvarchar(255)

as

declare @id_item int,
@fecha_inicio datetime

if(@id_variedad_flor is null)
	set @id_variedad_flor = '%%'

if(@accion = 'consultar_reporte')
begin
--	select @fecha_inicio = saldo_condonado.fecha + 1
--	from saldo_condonado
--	where @fecha > = saldo_condonado.fecha

	create table #entradas_saldo
	(
		fecha datetime,
		nombre_tipo_flor nvarchar(255),
		idc_tipo_flor nvarchar(255),
		id_variedad_flor int,
		nombre_variedad_flor nvarchar(255),
		id_bloque int,
		idc_bloque nvarchar(255),
		id_punto_corte int,
		nombre_punto_corte nvarchar(255),
		unidades_por_pieza int
	)
	create table #solicitados_saldo
	(
		fecha datetime,
		nombre_tipo_flor nvarchar(255),
		idc_tipo_flor nvarchar(255),
		id_variedad_flor int,
		nombre_variedad_flor nvarchar(255),
		id_bloque int,
		idc_bloque nvarchar(255),
		id_punto_corte int,
		nombre_punto_corte nvarchar(255),
		unidades_por_pieza int
	)
	/*si no existe una fecha anterior de saldo perdonado a la seleccionada se colocara la misma fecha para ambos parametros*/
	if(@fecha_inicio is null)
		set @fecha_inicio = @fecha

	while (datediff(dd,@fecha_inicio, @fecha) > = 1)
	begin
		/*insertar todas las entradas de flor que se han dado desde la fecha inicial calculada*/
		insert into #entradas_saldo
		(
		fecha,
		nombre_tipo_flor,
		idc_tipo_flor,
		id_variedad_flor,
		nombre_variedad_flor,
		id_bloque,
		idc_bloque,
		id_punto_corte,
		nombre_punto_corte,
		unidades_por_pieza
		)
		select convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) as fecha,
		ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
		tipo_flor.idc_tipo_flor,
		variedad_flor.id_variedad_flor,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		bloque.id_bloque,
		bloque.idc_bloque,
		punto_corte.id_punto_corte,
		punto_corte.nombre_punto_corte,
		sum(pieza_postcosecha.unidades_por_pieza) as unidades_por_pieza
		from pieza_postcosecha, 
		variedad_flor, 
		bloque, 
		tipo_flor,
		punto_corte
		where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
		and pieza_postcosecha.id_bloque = bloque.id_bloque
		and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) = @fecha_inicio
		and pieza_postcosecha.id_punto_corte = punto_corte.id_punto_corte
		and punto_corte.idc_punto_corte in ('R','Q')
		group by convert(nvarchar,pieza_postcosecha.fecha_entrada,101), 
		tipo_flor.nombre_tipo_flor,
		variedad_flor.id_variedad_flor,
		tipo_flor.idc_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.idc_variedad_flor,
		punto_corte.id_punto_corte,
		punto_corte.nombre_punto_corte,
		bloque.idc_bloque,
		bloque.id_bloque

		/*insertar todas las solicitudes de flor que se han dado desde la fecha inicial calculada*/
		insert into #solicitados_saldo
		(
		fecha,
		nombre_tipo_flor,
		idc_tipo_flor,
		id_variedad_flor,
		nombre_variedad_flor,
		id_bloque,
		idc_bloque,
		id_punto_corte,
		nombre_punto_corte,
		unidades_por_pieza
		)
		select convert(datetime,convert(nvarchar,Produccion_Solicitada_Rusia.fecha,101)) as fecha,
		ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
		tipo_flor.idc_tipo_flor,
		variedad_flor.id_variedad_flor,
		ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
		bloque.id_bloque,
		bloque.idc_bloque,
		punto_corte.id_punto_corte,
		punto_corte.nombre_punto_corte,
		sum(produccion_solicitada_rusia.cantidad_tallos) as cantidad_tallos
		from produccion_solicitada_rusia, 
		bloque,
		variedad_flor,
		tipo_flor,
		punto_corte,
		grado_flor
		where Produccion_Solicitada_Rusia.id_bloque = bloque.id_bloque
		and Produccion_Solicitada_Rusia.id_variedad_flor = variedad_flor.id_variedad_flor
		and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and convert(datetime,convert(nvarchar,Produccion_Solicitada_Rusia.fecha,101)) = @fecha_inicio
		and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
		and grado_flor.id_punto_corte = punto_corte.id_punto_corte
		and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and punto_corte.idc_punto_corte in ('R','Q')
		and produccion_solicitada_rusia.disponible = 1
		group by convert(nvarchar,Produccion_Solicitada_Rusia.fecha,101),
		tipo_flor.nombre_tipo_flor,
		tipo_flor.idc_tipo_flor,
		variedad_flor.nombre_variedad_flor,
		variedad_flor.idc_variedad_flor,
		variedad_flor.id_variedad_flor,
		punto_corte.id_punto_corte,
		punto_corte.nombre_punto_corte,
		bloque.idc_bloque,
		bloque.id_bloque

		set @fecha_inicio = @fecha_inicio + 1
	end

	alter table #entradas_saldo
	add saldo_inicial int

	update #entradas_saldo
	set saldo_inicial = #solicitados_saldo.unidades_por_pieza
	from #solicitados_saldo
	where #solicitados_saldo.id_variedad_flor = #entradas_saldo.id_variedad_flor
	and #solicitados_saldo.id_bloque = #entradas_saldo.id_bloque
	and #solicitados_saldo.id_punto_corte = #entradas_saldo.id_punto_corte
	and #solicitados_saldo.fecha = #entradas_saldo.fecha
		
	insert into #entradas_saldo 		
	(
	fecha,
	nombre_tipo_flor,
	idc_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_bloque,
	idc_bloque,
	id_punto_corte,
	nombre_punto_corte,
	unidades_por_pieza,
	saldo_inicial
	)
	select fecha,
	nombre_tipo_flor,
	idc_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_bloque,
	idc_bloque,
	id_punto_corte,
	nombre_punto_corte,
	0,
	unidades_por_pieza
	from #solicitados_saldo
	where not exists
	(
	select * 
	from #entradas_saldo 
	where #solicitados_saldo.id_variedad_flor = #entradas_saldo.id_variedad_flor
	and #solicitados_saldo.id_bloque = #entradas_saldo.id_bloque
	and #solicitados_saldo.id_punto_corte = #entradas_saldo.id_punto_corte
	and #solicitados_saldo.fecha = #entradas_saldo.fecha
	
	)

	update #entradas_saldo
	set saldo_inicial = 0
	where saldo_inicial is null

	select fecha,
	nombre_tipo_flor,
	idc_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_bloque,
	idc_bloque,
	id_punto_corte,
	nombre_punto_corte,
	sum(unidades_por_pieza) as unidades_por_pieza,
	sum(saldo_inicial) as saldo_inicial into #entradas_saldo_def
	from #entradas_saldo 		
	group by fecha,
	nombre_tipo_flor,
	idc_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_bloque,
	idc_bloque,
	id_punto_corte,
	nombre_punto_corte

	/*insertar las entradas de flor del dia seleccionado*/
	select convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) as fecha,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	punto_corte.id_punto_corte,
	punto_corte.nombre_punto_corte,
	sum(pieza_postcosecha.unidades_por_pieza) as unidades_por_pieza into #entradas
	from pieza_postcosecha, 
	variedad_flor, 
	bloque, 
	tipo_flor,
	punto_corte
	where pieza_postcosecha.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza_postcosecha.id_bloque = bloque.id_bloque
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and convert(datetime,convert(nvarchar,pieza_postcosecha.fecha_entrada,101)) = @fecha
	and pieza_postcosecha.id_punto_corte = punto_corte.id_punto_corte
	and punto_corte.idc_punto_corte in ('R','Q')
	group by convert(nvarchar,pieza_postcosecha.fecha_entrada,101), 
	tipo_flor.nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	punto_corte.id_punto_corte,
	punto_corte.nombre_punto_corte,
	bloque.idc_bloque,
	bloque.id_bloque

	/*insertar las solicitudes de flor del dia seleccionado*/
	select convert(datetime,convert(nvarchar,Produccion_Solicitada_Rusia.fecha,101)) as fecha,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	bloque.id_bloque,
	bloque.idc_bloque,
	punto_corte.id_punto_corte,
	punto_corte.nombre_punto_corte,
	sum(produccion_solicitada_rusia.cantidad_tallos) as cantidad_tallos into #solicitadas
	from produccion_solicitada_rusia, 
	bloque,
	variedad_flor,
	tipo_flor,
	punto_corte,
	grado_flor
	where Produccion_Solicitada_Rusia.id_bloque = bloque.id_bloque
	and Produccion_Solicitada_Rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and convert(datetime,convert(nvarchar,Produccion_Solicitada_Rusia.fecha,101)) = @fecha
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_punto_corte = punto_corte.id_punto_corte
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and punto_corte.idc_punto_corte in ('R','Q')
	and produccion_solicitada_rusia.disponible = 1
	group by convert(nvarchar,Produccion_Solicitada_Rusia.fecha,101),
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.id_variedad_flor,
	punto_corte.id_punto_corte,
	punto_corte.nombre_punto_corte,
	bloque.idc_bloque,
	bloque.id_bloque

	alter table #entradas
	add tallos_solicitados int,
	entradas_anteriores int,
	solicitados_anteriores int

	/*actualizar los tallos solicitados a las entradas del dia seleccionado*/
	update #entradas
	set tallos_solicitados = #solicitadas.cantidad_tallos
	from #solicitadas
	where #solicitadas.id_variedad_flor = #entradas.id_variedad_flor
	and #solicitadas.id_bloque = #entradas.id_bloque
	and #solicitadas.id_punto_corte = #entradas.id_punto_corte

	/*actualizar los tallos solicitados a las entradas del dia seleccionado que no estaban como entradas*/
	insert into #entradas 
	(
	fecha,
	nombre_tipo_flor, 
	id_variedad_flor, 
	nombre_variedad_flor, 
	id_bloque, 
	idc_bloque, 
	unidades_por_pieza, 
	tallos_solicitados, 
	nombre_punto_corte, 
	id_punto_corte, 
	idc_tipo_flor
	)
	select fecha, 
	nombre_tipo_flor, 
	id_variedad_flor, 
	nombre_variedad_flor, 
	id_bloque, 
	idc_bloque, 
	0, 
	cantidad_tallos, 
	nombre_punto_corte,		
	id_punto_corte, 
	idc_tipo_flor
	from #solicitadas
	where not exists
	(select * from #entradas
	where #solicitadas.id_variedad_flor = #entradas.id_variedad_flor
	and #solicitadas.id_bloque = #entradas.id_bloque
	and #solicitadas.id_punto_corte = #entradas.id_punto_corte)

	update #entradas
	set tallos_solicitados = 0
	where tallos_solicitados is null

	select sum(#entradas_saldo_def.unidades_por_pieza) as unidades_por_pieza,
	sum(#entradas_saldo_def.saldo_inicial) as saldo_inicial,
	#entradas_saldo_def.id_variedad_flor,
	#entradas_saldo_def.id_bloque,
	#entradas_saldo_def.id_punto_corte into #temp
	from #entradas_saldo_def 
	group by #entradas_saldo_def.id_variedad_flor,
	#entradas_saldo_def.id_bloque,
	#entradas_saldo_def.id_punto_corte

	update #entradas
	set entradas_anteriores = #temp.unidades_por_pieza,
	solicitados_anteriores = #temp.saldo_inicial
	from #temp
	where #temp.id_variedad_flor = #entradas.id_variedad_flor
	and #temp.id_bloque = #entradas.id_bloque
	and #temp.id_punto_corte = #entradas.id_punto_corte

	insert into #entradas 
	(
	fecha,
	nombre_tipo_flor, 
	id_variedad_flor, 
	nombre_variedad_flor, 
	id_bloque, 
	idc_bloque, 
	unidades_por_pieza, 
	tallos_solicitados, 
	nombre_punto_corte, 
	id_punto_corte, 
	idc_tipo_flor,
	entradas_anteriores,
	solicitados_anteriores
	)
	select fecha,
	nombre_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_bloque,
	idc_bloque,
	0 as unidades_por_pieza,
	0 as tallos_solicitados,
	nombre_punto_corte,
	id_punto_corte,
	idc_tipo_flor,
	unidades_por_pieza,
	saldo_inicial
	from #entradas_saldo_def
	where not exists
	(
	select *
	from #entradas
	where #entradas_saldo_def.id_variedad_flor = #entradas.id_variedad_flor
	and #entradas_saldo_def.id_bloque = #entradas.id_bloque
	and #entradas_saldo_def.id_punto_corte = #entradas.id_punto_corte
	)

	update #entradas
	set entradas_anteriores = 0
	where entradas_anteriores is null

	update #entradas
	set solicitados_anteriores = 0
	where solicitados_anteriores is null

	
	select nombre_tipo_flor,
	idc_tipo_flor,
	id_variedad_flor,
	nombre_variedad_flor,
	id_bloque,
	idc_bloque,
	nombre_punto_corte,
	isnull(unidades_por_pieza,0) as entradas,
	isnull(tallos_solicitados,0) as salidas,
	isnull(entradas_anteriores,0) - isnull(solicitados_anteriores,0) as faltante
	from #entradas
	order by idc_bloque,
	nombre_tipo_flor,
	nombre_variedad_flor

	drop table #entradas
	drop table #solicitadas
	drop table #entradas_saldo
	drop table #solicitados_saldo
	drop table #entradas_saldo_def
	drop table #temp
end
else
if(@accion = 'insertar')
begin
	select @id_item = count(*)
	from produccion_solicitada_rusia
	where id_bloque = @id_bloque
	and id_variedad_flor = convert(int,@id_variedad_flor)
	and fecha = @fecha
	and id_grado_flor = @id_grado_flor
	and id_tipo_pedido = @id_tipo_pedido
	and disponible = 1

	if(@id_item = 0)
	begin
		declare @fecha_minima datetime

		select @fecha_minima = min(produccion_solicitada_rusia.fecha) 
		from produccion_solicitada_rusia,
		comentario_produccion_solicitada,
		descripcion_produccion_solicitada
		where produccion_solicitada_rusia.id_produccion_solicitada_rusia = comentario_produccion_solicitada.id_produccion_solicitada_rusia
		and descripcion_produccion_solicitada.id_descripcion_produccion_solicitada  = comentario_produccion_solicitada.id_descripcion_produccion_solicitada
		and descripcion_produccion_solicitada.id_descripcion_produccion_solicitada = @id_descripcion_produccion_solicitada

		if(datediff(d,@fecha_minima,@fecha) < 7 or datediff(d,@fecha_minima,@fecha) is null)
		begin
			insert into produccion_solicitada_rusia (id_cuenta_interna, id_bloque, id_variedad_flor, cantidad_tallos, fecha, id_grado_flor, id_tipo_pedido)
			values (@id_cuenta_interna, @id_bloque, convert(int,@id_variedad_flor), @cantidad_tallos, @fecha, @id_grado_flor, @id_tipo_pedido)

			set @id_item = scope_identity()
		
			insert into comentario_produccion_solicitada (id_descripcion_produccion_solicitada, id_produccion_solicitada_rusia)
			values (@id_descripcion_produccion_solicitada, @id_item)

			select @id_item as id_produccion_solicitada_rusia
		end
		else
		begin
			set @id_item = -4
			select @id_item as id_produccion_solicitada_rusia 
		end
	end
	else
	begin
		set @id_item = -2
		select @id_item as id_produccion_solicitada_rusia 
	end
end
else
if(@accion = 'eliminar')
begin
	update produccion_solicitada_rusia 
	set disponible = 0,
	id_cuenta_interna = @id_cuenta_interna
	where id_produccion_solicitada_rusia = @id_produccion_solicitada_rusia
end
else
if(@accion = 'consultar')
begin
	select produccion_solicitada_rusia.id_produccion_solicitada_rusia,
	bloque.id_bloque,
	bloque.idc_bloque,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	tipo_pedido.id_tipo_pedido,
	'[' + tipo_pedido.idc_tipo_pedido + ']' + space(1) + tipo_pedido.nombre_tipo_pedido as nombre_tipo_pedido,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha,101)) as fecha,
	cantidad_tallos	
	from produccion_solicitada_rusia,
	bloque,
	variedad_flor,
	tipo_flor,
	grado_flor,
	tipo_pedido
	where convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha_creacion,101)) = convert(datetime,convert(nvarchar,getdate(),101))
	and produccion_solicitada_rusia.id_bloque = bloque.id_bloque
	and produccion_solicitada_rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and produccion_solicitada_rusia.id_tipo_pedido = tipo_pedido.id_tipo_pedido
	and produccion_solicitada_rusia.disponible = 1
	order by fecha,
	bloque.idc_bloque,	
	nombre_tipo_flor,
	nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	tipo_pedido.idc_tipo_pedido
end
else
if(@accion = 'consultar_fecha_especifica')
begin
	select produccion_solicitada_rusia.id_produccion_solicitada_rusia,
	bloque.id_bloque,
	bloque.idc_bloque,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	tipo_pedido.id_tipo_pedido,
	'[' + tipo_pedido.idc_tipo_pedido + ']' + space(1) + tipo_pedido.nombre_tipo_pedido as nombre_tipo_pedido,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha,101)) as fecha,
	cantidad_tallos	
	from produccion_solicitada_rusia,
	bloque,
	variedad_flor,
	tipo_flor,
	grado_flor,
	tipo_pedido
	where convert(datetime,convert(nvarchar,produccion_solicitada_rusia.fecha,101)) = convert(datetime,convert(nvarchar,@fecha,101))
	and produccion_solicitada_rusia.id_bloque = bloque.id_bloque
	and produccion_solicitada_rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and produccion_solicitada_rusia.id_tipo_pedido = tipo_pedido.id_tipo_pedido
	and produccion_solicitada_rusia.disponible = 1
	order by fecha,
	bloque.idc_bloque,	
	nombre_tipo_flor,
	nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	tipo_pedido.idc_tipo_pedido
end
else 
if(@accion = 'consultar_reporte_grado')
begin
	/*conultar las solicitudes discriminadas por grado*/
	select tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + space(1) + '[' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	grado_flor.id_grado_flor,
	bloque.idc_bloque,
	descripcion_produccion_solicitada.id_descripcion_produccion_solicitada,
	isnull(descripcion_produccion_solicitada.comentario,'') as comentario,
	tipo_pedido.id_tipo_pedido, 
	'[' + tipo_pedido.idc_tipo_pedido + ']' + space(1) + tipo_pedido.nombre_tipo_pedido as nombre_tipo_pedido,
	sum(produccion_solicitada_rusia.cantidad_tallos) as cantidad_tallos
	from bloque,
	variedad_flor,
	tipo_flor,
	grado_flor,
	punto_corte,
	tipo_pedido,
	produccion_solicitada_rusia left join
	comentario_produccion_solicitada on produccion_solicitada_rusia.id_produccion_solicitada_rusia = comentario_produccion_solicitada.id_produccion_solicitada_rusia 
	left join descripcion_produccion_solicitada on
	descripcion_produccion_solicitada.id_descripcion_produccion_solicitada = comentario_produccion_solicitada.id_descripcion_produccion_solicitada
	where Produccion_Solicitada_Rusia.id_bloque = bloque.id_bloque
	and Produccion_Solicitada_Rusia.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and convert(datetime,convert(nvarchar,Produccion_Solicitada_Rusia.fecha,101)) = @fecha
	and produccion_solicitada_rusia.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_punto_corte = punto_corte.id_punto_corte
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and punto_corte.idc_punto_corte in ('R','Q')
	and produccion_solicitada_rusia.disponible = 1
	and produccion_solicitada_rusia.id_tipo_pedido = tipo_pedido.id_tipo_pedido
	group by tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.nombre_grado_flor,
	grado_flor.idc_grado_flor,
	grado_flor.id_grado_flor,
	bloque.idc_bloque,
	descripcion_produccion_solicitada.id_descripcion_produccion_solicitada,
	descripcion_produccion_solicitada.comentario,
	tipo_pedido.id_tipo_pedido, 
	'[' + tipo_pedido.idc_tipo_pedido + ']' + space(1) + tipo_pedido.nombre_tipo_pedido
end
else
if(@accion = 'insertar_traslado')
begin
	insert into produccion_solicitada_rusia (id_cuenta_interna, id_bloque, id_variedad_flor, cantidad_tallos, fecha, id_grado_flor, id_tipo_pedido)
	values (@id_cuenta_interna, @id_bloque, convert(int,@id_variedad_flor), @cantidad_tallos, @fecha, @id_grado_flor, @id_tipo_pedido)

	set @id_item = scope_identity()

	insert into comentario_produccion_solicitada (id_descripcion_produccion_solicitada, id_produccion_solicitada_rusia)
	values (@id_descripcion_produccion_solicitada, @id_item)

	select @id_item as id_produccion_solicitada_rusia
end
else
if(@accion = 'consultar_bloques')
begin
	select bloque.id_bloque,
	bloque.idc_bloque
	from sembrar_cama_bloque, 
	construir_cama_bloque,
	cama_bloque,
	bloque,
	variedad_flor
	where sembrar_cama_bloque.id_construir_cama_bloque =  construir_cama_bloque.id_construir_cama_bloque
	and construir_cama_bloque.id_bloque = cama_bloque.id_bloque
	and construir_cama_bloque.id_nave = cama_bloque.id_nave
	and construir_cama_bloque.id_cama = cama_bloque.id_cama
	and cama_bloque.id_bloque = bloque.id_bloque
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_variedad_flor = convert(int,@id_variedad_flor)
	and not exists
	(select * from erradicar_cama_bloque
	where sembrar_cama_bloque.id_sembrar_cama_bloque = erradicar_cama_bloque.id_sembrar_cama_bloque)
	group by bloque.id_bloque,
	bloque.idc_bloque
	order by bloque.idc_bloque
end