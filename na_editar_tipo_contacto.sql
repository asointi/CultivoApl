set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_tipo_contacto]

@nombre_tipo_contacto nvarchar(255),
@idc_cliente_factura nvarchar(255),
@nombre nvarchar(255),
@numero_celular nvarchar(255),
@msn nvarchar(255),
@accion nvarchar(255)

as

declare @conteo int, @id_tipo_contacto int

if(@accion = 'modificar')
begin
	select @conteo = count(*) from tipo_contacto where nombre_tipo_contacto = @nombre_tipo_contacto

	if(@conteo = 1)
	begin
		select @conteo = count(*) 
		from tipo_contacto, tipo_contacto_cliente_factura, cliente_factura
		where tipo_contacto.id_tipo_contacto = tipo_contacto_cliente_factura.id_tipo_contacto
		and tipo_contacto_cliente_factura.id_cliente_factura = cliente_factura.id_cliente_factura
		and tipo_contacto.nombre_tipo_contacto = @nombre_tipo_contacto
		and cliente_factura.idc_cliente_factura = @idc_cliente_factura
		if(@conteo = 1)
		begin
			update tipo_contacto_cliente_factura
			set nombre = @nombre,
			msn = @msn,
			numero_celular = @numero_celular
			from tipo_contacto, tipo_contacto_cliente_factura, cliente_factura
			where tipo_contacto.id_tipo_contacto = tipo_contacto_cliente_factura.id_tipo_contacto
			and tipo_contacto_cliente_factura.id_cliente_factura = cliente_factura.id_cliente_factura
			and tipo_contacto. nombre_tipo_contacto = @nombre_tipo_contacto
			and cliente_factura.idc_cliente_factura = @idc_cliente_factura
		end
		else
		begin
			insert into tipo_contacto_cliente_factura (id_tipo_contacto, id_cliente_factura, nombre, numero_celular, msn)
			select tipo_contacto.id_tipo_contacto, cliente_factura.id_cliente_factura, @nombre, @numero_celular, @msn
			from tipo_contacto, cliente_factura
			where tipo_contacto.nombre_tipo_contacto = @nombre_tipo_contacto
			and cliente_factura.idc_cliente_factura = @idc_cliente_factura
		end
	end
	else
	begin
		insert into tipo_contacto (nombre_tipo_contacto)
		values (@nombre_tipo_contacto)
		
		set @id_tipo_contacto = scope_identity()

		insert into tipo_contacto_cliente_factura (id_tipo_contacto, id_cliente_factura, nombre, numero_celular, msn)
		select @id_tipo_contacto, cliente_factura.id_cliente_factura, @nombre, @numero_celular, @msn
		from cliente_factura
		where cliente_factura.idc_cliente_factura = @idc_cliente_factura
	end
end
else
if(@accion = 'eliminar')
begin
	delete from tipo_contacto_cliente_factura
	where id_cliente_factura = (select id_cliente_factura from cliente_factura where idc_cliente_factura = @idc_cliente_factura)
	and id_tipo_contacto = (select id_tipo_contacto from tipo_contacto where nombre_tipo_contacto = @nombre_tipo_contacto)
	select @conteo = count(*) from tipo_contacto_cliente_factura, tipo_contacto
	where tipo_contacto_cliente_factura.id_tipo_contacto = tipo_contacto.id_tipo_contacto
	and tipo_contacto.nombre_tipo_contacto = @nombre_tipo_contacto
	if(@conteo < 1)
	begin
		delete from tipo_contacto where nombre_tipo_contacto = @nombre_tipo_contacto
	end
end