/****** Object:  StoredProcedure [dbo].[wbl_obtener_etiquetas_impresas]    Script Date: 11/13/2007 12:55:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_obtener_etiquetas_impresas]

@fechain NVARCHAR(255),
@farmin NVARCHAR(255),
@usuarioin NVARCHAR(255)

AS

DECLARE @farmT NVARCHAR(255),
@tipoT NVARCHAR(255),
@variedadT NVARCHAR(255),
@gradoT NVARCHAR(255),
@tapaT NVARCHAR(255),
@tipo_cajaT NVARCHAR(255),
@marcaT NVARCHAR(255),
@unidades_cajaT INT,
@usuarioT NVARCHAR(255),
@fechaT DATETIME,
@cantidadT INT,
@fecha_aux DATETIME,
@fechaH DATETIME;

SET @fechaH = getDate();
set @fechain = convert(nvarchar, @fechain, 120)

select @fechain

DECLARE etiqueta_cursor CURSOR
FOR

SELECT farm, 
tipo, 
variedad, 
grado, 
tapa, 
tipo_caja, 
marca, 
unidades_por_caja, 
usuario, 
fecha, 
count(*), 
max(fecha_digita)
FROM etiqueta
WHERE usuario = @usuarioin 
AND farm = @farmin 
AND convert(datetime, convert(nvarchar, fecha, 120), 120) = convert(datetime, convert(nvarchar, @fechain, 120), 120) 
AND exists
( 
	SELECT *
	FROM Producto_Farm, 
	Tipo_Flor,
	farm as f
	WHERE Tipo_Flor.id_tipo_flor  = Producto_Farm.id_tipo_flor
	and f.id_farm = producto_farm.id_farm
	and f.idc_farm = etiqueta.farm
	and tipo_flor.idc_tipo_flor = etiqueta.tipo
)
GROUP BY farm, 
tipo, 
variedad, 
grado, 
tapa, 
tipo_caja, 
marca, 
unidades_por_caja, 
usuario, 
fecha
ORDER BY max(fecha_digita)

OPEN etiqueta_cursor
FETCH NEXT FROM etiqueta_cursor 
INTO @farmT, 
@tipoT, 
@variedadT, 
@gradoT, 
@tapaT, 
@tipo_cajaT, 
@marcaT, 
@unidades_cajaT, 
@usuarioT, 
@fechaT, 
@cantidadT, 
@fecha_aux

WHILE @@FETCH_STATUS = 0
BEGIN
	DELETE FROM ETIQUETA_TEMP_USER 
	WHERE usuario = @usuarioT 
	AND farm = @farmT 
	AND tipo = @tipoT 
	AND variedad = @variedadT 
	AND grado = @gradoT 
	AND tapa = @tapaT 
	AND tipo_caja = @tipo_cajaT 
	AND marca = @marcaT 
	AND unidades_por_caja = @unidades_cajaT 
	AND cantidad = @cantidadT

	BEGIN
		EXECUTE wbl_insertar_etiqueta_temp 
		@usuarioT, 
		@farmT, 
		@tipoT, 
		@variedadT, 
		@gradoT, 
		@tapaT, 
		@tipo_cajaT, 
		@marcaT, 
		@unidades_cajaT, 
		@fechaH, 
		@cantidadT
		
		FETCH NEXT 
		FROM etiqueta_cursor 
		INTO @farmT, 
		@tipoT, 
		@variedadT, 
		@gradoT, 
		@tapaT, 
		@tipo_cajaT, 
		@marcaT, 
		@unidades_cajaT, 
		@usuarioT, 
		@fechaT, 
		@cantidadT, 
		@fecha_aux
	END
END
CLOSE etiqueta_cursor
DEALLOCATE etiqueta_cursor