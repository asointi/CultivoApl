/****** Object:  StoredProcedure [dbo].[wbl_carga_opciones_reimpresion]    Script Date: 11/15/2007 12:00:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[wbl_carga_opciones_reimpresion]

@accion NVARCHAR(255), 
@usuarioin NVARCHAR(255),
@farmin NVARCHAR(255),
@fecha DATETIME = null, 
@days_back INT = null
AS
BEGIN

IF @accion = 'resumen'
BEGIN
	SELECT MAX(CODIGO) as maximo, MIN(CODIGO) as minimo, SUM(unidades_por_caja), Getdate()
	FROM ETIQUETA
	WHERE farm=@farmin AND usuario=@usuarioin AND
	((convert(datetime,convert(nvarchar, fecha, 111)) between
	 convert(datetime,convert(nvarchar, getdate()-@days_back, 111)) AND convert(datetime,convert(nvarchar, getdate()+1, 111))))
END
ELSE 
IF @accion = 'etiquetas'
	BEGIN
		SELECT codigo, farm, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja, usuario, fecha, fecha_digita
		FROM ETIQUETA
		WHERE farm=@farmin AND usuario=@usuarioin AND
		convert(nvarchar, fecha, 120) = convert(nvarchar, @fecha, 120)
	END
ELSE
	IF @accion = 'tipos'
	BEGIN
		SELECT distinct tipo
		FROM etiqueta
		WHERE farm=@farmin AND usuario=@usuarioin AND
		((convert(nvarchar, fecha, 111) >= convert(nvarchar, getdate()-@days_back, 111) AND fecha < convert(nvarchar, getdate()+1, 111)))
		ORDER BY tipo ASC
	END
ELSE
	IF @accion = 'consultar_impresoras'
	BEGIN
		select id_impresora,
		codigo_impresora,
		nombre_impresora,
		descripcion 
		from impresora
		order by nombre_impresora
	END
END