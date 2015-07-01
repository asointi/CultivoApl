USE [BD_Nf]
GO
/****** Object:  StoredProcedure [dbo].[wbl_seleccionar_fincas_usuario]    Script Date: 11/13/2007 12:58:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wbl_seleccionar_fincas_usuario]
@usuario NVARCHAR(255)
AS
BEGIN

SELECT farm.idc_farm AS LlaveFarm, farm.nombre_farm AS NombreFarm,
farm.id_farm, farm.tiene_variedad_flor_exclusiva AS var_exclusiva
FROM usuario_farm, farm WHERE usuario = @usuario AND
usuario_farm.farm=farm.idc_farm AND disponible=1 
ORDER BY NombreFarm

END


