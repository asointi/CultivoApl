/****** Object:  StoredProcedure [dbo].[wl_editar_wishlist]    Script Date: 10/06/2007 13:08:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_guia_cultivo_distribuidora]

@fecha_inicial datetime,
@fecha_final datetime

as

select guia.idc_guia,
guia.fecha_guia,
pieza.idc_pieza,
factura.idc_llave_factura + factura.idc_numero_factura as numero_factura,
isnull(pieza.unidades_por_pieza * item_factura.valor_unitario, 0) as valor,
isnull((
	select sum(cargo.valor_cargo)
	from bd_fresca.dbo.cargo
	where item_factura.id_item_factura = cargo.id_item_factura
	and item_factura.cargo_incluido = 1
) /
(
	select count(*) 
	from bd_fresca.dbo.pieza as p,
	bd_fresca.dbo.detalle_item_factura as dit
	where p.id_guia = guia.id_guia
	and p.id_pieza = dit.id_pieza
	and dit.id_item_factura = item_factura.id_item_factura
), 0) as cargo
from bd_fresca.dbo.guia, 
bd_fresca.dbo.pieza,
bd_fresca.dbo.detalle_item_factura,
bd_fresca.dbo.item_factura,
bd_fresca.dbo.factura
where pieza.id_guia = guia.id_guia
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and item_factura.id_factura = factura.id_factura
and guia.fecha_guia > = @fecha_inicial 
and guia.fecha_guia < = @fecha_final
group by item_factura.id_item_factura,
item_factura.valor_unitario,
item_factura.cargo_incluido,
guia.id_guia,
guia.idc_guia,
guia.fecha_guia,
pieza.idc_pieza,
factura.idc_llave_factura,
factura.idc_numero_factura,
pieza.unidades_por_pieza

union all

select guia.idc_guia,
guia.fecha_guia,
'' as idc_pieza,
credito.idc_numero_credito,
detalle_credito.valor_credito,
0 as cargo
from bd_fresca.dbo.credito,
bd_fresca.dbo.guia,
bd_fresca.dbo.detalle_credito
where detalle_credito.id_guia = guia.id_guia
and credito.id_credito = detalle_credito.id_credito
and guia.fecha_guia > = @fecha_inicial and 
guia.fecha_guia < = @fecha_final
group by guia.idc_guia,
guia.fecha_guia,
credito.idc_numero_credito,
detalle_credito.valor_credito