set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_usuario_cobol_web]

@accion nvarchar(255),
@id_usuario_cobol nvarchar(255),
@cliente_usuario_cobol int,
@id_despacho int,
@@control int output

as

declare @conteo int

if(@id_usuario_cobol is null)
	set @id_usuario_cobol = '%%'

if(@accion = 'consultar_usuario')
begin
	select id_usuario_cobol,
	login,
	ltrim(rtrim(login)) + space(1) + '[' + ltrim(rtrim(nombre)) + ']' as nombre
	from usuario_cobol
	order by login
end
else
if(@accion = 'consultar_usuario_cliente')
begin
	select cliente_usuario_cobol.id_cliente_usuario_cobol,
	usuario_cobol.login,
	usuario_cobol.nombre,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente
	from usuario_cobol,
	cliente_usuario_cobol,
	cliente_despacho
	where usuario_cobol.id_usuario_cobol = cliente_usuario_cobol.id_usuario_cobol
	and cliente_despacho.id_despacho = cliente_usuario_cobol.id_despacho
	and usuario_cobol.id_usuario_cobol like @id_usuario_cobol
	order by usuario_cobol.login,
	cliente_despacho.idc_cliente_despacho
end
else
if(@accion = 'eliminar_usuario_cliente')
begin
	delete from cliente_usuario_cobol 
	where id_cliente_usuario_cobol = @cliente_usuario_cobol
end
else
if(@accion = 'insertar_usuario_cliente')
begin
	select @conteo = count(*)
	from usuario_cobol,
	cliente_usuario_cobol,
	cliente_despacho
	where usuario_cobol.id_usuario_cobol = cliente_usuario_cobol.id_usuario_cobol
	and cliente_despacho.id_despacho = cliente_usuario_cobol.id_despacho
	and usuario_cobol.id_usuario_cobol = convert(int, @id_usuario_cobol)
	and cliente_despacho.id_despacho = @id_despacho

	if(@conteo = 0)
	begin
		insert into cliente_usuario_cobol (id_usuario_cobol, id_despacho)
		values(convert(int,@id_usuario_cobol), @id_despacho)

		set @@control = 1
		return @@control 
	end
	else
	begin
		set @@control = -2
		return @@control 
	end
end