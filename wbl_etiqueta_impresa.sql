SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

ALTER PROCEDURE [dbo].[wbl_etiqueta_impresa]

@id_etiqueta int, 
@id_usuario int,
@accion nvarchar(50)

as

if(@accion = 'consultar_etiquetas')
begin
	select etiqueta.farm as idc_farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.idc_grado_flor,
	etiqueta.tapa as idc_tapa,
	etiqueta.tipo_caja as idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	etiqueta.marca as code,
	etiqueta.unidades_por_caja as unidades_por_pieza,
	etiqueta.usuario as usuario_weblabel,
	etiqueta_impresa.id_etiqueta,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	etiqueta.codigo
	from etiqueta_impresa,
	etiqueta,
	usuarios,
	tipo_caja,
	caja,
	tipo_flor,
	variedad_flor,
	grado_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = etiqueta.tipo
	and variedad_flor.idc_variedad_flor = etiqueta.variedad
	and grado_flor.idc_grado_flor = etiqueta.grado
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and tipo_caja.idc_tipo_caja + caja.idc_caja = etiqueta.tipo_caja
	and etiqueta.id_etiqueta = etiqueta_impresa.id_etiqueta
	and usuarios.id_usuarios = etiqueta_impresa.id_usuario
	and etiqueta_impresa.id_usuario = @id_usuario
	group by etiqueta.farm,
	tipo_flor.idc_tipo_flor,
	variedad_flor.idc_variedad_flor,
	grado_flor.idc_grado_flor,
	etiqueta.tapa,
	etiqueta.tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
	etiqueta.marca,
	etiqueta.unidades_por_caja,
	etiqueta.usuario,
	etiqueta_impresa.id_etiqueta,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	etiqueta.codigo
	order by etiqueta_impresa.id_etiqueta

	delete from etiqueta_impresa
	where id_usuario = @id_usuario
end
else
if(@accion = 'insertar')
begin
	begin try
		insert into etiqueta_impresa (id_etiqueta, id_usuario)
		values (@id_etiqueta, @id_usuario)
	end try
	begin catch

	end catch
end
else
if(@accion = 'eliminar_etiquetas')
begin
	delete from etiqueta_impresa
	where id_usuario = @id_usuario
end
GO