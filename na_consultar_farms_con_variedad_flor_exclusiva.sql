/****** Object:  StoredProcedure [dbo].[na_consultar_farms_con_variedad_flor_exclusiva]    Script Date: 10/06/2007 11:58:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_consultar_farms_con_variedad_flor_exclusiva]

AS

SELECT *, nombre_farm + ' ( ' + idc_farm + ' ) ' as nombre_farm_idc
FROM farm
WHERE disponible = 1
ORDER BY nombre_farm

