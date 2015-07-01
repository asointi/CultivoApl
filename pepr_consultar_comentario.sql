USE [BD_Cultivo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pepr_consultar_comentario] 

@idc_pedido_pepr int,
@catalogo nvarchar(25)

as

select isnull(pedido_pepr.comentario, '') as comentario
from catalogo,
pedido_pepr
where catalogo.id_catalogo = pedido_pepr.id_catalogo
and convert(int, pedido_pepr.idc_pedido_pepr) = @idc_pedido_pepr
and catalogo.nombre_catalogo = @catalogo