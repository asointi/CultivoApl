set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_marca]

@accion nvarchar(255),
@code nvarchar(255),
@idc_cliente_despacho nvarchar(255),
@idc_cliente_despacho_distribuidora nvarchar(255)

AS

declare @conteo int,
@id_marca int

if(@accion = 'consultar_vendedor')
begin
	select vendedor.id_vendedor,
	vendedor.idc_vendedor,
	vendedor.nombre as nombre_vendedor,
	cliente_despacho_distribuidora.idc_cliente_despacho,
	cliente_despacho_distribuidora.nombre_cliente
	from marca,
	cliente_despacho_marca,
	cliente_despacho_distribuidora,
	cliente_factura_distribuidora,
	vendedor,
	cliente_despacho
	where
	cliente_despacho.id_cliente_despacho = vendedor.id_cliente_despacho
	and vendedor.id_vendedor = cliente_factura_distribuidora.id_vendedor
	and vendedor.id_cliente_despacho = cliente_factura_distribuidora.id_cliente_despacho_vendedor
	and cliente_despacho.id_cliente_despacho = cliente_factura_distribuidora.id_cliente_despacho
	and cliente_factura_distribuidora.id_cliente_factura = cliente_despacho_distribuidora.id_cliente_factura
	and cliente_factura_distribuidora.id_cliente_despacho = cliente_despacho_distribuidora.id_cliente_despacho_cultivo
	and cliente_despacho_distribuidora.id_despacho = cliente_despacho_marca.id_despacho
	and cliente_despacho_distribuidora.id_cliente_factura = cliente_despacho_marca.id_cliente_factura
	and cliente_despacho_distribuidora.id_cliente_despacho_cultivo = cliente_despacho_marca.id_cliente_despacho_cultivo
	and marca.id_marca = cliente_despacho_marca.id_marca
	and marca.code = @code
	and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	group by vendedor.id_vendedor,
	vendedor.idc_vendedor,
	vendedor.nombre,
	cliente_despacho_distribuidora.idc_cliente_despacho,
	cliente_despacho_distribuidora.nombre_cliente
	order by vendedor.id_vendedor,
	vendedor.idc_vendedor,
	vendedor.nombre
end
else
if(@accion = 'consultar_cliente')
begin
	select cliente_despacho_distribuidora.id_despacho,
	cliente_despacho_distribuidora.idc_cliente_despacho,
	cliente_despacho_distribuidora.nombre_cliente
	from cliente_despacho,
	cliente_factura_distribuidora,
	cliente_despacho_distribuidora
	where cliente_despacho.id_cliente_despacho = cliente_factura_distribuidora.id_cliente_despacho
	and cliente_factura_distribuidora.id_cliente_factura = cliente_despacho_distribuidora.id_cliente_factura
	and cliente_factura_distribuidora.id_cliente_despacho = cliente_despacho_distribuidora.id_cliente_despacho_cultivo
	and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	order by cliente_despacho_distribuidora.idc_cliente_despacho
end
else
if(@accion = 'insertar_marca')
begin
	select @conteo = count(*)
	from marca
	where marca.code = @code

	if(@conteo = 0)
	begin
		insert into marca (code)
		values (@code)

		set @id_marca = scope_identity()
	end
	else
	begin
		select @id_marca = marca.id_marca
		from marca
		where marca.code = @code
	end

	insert into cliente_despacho_marca (id_marca, id_despacho, id_cliente_factura, id_cliente_despacho_cultivo)
	select marca.id_marca, cliente_despacho_distribuidora.id_despacho, cliente_despacho_distribuidora.id_cliente_factura, cliente_despacho_distribuidora.id_cliente_despacho_cultivo
	from marca,
	cliente_despacho_distribuidora,
	cliente_factura_distribuidora,
	cliente_despacho
	where cliente_despacho_distribuidora.idc_cliente_despacho = @idc_cliente_despacho_distribuidora
	and marca.id_marca = @id_marca
	and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
	and cliente_despacho.id_cliente_despacho = cliente_factura_distribuidora.id_cliente_despacho
	and cliente_factura_distribuidora.id_cliente_factura = cliente_despacho_distribuidora.id_cliente_factura
	and cliente_factura_distribuidora.id_cliente_despacho = cliente_despacho_distribuidora.id_cliente_despacho_cultivo
end

