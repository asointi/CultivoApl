set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_temperatura_camion]

@accion nvarchar(255),
@placa nvarchar(255),
@temperatura decimal(20,4),
@fecha datetime,
@lugar nvarchar(255),
@conductor nvarchar(255),
@direccion nvarchar(255),
@ciudad nvarchar(255),
@evento nvarchar(255)

as

if(@accion = 'eliminar_tabla')
begin
	drop table bd_cultivo_temp.dbo.temperatura_coltrack

	create table bd_cultivo_temp.dbo.temperatura_coltrack
	(
		id int Identity(1,1) NOT NULL,
		placa nvarchar(255),
		temperatura decimal(20,4),
		fecha datetime,
		lugar nvarchar(255),
		conductor nvarchar(255),
		direccion nvarchar(255),
		ciudad nvarchar(255),
		evento nvarchar(255)
	)

	select 1 as eliminado
end
else
if(@accion = 'insertar')
begin	
	insert into bd_cultivo_temp.dbo.temperatura_coltrack
	(
		placa,
		temperatura,
		fecha,
		lugar,
		conductor,
		direccion,
		ciudad,
		evento
	)
	values 
	(
		@placa,
		@temperatura,
		@fecha,
		@lugar,
		@conductor,
		@direccion,
		@ciudad,
		@evento
	)

	select scope_identity() as id_temperatura_coltrack
end