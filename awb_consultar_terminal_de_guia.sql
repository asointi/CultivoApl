/****** Object:  StoredProcedure [dbo].[awb_consultar_terminal_de_guia]    Script Date: 10/06/2007 10:52:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[awb_consultar_terminal_de_guia]

@id_guia int,
@@nombre_terminal nvarchar(255) OUTPUT

AS

select @@nombre_terminal = t.nombre_terminal
from guia as g, terminal as t, aerolinea_ciudad_terminal as act
where g.id_guia = @id_guia
and g.id_ciudad = act.id_ciudad
and g.id_aerolinea = act.id_aerolinea
and act.id_terminal = t.id_terminal

if(@@nombre_terminal is null)
begin
	select @@nombre_terminal = t.nombre_terminal
	from guia as g, terminal as t, aerolinea as a
	where g.id_guia = @id_guia
	and g.id_aerolinea = a.id_aerolinea
	and a.id_terminal = t.id_terminal
end
	
