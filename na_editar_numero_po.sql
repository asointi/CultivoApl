/****** Object:  StoredProcedure [dbo].[pbinv_consultar_saldos_factura]    Script Date: 09/04/2008 16:58:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_numero_po]

@idc_orden_pedido nvarchar(20),
@numero_po nvarchar(50)

as

update orden_pedido
set numero_po = @numero_po
where convert(int,idc_orden_pedido) = convert(int,@idc_orden_pedido)