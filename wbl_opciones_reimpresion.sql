/****** Object:  StoredProcedure [dbo].[wbl_opciones_reimpresion]    Script Date: 10/06/2007 12:45:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_opciones_reimpresion]

@accion NVARCHAR(255), 
@usuarioin NVARCHAR(255),
@farmin NVARCHAR(255),
@fecha DATETIME

AS
BEGIN

IF @accion = 'resumen'
BEGIN
	SELECT MAX(CODIGO) as maximo, 
	MIN(CODIGO) as minimo, 
	SUM(unidades_por_caja), 
	Getdate()
	FROM ETIQUETA
	WHERE farm = @farmin 
	AND usuario = @usuarioin 
	AND	convert(nvarchar, fecha, 120) = convert(nvarchar, @fecha, 120)
END
ELSE 
IF @accion = 'etiquetas'
	BEGIN
		SELECT codigo, 
		farm, 
		tipo, 
		variedad, 
		grado, 
		tapa, 
		tipo_caja, 
		marca, 
		unidades_por_caja, 
		usuario, 
		fecha, 
		fecha_digita
		FROM ETIQUETA
		WHERE farm = @farmin 
		AND usuario = @usuarioin 
		AND	convert(nvarchar, fecha, 120) = convert(nvarchar, @fecha, 120)
	END
ELSE
	IF @accion = 'tipos'
	BEGIN
		SELECT distinct tipo
		FROM etiqueta
		WHERE farm = @farmin 
		AND usuario=@usuarioin 
		AND	convert(nvarchar, fecha, 120) = convert(nvarchar, @fecha, 120)
	END
END