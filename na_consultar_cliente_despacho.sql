/****** Object:  StoredProcedure [dbo].[na_consultar_todos_cliente_factura]    Script Date: 10/06/2007 12:03:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_consultar_cliente_despacho]

@orden nvarchar(255)

AS

SELECT cd.id_despacho,
cd.idc_cliente_despacho,
ltrim(rtrim(cd.nombre_cliente)) as nombre_cliente,
cd.contacto,
cd.direccion,
cd.ciudad,
cd.estado,
cd.telefono,
cd.fax,
LTRIM(RTRIM(cd.nombre_cliente)) + ' [' + LTRIM(RTRIM(cd.idc_cliente_despacho)) +']' as nombre_cliente_idc,
cf.idc_cliente_factura,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
(
	select nombre_estado
	from estado
	where estado.idc_estado = cd.estado
) as nombre_estado,
(
	select ltrim(rtrim(cliente_despacho.nombre_cliente))
	from cliente_despacho
	where cliente_despacho.idc_cliente_despacho = cf.idc_cliente_factura
) as nombre_cliente_factura,
isnull(cd.disponible, 1) as disponible
FROM cliente_factura as cf, 
cliente_despacho as cd,
vendedor
WHERE cf.id_cliente_factura = cd.id_cliente_factura 
and vendedor.id_vendedor = cf.id_vendedor
ORDER BY 
CASE @orden WHEN 'id_despacho' THEN id_despacho ELSE NULL END,
CASE @orden	WHEN 'id_cliente_factura' THEN cf.id_cliente_factura ELSE NULL END,
CASE @orden	WHEN 'idc_cliente_despacho' THEN idc_cliente_despacho ELSE NULL END,
CASE @orden	WHEN 'nombre_cliente' THEN nombre_cliente ELSE NULL END,
CASE @orden	WHEN 'ciudad' THEN ciudad ELSE NULL END,
CASE @orden	WHEN 'estado' THEN estado ELSE NULL END,
CASE @orden	WHEN '' THEN nombre_cliente ELSE NULL END