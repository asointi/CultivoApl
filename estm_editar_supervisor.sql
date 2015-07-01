set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_editar_supervisor]

@idc_supervisor nvarchar(255), 
@nombre_supervisor nvarchar(255), 
@accion nvarchar(255)


as

if(@idc_supervisor = '')
	set @idc_supervisor = '%%'

if(@accion = 'insertar')
begin
	if(@idc_supervisor not in (select idc_supervisor from supervisor))
	begin
		insert into supervisor (idc_supervisor, nombre_supervisor)
		values (@idc_supervisor, @nombre_supervisor)
	end
end
else
if(@accion = 'modificar')
begin
	update supervisor
	set nombre_supervisor = @nombre_supervisor
	where idc_supervisor = @idc_supervisor
end
else
if(@accion = 'consultar')
begin
	select idc_supervisor,
	nombre_supervisor
	from supervisor
	where idc_supervisor like @idc_supervisor
	and disponible = 1
	order by idc_supervisor
end
