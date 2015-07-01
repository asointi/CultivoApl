set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_ramo]

@fecha_inicial nvarchar(255),
@fecha_final nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select count(ramo.id_ramo) as cantidad_ramos,
	sum(ramo.tallos_por_ramo) as cantidad_tallos
	from ramo
	where convert(datetime,convert(nvarchar, fecha_entrada,101)) between
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
end