set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[cul_consultar_cliente_despacho]

@orden nvarchar(255)

AS

SELECT cd.*,
cliente_pedido.*, 
LTRIM(RTRIM(cliente_pedido.nombre_cliente_pedido)) + ' [' + LTRIM(RTRIM(cd.idc_cliente_despacho)) +']' as nombre_cliente_idc,
(select top 1 cliente_pedido.id_cliente_pedido 
from temporada_año
where cliente_pedido.id_cliente_pedido = temporada_año.id_cliente_pedido) as temporada
FROM cliente_despacho as cd, 
cliente_factura as cf,
cliente_pedido 
WHERE cd.disponible = 1
and cd.id_cliente_factura = cf.id_cliente_factura
and cliente_pedido.id_cliente_despacho = cd.id_cliente_despacho
ORDER BY 
CASE @orden WHEN 'id_cliente_despacho' THEN cd.id_cliente_despacho ELSE NULL END,
CASE @orden	WHEN 'id_cliente_factura' THEN cf.id_cliente_factura ELSE NULL END,
CASE @orden	WHEN 'idc_cliente_despacho' THEN idc_cliente_despacho ELSE NULL END,
CASE @orden	WHEN 'nombre_cliente' THEN nombre_cliente ELSE NULL END,
CASE @orden	WHEN 'ciudad' THEN ciudad ELSE NULL END,
CASE @orden	WHEN '' THEN nombre_cliente ELSE NULL END

