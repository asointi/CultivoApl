/****** Object:  StoredProcedure [dbo].[wl_editar_wishlist]    Script Date: 10/06/2007 13:08:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_cambiar_pieza]

@idc_pieza_anterior nvarchar(255),
@idc_pieza_nueva nvarchar(255)

AS

update pieza
set idc_pieza = @idc_pieza_nueva
where idc_pieza = @idc_pieza_anterior