/****** Object:  StoredProcedure [dbo].[na_consultar_todos_ciudad]    Script Date: 10/06/2007 12:02:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_todos_ciudad]

@orden nvarchar(255)
AS

SELECT *
FROM ciudad
where disponible = 1
ORDER BY 
CASE @orden WHEN 'id_ciudad' THEN id_ciudad ELSE NULL END,
CASE @orden	WHEN 'idc_ciudad' THEN idc_ciudad ELSE NULL END,
CASE @orden	WHEN 'nombre_ciudad' THEN nombre_ciudad ELSE NULL END,
CASE @orden	WHEN '' THEN nombre_ciudad ELSE NULL END
