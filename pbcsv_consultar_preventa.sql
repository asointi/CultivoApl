/****** Object:  StoredProcedure [dbo].[pbcsv_consultar_preventa]    Script Date: 10/06/2007 13:09:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbcsv_consultar_preventa]
	
AS

declare @idc_tipo_factura nvarchar(255)
set @idc_tipo_factura = '4'
	
select Item_Preventa.id_item_preventa as NroOfpv_sql, 
convert(nvarchar, fecha_despacho, 112) as FechaIniOfpv, 
convert(nvarchar, fecha_despacho, 112) as FechaFinOfpv,
Cliente_Despacho.idc_cliente_despacho as LLaveCliOfpv, 
Farm.idc_farm as LlavefarmOfpv,
Tipo_Flor.idc_tipo_flor LlaveTifOfpv, 
Variedad_Flor.idc_variedad_flor as LlaveVfVfOfpv, 
Grado_Flor.idc_grado_flor as LlaveTafTafOfpv, 
cantidad_piezas as PiezasOfpv, 
unidades_por_pieza as UncjOfpv, 
valor_unitario as VrUnitOfpv,
Tipo_Factura.idc_tipo_factura as TipoOfpv,
Tapa.idc_tapa as LlaveMrOfpv,
Item_Preventa_archivo.marca as StoreOfpv,
Tipo_Caja.idc_tipo_caja LlaveCjOfpv,
Transportador.idc_transportador as LlaveTranOfpv
from Item_Preventa, Preventa_Archivo, Item_Preventa_archivo, Tipo_Flor, Variedad_Flor, Grado_Flor, Tipo_Factura, Cliente_Despacho, Farm, Tapa, Tipo_Caja, Transportador
where Preventa_Archivo.id_preventa_archivo = Item_Preventa_archivo.id_preventa_archivo
and Item_Preventa_Archivo.id_item_preventa_archivo = Item_Preventa.id_item_preventa_archivo
and Variedad_Flor.id_variedad_flor = Item_Preventa_archivo.id_variedad_flor
and Grado_Flor.id_grado_flor = Item_Preventa_archivo.id_grado_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Tipo_factura.idc_tipo_factura = @idc_tipo_factura
and Cliente_Despacho.id_despacho = Item_Preventa_Archivo.id_despacho
and Farm.id_farm = Item_Preventa_Archivo.id_farm
and Tapa.id_tapa = Item_Preventa_Archivo.id_tapa
and Tipo_Caja.id_tipo_caja = Item_Preventa_Archivo.id_tipo_caja
and Transportador.id_transportador = Item_Preventa_Archivo.id_transportador
and Item_Preventa.procesado = 0