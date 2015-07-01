SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bancos_editar_categoria] 

@accion nvarchar(255),
@nombre_categoria nvarchar (255),
@nombre_subcategoria nvarchar (255),
@id_categoria int,
@id_subcategoria int,
@id_subcategoria_concepto_contable int,
@usuario_cobol nvarchar(255),
@idc_concepto nvarchar(255)

AS

declare @conteo int

if(@accion = 'insertar_categoria')
begin
	select @conteo = count(*)
	from categoria
	where ltrim(rtrim(nombre_categoria)) = ltrim(rtrim(@nombre_categoria))

	if(@conteo = 0)
	begin
		insert into categoria (nombre_categoria)
		values (@nombre_categoria)
	
		select 1 as result
	end
	else
	begin
		select -1 as result
	end
end
else
if(@accion = 'consultar_categoria')
begin
	select categoria.id_categoria,
	categoria.nombre_categoria
	from categoria
	order by categoria.nombre_categoria
end
else
if(@accion = 'modificar_categoria')
begin
	select @conteo = count(*)
	from categoria
	where ltrim(rtrim(nombre_categoria)) = ltrim(rtrim(@nombre_categoria))

	if(@conteo = 0)
	begin
		update categoria
		set nombre_categoria = @nombre_categoria
		where id_categoria = @id_categoria
			
		select 4 as result
	end
	else
	begin
		select -4 as result
	end
end
else
if(@accion = 'consultar_eliminacion_categoria')
begin
	select count(*) as cantidad_subcategoria,
	(
		select count(*)
		from categoria,
		subcategoria,
		subcategoria_concepto_contable
		where categoria.id_categoria = subcategoria.id_categoria
		and categoria.id_categoria = @id_categoria
		and subcategoria.id_subcategoria = subcategoria_concepto_contable.id_subcategoria
	) as cantidad_subcategoria_concepto_contable
	from categoria,
	subcategoria
	where categoria.id_categoria = subcategoria.id_categoria
	and categoria.id_categoria = @id_categoria
end
else
if(@accion = 'eliminar_categoria')
begin
	delete from subcategoria_concepto_contable
	where id_subcategoria = @id_subcategoria

	delete from subcategoria
	where id_categoria = @id_categoria

	delete from categoria
	where id_categoria = @id_categoria
end
else
if(@accion = 'insertar_subcategoria')
begin
	select @conteo = count(*)
	from subcategoria
	where ltrim(rtrim(nombre_subcategoria)) = ltrim(rtrim(@nombre_subcategoria))
	and subcategoria.id_categoria = @id_categoria

	if(@conteo = 0)
	begin
		insert into subcategoria (nombre_subcategoria, id_categoria)
		values (@nombre_subcategoria, @id_categoria)
	
		select 2 as result
	end
	else
	begin
		select -2 as result
	end
end
else
if(@accion = 'consultar_subcategoria')
begin
	select categoria.id_categoria,
	categoria.nombre_categoria,
	subcategoria.id_subcategoria,
	subcategoria.nombre_subcategoria
	from categoria,
	subcategoria
	where categoria.id_categoria = subcategoria.id_categoria
	and categoria.id_categoria > =
	case
		when @id_categoria = 0 then 1
		else @id_categoria
	end
	and categoria.id_categoria < =
	case
		when @id_categoria = 0 then 99999
		else @id_categoria
	end
	order by categoria.nombre_categoria,
	subcategoria.nombre_subcategoria
end
else
if(@accion = 'modificar_subcategoria')
begin
	select @conteo = count(*)
	from subcategoria
	where ltrim(rtrim(nombre_subcategoria)) = ltrim(rtrim(@nombre_subcategoria))
	and id_categoria = @id_categoria

	if(@conteo = 0)
	begin
		update subcategoria
		set nombre_subcategoria = @nombre_subcategoria
		where id_subcategoria = @id_subcategoria
		and id_categoria = @id_categoria
			
		select 5 as result
	end
	else
	begin
		select -5 as result
	end
end
else
if(@accion = 'consultar_eliminacion_subcategoria')
begin
	select count(*) as cantidad
	from subcategoria,
	subcategoria_concepto_contable
	where subcategoria.id_subcategoria = @id_subcategoria
	and subcategoria.id_subcategoria = subcategoria_concepto_contable.id_subcategoria
end
else
if(@accion = 'eliminar_subcategoria')
begin
	delete from subcategoria_concepto_contable
	where id_subcategoria = @id_subcategoria

	delete from subcategoria
	where id_subcategoria = @id_subcategoria
end
else
if(@accion = 'insertar_subcategoria_concepto_contable')
begin
	begin try
		insert into subcategoria_concepto_contable (id_concepto, id_subcategoria, usuario_cobol)
		select concepto_contable.id_concepto,
		subcategoria.id_subcategoria,
		@usuario_cobol
		from concepto_contable,
		subcategoria
		where concepto_contable.idc_concepto = @idc_concepto
		and subcategoria.id_subcategoria = @id_subcategoria

		select 3 as result
	end try
	begin catch
		select -3 as result
	end catch
end
else
if(@accion = 'consultar_subcategoria_concepto_contable')
begin
	select categoria.id_categoria,
	categoria.nombre_categoria,
	subcategoria.id_subcategoria,
	subcategoria.nombre_subcategoria,
	subcategoria_concepto_contable.id_subcategoria_concepto_contable,
	concepto_contable.idc_concepto,
	concepto_contable.descripcion,
	subcategoria_concepto_contable.fecha_transaccion,
	subcategoria_concepto_contable.usuario_cobol
	from categoria,
	subcategoria,
	subcategoria_concepto_contable,
	concepto_contable
	where categoria.id_categoria = subcategoria.id_categoria
	and subcategoria.id_subcategoria = subcategoria_concepto_contable.id_subcategoria
	and concepto_contable.id_concepto = subcategoria_concepto_contable.id_concepto
	and subcategoria.id_subcategoria > =
	case
		when @id_subcategoria = 0 then 1
		else @id_subcategoria
	end
	and subcategoria.id_subcategoria < =
	case
		when @id_subcategoria = 0 then 99999
		else @id_subcategoria
	end
	and concepto_contable.idc_concepto > =
	case
		when @idc_concepto = '' then ''
		else @idc_concepto
	end
	and concepto_contable.idc_concepto < =
	case
		when @idc_concepto = '' then 'ZZZZZZZZZZ'
		else @idc_concepto
	end
	order by categoria.nombre_categoria,
	subcategoria.nombre_subcategoria,
	concepto_contable.descripcion
end
else
if(@accion = 'eliminar_subcategoria_concepto_contable')
begin
	delete from subcategoria_concepto_contable
	where id_subcategoria_concepto_contable = @id_subcategoria_concepto_contable
end
else
if(@accion = 'modificar_subcategoria_concepto_contable')
begin
	update subcategoria_concepto_contable
	set id_subcategoria = @id_subcategoria,
	fecha_transaccion = getdate(),
	usuario_cobol = @usuario_cobol
	where subcategoria_concepto_contable.id_subcategoria_concepto_contable = @id_subcategoria_concepto_contable
end

