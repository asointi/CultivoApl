set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[inv_cambio_marca_por_pieza]

@idc_pieza nvarchar(255),
@tiene_marca bit

as

declare @id_pieza int

select @id_pieza = id_pieza
from pieza
where pieza.idc_pieza = @idc_pieza

update pieza
set tiene_marca = @tiene_marca
where pieza.id_pieza = @id_pieza
and not exists
(
	select * 
	from detalle_item_factura
	where detalle_item_factura.id_pieza = pieza.id_pieza
)
and pieza.disponible = 1