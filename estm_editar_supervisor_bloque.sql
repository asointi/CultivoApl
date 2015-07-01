set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[estm_editar_supervisor_bloque]

@id_supervisor nvarchar(255), 
@id_bloque nvarchar(255), 
@area decimal(20,4), 
@accion nvarchar(255)

as

if(@id_supervisor is null)
	set @id_supervisor = '%%'
if(@id_bloque is null)
	set @id_bloque = '%%'

if(@accion = 'consultar')
begin
	select bloque.id_bloque,
	bloque.idc_bloque,
	bloque.area,
	supervisor.id_supervisor,
	supervisor.idc_supervisor,
	isnull('[' + supervisor.idc_supervisor + ']' + space(1) + supervisor.nombre_supervisor, 'Sin Supervisor') as nombre_supervisor
	from 
	bloque left join supervisor 
	on bloque.id_supervisor = supervisor.id_supervisor
	where bloque.id_bloque like @id_bloque
	--and supervisor.id_supervisor like @id_supervisor
	and bloque.disponible = 1
	--and supervisor.disponible = 1
	order by bloque.idc_bloque,
	supervisor.idc_supervisor
end
else
if(@accion = 'consultar_bloque')
begin
	select id_bloque, 
	idc_bloque 
	from bloque
	where bloque.disponible = 1
	order by idc_bloque 
end
else
if(@accion = 'consultar_supervisor')
begin
	select supervisor.id_supervisor, 
	supervisor.idc_supervisor, 
	'[' + supervisor.idc_supervisor + ']' + space(1) + supervisor.nombre_supervisor as nombre_supervisor
	from supervisor
	where supervisor.disponible = 1
	order by supervisor.idc_supervisor 
end
else
if(@accion = 'modificar')
begin
	update bloque
	set area = @area
	where bloque.id_bloque = @id_bloque	
end