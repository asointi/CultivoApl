/****** Object:  StoredProcedure [dbo].[pbinv_actualizar_preventa_sin_confirmar]    Script Date: 10/06/2007 13:23:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_actualizar_preventa_sin_confirmar]

@id_preventa_sin_confirmar integer, 
@id_transportador integer,
@id_despacho integer,
@valor_unitario decimal(20,4),
@fecha_despacho datetime

AS

BEGIN

if (@id_preventa_sin_confirmar not in (select id_preventa_sin_confirmar from Item_Preventa))
begin
	update Preventa_Sin_Confirmar
	set id_transportador = @id_transportador,
	id_despacho = @id_despacho,
	valor_unitario = @valor_unitario,
	fecha_despacho = @fecha_despacho
	from Preventa_Sin_Confirmar
	where id_preventa_sin_confirmar = @id_preventa_sin_confirmar
end
else
return -1

END