set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[bouquet_editar_item_number] 

@accion nvarchar(50),
@idc_cliente_factura nvarchar(25),
@numero_item nvarchar(15),
@id_bouquet int,
@id_item_number int

as

if(@accion = 'consultar')
begin
	select cliente_factura.idc_cliente_factura,
	item_number.id_item_number,
	item_number.numero_item,
	tipo_flor.idc_tipo_flor,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	grado_flor.nombre_grado_flor,
	farm.idc_farm,
	farm.nombre_farm,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	tapa.idc_tapa,
	tapa.nombre_tapa,
	capuchon.nombre_capuchon,
	comida_bouquet.nombre_comida,
	bouquet.id_bouquet,
	bouquet.unidades,
	bouquet.nombre_bouquet,
	convert(nvarchar,bouquet.upc) as upc,
	bouquet.upc_date,
	bouquet.precio_miami,
	bouquet.precio_retail,
	bouquet.especificacion,
	bouquet.construccion_bouquet,
	bouquet.imagen
	from item_number,
	cliente_factura,
	bouquet,
	encabezado,
	tipo_flor,
	variedad_flor,
	grado_flor,
	farm,
	caja,
	tapa,
	capuchon,
	comida_bouquet,
	tipo_caja
	where cliente_factura.id_cliente_factura = item_number.id_cliente_factura
	and bouquet.id_bouquet = item_number.id_bouquet
	and encabezado.id_grado_flor = bouquet.id_grado_flor
	and encabezado.id_variedad_flor = bouquet.id_variedad_flor
	and encabezado.id_farm = bouquet.id_farm
	and encabezado.id_tipo_caja = bouquet.id_tipo_caja
	and caja.id_caja = bouquet.id_caja
	and encabezado.id_tapa = bouquet.id_tapa
	and encabezado.unidades = bouquet.unidades
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja	
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = encabezado.id_variedad_flor
	and grado_flor.id_grado_flor = encabezado.id_grado_flor
	and farm.id_farm = encabezado.id_farm
	and tipo_caja.id_tipo_caja = encabezado.id_tipo_caja
	and tapa.id_tapa = encabezado.id_tapa
	and capuchon.id_capuchon = bouquet.id_capuchon
	and comida_bouquet.id_comida_bouquet = bouquet.id_comida_bouquet
	and cliente_factura.idc_cliente_factura > =
	case
		when @idc_cliente_factura = '' then '          '
		else idc_cliente_factura
	end
	and cliente_factura.idc_cliente_factura < =
	case
		when @idc_cliente_factura = '' then 'ZZZZZZZZZZ'
		else idc_cliente_factura
	end
	and item_number.numero_item > =
	case
		when @numero_item = '' then '               '
		else @numero_item
	end
	and item_number.numero_item < =
	case
		when @numero_item = '' then 'ZZZZZZZZZZZZZZZ'
		else @numero_item
	end
	and bouquet.id_bouquet > =
	case
		when @id_bouquet = 0 then 0
		else @id_bouquet
	end
	and bouquet.id_bouquet < =
	case
		when @id_bouquet = 0 then 999999
		else @id_bouquet
	end
end
else
if(@accion = 'insertar')
begin
	begin try
		insert into item_number (id_cliente_factura, numero_item, id_bouquet)
		select cliente_factura.id_cliente_factura,
		ltrim(rtrim(@numero_item)),
		@id_bouquet
		from cliente_factura
		where ltrim(rtrim(cliente_factura.idc_cliente_factura)) = ltrim(rtrim(@idc_cliente_factura))

		select scope_identity() as id_item_number
	end try
	begin catch
		select -1 as id_item_number
	end catch
end
else
if(@accion = 'actualizar')
begin
	begin try
		update item_number
		set numero_item = @numero_item
		where id_item_number = @id_item_number

		select 2 as resultado
	end try
	begin catch
		select -2 as resultado
	end catch
end
else
if(@accion = 'eliminar')
begin
	delete from item_number
	where id_item_number = @id_item_number
end