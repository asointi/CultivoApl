set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_capuchon_comercializadora] 

@accion nvarchar(50),
@nombre_capuchon nvarchar(255), 
@decorado bit, 
@descripcion nvarchar(512),
@id_capuchon int

as

declare @conteo int

if(@accion = 'consultar')
begin
	select capuchon.id_capuchon,
	capuchon.nombre_capuchon,
	capuchon.decorado,
	capuchon.descripcion 
	from capuchon
	order by capuchon.nombre_capuchon
end
else
if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from capuchon
	where nombre_capuchon = ltrim(rtrim(@nombre_capuchon))

	if(@conteo = 0)
	begin
		insert into capuchon (nombre_capuchon, decorado, descripcion)
		values (ltrim(rtrim(@nombre_capuchon)), @decorado, ltrim(rtrim(@descripcion)))

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
	update capuchon
	set nombre_capuchon = ltrim(rtrim(@nombre_capuchon)),
	decorado = @decorado,
	descripcion = ltrim(rtrim(@descripcion))
	where id_capuchon = @id_capuchon
end
else
if(@accion = 'eliminar')
begin
--	select @conteo = count(*)
--	from capuchon
--	where id_capuchon = @id_capuchon
	set @conteo = 0

	if(@conteo = 0)
	begin
		delete from capuchon
		where id_capuchon = @id_capuchon

		select 2 as resultado
	end
	else
	begin
		select -2 as resultado
	end
end