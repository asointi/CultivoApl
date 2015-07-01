SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2009/02/09
-- Description:	verificar que la guias no tengan ciudad nula
-- =============================================
CREATE TRIGGER [dbo].[consultar_guias_con_ciudad_nula]
   ON  guia
   AFTER INSERT
AS 
BEGIN
	declare @id_guia int,
	@id_ciudad int

	select @id_guia = max(id_guia) from guia
	select @id_ciudad = id_ciudad from guia where id_guia = @id_guia

	if(@id_ciudad is null)
	begin
		update guia
		set id_ciudad = ciudad.id_ciudad
		from ciudad
		where ciudad.idc_ciudad = 'N/A'
		and guia.id_guia = @id_guia
	end
END
GO
