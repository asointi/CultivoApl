/****** Object:  StoredProcedure [dbo].[na_remover_variedad_flor_de_farm]    Script Date: 10/06/2007 12:11:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_remover_variedad_flor_de_farm]

@id_farm_variedad_flor int

AS

DELETE farm_variedad_flor
WHERE id_farm_variedad_flor=@id_farm_variedad_flor
