/****** Object:  StoredProcedure [dbo].[wbl_seleccionar_codigo_comercializadora]    Script Date: 10/06/2007 12:51:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_seleccionar_codigo_comercializadora]

@comercializadora NVARCHAR(255)

AS
BEGIN
    SELECT id_farm_cobol
	FROM GLOBALES_SQL 
	WHERE nombre_comercializadora=@comercializadora
END
