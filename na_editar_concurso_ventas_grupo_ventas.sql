set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_concurso_ventas_grupo_ventas]

@accion nvarchar(255),
@nombre_grupo_ventas nvarchar(255),
@dolares_vendidos decimal(20,4),
@id_grupo_ventas int,
@idc_vendedor nvarchar(10)

AS

declare @conteo int

if(@accion = 'insertar_grupo_ventas')
begin
	select @conteo = count(*)
	from grupo_ventas
	where ltrim(rtrim(grupo_ventas.nombre_grupo_ventas)) = ltrim(rtrim(@nombre_grupo_ventas))

	if(@conteo = 0)
	begin 
		declare @id_grupo_ventas_aux int
		
		insert into grupo_ventas (nombre_grupo_ventas)
		values (@nombre_grupo_ventas)

		set @id_grupo_ventas_aux = scope_identity()

		select @id_grupo_ventas_aux as id_grupo_ventas
	end
	else
	begin
		select 0 as id_grupo_ventas
	end
end
else
if(@accion = 'actualizar_grupo_ventas')
begin
	update grupo_ventas
	set dolares_vendidos = @dolares_vendidos,
	nombre_grupo_ventas = @nombre_grupo_ventas
	where grupo_ventas.id_grupo_ventas = @id_grupo_ventas
end
else
if(@accion = 'consultar_grupo_ventas')
begin
	select id_grupo_ventas,
	nombre_grupo_ventas,
	dolares_vendidos
	from grupo_ventas
	order by nombre_grupo_ventas
end
else
if(@accion = 'insertar_grupo_ventas_asignado')
begin
	select @conteo = count(*)
	from grupo_ventas_asignado,
	vendedor
	where grupo_ventas_asignado.id_vendedor = vendedor.id_vendedor
	and ltrim(rtrim(vendedor.idc_vendedor)) = ltrim(rtrim(@idc_vendedor))

	if(@conteo = 0)
	begin 
		insert into grupo_ventas_asignado (id_grupo_ventas, id_vendedor)
		select @id_grupo_ventas, vendedor.id_vendedor
		from vendedor
		where ltrim(rtrim(vendedor.idc_vendedor)) = ltrim(rtrim(@idc_vendedor))

		select 1 as id_grupo_ventas_asignado
	end
	else
	begin
		select 0 as id_grupo_ventas_asignado
	end
end
else
if(@accion = 'eliminar_grupo_ventas_asignado')
begin
	delete from grupo_ventas_asignado
	where grupo_ventas_asignado.id_vendedor =
	(
		select id_vendedor
		from vendedor
		where ltrim(rtrim(vendedor.idc_vendedor)) = ltrim(rtrim(@idc_vendedor))		
	)
end
else
if(@accion = 'eliminar_grupo_ventas')
begin
	delete from grupo_ventas
	where id_grupo_ventas = @id_grupo_ventas
end
else
if(@accion = 'consultar_grupo_ventas_asignado')
begin
	select grupo_ventas.id_grupo_ventas,
	grupo_ventas.nombre_grupo_ventas,
	grupo_ventas.dolares_vendidos,
	vendedor.idc_vendedor,
	ltrim(rtrim(vendedor.nombre)) as nombre_vendedor
	from grupo_ventas,
	grupo_ventas_asignado,
	vendedor
	where grupo_ventas.id_grupo_ventas = grupo_ventas_asignado.id_grupo_ventas
	and vendedor.id_vendedor = grupo_ventas_asignado.id_vendedor
	and grupo_ventas.id_grupo_ventas > = 
	case
		when @id_grupo_ventas = 0 then 1
		else @id_grupo_ventas
	end
	and grupo_ventas.id_grupo_ventas < = 
	case
		when @id_grupo_ventas = 0 then 9999999
		else @id_grupo_ventas
	end
	order by grupo_ventas.nombre_grupo_ventas,
	nombre_vendedor
end