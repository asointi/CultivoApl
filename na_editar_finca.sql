set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_finca]

@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select finca.id_finca,
	finca.idc_finca,
	finca.nombre_finca + space(1) + '[' + finca.idc_finca + ']' as nombre_finca,
	'[' + finca.idc_finca + ']' + space(1) + ltrim(rtrim(finca.nombre_finca)) as nombre_completo
	from finca
	order by finca.nombre_finca
end