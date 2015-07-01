/****** Object:  StoredProcedure [dbo].[na_consultar_todos_cliente_factura]    Script Date: 10/06/2007 12:03:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[na_consultar_todos_cliente_factura]

@orden nvarchar(255)

AS

SELECT cd.*, 
LTRIM(RTRIM(cd.nombre_cliente)) + ' [' + LTRIM(RTRIM(cd.idc_cliente_despacho)) +']' as	 
FROM cliente_factura as cf, 
cliente_despacho as cd
WHERE cf.id_cliente_factura = cd.id_cliente_factura 
and cf.idc_cliente_factura = cd.idc_cliente_despacho
and cf.disponible = 1
ORDER BY 
CASE @orden WHEN 'id_despacho' THEN id_despacho ELSE NULL END,
CASE @orden	WHEN 'id_cliente_factura' THEN cf.id_cliente_factura ELSE NULL END,
CASE @orden	WHEN 'idc_cliente_despacho' THEN idc_cliente_despacho ELSE NULL END,
CASE @orden	WHEN 'nombre_cliente' THEN nombre_cliente ELSE NULL END,
CASE @orden	WHEN 'ciudad' THEN ciudad ELSE NULL END,
CASE @orden	WHEN 'estado' THEN estado ELSE NULL END,
CASE @orden	WHEN '' THEN nombre_cliente ELSE NULL END

