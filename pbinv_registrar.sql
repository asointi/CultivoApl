set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[pbinv_registrar]

@id_farm integer

AS

BEGIN

insert into Inventario_Preventa (id_farm)
values (@id_farm)
return scope_identity()

END
