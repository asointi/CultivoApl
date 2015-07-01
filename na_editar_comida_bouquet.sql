set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_comida_bouquet] 

@accion nvarchar(50),
@nombre_comida nvarchar(255), 
@id_comida_bouquet int

as

declare @conteo int

if(@accion = 'consultar')
begin
	select comida_bouquet.id_comida_bouquet,
	comida_bouquet.nombre_comida
	from comida_bouquet
	order by comida_bouquet.nombre_comida
end
else
if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from comida_bouquet
	where nombre_comida = ltrim(rtrim(@nombre_comida))

	if(@conteo = 0)
	begin
		insert into comida_bouquet (nombre_comida)
		values (ltrim(rtrim(@nombre_comida)))

		select 1 as resultado
	end
	else
	begin
		select -1 as resultado
	end
end
else
if(@accion = 'modificar')
begin
	update comida_bouquet
	set nombre_comida = ltrim(rtrim(@nombre_comida))
	where id_comida_bouquet = @id_comida_bouquet
end
else
if(@accion = 'eliminar')
begin
--	select @conteo = count(*)
--	from comida_bouquet
--	where id_comida_bouquet = @id_comida_bouquet
	set @conteo = 0

	if(@conteo = 0)
	begin
		delete from comida_bouquet
		where id_comida_bouquet = @id_comida_bouquet

		select 2 as resultado
	end
	else
	begin
		select -2 as resultado
	end
end