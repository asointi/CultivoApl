SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[inv_consultar_postcosecha_fincas]

@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select finca_propia.id_finca_propia as id_finca,
	'[' + finca_propia.idc_finca_propia + ']' + space(1) + ltrim(rtrim(finca_propia.nombre_finca_propia)) as nombre_finca
	from finca_propia,
	finca_bloque
	where finca_propia.id_finca_propia = finca_bloque.id_finca_propia
	and finca_propia.disponible = 1
	group by finca_propia.id_finca_propia,
	finca_propia.idc_finca_propia,
	ltrim(rtrim(finca_propia.nombre_finca_propia))
	order by nombre_finca
end 