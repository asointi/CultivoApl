/****** Object:  StoredProcedure [dbo].[pbinv_consultar_preventa_sin_confirmar]    Script Date: 10/06/2007 13:29:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[pbinv_consultar_preventa_sin_confirmar]

@id_cliente_despacho integer,
@fecha_despacho datetime

AS

BEGIN

select Preventa_Sin_Confirmar.id_preventa_sin_confirmar,
Tipo_Flor.idc_tipo_flor,
Tipo_Flor.nombre_tipo_flor,
Variedad_Flor.idc_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Transportador.id_transportador,
Transportador.idc_transportador,
Transportador.nombre_transportador,
Cliente_Despacho.id_despacho,
Cliente_Despacho.idc_cliente_despacho,
Cliente_Despacho.nombre_cliente,
Tapa.idc_tapa,
Tapa.nombre_tapa,
Tipo_Caja.idc_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Item_Inventario_Preventa.marca,
Preventa_Sin_Confirmar.valor_unitario,
Item_Inventario_Preventa.unidades_por_pieza

from 
Preventa_Sin_Confirmar, 
Item_Inventario_Preventa, 
Transportador, 
Cliente_Despacho, 
Variedad_Flor,
Grado_Flor,
Tapa,
Tipo_Caja,
Tipo_Flor
where 
Preventa_Sin_Confirmar.id_transportador = Transportador.id_transportador
and Preventa_Sin_Confirmar.id_despacho = Cliente_Despacho.id_despacho
and Preventa_Sin_Confirmar.id_item_inventario_preventa = Item_Inventario_Preventa.id_item_inventario_preventa
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Cliente_Despacho.id_despacho = @id_cliente_despacho
and convert(datetime, Preventa_Sin_Confirmar.fecha_despacho, 101) >= convert(datetime, @fecha_despacho, 101)
END