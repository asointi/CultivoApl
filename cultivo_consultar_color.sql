/****** Object:  StoredProcedure [dbo].[na_editar_color]    Script Date: 11/15/2007 11:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[cultivo_consultar_color]

AS
        
SELECT id_color_cultivo as id_color,
idc_color,
nombre_color 
FROM color_cultivo
order by nombre_color
