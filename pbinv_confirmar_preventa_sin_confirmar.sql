/****** Object:  StoredProcedure [dbo].[pbinv_confirmar_preventa_sin_confirmar]    Script Date: 10/06/2007 13:25:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_confirmar_preventa_sin_confirmar]

@id_preventa_sin_confirmar integer

AS

BEGIN

if(@id_preventa_sin_confirmar not in (select id_preventa_sin_confirmar from Item_Preventa))
begin
	insert into Item_preventa (id_preventa_sin_confirmar)
	values (@id_preventa_sin_confirmar)
end
else
return -1

END