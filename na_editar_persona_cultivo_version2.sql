set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[na_editar_persona_cultivo_version2]

@idc_persona nvarchar(255),
@identificacion nvarchar(255),
@nombre nvarchar(255),
@apellido nvarchar(255),
@idc_supervisor nvarchar(255)
as

declare @conteo int

select @conteo = count(*) from persona where idc_persona = @idc_persona

if(@conteo = 0)
begin
	insert into Persona (idc_persona, nombre, apellido, identificacion, id_supervisor)
	select @idc_persona, @nombre, @apellido, @identificacion, supervisor.id_supervisor
	from supervisor
	where supervisor.idc_supervisor = @idc_supervisor
end
else
begin
	update persona
	set nombre = @nombre,
	apellido = @apellido,
	identificacion = @identificacion,
	id_supervisor = (select supervisor.id_supervisor from supervisor where supervisor.idc_supervisor = @idc_supervisor)
	where idc_persona = @idc_persona
end