/****** Object:  StoredProcedure [dbo].[na_consultar_porcentaje_descuento]    Script Date: 11/16/2007 10:58:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_consultar_porcentaje_descuento]

@idc_cliente_factura nvarchar(15), 
@idc_farm nvarchar(5)

AS

select isnull(sum(tipo_descuento_tipo_farm.porcentaje_descuento),0) as porcentaje_descuento
from farm, 
tipo_farm, 
tipo_descuento, 
cliente_factura, 
tipo_descuento_cliente_factura, 
tipo_descuento_tipo_farm
where farm.idc_farm = @idc_farm
and cliente_factura.idc_cliente_factura = @idc_cliente_factura
and farm.id_tipo_farm = tipo_farm.id_tipo_farm
and tipo_farm.id_tipo_farm = tipo_descuento_tipo_farm.id_tipo_farm
and cliente_factura.id_cliente_factura = tipo_descuento_cliente_factura.id_cliente_factura
and tipo_descuento.id_tipo_descuento = tipo_descuento_cliente_factura.id_tipo_descuento
and tipo_descuento.id_tipo_descuento = tipo_descuento_tipo_farm.id_tipo_descuento