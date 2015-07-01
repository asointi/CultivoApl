set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[bouquet_editar_formato_upc] 

@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select id_formato_upc,
	nombre_formato 
	from formato_upc
	order by nombre_formato
end
