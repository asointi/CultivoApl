set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[na_editar_persona]

@id_persona nvarchar(255),
@nombre_persona nvarchar(255),
@accion nvarchar(255),
@impresora_salida int

AS

if(@id_persona is null)
	set @id_persona = '%%'

if(@accion = 'insertar')
begin
	if(ltrim(rtrim(@nombre_persona)) not in (select ltrim(rtrim(nombre_persona)) from persona))
	begin
		insert into persona (nombre_persona, impresora_salida)
		values (@nombre_persona, @impresora_salida)
		return scope_identity()
	end
	else
		return -1
end
else
if(@accion = 'modificar')
begin
	update persona
	set nombre_persona = @nombre_persona,
	impresora_salida = @impresora_salida
	where id_persona = @id_persona
end
else
if(@accion = 'consultar')
begin
	select id_persona, 
	nombre_persona,
	impresora_salida
	from persona
	where id_persona = @id_persona
end



