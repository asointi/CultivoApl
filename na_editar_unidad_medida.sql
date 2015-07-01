set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_unidad_medida]

@accion nvarchar(255),
@nombre_unidad_medida nvarchar(255),
@id_unidad_medida int,
@id_detalle_labor int

AS

declare @conteo int,
@id_unidad_medida_aux int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from unidad_medida
	where ltrim(rtrim(unidad_medida.nombre_unidad_medida)) = ltrim(rtrim(@nombre_unidad_medida))

	if(@conteo = 0)
	begin
		insert into unidad_medida (nombre_unidad_medida)
		values (@nombre_unidad_medida)

		set @id_unidad_medida_aux = scope_identity()

		select @id_unidad_medida_aux as id_unidad_medida
	end
	else
	begin
		select -1 as id_unidad_medida
	end
end
else
if(@accion = 'consultar')
begin
	select unidad_medida.id_unidad_medida,
	unidad_medida.nombre_unidad_medida
	from unidad_medida
	order by unidad_medida.nombre_unidad_medida
end
else
if(@accion = 'actualizar')
begin
	select @conteo = count(*)
	from unidad_medida
	where ltrim(rtrim(unidad_medida.nombre_unidad_medida)) = ltrim(rtrim(@nombre_unidad_medida))

	if(@conteo = 0)
	begin
		update unidad_medida
		set nombre_unidad_medida = @nombre_unidad_medida
		where id_unidad_medida = @id_unidad_medida

		select 2 as id_unidad_medida
	end
	else
	begin
		select -1 as id_unidad_medida
	end
end
else
if(@accion = 'eliminar')
begin
	select @conteo = count(*)
	from unidad_medida,
	detalle_labor
	where unidad_medida.id_unidad_medida = detalle_labor.id_unidad_medida
	and unidad_medida.id_unidad_medida = @id_unidad_medida

	if(@conteo = 0)
	begin
		delete from unidad_medida
		where id_unidad_medida = @id_unidad_medida

		select 3 as id_unidad_medida
	end
	else
	begin
		select -1 as id_unidad_medida
	end
end