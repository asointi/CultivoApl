/****** Object:  StoredProcedure [dbo].[wbl_obtiene_opciones_reimpresion]    Script Date: 24/07/2014 1:32:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_obtiene_opciones_reimpresion]

@accion NVARCHAR(255), 
@usuarioin NVARCHAR(50),
@farmin NVARCHAR(10),
@fecha DATETIME = null, 
@days_back INT = null

AS

declare @fecha_interna datetime 

set @fecha_interna = convert(nvarchar, getdate(), 101)

IF (@accion = 'resumen')
BEGIN
	SELECT MAX(CODIGO) as maximo, 
	MIN(CODIGO) as minimo,	
	SUM(unidades_por_caja), 
	Getdate()
	FROM ETIQUETA,
	farm
	WHERE etiqueta.farm = farm.idc_farm
	and farm.idc_farm = @farmin
	AND usuario = @usuarioin 
	AND convert(datetime, convert(nvarchar, etiqueta.fecha, 101)) between
	dateadd(dd, -@days_back, @fecha_interna) and dateadd(dd, 1, @fecha_interna)
END
ELSE 
IF @accion = 'etiquetas'
BEGIN
	SELECT ETIQUETA.codigo, 
	ETIQUETA.farm, 
	ETIQUETA.tipo, 
	ETIQUETA.variedad, 
	ETIQUETA.grado, 
	ETIQUETA.tapa, 
	ETIQUETA.tipo_caja, 
	ETIQUETA.marca, 
	ETIQUETA.unidades_por_caja, 
	usuarios.usuario, 
	usuarios.id_usuarios as id_usuario,
	ETIQUETA.fecha, 
	ETIQUETA.fecha_digita,
	CAST(CONVERT(datetime,ETIQUETA.fecha_digita) as DECIMAL(20,7)) as fecha_creacion_etiqueta,
	ETIQUETA.id_etiqueta
	FROM ETIQUETA,
	usuarios,
	farm
	WHERE ETIQUETA.farm = farm.idc_farm
	and farm.idc_farm = @farmin
	AND usuarios.usuario = etiqueta.usuario
	and usuarios.usuario = @usuarioin 
	AND convert(datetime, convert(nvarchar, ETIQUETA.fecha, 101)) = convert(datetime, convert(nvarchar,@fecha, 101))
END
ELSE
IF (@accion = 'tipos')
BEGIN
	SELECT ETIQUETA.tipo
	FROM ETIQUETA,
	farm
	WHERE etiqueta.farm = farm.idc_farm
	and farm.idc_farm = @farmin
	AND usuario = @usuarioin 
	AND convert(datetime, convert(nvarchar, etiqueta.fecha, 101)) between
	dateadd(dd, -@days_back, @fecha_interna) and dateadd(dd, 1, @fecha_interna)
	group by ETIQUETA.tipo
	ORDER BY ETIQUETA.tipo
END