set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[estm_generar_reporte_supervisor_estimado]

@id_supervisor nvarchar(255),
@id_bloque nvarchar(255),
@id_variedad_flor nvarchar(255),
@id_tipo_flor nvarchar(255),
@id_sesion nvarchar(255),
@id_precopia_conteo_estimado_variedad_flor int,
@accion nvarchar(255)

as

declare @id_item int

if(@id_supervisor is null)
	set @id_supervisor = '%%'
if(@id_bloque is null)
	set @id_bloque = '%%'
if(@id_variedad_flor is null)
	set @id_variedad_flor = '%%'
if(@id_tipo_flor is null)
	set @id_tipo_flor = '%%'

if(@accion = 'consultar_variedad_flor_bloque')
begin
	select bloque.id_bloque,
	bloque.idc_bloque,
	'[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor
	from sembrar_cama_bloque,
	variedad_flor,
	tipo_flor,
	construir_cama_bloque,
	cama_bloque,
	bloque,
	supervisor
	where supervisor.id_supervisor = bloque.id_supervisor
	and bloque.id_bloque = cama_bloque.id_bloque
	and cama_bloque.id_cama = construir_cama_bloque.id_cama
	and cama_bloque.id_bloque = construir_cama_bloque.id_bloque
	and construir_cama_bloque.id_construir_cama_bloque = sembrar_cama_bloque.id_construir_cama_bloque
	and sembrar_cama_bloque.id_variedad_flor = variedad_flor.id_variedad_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and not exists 
	(select * from destruir_cama_bloque
	where destruir_cama_bloque.id_construir_cama_bloque = construir_cama_bloque.id_construir_cama_bloque)
	and not exists
	(select * from erradicar_cama_bloque
	where erradicar_cama_bloque.id_sembrar_cama_bloque = sembrar_cama_bloque.id_sembrar_cama_bloque)
	and bloque.disponible = 1
	and supervisor.disponible = 1
	and supervisor.id_supervisor like @id_supervisor
	and bloque.id_bloque like @id_bloque
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	group by bloque.id_bloque,
	bloque.idc_bloque,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor,	
	variedad_flor.id_variedad_flor,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor
	order by bloque.idc_bloque,
	supervisor.idc_supervisor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor
end
else
if(@accion = 'insertar_precopia')
begin
	insert into precopia_conteo_estimado_variedad_flor (id_variedad_flor, id_bloque, id_sesion)
	values (convert(int,@id_variedad_flor), convert(int,@id_bloque), @id_sesion)

	set @id_item = scope_identity()
	select @id_item as id_precopia_conteo_estimado_variedad_flor
end
else
if(@accion = 'consultar_precopia')
begin
	select precopia_conteo_estimado_variedad_flor.id_precopia_conteo_estimado_variedad_flor,
	bloque.id_bloque,
	variedad_flor.id_variedad_flor,
	bloque.idc_bloque,
	'[' + supervisor.idc_supervisor + ']' + space(1) + ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor
	from precopia_conteo_estimado_variedad_flor,
	variedad_flor,
	tipo_flor,
	bloque,
	supervisor
	where precopia_conteo_estimado_variedad_flor.id_variedad_flor = variedad_flor.id_variedad_flor
	and precopia_conteo_estimado_variedad_flor.id_bloque = bloque.id_bloque
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and bloque.id_supervisor = supervisor.id_supervisor
	and precopia_conteo_estimado_variedad_flor.id_sesion = @id_sesion
	order by bloque.idc_bloque,
	supervisor.idc_supervisor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor
end
else 
if(@accion = 'eliminar_precopia')
begin
	delete from precopia_conteo_estimado_variedad_flor 
	where id_precopia_conteo_estimado_variedad_flor = @id_precopia_conteo_estimado_variedad_flor
end
else
if(@accion = 'eliminar_precopia_total')
begin
	delete from precopia_conteo_estimado_variedad_flor 
	where id_sesion = @id_sesion
end
else
if(@accion = 'consultar_fechas')
begin
	declare @dia_jueves int,
	@dias int 
	set @dia_jueves = 5
	set @dias = 0

	create table #temp 
	(
		id int identity(1,1),
		fecha_inicial datetime, 
		fecha_final datetime
	)

	while (@dias < = 21)
	begin
		insert into #temp (fecha_inicial, fecha_final)
		select 'fecha_inicial' =
		case
			when datepart(dw, getdate()) < = 5 then convert(datetime,convert(nvarchar,dateadd(dd, (@dia_jueves - datepart(dw, getdate())), getdate()) + @dias,101))
			else convert(datetime,convert(nvarchar,dateadd(dd, (@dia_jueves - datepart(dw, getdate())) + 7, getdate()) + @dias,101))
		end,
		'fecha_final' =
		case
			when datepart(dw, getdate()) < = 5 then convert(datetime,convert(nvarchar,dateadd(dd, (@dia_jueves - datepart(dw, getdate()))+6, getdate()) + @dias,101))
			else convert(datetime,convert(nvarchar,dateadd(dd, (@dia_jueves - datepart(dw, getdate())) + 13, getdate()) + @dias,101))
		end
		set @dias = @dias + 7
	end
	
	select id,
	fecha_inicial,
	fecha_final
	from #temp

	drop table #temp
end