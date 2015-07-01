/****** Object:  StoredProcedure [dbo].[awb_consultar_piezas_de_guia]    Script Date: 10/06/2007 10:56:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[awb_consultar_piezas_de_guia]

@id_guia int,
@@piezas int OUTPUT

AS

select @@piezas = count(p.id_guia)
from guia as g, pieza as p
where g.id_guia = p.id_guia 
and g.id_guia = @id_guia 
