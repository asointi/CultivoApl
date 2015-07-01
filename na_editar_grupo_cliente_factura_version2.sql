alter PROCEDURE [dbo].[na_editar_grupo_cliente_factura_version2]

@accion nvarchar(255),
@idc_cliente_factura nvarchar(20)

as

if(@accion = 'consultar_cliente_factura')
begin
	select ltrim(rtrim(tipo_contacto_cliente_factura.nombre)) as nombre_tipo_contacto,
	tipo_contacto_cliente_factura.numero_celular,
	tipo_contacto_cliente_factura.msn,
	grupo_cliente_factura.id_grupo_cliente_factura,
	grupo_cliente_factura.nombre_grupo_cliente_factura,
	grupo_cliente_factura.correo as correo_grupo_cliente
	from cliente_factura left join tipo_contacto_cliente_factura
	on cliente_factura.id_cliente_factura = tipo_contacto_cliente_factura.id_cliente_factura,
	grupo_cliente_factura
	where grupo_cliente_factura.id_grupo_cliente_factura = cliente_factura.id_grupo_cliente_factura
	and cliente_factura.idc_cliente_factura > =
	case
		when @idc_cliente_factura = '' then '          '
		else @idc_cliente_factura
	end
	and cliente_factura.idc_cliente_factura < =
	case
		when @idc_cliente_factura = '' then 'ZZZZZZZZZZ'
		else @idc_cliente_factura
	end
end