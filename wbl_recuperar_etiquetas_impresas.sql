/****** Object:  StoredProcedure [dbo].[wbl_recuperar_etiquetas_impresas]    Script Date: 10/06/2007 12:46:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_recuperar_etiquetas_impresas]

@fechain DATETIME,
@farmin NVARCHAR(255),
@usuarioin NVARCHAR(255)

AS
BEGIN

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

DECLARE etiqueta_cursor CURSOR
FOR

SELECT farm, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja, usuario, fecha, count (*), max(fecha_digita)
FROM etiqueta
WHERE usuario=@usuarioin AND farm=@farmin AND
convert(nvarchar, fecha, 120) = convert(nvarchar, @fechain, 120) AND
etiqueta.tipo IN
( 
SELECT DISTINCT Tipo_Flor.idc_tipo_flor 
FROM Producto_Farm as Producto_Farm, Tipo_Flor as Tipo_Flor
WHERE Producto_Farm.id_tipo_flor = Tipo_Flor.id_tipo_flor 
AND Producto_Farm.id_farm IN 
(
select id_farm from Farm where Farm.idc_farm=@farmin
)
)
GROUP BY farm, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja, usuario, fecha
ORDER BY max(fecha_digita)

OPEN etiqueta_cursor

FETCH NEXT FROM etiqueta_cursor INTO @farmT, @tipoT, @variedadT, @gradoT, @tapaT, @tipo_cajaT, @marcaT, @unidades_cajaT, @usuarioT, @fechaT, @cantidadT, @fecha_aux

WHILE @@FETCH_STATUS = 0
BEGIN
	DELETE FROM ETIQUETA_TEMP_USER 
	WHERE usuario=@usuarioT AND farm=@farmT AND 
		  tipo=@tipoT AND variedad=@variedadT AND 
		  grado=@gradoT AND tapa=@tapaT AND 
		  tipo_caja=@tipo_cajaT AND marca=@marcaT AND 
		  unidades_por_caja=@unidades_cajaT AND 
		  cantidad=@cantidadT
	BEGIN
		EXECUTE 
			wbl_insertar_etiqueta_temp @usuarioT, @farmT, @tipoT, @variedadT, @gradoT, @tapaT, @tipo_cajaT, @marcaT, @unidades_cajaT, @fechaH, @cantidadT
		
		FETCH NEXT 
		FROM etiqueta_cursor 
		INTO @farmT, @tipoT, @variedadT, @gradoT, @tapaT, @tipo_cajaT, @marcaT, @unidades_cajaT, @usuarioT, @fechaT, @cantidadT, @fecha_aux
	END
	
END
CLOSE etiqueta_cursor
DEALLOCATE etiqueta_cursor

END
