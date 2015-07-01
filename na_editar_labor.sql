set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[na_editar_labor]

@accion nvarchar(255)

AS

if(@accion = 'consultar')
begin
	select labor.id_labor,
	labor.idc_labor,
	ltrim(rtrim(labor.nombre_labor)) as nombre_labor 
	from labor
	order by nombre_labor 
end