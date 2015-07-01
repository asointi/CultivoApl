set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_editar_apropiar_conteo_rusia]

@id_conteo_propietario_cama int,
@accion nvarchar(80),
@unidades_solicitadas int, 
@usuario_cobol nvarchar(50),
@idc_tipo_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@id_apropiar_conteo_rusia int

as

if(@accion = 'consultar_conteo_semana_entrante')
begin
	select top 1 conteo_propietario_cama.id_conteo_propietario_cama,
	tipo_conteo_propietario_cama.nombre as nombre_tipo_conteo,
	conteo_propietario_cama.fecha_conteo
	from conteo_propietario_cama,
	tipo_conteo_propietario_cama,
	estado_variedad_flor
	where dbo.Conteo_Propietario_Cama.id_tipo_conteo_propietario_cama = dbo.Tipo_Conteo_Propietario_Cama.id_tipo_conteo_propietario_cama
	and dbo.Tipo_Conteo_Propietario_Cama.nombre = 'Estimado semana entrante'
	and dbo.Conteo_Propietario_Cama.id_estado_variedad_flor_final = dbo.Estado_Variedad_Flor.id_estado_variedad_flor
	and dbo.Estado_Variedad_Flor.nombre_estado = 'En Adelante'
	and dbo.Conteo_Propietario_Cama.fecha_conteo < = convert(datetime, convert(nvarchar,getdate(), 101))
	order by dbo.Conteo_Propietario_Cama.fecha_conteo desc
end
else
if(@accion = 'consultar_apropiar_conteo_rusia')
begin
	select apropiar_conteo_rusia.id_apropiar_conteo_rusia,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	apropiar_conteo_rusia.unidades_solicitadas,
	apropiar_conteo_rusia.fecha_solicitud,
	apropiar_conteo_rusia.usuario_cobol 
	from apropiar_conteo_rusia,
	grado_flor,
	tipo_flor,
	variedad_flor
	where tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = apropiar_conteo_rusia.id_variedad_flor
	and grado_flor.id_grado_flor = apropiar_conteo_rusia.id_grado_flor
	and apropiar_conteo_rusia.id_conteo_propietario_cama = @id_conteo_propietario_cama
end
else
if(@accion = 'modificar_apropiar_conteo_rusia')
begin
	update apropiar_conteo_rusia
	set unidades_solicitadas = @unidades_solicitadas,
	usuario_cobol = @usuario_cobol,
	fecha_solicitud = getdate()
	where apropiar_conteo_rusia.id_apropiar_conteo_rusia = @id_apropiar_conteo_rusia
end
else
if(@accion = 'eliminar_apropiar_conteo_rusia')
begin
	delete from apropiar_conteo_rusia
	where apropiar_conteo_rusia.id_apropiar_conteo_rusia = @id_apropiar_conteo_rusia
end
else
if(@accion = 'insertar_apropiar_conteo_rusia')
begin
	insert into apropiar_conteo_rusia (id_variedad_flor, id_grado_flor, id_conteo_propietario_cama, unidades_solicitadas, usuario_cobol)
	select variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	@id_conteo_propietario_cama, 
	@unidades_solicitadas, 
	@usuario_cobol
	from tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
end
