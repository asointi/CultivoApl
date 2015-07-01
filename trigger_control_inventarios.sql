set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:			Diego Piñeros
-- Create date:		2009/01/13
-- Description:		cambiar el control de saldos segun la tapa insertada
-- =============================================

ALTER TRIGGER [dbo].[control_inventarios]
   ON  [dbo].[Item_Inventario_Preventa]
   for  insert
AS 

update item_inventario_preventa
set controla_saldos = 
case
when tapa.idc_tapa = '..' then 0
when tapa.idc_tapa = 'F2' then 1
else 0
end
from tapa
where item_inventario_preventa.id_tapa = tapa.id_tapa
and item_inventario_preventa.id_item_inventario_preventa = 
(
select max(id_item_inventario_preventa)
from item_inventario_preventa
)