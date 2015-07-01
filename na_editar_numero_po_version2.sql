/****** Object:  StoredProcedure [dbo].[pbinv_consultar_saldos_factura]    Script Date: 09/04/2008 16:58:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[na_editar_numero_po_version2]

@id_orden_pedido int,
@numero_po nvarchar(50)

as

update orden_pedido
set numero_po = @numero_po
where id_orden_pedido = @id_orden_pedido
