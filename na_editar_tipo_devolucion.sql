set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_tipo_devolucion]

@accion nvarchar(255),
@nombre_tipo_devolucion nvarchar(255),
@id_tipo_devolucion int

AS

declare @conteo int,
@id_tipo_devolucion_aux int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from tipo_devolucion
	where ltrim(rtrim(tipo_devolucion.nombre_tipo_devolucion)) = ltrim(rtrim(@nombre_tipo_devolucion))

	if(@conteo = 0)
	begin
		insert into tipo_devolucion (nombre_tipo_devolucion)
		values (@nombre_tipo_devolucion)

		set @id_tipo_devolucion_aux = scope_identity()

		select @id_tipo_devolucion_aux as id_tipo_devolucion
	end
	else
	begin
		select -1 as id_tipo_devolucion
	end
end
else
if(@accion = 'consultar')
begin
	select tipo_devolucion.id_tipo_devolucion,
	tipo_devolucion.nombre_tipo_devolucion
	from tipo_devolucion
	where nombre_tipo_devolucion <> 'Anterior'
	order by tipo_devolucion.nombre_tipo_devolucion
end
else
if(@accion = 'actualizar')
begin
	select @conteo = count(*)
	from tipo_devolucion
	where ltrim(rtrim(tipo_devolucion.nombre_tipo_devolucion)) = ltrim(rtrim(@nombre_tipo_devolucion))

	if(@conteo = 0)
	begin
		update tipo_devolucion
		set nombre_tipo_devolucion = @nombre_tipo_devolucion
		where id_tipo_devolucion = @id_tipo_devolucion

		select 2 as id_tipo_devolucion
	end
	else
	begin
		select -1 as id_tipo_devolucion
	end
end
else
if(@accion = 'eliminar')
begin
	select @conteo = count(*)
	from tipo_devolucion,
	ramo_devuelto
	where tipo_devolucion.id_tipo_devolucion = ramo_devuelto.id_tipo_devolucion
	and tipo_devolucion.id_tipo_devolucion = @id_tipo_devolucion

	if(@conteo = 0)
	begin
		delete from tipo_devolucion
		where id_tipo_devolucion = @id_tipo_devolucion

		select 3 as id_tipo_devolucion
	end
	else
	begin
		select -1 as id_tipo_devolucion
	end
end