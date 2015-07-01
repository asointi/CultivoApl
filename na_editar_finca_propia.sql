set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_finca_propia]

@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select finca_propia.id_finca_propia,
	finca_propia.idc_finca_propia,
	finca_propia.nombre_finca_propia 
	from finca_propia
	where finca_propia.disponible = 1
	order by finca_propia.nombre_finca_propia
end