/****** Object:  StoredProcedure [dbo].[wbl_seleccionar_opcion_reimprimir]    Script Date: 11/15/2007 12:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[wbl_seleccionar_opcion_reimprimir] 

@accion NVARCHAR(255),
@fechain DATETIME,
@farmin NVARCHAR(255),
@usuarioin NVARCHAR(255),
@codigoInit NVARCHAR(255) = null,
@codigoFinit NVARCHAR(255)= null,
@tipoin NVARCHAR(255) = null,
@days_back INT

AS
BEGIN

IF @accion = 'todas'
	BEGIN
		SELECT codigo, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja, convert(nvarchar, fecha, 120) as fecha
		FROM etiqueta
		WHERE farm=@farmin AND usuario=@usuarioin 
		AND ((convert(nvarchar, fecha, 111) between 
		convert(nvarchar, getdate()-@days_back, 111) AND convert(nvarchar, getdate()+1, 111)))
		ORDER BY codigo DESC
	END
ELSE 
	IF @accion = 'codigo'
		BEGIN
			SELECT codigo, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja, convert(nvarchar, fecha, 120) as fecha
			FROM etiqueta
			WHERE farm=@farmin AND usuario=@usuarioin
			AND codigo between @codigoInit AND @codigoFinit
			ORDER BY codigo DESC 
		END
	
	ELSE
		IF @accion = 'tipo'
			BEGIN
				SELECT codigo, tipo, variedad, grado, tapa, tipo_caja, marca, unidades_por_caja, convert(nvarchar, fecha, 120) as fecha
				FROM etiqueta
				WHERE farm=@farmin 
				AND usuario=@usuarioin 
				AND	tipo=@tipoin
				AND ((convert(nvarchar, fecha, 111) between
				convert(nvarchar, getdate()-@days_back, 111) AND convert(nvarchar, getdate()+1, 111)))
				ORDER BY codigo DESC
			END
END

