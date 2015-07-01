SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_consultar_capuchon]

@id_po int = null

AS

select id_capuchon_cultivo,
idc_capuchon,
descripcion, 
ancho_superior, 
ancho_inferior, 
alto,
decorado,
isnull(
(
	select capuchon_cultivo.id_capuchon_cultivo
	from cliente_despacho,
	po,
	cliente_factura
	where po.id_po = @id_po
	and cliente_despacho.id_despacho = po.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and capuchon_cultivo.id_capuchon_cultivo = cliente_factura.id_capuchon_cultivo
)
, 0) as capuchon_por_defecto
from capuchon_cultivo
where disponible = 1
order by descripcion