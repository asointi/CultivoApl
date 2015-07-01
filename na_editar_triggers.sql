set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

ALTER PROCEDURE [dbo].[na_editar_triggers]

@activar bit

as
if(@activar = 1)
begin
	ENABLE TRIGGER Pieza_Postcosecha.actualizacion_datos_tablero_pieza_postcosecha ON Pieza_Postcosecha
end 
else
begin
	DISABLE TRIGGER Pieza_Postcosecha.actualizacion_datos_tablero_pieza_postcosecha ON Pieza_Postcosecha

end 
