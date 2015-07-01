set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_vendedor_por_cliente]

@idc_cliente_despacho nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select vendedor.idc_vendedor,
	vendedor.nombre as nombre_vendedor
	from cliente_despacho, 
	cliente_factura,
	vendedor
	where cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor
	and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
end