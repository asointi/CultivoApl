/****** Object:  StoredProcedure [dbo].[wbl_obtener_opcion_reimprimir]    Script Date: 11/13/2007 12:56:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_obtener_opcion_reimprimir] 

@accion NVARCHAR(255),
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
		AND (convert(datetime, convert(nvarchar, fecha, 111), 111) between
		convert(datetime, convert(nvarchar, getdate()-@days_back, 111), 111) and convert(datetime, convert(nvarchar, getdate()+1, 111), 111))
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
				--convert(nvarchar, fecha, 120) = convert(nvarchar, @fechain, 120)
				AND	tipo=@tipoin
				AND (convert(datetime,convert(nvarchar, fecha, 111), 111) >= convert(datetime, convert(nvarchar, getdate()-@days_back, 111), 111) 
				AND convert(datetime, convert(nvarchar, fecha, 111), 111) < convert(datetime, convert(nvarchar, getdate()+1, 111), 111))
				ORDER BY codigo DESC
			END
END





