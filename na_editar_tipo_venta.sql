set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_tipo_venta]

@accion nvarchar(255)

AS

if(@accion = 'consultar')
begin
	select id_tipo_venta,
	nombre_tipo_venta 
	from tipo_venta
	order by nombre_tipo_venta
end