SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_todos_vendedor]

@orden nvarchar(255)

AS

SELECT *, nombre + ' [' + idc_vendedor +']' as nombre_idc
FROM vendedor
ORDER BY 
CASE @orden WHEN 'id_vendedor' THEN id_vendedor ELSE NULL END,
CASE @orden	WHEN 'idc_vendedor' THEN idc_vendedor ELSE NULL END,
CASE @orden	WHEN 'nombre' THEN nombre ELSE NULL END,
CASE @orden	WHEN '' THEN nombre ELSE NULL END
