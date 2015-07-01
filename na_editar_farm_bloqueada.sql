SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[na_editar_farm_bloqueada]

@id_farm int,
@bloqueada bit

AS

update farm
set bloqueada = @bloqueada
where id_farm = @id_farm