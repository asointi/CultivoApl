alter PROCEDURE [dbo].[na_editar_grupo_cliente_factura]

@nombre_grupo_cliente_factura nvarchar(255), 
@correo nvarchar(255),
@accion nvarchar(255),
@id_grupo_cliente_factura int,
@id_cliente_factura int,
@id_detalle_grupo_cliente_factura int,
@filtro nvarchar(255)

as

declare @conteo int

if(@accion = 'consultar_cliente_factura')
begin
	if(@filtro is null)
	begin
		select cliente_factura.id_cliente_factura,
		ltrim(rtrim(cliente_factura.idc_cliente_factura)) + space(1) + '[' + ltrim(rtrim(cliente_despacho.nombre_cliente)) + ']' as cliente,
		cliente_factura.id_cliente_factura as id_detalle_grupo_cliente_factura
		from grupo_cliente_factura,
		cliente_factura,
		cliente_despacho
		where cliente_factura.idc_cliente_factura = cliente_despacho.idc_cliente_despacho
		and grupo_cliente_factura.id_grupo_cliente_factura = @id_grupo_cliente_factura
		and grupo_cliente_factura.id_grupo_cliente_factura = cliente_factura.id_grupo_cliente_factura
	end
	else
	begin
		set @filtro = '%' + isnull(@filtro, '') + '%'

		select cliente_factura.id_cliente_factura,
		ltrim(rtrim(cliente_factura.idc_cliente_factura)) + space(1) + '[' + ltrim(rtrim(cliente_despacho.nombre_cliente)) + ']' as cliente,
		cliente_factura.id_cliente_factura as id_detalle_grupo_cliente_factura
		from grupo_cliente_factura,
		cliente_factura,
		cliente_despacho
		where cliente_factura.idc_cliente_factura = cliente_despacho.idc_cliente_despacho
		and grupo_cliente_factura.id_grupo_cliente_factura = @id_grupo_cliente_factura
		and grupo_cliente_factura.id_grupo_cliente_factura = cliente_factura.id_grupo_cliente_factura
		union all
		select cliente_factura.id_cliente_factura,
		ltrim(rtrim(cliente_factura.idc_cliente_factura)) + space(1) + '[' + ltrim(rtrim(cliente_despacho.nombre_cliente)) + ']' as cliente,
		0 as id_detalle_grupo_cliente_factura
		from cliente_factura,
		cliente_despacho,
		grupo_cliente_factura
		where cliente_factura.idc_cliente_factura like @filtro
		and cliente_factura.idc_cliente_factura = cliente_despacho.idc_cliente_despacho
		and cliente_factura.id_grupo_cliente_factura = grupo_cliente_factura.id_grupo_cliente_factura
		and grupo_cliente_factura.nombre_grupo_cliente_factura = 'N/A'
		and cliente_factura.disponible = 1
		order by cliente
	end
end
else
if(@accion = 'consultar_grupo_cliente')
begin
	select grupo_cliente_factura.id_grupo_cliente_factura,
	grupo_cliente_factura.nombre_grupo_cliente_factura as nombre_grupo_cliente,
	 '(' +
		convert(nvarchar,
		(
			select count(*)
			from cliente_factura
			where grupo_cliente_factura.id_grupo_cliente_factura = cliente_factura.id_grupo_cliente_factura
		)
	) + ')' as cantidad,
	grupo_cliente_factura.correo
	from grupo_cliente_factura
	where grupo_cliente_factura.nombre_grupo_cliente_factura <> 'N/A'
	order by grupo_cliente_factura.nombre_grupo_cliente_factura
end
else
if(@accion = 'consultar_grupo_cliente_COBOL')
begin
	select grupo_cliente_factura.id_grupo_cliente_factura,
	grupo_cliente_factura.nombre_grupo_cliente_factura as nombre_grupo_cliente,
	 '(' +
		convert(nvarchar,
		(
			select count(*)
			from cliente_factura
			where grupo_cliente_factura.id_grupo_cliente_factura = cliente_factura.id_grupo_cliente_factura
		)
	) + ')' as cantidad,
	grupo_cliente_factura.correo
	from grupo_cliente_factura
	order by grupo_cliente_factura.nombre_grupo_cliente_factura
end
else
if(@accion = 'insertar_grupo_cliente')
begin
	select @conteo = count(*)
	from grupo_cliente_factura
	where ltrim(rtrim(nombre_grupo_cliente_factura)) = ltrim(rtrim(@nombre_grupo_cliente_factura))

	if(@conteo = 0)
	begin
		insert into grupo_cliente_factura (nombre_grupo_cliente_factura, correo)
		values (@nombre_grupo_cliente_factura, @correo)

		select 1 as id_grupo_cliente_factura
	end
	else
	begin
		select -1 as id_grupo_cliente_factura
	end
end
else
if(@accion = 'modificar_grupo_cliente')
begin
	select @conteo = count(*)
	from grupo_cliente_factura
	where ltrim(rtrim(nombre_grupo_cliente_factura)) = ltrim(rtrim(@nombre_grupo_cliente_factura))
	and id_grupo_cliente_factura <> @id_grupo_cliente_factura

	if(@conteo = 0)
	begin
		update grupo_cliente_factura
		set nombre_grupo_cliente_factura = @nombre_grupo_cliente_factura,
		correo = @correo
		where id_grupo_cliente_factura = @id_grupo_cliente_factura

		select 1 as id_grupo_cliente_factura
	end
	else
	begin
		select -1 as id_grupo_cliente_factura
	end
end
else
if(@accion = 'eliminar_grupo_cliente')
begin
	update cliente_factura
	set id_grupo_cliente_factura = grupo_cliente_factura.id_grupo_cliente_factura
	from grupo_cliente_factura
	where cliente_factura.id_grupo_cliente_factura = @id_grupo_cliente_factura
	and grupo_cliente_factura.nombre_grupo_cliente_factura = 'N/A'

	delete from grupo_cliente_factura where id_grupo_cliente_factura = @id_grupo_cliente_factura
end
else
if(@accion = 'insertar_detalle_grupo_cliente')
begin
	update cliente_factura
	set id_grupo_cliente_factura = @id_grupo_cliente_factura
	where id_cliente_factura = @id_cliente_factura
	
	select 1 as id_detalle_grupo_cliente_factura
end
else
if(@accion = 'eliminar_detalle_grupo_cliente')
begin
	update cliente_factura
	set id_grupo_cliente_factura = grupo_cliente_factura.id_grupo_cliente_factura
	from grupo_cliente_factura
	where grupo_cliente_factura.nombre_grupo_cliente_factura = 'N/A'
	and cliente_factura.id_cliente_factura = @id_detalle_grupo_cliente_factura
end