/****** Object:  StoredProcedure [dbo].[wl_consultar_piezas_no_confirmadas_de_wishlist]    Script Date: 10/06/2007 12:58:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[wl_consultar_piezas_no_confirmadas_de_wishlist]

@id_wishlist int,@@piezas_no_confirmadas int OUTPUT

AS

DECLARE @piezas_wl int,@piezas_conf int

select @piezas_wl = sum(piezas) from wl_item_wishlist where id_wishlist = @id_wishlist
select @piezas_conf = sum(c.piezas_conf) from wl_item_wishlist as i, wl_confirmacion as c where i.id_wishlist = @id_wishlist and i.id_item_wishlist = c.id_item_wishlist

if @piezas_conf IS NOT NULL
	SET @@piezas_no_confirmadas = @piezas_wl - @piezas_conf
ELSE
	BEGIN
		IF @piezas_wl IS NOT NULL
			SET @@piezas_no_confirmadas = @piezas_wl
		ELSE
			SET @@piezas_no_confirmadas = 0
	END
