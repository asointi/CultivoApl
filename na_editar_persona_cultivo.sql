set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

create PROCEDURE [dbo].[na_editar_persona_cultivo]

@idc_persona nvarchar(255),
@identificacion nvarchar(255),
@nombre nvarchar(255),
@apellido nvarchar(255)
as

declare @conteo int

select @conteo = count(*) from persona where idc_persona = @idc_persona

if(@conteo = 0)
begin
	insert into Persona (idc_persona, nombre, apellido, identificacion)
	values (@idc_persona, @nombre, @apellido, @identificacion)
end
else
begin
	update persona
	set nombre = @nombre,
	apellido = @apellido,
	identificacion = @identificacion
	where idc_persona = @idc_persona
end