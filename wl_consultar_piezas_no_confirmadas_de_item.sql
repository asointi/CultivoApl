/****** Object:  StoredProcedure [dbo].[wl_consultar_piezas_no_confirmadas_de_item]    Script Date: 10/06/2007 12:57:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wl_consultar_piezas_no_confirmadas_de_item]

@id_item_wishlist int,@@piezas_no_confirmadas int OUTPUT

AS

DECLARE @piezas_wl int, @piezas_conf int

select @piezas_wl = piezas from wl_item_wishlist where id_item_wishlist = @id_item_wishlist
select @piezas_conf = sum(piezas_conf) from wl_confirmacion where id_item_wishlist = @id_item_wishlist

if @piezas_conf IS NOT NULL
	SET @@piezas_no_confirmadas = @piezas_wl - @piezas_conf
ELSE
	BEGIN
		IF @piezas_wl IS NOT NULL
			SET @@piezas_no_confirmadas = @piezas_wl
		ELSE
			SET @@piezas_no_confirmadas = 0
	END
