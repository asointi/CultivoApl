set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_supervisor]

@idc_supervisor nvarchar(255),
@nombre_supervisor nvarchar(255)

as

declare @conteo int

select @conteo = count(*)
from supervisor
where supervisor.idc_supervisor = @idc_supervisor

if(@conteo = 0)
begin
	insert into supervisor (idc_supervisor, nombre_supervisor)
	values (@idc_supervisor, @nombre_supervisor)
end
else
begin
	update supervisor
	set nombre_supervisor = @nombre_supervisor
	where idc_supervisor = @idc_supervisor
end