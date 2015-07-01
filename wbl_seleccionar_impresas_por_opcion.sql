/****** Object:  StoredProcedure [dbo].[wbl_seleccionar_impresas_por_opcion]    Script Date: 10/06/2007 12:53:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_seleccionar_impresas_por_opcion] 

@accion NVARCHAR(255),
@fechain DATETIME,
@farmin NVARCHAR(255),
@usuarioin NVARCHAR(255),
@codigoInit NVARCHAR(255) = null,
@codigoFinit NVARCHAR(255)= null,
@tipoin NVARCHAR(255) = null

AS
BEGIN

IF @accion = 'todas'
	BEGIN
		SELECT codigo, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja
		FROM etiqueta
		WHERE farm=@farmin AND usuario=@usuarioin 
		AND	convert(nvarchar, fecha, 120) = convert(nvarchar, @fechain, 120)
	END

ELSE 
	IF @accion = 'codigo'
		BEGIN
			SELECT codigo, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja
			FROM etiqueta
			WHERE farm=@farmin AND usuario=@usuarioin 
			AND	convert(nvarchar, fecha, 120) = convert(nvarchar, @fechain, 120) AND
			codigo between @codigoInit AND @codigoFinit
		END
	
	ELSE
		IF @accion = 'tipo'
			BEGIN
				SELECT codigo, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja
				FROM etiqueta
				WHERE farm=@farmin 
				AND usuario=@usuarioin 
				AND	tipo=@tipoin AND
				convert(nvarchar, fecha, 120) = convert(nvarchar, @fechain, 120)
			END
END
