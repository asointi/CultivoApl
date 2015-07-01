set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[wbl_seleccionar_etiquetas_opcion_reimprimir] 

@accion NVARCHAR(255),
@farmin NVARCHAR(10),
@usuarioin NVARCHAR(50),
@codigoInit NVARCHAR(15) = null,
@codigoFinit NVARCHAR(15)= null,
@tipoin NVARCHAR(10) = null,
@days_back INT

AS

declare @fecha datetime 

set @fecha = convert(nvarchar, getdate(), 101)

IF (@accion = 'todas')
BEGIN
	SELECT etiqueta.id_etiqueta,
	etiqueta.codigo, 
	farm.idc_farm as farm, 
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor, 
	tipo_flor.idc_tipo_flor as tipo, 
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor, 
	variedad_flor.idc_variedad_flor as variedad, 
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor, 
	grado_flor.idc_grado_flor as grado, 
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa, 
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja, 
	etiqueta.marca, 
	etiqueta.unidades_por_caja, 
	convert(nvarchar, etiqueta.fecha, 120) as fecha,
	etiqueta.fecha_digita,
	CAST(CONVERT(datetime,ETIQUETA.fecha_digita) as DECIMAL(20,7)) as fecha_creacion_etiqueta,
	etiqueta.id_etiqueta,
	usuarios.id_usuarios as id_usuario
	FROM etiqueta, 
	tipo_flor,
	producto_farm, 
	farm, 
	variedad_flor,
	grado_flor, 
	tapa, 
	caja, 
	tipo_caja,
	usuarios
	WHERE tipo_flor.idc_tipo_flor = etiqueta.tipo 
	AND	grado_flor.idc_grado_flor = etiqueta.grado 
	AND	variedad_flor.idc_variedad_flor = etiqueta.variedad 
	AND	farm.idc_farm = etiqueta.farm 
	AND	tapa.idc_tapa = etiqueta.tapa 
	AND	tipo_caja.idc_tipo_caja + caja.idc_caja = etiqueta.tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	AND	tipo_caja.id_tipo_caja = caja.id_tipo_caja 
	AND	producto_farm.id_tipo_flor = tipo_flor.id_tipo_flor 
	AND	producto_farm.id_farm = farm.id_farm 
	AND	producto_farm.id_tipo_flor = grado_flor.id_tipo_flor 
	AND	producto_farm.id_tapa = tapa.id_tapa 
	AND	producto_farm.id_caja = caja.id_caja 
	AND	producto_farm.id_tipo_flor = variedad_flor.id_tipo_flor 
	AND	etiqueta.farm = @farmin 
	AND usuarios.usuario = etiqueta.usuario
	and usuarios.usuario = @usuarioin 
	AND convert(datetime, convert(nvarchar, etiqueta.fecha, 101)) between
	dateadd(dd, -@days_back, @fecha) and dateadd(dd, 1, @fecha)
	ORDER BY etiqueta.codigo DESC
END
ELSE 
IF (@accion = 'codigo')
BEGIN
	SELECT etiqueta.id_etiqueta,
	etiqueta.codigo, 
	farm.idc_farm as farm, 
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor, 
	tipo_flor.idc_tipo_flor as tipo, 
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor, 
	variedad_flor.idc_variedad_flor as variedad, 
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor, 
	grado_flor.idc_grado_flor as grado, 
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa, 
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja, 
	etiqueta.marca, 
	etiqueta.unidades_por_caja, 
	convert(nvarchar, etiqueta.fecha, 120) as fecha,
	etiqueta.fecha_digita,
	CAST(CONVERT(datetime,ETIQUETA.fecha_digita) as DECIMAL(20,7)) as fecha_creacion_etiqueta,
	etiqueta.id_etiqueta,
	usuarios.id_usuarios as id_usuario
	FROM etiqueta, 
	tipo_flor,
	producto_farm, 
	farm, 
	variedad_flor,
	grado_flor, 
	tapa, 
	caja, 
	tipo_caja,
	usuarios
	WHERE tipo_flor.idc_tipo_flor = etiqueta.tipo 
	AND	grado_flor.idc_grado_flor = etiqueta.grado 
	AND	variedad_flor.idc_variedad_flor = etiqueta.variedad 
	AND	farm.idc_farm = etiqueta.farm 
	AND	tapa.idc_tapa = etiqueta.tapa 
	AND	tipo_caja.idc_tipo_caja + caja.idc_caja = etiqueta.tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	AND	tipo_caja.id_tipo_caja = caja.id_tipo_caja 
	AND	producto_farm.id_tipo_flor = tipo_flor.id_tipo_flor 
	AND	producto_farm.id_farm = farm.id_farm 
	AND	producto_farm.id_tipo_flor = grado_flor.id_tipo_flor 
	AND	producto_farm.id_tapa = tapa.id_tapa 
	AND	producto_farm.id_caja = caja.id_caja 
	AND	producto_farm.id_tipo_flor = variedad_flor.id_tipo_flor 
	and etiqueta.farm = @farmin 
	AND usuarios.usuario = etiqueta.usuario
	and usuarios.usuario = @usuarioin 
	AND etiqueta.codigo between 
	@codigoInit AND @codigoFinit
	ORDER BY etiqueta.codigo DESC
END
ELSE
IF (@accion = 'tipo')
BEGIN
	SELECT etiqueta.id_etiqueta,
	etiqueta.codigo, 
	farm.idc_farm as farm, 
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor, 
	tipo_flor.idc_tipo_flor as tipo, 
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor, 
	variedad_flor.idc_variedad_flor as variedad, 
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor, 
	grado_flor.idc_grado_flor as grado, 
	ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa, 
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja, 
	etiqueta.marca, 
	etiqueta.unidades_por_caja, 
	convert(nvarchar, etiqueta.fecha, 120) as fecha,
	etiqueta.fecha_digita,
	CAST(CONVERT(datetime,ETIQUETA.fecha_digita) as DECIMAL(20,7)) as fecha_creacion_etiqueta,
	etiqueta.id_etiqueta,
	usuarios.id_usuarios as id_usuario
	FROM etiqueta, 
	tipo_flor,
	producto_farm, 
	farm, 
	variedad_flor,
	grado_flor, 
	tapa, 
	caja, 
	tipo_caja,
	usuarios
	WHERE tipo_flor.idc_tipo_flor = etiqueta.tipo 
	AND	grado_flor.idc_grado_flor = etiqueta.grado 
	AND	variedad_flor.idc_variedad_flor = etiqueta.variedad 
	AND	farm.idc_farm = etiqueta.farm 
	AND	tapa.idc_tapa = etiqueta.tapa 
	AND	tipo_caja.idc_tipo_caja + caja.idc_caja = etiqueta.tipo_caja
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	AND	tipo_caja.id_tipo_caja = caja.id_tipo_caja 
	AND	producto_farm.id_tipo_flor = tipo_flor.id_tipo_flor 
	AND	producto_farm.id_farm = farm.id_farm 
	AND	producto_farm.id_tipo_flor = grado_flor.id_tipo_flor 
	AND	producto_farm.id_tapa = tapa.id_tapa 
	AND	producto_farm.id_caja = caja.id_caja 
	AND	producto_farm.id_tipo_flor = variedad_flor.id_tipo_flor 
	and etiqueta.farm = @farmin 
	AND usuarios.usuario = etiqueta.usuario
	and usuarios.usuario = @usuarioin 
	AND	etiqueta.tipo = @tipoin
	AND convert(datetime, convert(nvarchar, etiqueta.fecha, 101)) between
	dateadd(dd, -@days_back, @fecha) and dateadd(dd, 1, @fecha)
	ORDER BY etiqueta.codigo DESC
END