set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_editar_conteo_estimado_variedad_flor]

@id_consecutivo_reporte_supervisor nvarchar(512),
@id_rango_fecha_reporte_supervisor int,
@id_conteo_estimado_variedad_flor int,
@fecha_inicial datetime,
@fecha_final datetime,
@cantidad_tallos int,
@id_sesion nvarchar(255),
@id_cuenta_interna int,
@id_grupo_consecutivo int,
@accion nvarchar(255),
@@control int output

as

declare @id_item int,
@conteo int,
@numero_consecutivo int,
@id_supervisor int

if(@accion = 'generar_reporte_detalle')
begin
	select consecutivo_reporte_supervisor.numero_consecutivo,
	bloque.id_bloque,
	bloque.idc_bloque,
	'[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	grupo_consecutivo.fecha_transaccion,
	reporte_supervisor_procesado.id_reporte_supervisor_procesado
	from grupo_consecutivo,
	consecutivo_reporte_supervisor left join reporte_supervisor_procesado 
	on consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor = reporte_supervisor_procesado.id_consecutivo_reporte_supervisor,
	conteo_estimado_variedad_flor,
	bloque,
	supervisor
	where grupo_consecutivo.id_grupo_consecutivo = consecutivo_reporte_supervisor.id_grupo_consecutivo
	and consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor = conteo_estimado_variedad_flor.id_consecutivo_reporte_supervisor
	and conteo_estimado_variedad_flor.id_bloque = bloque.id_bloque
	and bloque.id_supervisor = supervisor.id_supervisor
	group by consecutivo_reporte_supervisor.numero_consecutivo,
	bloque.id_bloque,
	bloque.idc_bloque,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor,
	grupo_consecutivo.fecha_transaccion,
	reporte_supervisor_procesado.id_reporte_supervisor_procesado
end
else
if(@accion = 'generar_reporte_por_grupo')
begin
	select consecutivo_reporte_supervisor.numero_consecutivo,
	'[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	bloque.idc_bloque,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	rango_fecha_reporte_supervisor.fecha_inicial,
	rango_fecha_reporte_supervisor.fecha_final,
	(select cantidad_tallos from cantidad_tallos_conteo_estimado
	where cantidad_tallos_conteo_estimado.id_bloque = conteo_estimado_variedad_flor.id_bloque
	and cantidad_tallos_conteo_estimado.id_variedad_flor = conteo_estimado_variedad_flor.id_variedad_flor
	and cantidad_tallos_conteo_estimado.id_consecutivo_reporte_supervisor = conteo_estimado_variedad_flor.id_consecutivo_reporte_supervisor
	and cantidad_tallos_conteo_estimado.id_rango_fecha_reporte_supervisor = rango_fecha_reporte_supervisor.id_rango_fecha_reporte_supervisor) as cantidad_tallos
	from consecutivo_reporte_supervisor,
	conteo_estimado_variedad_flor,
	rango_fecha_reporte_supervisor,
	supervisor,
	bloque,
	variedad_flor,
	tipo_flor,
	grupo_consecutivo
	where grupo_consecutivo.id_grupo_consecutivo = consecutivo_reporte_supervisor.id_grupo_consecutivo
	and grupo_consecutivo.id_grupo_consecutivo = rango_fecha_reporte_supervisor.id_grupo_consecutivo
	and supervisor.id_supervisor = consecutivo_reporte_supervisor.id_supervisor
	and bloque.id_supervisor = supervisor.id_supervisor
	and bloque.id_bloque = conteo_estimado_variedad_flor.id_bloque
	and variedad_flor.id_variedad_flor = conteo_estimado_variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor = conteo_estimado_variedad_flor.id_consecutivo_reporte_supervisor
	and grupo_consecutivo.id_grupo_consecutivo = @id_grupo_consecutivo
end
else
if(@accion = 'generar_reporte_para_supervisor')
begin
	create table #temp (id int)

	/*crear la insercion para los valores separados por comas*/
	declare @sql varchar(8000)
	select @sql = 'insert into #temp select '+	replace(@id_consecutivo_reporte_supervisor,',',' union all select ')

	/*cargar todos los valores de la variable @id_consecutivo_reporte_supervisor en la tabla temporal*/
	exec (@SQL)

	select consecutivo_reporte_supervisor.numero_consecutivo,
	'[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	bloque.idc_bloque,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	rango_fecha_reporte_supervisor.fecha_inicial,
	rango_fecha_reporte_supervisor.fecha_final,
	(select cantidad_tallos from cantidad_tallos_conteo_estimado
	where cantidad_tallos_conteo_estimado.id_bloque = conteo_estimado_variedad_flor.id_bloque
	and cantidad_tallos_conteo_estimado.id_variedad_flor = conteo_estimado_variedad_flor.id_variedad_flor
	and cantidad_tallos_conteo_estimado.id_consecutivo_reporte_supervisor = conteo_estimado_variedad_flor.id_consecutivo_reporte_supervisor
	and cantidad_tallos_conteo_estimado.id_rango_fecha_reporte_supervisor = rango_fecha_reporte_supervisor.id_rango_fecha_reporte_supervisor) as cantidad_tallos
	from consecutivo_reporte_supervisor,
	conteo_estimado_variedad_flor,
	rango_fecha_reporte_supervisor,
	supervisor,
	bloque,
	variedad_flor,
	tipo_flor,
	grupo_consecutivo
	where grupo_consecutivo.id_grupo_consecutivo = consecutivo_reporte_supervisor.id_grupo_consecutivo
	and grupo_consecutivo.id_grupo_consecutivo = rango_fecha_reporte_supervisor.id_grupo_consecutivo
	and supervisor.id_supervisor = consecutivo_reporte_supervisor.id_supervisor
	and bloque.id_supervisor = supervisor.id_supervisor
	and bloque.id_bloque = conteo_estimado_variedad_flor.id_bloque
	and variedad_flor.id_variedad_flor = conteo_estimado_variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor = conteo_estimado_variedad_flor.id_consecutivo_reporte_supervisor
	and consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor in (select id from #temp)
end
else
if(@accion = 'consultar')
begin
	select conteo_estimado_variedad_flor.id_conteo_estimado_variedad_flor,
	rango_fecha_reporte_supervisor.id_rango_fecha_reporte_supervisor,
	'[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	bloque.idc_bloque,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor,
	rango_fecha_reporte_supervisor.fecha_inicial,
	rango_fecha_reporte_supervisor.fecha_final
	from consecutivo_reporte_supervisor,
	rango_fecha_reporte_supervisor,
	conteo_estimado_variedad_flor,
	bloque,
	variedad_flor,
	tipo_flor,
	supervisor,
	grupo_consecutivo
	where grupo_consecutivo.id_grupo_consecutivo = consecutivo_reporte_supervisor.id_grupo_consecutivo
	and grupo_consecutivo.id_grupo_consecutivo = rango_fecha_reporte_supervisor.id_grupo_consecutivo
	and consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor = conteo_estimado_variedad_flor.id_consecutivo_reporte_supervisor
	and conteo_estimado_variedad_flor.id_bloque = bloque.id_bloque
	and conteo_estimado_variedad_flor.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and consecutivo_reporte_supervisor.id_supervisor = supervisor.id_supervisor
	and supervisor.id_supervisor = bloque.id_supervisor
	and consecutivo_reporte_supervisor.id_consecutivo_reporte_supervisor = convert(int,@id_consecutivo_reporte_supervisor)
	order by bloque.idc_bloque,
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)),
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	variedad_flor.idc_variedad_flor,
	rango_fecha_reporte_supervisor.fecha_inicial,
	rango_fecha_reporte_supervisor.fecha_final
end
else
if(@accion = 'insertar_grupo_consecutivo')
begin
	insert into grupo_consecutivo (id_cuenta_interna)
	values (@id_cuenta_interna)

	set @id_item = scope_identity()
	select @id_item as id_grupo_consecutivo
end
else
if(@accion = 'insertar_fechas')
begin
	insert into rango_fecha_reporte_supervisor (id_grupo_consecutivo, fecha_inicial, fecha_final)
	values (@id_grupo_consecutivo, @fecha_inicial, @fecha_final)
	
	set @id_item = scope_identity()
	select @id_item as id_rango_fecha_reporte_supervisor
end
else
if(@accion = 'insertar_conteo_estimado_variedad_flor')
begin
	select @conteo = count(*) 
	from precopia_conteo_estimado_variedad_flor
	where id_sesion = @id_sesion

	if(@conteo > 0)
	begin
		select top 1 @id_supervisor = supervisor.id_supervisor 
		from precopia_conteo_estimado_variedad_flor,
		bloque,
		supervisor
		where precopia_conteo_estimado_variedad_flor.id_sesion = @id_sesion
		and supervisor.id_supervisor = bloque.id_supervisor 
		and bloque.id_bloque = precopia_conteo_estimado_variedad_flor.id_bloque
		group by supervisor.id_supervisor
		order by supervisor.id_supervisor

		select @numero_consecutivo = isnull(max(numero_consecutivo),0)
		from consecutivo_reporte_supervisor

		insert into consecutivo_reporte_supervisor (id_grupo_consecutivo, numero_consecutivo, id_supervisor)
		values (@id_grupo_consecutivo, @numero_consecutivo + 1, @id_supervisor)

		set @id_item = scope_identity()

		insert into conteo_estimado_variedad_flor (id_bloque, id_variedad_flor, id_consecutivo_reporte_supervisor)
		select precopia_conteo_estimado_variedad_flor.id_bloque, 
		precopia_conteo_estimado_variedad_flor.id_variedad_flor, 
		@id_item
		from precopia_conteo_estimado_variedad_flor,
		bloque,
		supervisor
		where supervisor.id_supervisor = bloque.id_supervisor
		and bloque.id_bloque = precopia_conteo_estimado_variedad_flor.id_bloque
		and supervisor.id_supervisor = @id_supervisor
		and	precopia_conteo_estimado_variedad_flor.id_sesion = @id_sesion

		delete from precopia_conteo_estimado_variedad_flor
		where precopia_conteo_estimado_variedad_flor.id_sesion = @id_sesion
		and precopia_conteo_estimado_variedad_flor.id_bloque in 
		(select bloque.id_bloque
		from bloque, supervisor
		where supervisor.id_supervisor = bloque.id_supervisor
		and supervisor.id_supervisor = @id_supervisor)

		set @@control = 1
		return @@control 
	end
	else
	begin
		set @@control = -5
		return @@control 
	end
end
else
if(@accion = 'insertar_cantidad_tallos_conteo_estimado')
begin
	insert into cantidad_tallos_conteo_estimado (id_rango_fecha_reporte_supervisor, id_consecutivo_reporte_supervisor, id_bloque, id_variedad_flor, cantidad_tallos)
	select @id_rango_fecha_reporte_supervisor, id_consecutivo_reporte_supervisor, id_bloque, id_variedad_flor, @cantidad_tallos
	from conteo_estimado_variedad_flor
	where id_conteo_estimado_variedad_flor = @id_conteo_estimado_variedad_flor
end