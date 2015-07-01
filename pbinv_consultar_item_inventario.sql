/****** Object:  StoredProcedure [dbo].[pbinv_consultar_item_inventario]    Script Date: 01/05/2008 09:38:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[pbinv_consultar_item_inventario]

@id_item_inventario_preventa integer

AS

BEGIN
select fecha_disponible_distribuidora, cantidad_piezas
from detalle_item_inventario_preventa
where id_item_inventario_preventa = @id_item_inventario_preventa
and id_detalle_item_inventario_preventa in
(
select max(id_detalle_item_inventario_preventa) from detalle_item_inventario_preventa
group by id_detalle_item_inventario_preventa_padre
)



END
