/****** Object:  StoredProcedure [dbo].[wbl_editar_etiqueta_temp]    Script Date: 10/06/2007 12:35:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_editar_etiqueta_temp]

@idTempFind  INT,
@tipoNew NVARCHAR(255),
@variedadNew NVARCHAR(255),
@gradoNew NVARCHAR(255),
@tapaNew NVARCHAR(255),
@tipo_cajaNew NVARCHAR(255),
@marcaNew NVARCHAR(255),
@unidades_cajaNew INT,
@fechaNew DATETIME,
@cantidadNew INT

AS

UPDATE etiqueta_temp_user
SET tipo = @tipoNew,
variedad = @variedadNew, 
grado = @gradoNew, 
tapa = @tapaNew, 
tipo_caja = @tipo_cajaNew, 
marca = @marcaNew, 
unidades_por_caja = @unidades_cajaNew, 
fecha = @fechaNew, 
cantidad = @cantidadNew
WHERE idTemp = @idTempFind