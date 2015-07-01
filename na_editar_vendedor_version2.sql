set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_vendedor_version2]

@accion nvarchar(255),
@id_vendedor nvarchar(255),
@correo nvarchar(255),
@idc_vendedor nvarchar(255)

as

if(@id_vendedor is null)
	set @id_vendedor = '%%'

if(@accion = 'consultar_reporte')
begin
	select vendedor.id_vendedor,
	vendedor.idc_vendedor,
	vendedor.nombre,
	cliente_factura.id_cliente_factura,
	cliente_factura.idc_cliente_factura,
	cliente_factura.visualizar_cargos,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente,
	cliente_despacho.contacto,
	cliente_despacho.direccion,
	cliente_despacho.ciudad,
	cliente_despacho.estado,
	cliente_despacho.telefono,
	cliente_despacho.fax
	from vendedor,
	cliente_factura,
	cliente_despacho
	where vendedor.id_vendedor = cliente_factura.id_vendedor
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor like @id_vendedor
end
else
if(@accion = 'consultar')
begin
	select id_vendedor,
	idc_vendedor,
	ltrim(rtrim(idc_vendedor)) + space(1) + '[' + ltrim(rtrim(nombre)) + ']' as nombre_vendedor,
	isnull(correo, '') as correo
	from vendedor
	order by idc_vendedor
end
else
if(@accion = 'actualizar')
begin
	update vendedor
	set correo = @correo
	where id_vendedor = @id_vendedor
end
else
if(@accion = 'consultar_correo')
begin
	select idc_vendedor, 
	isnull(correo, '') as correo
	from vendedor
	where idc_vendedor >=
	case
		when @idc_vendedor = '' then ''
		else @idc_vendedor
	end
	and idc_vendedor <=
	case
		when @idc_vendedor = '' then 'ZZZZZZZZ'
		else @idc_vendedor
	end
end