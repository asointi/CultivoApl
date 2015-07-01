set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_tipo_contacto_cliente_factura]

@nombre_tipo_contacto nvarchar(255),
@idc_cliente_factura nvarchar(255),
@accion nvarchar(255),
@numero_celular int, 
@correo_electronico nvarchar(255)

as

declare @conteo int

select @conteo = count(*) from tipo_contacto, cliente_factura, tipo_contacto_cliente_factura
where tipo_contacto.id_tipo_contacto = tipo_contacto_cliente_factura.id_tipo_contacto
and cliente_factura.id_cliente_factura = tipo_contacto_cliente_factura.id_cliente_factura
and cliente_factura.idc_cliente_factura = @idc_cliente_factura
and ltrim(rtrim(tipo_contacto.nombre_tipo_contacto)) = ltrim(rtrim(@nombre_tipo_contacto))
and tipo_contacto_cliente_factura.numero_celular = @numero_celular
and ltrim(rtrim(tipo_contacto_cliente_factura.correo_electronico)) = ltrim(rtrim(@correo_electronico))

if(ltrim(rtrim(@nombre_tipo_contacto)) = '')
	set @nombre_tipo_contacto = '%%'

if(@idc_cliente_factura = '')
	set @idc_cliente_factura = '%%' 

if(@accion = 'consultar')
begin
	select tipo_contacto_cliente_factura.id_tipo_contacto_cliente_factura,
	tipo_contacto_cliente_factura.numero_celular,
	ltrim(rtrim(tipo_contacto_cliente_factura.correo_electronico)) as correo_electronico
	from tipo_contacto_cliente_factura, cliente_factura, tipo_contacto
	where tipo_contacto_cliente_factura.id_cliente_factura = cliente_factura.id_cliente_factura
	and tipo_contacto_cliente_factura.id_tipo_contacto = tipo_contacto.id_tipo_contacto
	and ltrim(rtrim(tipo_contacto.nombre_tipo_contacto)) like ltrim(rtrim(@nombre_tipo_contacto))
	and cliente_factura.idc_cliente_factura = @idc_cliente_factura
end
else
if(@accion = 'insertar')
begin
	if(@conteo = 0)
	begin
		insert into tipo_contacto_cliente_factura (id_tipo_contacto, id_cliente_factura, numero_celular, correo_electronico)
		select tipo_contacto.id_tipo_contacto, cliente_factura.id_cliente_factura, @numero_celular, @correo_electronico
		from tipo_contacto, cliente_factura
		where ltrim(rtrim(tipo_contacto.nombre_tipo_contacto)) = ltrim(rtrim(@nombre_tipo_contacto))
		and cliente_factura.idc_cliente_factura = @idc_cliente_factura
	end
end
else
if(@accion = 'modificar')
begin
	update tipo_contacto_cliente_factura
	set numero_celular = @numero_celular,
	correo_electronico = @correo_electronico
	from cliente_factura, tipo_contacto, tipo_contacto_cliente_factura
	where ltrim(rtrim(tipo_contacto.nombre_tipo_contacto)) = ltrim(rtrim(@nombre_tipo_contacto))
	and cliente_factura.idc_cliente_factura = @idc_cliente_factura
	and cliente_factura.id_cliente_factura = tipo_contacto_cliente_factura.id_cliente_factura
	and tipo_contacto.id_tipo_contacto = tipo_contacto_cliente_factura.id_tipo_contacto
end
else
if(@accion = 'eliminar')
begin
	declare @id_cliente_factura int,
	@id_tipo_contacto int
	
	select @id_cliente_factura = cliente_factura.id_cliente_factura
	from cliente_factura
	where cliente_factura.idc_cliente_factura = @idc_cliente_factura
	
	select @id_tipo_contacto = tipo_contacto.id_tipo_contacto
	from tipo_contacto	
	where ltrim(rtrim(tipo_contacto.nombre_tipo_contacto)) = ltrim(rtrim(@nombre_tipo_contacto))

	delete from tipo_contacto_cliente_factura
	where tipo_contacto_cliente_factura.numero_celular = @numero_celular
	and tipo_contacto_cliente_factura.correo_electronico = @correo_electronico
	and tipo_contacto_cliente_factura.id_cliente_factura = @id_cliente_factura
	and tipo_contacto_cliente_factura.id_tipo_contacto = @id_tipo_contacto
end
