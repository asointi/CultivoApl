set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_recargo_tipo_cargo]

@accion nvarchar(255),
@id_tipo_cargo int,
@id_cliente_factura int,
@valor decimal(20,4),
@id_recargo_tipo_cargo int

as

declare @conteo int,
@id_recargo_tipo_cargo_aux int

if(@accion = 'consultar_tipo_cargo')
begin
	select tipo_cargo.id_tipo_cargo,
	tipo_cargo.idc_tipo_cargo,
	tipo_cargo.nombre_tipo_cargo
	from tipo_cargo
	order by tipo_cargo.nombre_tipo_cargo
end
else
if(@accion = 'insertar_recargo')
begin
	select @conteo = count(*)
	from recargo_tipo_cargo
	where id_tipo_cargo = @id_tipo_cargo
	and id_cliente_factura = @id_cliente_factura

	if(@conteo = 0)
	begin
		insert into recargo_tipo_cargo (id_tipo_cargo, id_cliente_factura, valor)
		values (@id_tipo_cargo, @id_cliente_factura, @valor)

		set @id_recargo_tipo_cargo_aux = scope_identity()

		select @id_recargo_tipo_cargo_aux as id_recargo_tipo_cargo
	end
	else
	begin
		select -1 as id_recargo_tipo_cargo
	end
end
else
if(@accion = 'actualizar_recargo')
begin
	update recargo_tipo_cargo
	set valor = @valor
	where id_recargo_tipo_cargo = @id_recargo_tipo_cargo
end
else
if(@accion = 'eliminar_recargo')
begin
	delete from recargo_tipo_cargo
	where id_recargo_tipo_cargo = @id_recargo_tipo_cargo
end
else
if(@accion = 'consultar_recargo')
begin
	select cliente_factura.idc_cliente_factura,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	tipo_cargo.idc_tipo_cargo,
	tipo_cargo.nombre_tipo_cargo,
	recargo_tipo_cargo.id_recargo_tipo_cargo,
	recargo_tipo_cargo.valor
	from recargo_tipo_cargo,
	tipo_cargo,
	cliente_factura,
	cliente_despacho
	where tipo_cargo.id_tipo_cargo = recargo_tipo_cargo.id_tipo_cargo
	and cliente_factura.id_cliente_factura = recargo_tipo_cargo.id_cliente_factura
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and cliente_factura.idc_cliente_factura = cliente_despacho.idc_cliente_despacho
	order by nombre_cliente,
	tipo_cargo.nombre_tipo_cargo	
END