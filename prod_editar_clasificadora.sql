set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_editar_clasificadora]

@accion nvarchar(255),
@id_clasificadora nvarchar(255)

as

if (@id_clasificadora is null)
	set @id_clasificadora = '%%'

if(@accion = 'consultar')
begin
	select id_clasificadora,
	nombre_clasificadora,
	ubicacion,
	direccion_ip,
	numero_puerto 
	from clasificadora
	where id_clasificadora like @id_clasificadora
	order by nombre_clasificadora
end