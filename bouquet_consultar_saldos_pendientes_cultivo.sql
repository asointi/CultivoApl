/****** Object:  StoredProcedure [dbo].[wl_editar_wishlist]    Script Date: 10/06/2007 13:08:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bouquet_consultar_saldos_pendientes_cultivo]

@fecha_despacho nvarchar(8)

as

declare @fecha datetime
set @fecha = @fecha_despacho

exec bd_fresca.bd_fresca.dbo.bouquet_consultar_saldos_pendientes
@fecha_vuelo = @fecha