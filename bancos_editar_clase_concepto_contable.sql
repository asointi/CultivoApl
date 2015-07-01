SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bancos_editar_clase_concepto_contable] 

@accion nvarchar(255),
@nombre_clase nvarchar (255),
@id_clase int,
@idc_concepto nvarchar(255),
@usuario_cobol nvarchar(255),
@id_clase_concepto_contable int

AS

declare @conteo int

if(@accion = 'insertar_clase')
begin
	select @conteo = count(*)
	from clase
	where ltrim(rtrim(nombre_clase)) = ltrim(rtrim(@nombre_clase))
	
	if(@conteo = 0)
	begin
		insert into clase (nombre_clase)
		values (@nombre_clase)

		select 1 as result
	end
	else
	begin
		select -1 as result
	end
end
else
if(@accion = 'consultar_clase')
begin
	select clase.id_clase,
	clase.nombre_clase 
	from clase
	order by clase.nombre_clase
end
else
if(@accion = 'modificar_clase')
begin
	select @conteo = count(*)
	from clase
	where ltrim(rtrim(nombre_clase)) = ltrim(rtrim(@nombre_clase))
	
	if(@conteo = 0)
	begin
		update clase
		set nombre_clase = @nombre_clase
		where id_clase = @id_clase

		select 3 as result
	end
	else
	begin
		select -3 as result
	end
end
else
if(@accion = 'consultar_eliminacion_clase')
begin
	select count(*) as cantidad
	from clase,
	clase_concepto_contable
	where clase.id_clase = clase_concepto_contable.id_clase
	and clase.id_clase = @id_clase
end
else
if(@accion = 'eliminar_clase')
begin
	delete from clase_concepto_contable
	where id_clase = @id_clase

	delete from clase
	where id_clase = @id_clase
end
else
if(@accion = 'insertar_clase_concepto_contable')
begin
	begin try
		insert into clase_concepto_contable (id_concepto, id_clase, usuario_cobol)
		select concepto_contable.id_concepto,
		clase.id_clase,
		@usuario_cobol
		from concepto_contable,
		clase
		where concepto_contable.idc_concepto = @idc_concepto
		and clase.id_clase = @id_clase

		select 2 as result
	end try
	begin catch
		select -2 as result
	end catch
end
else
if(@accion = 'consultar_clase_concepto_contable')
begin
	select clase.id_clase,
	clase.nombre_clase,
	clase_concepto_contable.id_clase_concepto_contable,
	concepto_contable.idc_concepto,
	concepto_contable.descripcion,
	clase_concepto_contable.fecha_transaccion,
	clase_concepto_contable.usuario_cobol
	from clase,
	clase_concepto_contable,
	concepto_contable
	where clase.id_clase = clase_concepto_contable.id_clase
	and concepto_contable.id_concepto = clase_concepto_contable.id_concepto
	and clase.id_clase > =
	case
		when @id_clase = 0 then 1
		else @id_clase
	end
	and clase.id_clase < =
	case
		when @id_clase = 0 then 99999
		else @id_clase
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
	order by clase.nombre_clase,
	concepto_contable.descripcion
end
else
if(@accion = 'modificar_clase_concepto_contable')
begin
	update clase_concepto_contable
	set id_clase = @id_clase,
	fecha_transaccion = getdate(),
	usuario_cobol = @usuario_cobol
	where clase_concepto_contable.id_clase_concepto_contable = @id_clase_concepto_contable
end
else
if(@accion = 'eliminar_clase_concepto_contable')
begin
	delete from clase_concepto_contable
	where id_clase_concepto_contable = @id_clase_concepto_contable
end