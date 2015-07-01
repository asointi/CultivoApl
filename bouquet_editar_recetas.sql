/****** Object:  StoredProcedure [dbo].[bouquet_editar_recetas]    Script Date: 08/08/2014 3:57:08 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/30
-- Description:	Maneja informacion de las recetas de los Bouquets
-- =============================================

ALTER PROCEDURE [dbo].[bouquet_editar_recetas] 

@accion nvarchar(255),
@id_formula_bouquet int,
@id_version_bouquet int,
@id_cuenta_interna int, 
@nombre_formula_bouquet nvarchar(50),
@especificacion_bouquet nvarchar(1024), 
@construccion_bouquet nvarchar(1024),
@id_variedad_flor_cultivo int, 
@id_grado_flor_cultivo int, 
@cantidad_tallos int,
@observacion nvarchar(1024),
@cadena_formula nvarchar(255),
@unidades int,
@precio_miami decimal(20,4),
@id_comida_bouquet int,
@opcion_menu int = null,
@id_variedad_flor_cultivo_sustitucion int = null, 
@id_grado_flor_cultivo_sustitucion int = null,
@id_detalle_version_bouquet int = null,
@id_detalle_formula_bouquet int = null,
@id_formato_upc int = null

as

declare @id_formula_unica_bouquet int,
@sql varchar(max),
@conteo int,
@cadena_formula_comparacion nvarchar(255),
@upc nvarchar(255),
@descripcion nvarchar(255),
@fecha nvarchar(255),
@precio nvarchar(255),
@id_detalle_version_bouquet_ant int

set @upc = 'UPC'
set @descripcion = 'Descripcion'
set @fecha = 'Fecha'
set @precio = 'Precio'
set @id_detalle_version_bouquet_ant = @id_detalle_version_bouquet

if(@accion = 'insertar_formula')
begin
	set @cadena_formula_comparacion = @cadena_formula

	/*seleccionar las ultimas versiones de los registros enviados a los cultivos*/
	select max(id_farm_detalle_po) as id_farm_detalle_po into #farm_detalle_po
	from farm_detalle_po
	group by id_farm_detalle_po_padre

	/*verificar que la orden haya sido enviada al cultivo*/
	select @conteo = count(*) 
	from version_bouquet,
	detalle_po,
	farm_detalle_po,
	solicitud_confirmacion_cultivo
	where version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and detalle_po.id_detalle_po = farm_detalle_po.id_detalle_po
	and exists
	(
		select *
		from #farm_detalle_po
		where farm_detalle_po.id_farm_detalle_po = #farm_detalle_po.id_farm_detalle_po
	)
	and not exists
	(
		select *
		from cancela_detalle_po
		where detalle_po.id_detalle_po = cancela_detalle_po.id_detalle_po
	)
	and version_bouquet.id_version_bouquet = @id_version_bouquet
	and farm_detalle_po.id_farm_detalle_po = solicitud_confirmacion_cultivo.id_farm_detalle_po

	/*verificar la existencia de la formula*/
	select @id_formula_unica_bouquet = id_formula_unica_bouquet
	from formula_unica_bouquet
	where cadena_formula_unica = @cadena_formula

	if(@id_formula_unica_bouquet is null and @cadena_formula <> '')
	begin
		/*insertar la formula y su respectivo detalle*/
		insert into formula_unica_bouquet (cadena_formula_unica)
		values (@cadena_formula)

		set @id_formula_unica_bouquet = scope_identity()

		insert into formula_bouquet (id_cuenta_interna, id_formula_unica_bouquet, nombre_formula_bouquet, especificacion_bouquet, construccion_bouquet)
		values (@id_cuenta_interna, @id_formula_unica_bouquet, @nombre_formula_bouquet, @especificacion_bouquet, @construccion_bouquet)

		set @id_formula_bouquet = scope_identity()

		create table #temp 
		(
			id nvarchar(255),
			id_variedad_flor_cultivo int, 
			id_grado_flor_cultivo int,
			cantidad_tallos int
		)

		set @cadena_formula = @cadena_formula + ''''

		/*crear la insercion para los valores separados por el signo de pesos $*/
		select @sql = 'insert into #temp (id) select '''+	replace(@cadena_formula,'$',''' union all select ''')

		/*cargar todos los valores de la variable @cadena_formula en la tabla temporal*/
		exec (@SQL)
		
		update #temp
		set id_variedad_flor_cultivo = left(id, patindex('%,%', id)-1),
		id_grado_flor_cultivo = substring(id, (patindex('%,%', id) + 1), (charindex(',',id, patindex('%,%', id) + 1)) - (patindex('%,%', id) + 1)),
		cantidad_tallos = right(id, (len(id)) - (charindex(',',id, patindex('%,%', id) + 1)))

		insert into detalle_formula_bouquet (id_variedad_flor_cultivo, id_grado_flor_cultivo, id_formula_unica_bouquet, cantidad_tallos)
		select id_variedad_flor_cultivo, id_grado_flor_cultivo,	@id_formula_unica_bouquet, cantidad_tallos
		from #temp
	end
	else
	begin
		select @id_formula_bouquet = id_formula_bouquet
		from formula_bouquet
		where nombre_formula_bouquet = @nombre_formula_bouquet
		and especificacion_bouquet = @especificacion_bouquet
		and construccion_bouquet = @construccion_bouquet
		and id_formula_unica_bouquet = @id_formula_unica_bouquet

		if(@id_formula_bouquet is null)
		begin
			insert into formula_bouquet (id_cuenta_interna, id_formula_unica_bouquet, nombre_formula_bouquet, especificacion_bouquet, construccion_bouquet)
			values (@id_cuenta_interna, @id_formula_unica_bouquet, @nombre_formula_bouquet, @especificacion_bouquet, @construccion_bouquet)

			set @id_formula_bouquet = scope_identity()
		end
	end
	
	/*verificar que exista la relacion entre la formula y el bouquet*/
	select @id_detalle_version_bouquet = detalle_version_bouquet.id_detalle_version_bouquet
	from detalle_version_bouquet,
	formula_bouquet
	where formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and detalle_version_bouquet.id_version_bouquet = @id_version_bouquet
	and formula_bouquet.id_formula_bouquet = @id_formula_bouquet
	
	if(@id_detalle_version_bouquet is null and @id_detalle_version_bouquet_ant is null)
	begin
		/*crear la relacion entre la formula y el bouquet*/
		insert into detalle_version_bouquet (id_version_bouquet, id_formula_bouquet, unidades, precio_miami, opcion_menu, id_comida_bouquet, id_formato_upc)
		select version_bouquet.id_version_bouquet, 
		@id_formula_bouquet, 
		@unidades, 
		@precio_miami,
		@opcion_menu,
		@id_comida_bouquet,
		@id_formato_upc
		from version_bouquet
		where version_bouquet.id_version_bouquet = @id_version_bouquet

		set @id_detalle_version_bouquet = scope_identity()

		select @id_formula_bouquet as id_formula_bouquet,
		@id_detalle_version_bouquet as id_detalle_version_bouquet,
		@id_version_bouquet as id_version_bouquet
	end
	else
	if(@id_detalle_version_bouquet is null and @id_detalle_version_bouquet_ant is not null)
	begin
		update detalle_version_bouquet
		set id_formula_bouquet = @id_formula_bouquet,
		unidades = @unidades,
		precio_miami = @precio_miami,
		opcion_menu = @opcion_menu,
		id_comida_bouquet = @id_comida_bouquet,
		id_formato_upc = @id_formato_upc
		where id_detalle_version_bouquet = @id_detalle_version_bouquet_ant

		select @id_formula_bouquet as id_formula_bouquet,
		@id_detalle_version_bouquet_ant as id_detalle_version_bouquet,
		@id_version_bouquet as id_version_bouquet
	end
	else
	begin
		/*el bouquet enviado no ha sido enviado al cultivo, por lo tanto se puede modificar*/
		if(@conteo = 0)
		begin
			update detalle_version_bouquet
			set id_formula_bouquet = @id_formula_bouquet,
			unidades = @unidades,
			precio_miami = @precio_miami,
			opcion_menu = @opcion_menu,
			id_comida_bouquet = @id_comida_bouquet,
			id_formato_upc = @id_formato_upc
			where id_detalle_version_bouquet = @id_detalle_version_bouquet
		end
		else
		begin
			/*el registro ya fue enviado a la finca - se debe crear una nueva version del bouquet*/
			insert into version_bouquet (id_caja, id_bouquet)
			select id_caja, 
			id_bouquet
			from version_bouquet		
			where id_version_bouquet = @id_version_bouquet
	
			set @id_version_bouquet = scope_identity()

			insert into detalle_version_bouquet (id_version_bouquet, id_formula_bouquet, unidades, precio_miami, opcion_menu, id_comida_bouquet, id_formato_upc)
			select version_bouquet.id_version_bouquet,
			@id_formula_bouquet,
			@unidades,
			@precio_miami,
			@opcion_menu,
			@id_comida_bouquet,
			@id_formato_upc
			from version_bouquet
			where version_bouquet.id_version_bouquet = @id_version_bouquet
	
			set @id_detalle_version_bouquet = scope_identity()
		end

		select @id_formula_bouquet as id_formula_bouquet,
		@id_detalle_version_bouquet as id_detalle_version_bouquet,
		@id_version_bouquet as id_version_bouquet
	end

	drop table #farm_detalle_po
end
else
if(@accion = 'consultar_detalle_formula_opcion3')
begin
	select formula_bouquet.nombre_formula_bouquet,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) + ' ' + ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) + ' ' + ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_flor,
	(
		select observacion_detalle_formula_bouquet.observacion
		from observacion_detalle_formula_bouquet
		where detalle_formula_bouquet.id_detalle_formula_bouquet = observacion_detalle_formula_bouquet.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = observacion_detalle_formula_bouquet.id_detalle_version_bouquet
	) as observacion,
	detalle_formula_bouquet.cantidad_tallos,
	(
		select ltrim(rtrim(t.nombre_tipo_flor)) + ' ' + ltrim(rtrim(v.nombre_variedad_flor)) + ' ' + ltrim(rtrim(g.nombre_grado_flor))
		from tipo_flor_cultivo as t,
		variedad_flor_cultivo as v,
		grado_flor_cultivo as g,
		sustitucion_detalle_formula_bouquet
		where t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
		and t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
		and v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
		and g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
		and detalle_formula_bouquet.id_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
	) as nombre_flor_sustitucion into #formula_bouquet
	from version_bouquet,
	detalle_version_bouquet,
	formula_bouquet,
	formula_unica_bouquet,
	detalle_formula_bouquet,
	tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo
	where formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
	and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by nombre_flor

	select null as nombre_flor,
	nombre_formula_bouquet as cantidad_tallos,
	'' as observacion,
	null as nombre_flor_sustitucion
	from #formula_bouquet
	group by nombre_formula_bouquet
	union all
	select nombre_flor,
	convert(nvarchar,sum(cantidad_tallos)),
	observacion,
	nombre_flor_sustitucion
	from #formula_bouquet
	group by nombre_flor, observacion, nombre_flor_sustitucion
	union all
	select 'Total',
	convert(nvarchar,sum(cantidad_tallos)),
	'',
	''
	from #formula_bouquet

	drop table #formula_bouquet
end
else
if(@accion = 'consultar_favoritos')
begin
	declare @cols nvarchar(max),
	@query nvarchar(max),
	@id_cliente_despacho int,
	@id_variedad_flor int,
	@id_grado_flor int
	
	select @id_cliente_despacho = cliente_despacho.id_despacho,
	@id_variedad_flor = bouquet.id_variedad_flor,
	@id_grado_flor = bouquet.id_grado_flor
	from version_bouquet,
	bouquet,
	detalle_po,
	po,
	cliente_despacho
	where bouquet.id_bouquet = version_bouquet.id_bouquet
	and version_bouquet.id_version_bouquet = @id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and po.id_po = detalle_po.id_po
	and cliente_despacho.id_despacho = po.id_despacho

	select formula_bouquet.id_formula_bouquet,
	convert(nvarchar,max(detalle_version_bouquet.id_detalle_version_bouquet)) + '-' + formula_bouquet.nombre_formula_bouquet as nombre_formula_bouquet,
	formula_bouquet.nombre_formula_bouquet as nombre_formula_bouquet_orden,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) + ' ' + ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) + ' ' + ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_flor,
	detalle_formula_bouquet.cantidad_tallos into #formula
	from po,
	cliente_despacho,
	bouquet,
	detalle_po,
	version_bouquet,
	detalle_version_bouquet,
	formula_bouquet,
	tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo,
	formula_unica_bouquet,
	detalle_formula_bouquet
	where bouquet.id_bouquet = version_bouquet.id_bouquet
	and bouquet.id_variedad_flor = @id_variedad_flor
	and bouquet.id_grado_flor = @id_grado_flor
	and cliente_despacho.id_despacho = po.id_despacho
	and cliente_despacho.id_despacho = @id_cliente_despacho
	and po.id_po = detalle_po.id_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
	and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
	group by formula_bouquet.id_formula_bouquet,
	convert(nvarchar,formula_bouquet.id_formula_bouquet),
	formula_bouquet.nombre_formula_bouquet,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)),
	ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)),
	ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)),
	detalle_formula_bouquet.cantidad_tallos

	insert into #formula (id_formula_bouquet, nombre_formula_bouquet, nombre_formula_bouquet_orden, nombre_flor, cantidad_tallos)
	select formula_bouquet.id_formula_bouquet,
	convert(nvarchar,max(detalle_version_bouquet.id_detalle_version_bouquet)) + '-' + formula_bouquet.nombre_formula_bouquet as nombre_formula_bouquet,
	formula_bouquet.nombre_formula_bouquet as nombre_formula_bouquet_orden,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) + ' ' + ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) + ' ' + ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_flor,
	detalle_formula_bouquet.cantidad_tallos 
	from po,
	cliente_despacho,
	bouquet,
	detalle_po,
	version_bouquet,
	detalle_version_bouquet,
	formula_bouquet,
	tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo,
	formula_unica_bouquet,
	detalle_formula_bouquet,
	cuenta_interna
	where bouquet.id_bouquet = version_bouquet.id_bouquet
	and bouquet.id_variedad_flor = @id_variedad_flor
	and bouquet.id_grado_flor = @id_grado_flor
	and po.id_po = detalle_po.id_po
	and version_bouquet.id_version_bouquet = detalle_po.id_version_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
	and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
	and cuenta_interna.id_cuenta_interna = po.id_cuenta_interna
	and cuenta_interna.id_cuenta_interna = @id_cuenta_interna
	and not exists
	(
		select *
		from #formula
		where formula_bouquet.id_formula_bouquet = #formula.id_formula_bouquet
	)
 	group by formula_bouquet.id_formula_bouquet,
	convert(nvarchar,formula_bouquet.id_formula_bouquet),
	formula_bouquet.nombre_formula_bouquet,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)),
	ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)),
	ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)),
	detalle_formula_bouquet.cantidad_tallos

	select @cols = STUFF((SELECT ',' + QUOTENAME(nombre_formula_bouquet) 
						from #formula
						group by nombre_formula_bouquet, nombre_formula_bouquet_orden
						order by nombre_formula_bouquet_orden
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')

	set @query = 'SELECT nombre_flor, ' + @cols + ' from 
				 (
					select cantidad_tallos, nombre_flor, nombre_formula_bouquet
					from #formula
				) x
				pivot 
				(
					max(cantidad_tallos)
					for nombre_formula_bouquet in (' + @cols + ')
				) p '

	execute(@query)

	drop table #formula
end
else
if(@accion = 'consultar_formula')
begin
	select formula_bouquet.id_formula_bouquet,
	formula_bouquet.nombre_formula_bouquet,
	formula_bouquet.especificacion_bouquet,
	formula_bouquet.construccion_bouquet
	from formula_bouquet,
	detalle_version_bouquet
	where formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	group by formula_bouquet.id_formula_bouquet,
	formula_bouquet.nombre_formula_bouquet,
	formula_bouquet.especificacion_bouquet,
	formula_bouquet.construccion_bouquet

	select detalle_formula_bouquet.id_detalle_formula_bouquet,
	tipo_flor_cultivo.nombre_tipo_flor,
	variedad_flor_cultivo.nombre_variedad_flor,
	grado_flor_cultivo.nombre_grado_flor,
	tipo_flor_cultivo.id_tipo_flor_cultivo,
	variedad_flor_cultivo.id_variedad_flor_cultivo,
	grado_flor_cultivo.id_grado_flor_cultivo,
	cantidad_tallos, 
	(
		select observacion_detalle_formula_bouquet.observacion
		from observacion_detalle_formula_bouquet
		where detalle_formula_bouquet.id_detalle_formula_bouquet = observacion_detalle_formula_bouquet.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = observacion_detalle_formula_bouquet.id_detalle_version_bouquet
	) as observacion,
	detalle_version_bouquet.unidades,
	convert(decimal(20,2),detalle_version_bouquet.precio_miami) as precio_miami,
	detalle_version_bouquet.id_comida_bouquet,
	(
		select id_grado_flor_cultivo
		from sustitucion_detalle_formula_bouquet
		where Detalle_Version_Bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
		and Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
	) as id_grado_flor_cultivo_sustitucion,
	(
		select id_variedad_flor_cultivo
		from sustitucion_detalle_formula_bouquet
		where Detalle_Version_Bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
		and Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
	) as id_variedad_flor_cultivo_sustitucion,
	(
		select t.id_tipo_flor_cultivo
		from tipo_flor_cultivo as t,
		variedad_flor_cultivo as v,
		grado_flor_cultivo as g,
		sustitucion_detalle_formula_bouquet
		where t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
		and t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
		and v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
		and g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
		and Detalle_Version_Bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
		and Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
	) as id_tipo_flor_cultivo_sustitucion,
	(
		select ltrim(rtrim(t.nombre_tipo_flor))
		from tipo_flor_cultivo as t,
		variedad_flor_cultivo as v,
		grado_flor_cultivo as g,
		Sustitucion_Detalle_Formula_Bouquet
		where t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
		and t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
		and v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
		and g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
		and Detalle_Version_Bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
		and Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
	) as nombre_tipo_flor_sustitucion,
	(
		select ltrim(rtrim(v.nombre_variedad_flor))
		from variedad_flor_cultivo as v,
		Sustitucion_Detalle_Formula_Bouquet
		where v.id_variedad_flor_cultivo = sustitucion_detalle_formula_bouquet.id_variedad_flor_cultivo
		and Detalle_Version_Bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
		and Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
	) as nombre_variedad_flor_sustitucion,
	(
		select ltrim(rtrim(g.nombre_grado_flor))
		from grado_flor_cultivo as g,
		Sustitucion_Detalle_Formula_Bouquet
		where g.id_grado_flor_cultivo = sustitucion_detalle_formula_bouquet.id_grado_flor_cultivo
		and Detalle_Version_Bouquet.id_detalle_version_bouquet = sustitucion_detalle_formula_bouquet.id_detalle_version_bouquet
		and Detalle_Formula_Bouquet.id_detalle_formula_bouquet = Sustitucion_Detalle_Formula_Bouquet.id_detalle_formula_bouquet
	) as nombre_grado_flor_sustitucion,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @upc
	) as upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @upc
	) as orden_upc,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @descripcion
	) as descripcion_upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @descripcion
	) as orden_descripcion_upc,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @fecha
	) as fecha_upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @fecha
	) as orden_fecha_upc,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @precio
	) as precio_upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @precio
	) as orden_precio_upc
	from detalle_formula_bouquet,
	detalle_version_bouquet,
	formula_unica_bouquet,
	formula_bouquet,
	tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo
	where formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
	and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
	and detalle_version_bouquet.id_detalle_version_bouquet = @id_detalle_version_bouquet
	order by nombre_tipo_flor,
	variedad_flor_cultivo.nombre_variedad_flor,
	grado_flor_cultivo.nombre_grado_flor
end
else 
if(@accion = 'consultar_variedad_sin_formula')
begin
	select ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) + ' ' + ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) + ' ' + 
	(
		select ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor))
		from grado_flor_cultivo
		where tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
		and grado_flor_cultivo.id_grado_flor_cultivo = @id_grado_flor_cultivo
	) as nombre_flor,
	variedad_flor_cultivo.id_variedad_flor_cultivo
	from tipo_flor_cultivo,
	variedad_flor_cultivo
	where tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.idc_tipo_flor = 'XQ'
	and variedad_flor_cultivo.idc_variedad_flor = 'EC'
end
else
if(@accion = 'actualizar_restriccion_detalle_formula')
begin
	declare @id_Observacion_Detalle_Formula_Bouquet int,
	@id_sustitucion_detalle_formula_bouquet int

	select @id_detalle_formula_bouquet = detalle_formula_bouquet.id_detalle_formula_bouquet
	from detalle_formula_bouquet,
	formula_unica_bouquet,
	formula_bouquet
	where detalle_formula_bouquet.id_variedad_flor_cultivo = @id_variedad_flor_cultivo 
	and detalle_formula_bouquet.id_grado_flor_cultivo = @id_grado_flor_cultivo
	and detalle_formula_bouquet.cantidad_tallos = @cantidad_tallos
	and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and formula_bouquet.id_formula_bouquet = @id_formula_bouquet

	select @id_Observacion_Detalle_Formula_Bouquet = Observacion_Detalle_Formula_Bouquet.id_Observacion_Detalle_Formula_Bouquet
	from Observacion_Detalle_Formula_Bouquet
	where id_detalle_formula_bouquet = @id_detalle_formula_bouquet
	and id_detalle_version_bouquet = @id_detalle_version_bouquet

	if(@id_Observacion_Detalle_Formula_Bouquet is not null)
	begin
		update Observacion_Detalle_Formula_Bouquet
		set observacion = @observacion
		where id_Observacion_Detalle_Formula_Bouquet = @id_Observacion_Detalle_Formula_Bouquet
	end
	else
	if(@observacion is not null)
	begin
		insert into Observacion_Detalle_Formula_Bouquet (id_detalle_formula_bouquet, id_detalle_version_bouquet, observacion)
		values (@id_detalle_formula_bouquet, @id_detalle_version_bouquet, @observacion)
	end

	if(@id_variedad_flor_cultivo_sustitucion is not null and @id_grado_flor_cultivo_sustitucion is not null)
	begin
		select @id_sustitucion_detalle_formula_bouquet = sustitucion_detalle_formula_bouquet.id_sustitucion_detalle_formula_bouquet
		from sustitucion_detalle_formula_bouquet
		where id_detalle_formula_bouquet = convert(int,@id_detalle_formula_bouquet)
		and id_detalle_version_bouquet = @id_detalle_version_bouquet
	
		if(@id_sustitucion_detalle_formula_bouquet is null)
		begin
			insert into sustitucion_detalle_formula_bouquet (id_detalle_formula_bouquet, id_variedad_flor_cultivo, id_grado_flor_cultivo, id_detalle_version_bouquet)
			values (convert(int,@id_detalle_formula_bouquet), @id_variedad_flor_cultivo_sustitucion, @id_grado_flor_cultivo_sustitucion, @id_detalle_version_bouquet)
		end
		else
		begin
			update sustitucion_detalle_formula_bouquet
			set id_variedad_flor_cultivo = @id_variedad_flor_cultivo_sustitucion, 
			id_grado_flor_cultivo = @id_grado_flor_cultivo_sustitucion
			where id_sustitucion_detalle_formula_bouquet = @id_sustitucion_detalle_formula_bouquet
		end
	end
end
else
if(@accion = 'consultar_numero_consecutivo')
begin
	declare @nombre_tipo_flor nvarchar(255),
	@numero_consecutivo int

	select @nombre_tipo_flor = ltrim(rtrim(variedad_flor.nombre_variedad_flor))
	from bouquet,
	version_bouquet,
	variedad_flor
	where variedad_flor.id_variedad_flor = bouquet.id_variedad_flor
	and bouquet.id_bouquet = version_bouquet.id_bouquet
	and version_bouquet.id_version_bouquet = @id_version_bouquet

	select substring(ltrim(rtrim(nombre_formula_bouquet)), len(@nombre_tipo_flor)+1, len(ltrim(rtrim(nombre_formula_bouquet)))) as numero_consecutivo into #consecutivo
	from formula_bouquet
	where left(ltrim(rtrim(nombre_formula_bouquet)), len(@nombre_tipo_flor)) = @nombre_tipo_flor

	select @numero_consecutivo = max(numero_consecutivo) 
	from #consecutivo
	where isnumeric(numero_consecutivo) = 1

	if(@numero_consecutivo is null)
	begin
		set @numero_consecutivo = 1
	end
	else
	begin
		set @numero_consecutivo = @numero_consecutivo + 1
	end

	select @nombre_tipo_flor + ' ' + 
	case
		when len(@numero_consecutivo) = 1 then '00' +  convert(nvarchar,@numero_consecutivo)
		when len(@numero_consecutivo) = 2 then '0' +  convert(nvarchar,@numero_consecutivo)
		else  convert(nvarchar,@numero_consecutivo)
	end as numero_consecutivo

	drop table #consecutivo
end
else
if(@accion = 'consultar_todas_recetas')
begin
	select formula_bouquet.id_formula_bouquet,
	formula_bouquet.nombre_formula_bouquet,
	formula_bouquet.especificacion_bouquet,
	formula_bouquet.construccion_bouquet,
	sum(detalle_version_bouquet.unidades) as unidades,
	sum(detalle_version_bouquet.precio_miami) as precio_miami,
	max(detalle_version_bouquet.opcion_menu) as opcion_menu
	from formula_bouquet,
	detalle_version_bouquet,
	version_bouquet
	where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and version_bouquet.id_version_bouquet = @id_version_bouquet
	group by formula_bouquet.id_formula_bouquet,
	formula_bouquet.nombre_formula_bouquet,
	formula_bouquet.especificacion_bouquet,
	formula_bouquet.construccion_bouquet
	order by formula_bouquet.nombre_formula_bouquet

	select detalle_version_bouquet.id_detalle_version_bouquet,
	detalle_version_bouquet.unidades,
	detalle_version_bouquet.precio_miami,
	detalle_version_bouquet.opcion_menu,
	comida_bouquet.id_comida_bouquet,
	comida_bouquet.nombre_comida,
	formula_bouquet.id_formula_bouquet,
	formula_bouquet.nombre_formula_bouquet,
	formula_bouquet.especificacion_bouquet,
	formula_bouquet.construccion_bouquet,
	tipo_flor_cultivo.id_tipo_flor_cultivo,
	tipo_flor_cultivo.idc_tipo_flor,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor_cultivo.id_variedad_flor_cultivo,
	variedad_flor_cultivo.idc_variedad_flor,
	ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor_cultivo.id_grado_flor_cultivo,
	grado_flor_cultivo.idc_grado_flor,
	ltrim(rtrim(grado_flor_cultivo.nombre_grado_flor)) as nombre_grado_flor,
	detalle_formula_bouquet.cantidad_tallos,
	(
		select observacion_detalle_formula_bouquet.observacion
		from observacion_detalle_formula_bouquet
		where detalle_formula_bouquet.id_detalle_formula_bouquet = observacion_detalle_formula_bouquet.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = observacion_detalle_formula_bouquet.id_detalle_version_bouquet
	) as observacion,
	(
		select t.id_tipo_flor_cultivo
		from sustitucion_detalle_formula_bouquet as s,
		tipo_flor_cultivo as t,
		variedad_flor_cultivo as v,
		grado_flor_cultivo as g
		where t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
		and t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
		and v.id_variedad_flor_cultivo = s.id_variedad_flor_cultivo
		and g.id_grado_flor_cultivo = s.id_grado_flor_cultivo
		and detalle_formula_bouquet.id_detalle_formula_bouquet = s.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = s.id_detalle_version_bouquet
	) as id_tipo_flor_cultivo_sustitucion,
	(
		select ltrim(rtrim(t.nombre_tipo_flor))
		from sustitucion_detalle_formula_bouquet as s,
		tipo_flor_cultivo as t,
		variedad_flor_cultivo as v,
		grado_flor_cultivo as g
		where t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
		and t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
		and v.id_variedad_flor_cultivo = s.id_variedad_flor_cultivo
		and g.id_grado_flor_cultivo = s.id_grado_flor_cultivo
		and detalle_formula_bouquet.id_detalle_formula_bouquet = s.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = s.id_detalle_version_bouquet
	) as nombre_tipo_flor_cultivo_sustitucion,
	(
		select v.id_variedad_flor_cultivo
		from sustitucion_detalle_formula_bouquet as s,
		tipo_flor_cultivo as t,
		variedad_flor_cultivo as v
		where t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
		and v.id_variedad_flor_cultivo = s.id_variedad_flor_cultivo
		and detalle_formula_bouquet.id_detalle_formula_bouquet = s.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = s.id_detalle_version_bouquet
	) as id_variedad_flor_cultivo_sustitucion,
	(
		select ltrim(rtrim(v.nombre_variedad_flor))
		from sustitucion_detalle_formula_bouquet as s,
		tipo_flor_cultivo as t,
		variedad_flor_cultivo as v
		where t.id_tipo_flor_cultivo = v.id_tipo_flor_cultivo
		and v.id_variedad_flor_cultivo = s.id_variedad_flor_cultivo
		and detalle_formula_bouquet.id_detalle_formula_bouquet = s.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = s.id_detalle_version_bouquet
	) as nombre_variedad_flor_cultivo_sustitucion,
	(
		select g.id_grado_flor_cultivo
		from sustitucion_detalle_formula_bouquet as s,
		tipo_flor_cultivo as t,
		grado_flor_cultivo as g
		where t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
		and g.id_grado_flor_cultivo = s.id_grado_flor_cultivo
		and detalle_formula_bouquet.id_detalle_formula_bouquet = s.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = s.id_detalle_version_bouquet
	) as id_grado_flor_cultivo_sustitucion,
	(
		select ltrim(rtrim(g.nombre_grado_flor))
		from sustitucion_detalle_formula_bouquet as s,
		tipo_flor_cultivo as t,
		grado_flor_cultivo as g
		where t.id_tipo_flor_cultivo = g.id_tipo_flor_cultivo
		and g.id_grado_flor_cultivo = s.id_grado_flor_cultivo
		and detalle_formula_bouquet.id_detalle_formula_bouquet = s.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = s.id_detalle_version_bouquet
	) as nombre_grado_flor_cultivo_sustitucion,
	(
		select s.id_sustitucion_detalle_formula_bouquet
		from sustitucion_detalle_formula_bouquet as s
		where detalle_formula_bouquet.id_detalle_formula_bouquet = s.id_detalle_formula_bouquet
		and detalle_version_bouquet.id_detalle_version_bouquet = s.id_detalle_version_bouquet
	) as id_sustitucion_detalle_formula_bouquet,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @upc
	) as upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @upc
	) as orden_upc,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @descripcion
	) as descripcion_upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @descripcion
	) as orden_descripcion_upc,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @fecha
	) as fecha_upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @fecha
	) as orden_fecha_upc,
	(
		select valor
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @precio
	) as precio_upc,
	(
		select orden
		from informacion_upc,
		upc_detalle_po
		where informacion_upc.id_informacion_upc = upc_detalle_po.id_informacion_upc
		and detalle_version_bouquet.id_detalle_version_bouquet = upc_detalle_po.id_detalle_version_bouquet
		and informacion_upc.nombre_informacion_upc = @precio
	) as orden_precio_upc,
	detalle_version_bouquet.id_formato_upc,
	(
		select formato_upc.nombre_formato
		from formato_upc
		where formato_upc.id_formato_upc = detalle_version_bouquet.id_formato_upc
	) as nombre_formato
	from formula_bouquet,
	detalle_version_bouquet,
	detalle_formula_bouquet,
	version_bouquet,
	comida_bouquet,
	formula_unica_bouquet,
	tipo_flor_cultivo,
	variedad_flor_cultivo,
	grado_flor_cultivo
	where formula_bouquet.id_formula_bouquet = detalle_version_bouquet.id_formula_bouquet
	and version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and comida_bouquet.id_comida_bouquet = detalle_version_bouquet.id_comida_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = formula_bouquet.id_formula_unica_bouquet
	and formula_unica_bouquet.id_formula_unica_bouquet = detalle_formula_bouquet.id_formula_unica_bouquet
	and tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and tipo_flor_cultivo.id_tipo_flor_cultivo = grado_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = detalle_formula_bouquet.id_variedad_flor_cultivo
	and grado_flor_cultivo.id_grado_flor_cultivo = detalle_formula_bouquet.id_grado_flor_cultivo
	and version_bouquet.id_version_bouquet = @id_version_bouquet
	order by nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor

	select detalle_version_bouquet.id_detalle_version_bouquet,
	capuchon_formula_bouquet.id_capuchon_formula_bouquet,
	capuchon_cultivo.id_capuchon_cultivo,
	capuchon_cultivo.idc_capuchon,
	ltrim(rtrim(capuchon_cultivo.descripcion)) + ' (' + convert(nvarchar,convert(decimal(20,1),ancho_superior)) + ')' as nombre_capuchon
	from version_bouquet,
	detalle_version_bouquet,
	capuchon_formula_bouquet,
	capuchon_cultivo
	where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = capuchon_formula_bouquet.id_detalle_version_bouquet
	and capuchon_cultivo.id_capuchon_cultivo = capuchon_formula_bouquet.id_capuchon_cultivo
	and version_bouquet.id_version_bouquet = @id_version_bouquet

	select sticker.id_sticker,
	sticker.nombre_sticker,
	sticker_bouquet.id_sticker_bouquet,
	detalle_version_bouquet.id_detalle_version_bouquet
	from sticker,
	sticker_bouquet,
	detalle_version_bouquet,
	version_bouquet
	where version_bouquet.id_version_bouquet = detalle_version_bouquet.id_version_bouquet
	and detalle_version_bouquet.id_detalle_version_bouquet = sticker_bouquet.id_detalle_version_bouquet
	and sticker.id_sticker = sticker_bouquet.id_sticker
	and version_bouquet.id_version_bouquet = @id_version_bouquet
end
else
if(@accion = 'eliminar_receta')
begin
	delete from upc_detalle_po
	where id_detalle_version_bouquet = @id_detalle_version_bouquet

	delete from capuchon_formula_bouquet
	where id_detalle_version_bouquet = @id_detalle_version_bouquet

	delete from sticker_bouquet
	where id_detalle_version_bouquet = @id_detalle_version_bouquet

	delete from observacion_detalle_formula_bouquet
	where id_detalle_version_bouquet = @id_detalle_version_bouquet

	delete from sustitucion_detalle_formula_bouquet
	where id_detalle_version_bouquet = @id_detalle_version_bouquet

	delete from detalle_version_bouquet
	where id_detalle_version_bouquet = @id_detalle_version_bouquet
end
else
if(@accion = 'eliminar_sustitucion')
begin
	begin try
		delete from sustitucion_detalle_formula_bouquet
		where id_detalle_formula_bouquet = @id_detalle_formula_bouquet
		and id_detalle_version_bouquet = @id_detalle_version_bouquet

		delete from observacion_detalle_formula_bouquet
		where id_detalle_formula_bouquet = @id_detalle_formula_bouquet
		and id_detalle_version_bouquet = @id_detalle_version_bouquet

		select 1 as elimina
	end try
	begin catch
		select -1 as elimina
	end catch
end