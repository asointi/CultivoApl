/****** Object:  StoredProcedure [dbo].[na_consultar_todos_tipo_flor]    Script Date: 10/06/2007 12:07:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_todos_tipo_flor]

@orden nvarchar(255)

AS

SELECT *,
LTRIM(RTRIM(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + '] ' as nombre_tipo_flor_idc
FROM tipo_flor
WHERE tipo_flor.disponible = 1
ORDER BY 
CASE @orden WHEN 'id_tipo_flor' THEN tipo_flor.id_tipo_flor ELSE NULL END,
CASE @orden	WHEN 'nombre_tipo_flor' THEN tipo_flor.nombre_tipo_flor ELSE NULL END,
			CASE @orden	WHEN 'idc_tipo_flor' THEN tipo_flor.idc_tipo_flor ELSE NULL END,
			CASE @orden	WHEN '' THEN tipo_flor.nombre_tipo_flor ELSE NULL END
