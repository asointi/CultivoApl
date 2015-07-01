/****** Object:  StoredProcedure [dbo].[awb_consultar_terminal_de_guia]    Script Date: 10/06/2007 10:52:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[na_editar_persona]

@id_persona nvarchar(255),
@nombre_persona nvarchar(255),
@accion nvarchar(255)

AS

if(@id_persona is null)
	set @id_persona = '%%'

if(@accion = 'insertar')
begin
	if(ltrim(rtrim(@nombre_persona)) not in (select ltrim(rtrim(nombre_persona)) from persona))
	begin
		insert into persona (nombre_persona)
		values (@nombre_persona)
		return scope_identity()
	end
	else
		return -1
end
else
if(@accion = 'modificar')
begin
	update persona
	set nombre_persona = @nombre_persona
	where id_persona like @id_persona
end
else
if(@accion = 'consultar')
begin
	select id_persona, 
	nombre_persona
	from persona
	where id_persona like @id_persona
end