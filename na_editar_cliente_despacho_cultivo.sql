set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_cliente_despacho_cultivo]

@accion nvarchar(255)

AS

if(@accion = 'consultar')
begin
	select cliente_factura.idc_cliente_factura,
	cliente_factura.nombre_cliente_factura,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente as nombre_cliente_despacho,
	cliente_despacho.contacto,
	cliente_despacho.direccion,
	cliente_despacho.ciudad,
	cliente_despacho.recibe_flor_sin_clasificar 
	from cliente_despacho,
	cliente_factura
	where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and cliente_despacho.disponible = 1
	order by cliente_despacho.idc_cliente_despacho
end