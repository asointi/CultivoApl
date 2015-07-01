set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[estm_editar_variedad_flor_bloque]

@id_supervisor nvarchar(255), 
@id_bloque nvarchar(255),
@id_variedad_flor nvarchar(255),
@id_tipo_flor nvarchar(255),
@id_sesion nvarchar(255),
@accion nvarchar(255)

as

declare @id_item int

if(@id_bloque is null)
	set @id_bloque = '%%'

if(@id_supervisor is null)
	set @id_supervisor = '%%'

if(@id_tipo_flor is null)
	set @id_tipo_flor = '%%'

if(@id_variedad_flor is null)
	set @id_variedad_flor = '%%'

if(@accion = 'consultar_supervisor')
begin
	select supervisor.id_supervisor,
	supervisor.idc_supervisor,
	'[' + supervisor.idc_supervisor + ']' + space(1) + supervisor.nombre_supervisor as nombre_supervisor
	from supervisor, 
	bloque
	where supervisor.id_supervisor = bloque.id_supervisor
	and bloque.disponible = 1
	and supervisor.disponible = 1
	group by supervisor.id_supervisor,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor
	order by supervisor.idc_supervisor
end
else
if(@accion = 'consultar_bloque')
begin
	select bloque.id_bloque,
	bloque.idc_bloque
	from bloque,
	supervisor
	where bloque.disponible = 1
	and supervisor.disponible = 1
	and supervisor.id_supervisor = bloque.id_supervisor
	and supervisor.id_supervisor like @id_supervisor
	group by bloque.id_bloque,
	bloque.idc_bloque
	order by bloque.idc_bloque
end
else
if(@accion = 'consultar')
begin
	select bloque.id_bloque,
	bloque.idc_bloque,	
	variedad_flor.id_variedad_flor,
	tipo_flor.nombre_tipo_flor + space(1) + '(' + tipo_flor.idc_tipo_flor + ')' as nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor + space(1) + '(' + variedad_flor.idc_variedad_flor + ')' as nombre_variedad_flor
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
	and not exists
	(select * from precopia_conteo_estimado_variedad_flor
	where variedad_flor.id_variedad_flor = precopia_conteo_estimado_variedad_flor.id_variedad_flor
	and bloque.id_bloque = precopia_conteo_estimado_variedad_flor.id_bloque
	and precopia_conteo_estimado_variedad_flor.id_sesion = @id_sesion)
	and supervisor.id_supervisor like @id_supervisor	
	and tipo_flor.id_tipo_flor like @id_tipo_flor
	and variedad_flor.id_variedad_flor like @id_variedad_flor
	and bloque.id_bloque like @id_bloque
	and bloque.disponible = 1
	and supervisor.disponible = 1
	group by bloque.id_bloque,
	bloque.idc_bloque,	
	variedad_flor.id_variedad_flor,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	variedad_flor.idc_variedad_flor
	order by bloque.idc_bloque,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor
end
else
if(@accion = 'consultar_tipo_flor')
begin
	select tipo_flor.id_tipo_flor,
	LTRIM(RTRIM(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + '] ' as nombre_tipo_flor_idc
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
	and bloque.id_bloque like @id_bloque
	group by tipo_flor.id_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	tipo_flor.idc_tipo_flor
	order by tipo_flor.nombre_tipo_flor
end
else
if(@accion = 'consultar_variedad_flor')
begin
	select variedad_flor.id_variedad_flor,
	LTRIM(RTRIM(variedad_flor.nombre_variedad_flor)) + ' [' + tipo_flor.idc_tipo_flor + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_color_idc
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
	and tipo_flor.id_tipo_flor = convert(int,@id_tipo_flor)
	group by variedad_flor.id_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor
	order by variedad_flor.nombre_variedad_flor
end