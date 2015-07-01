/****** Object:  StoredProcedure [dbo].[pbinv_consultar_saldos_factura]    Script Date: 09/04/2008 16:58:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[na_editar_comentario_orden_pedido]

@idc_orden_pedido nvarchar(255),
@comentario nvarchar(1024)

as

update orden_pedido
set comentario = @comentario
where convert(int,idc_orden_pedido) = convert(int,@idc_orden_pedido)