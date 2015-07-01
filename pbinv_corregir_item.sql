set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[pbinv_corregir_item]

@id_item_inventario_preventa integer, 
@id_tapa integer, 
@id_tipo_caja integer, 
@id_variedad_flor integer,
@id_grado_flor integer, 
@unidades_por_pieza integer, 
@marca nvarchar(255), 
@precio_minimo decimal(20,4)
AS

BEGIN

update Item_Inventario_Preventa
set id_tapa = @id_tapa,
id_tipo_caja = @id_tipo_caja,
id_variedad_flor = @id_variedad_flor,
id_grado_flor = @id_grado_flor,
unidades_por_pieza = @unidades_por_pieza,
marca = @marca,
precio_minimo = @precio_minimo
from Item_Inventario_Preventa
where 
id_item_inventario_preventa = @id_item_inventario_preventa

END
