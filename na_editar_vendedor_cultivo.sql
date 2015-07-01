set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_vendedor_cultivo]

@accion nvarchar(255),
@id_distribuidora int

as

if(@accion = 'consultar_vendedor')
begin
	select id_vendedor, 
	idc_vendedor,
	nombre as nombre_vendedor,
	distribuidora.nombre_distribuidora
	from vendedor,
	distribuidora
	where vendedor.id_distribuidora = distribuidora.id_distribuidora
	order by distribuidora.nombre_distribuidora,
	vendedor.idc_vendedor
end
else
if(@accion = 'consultar_distribuidora')
begin
	select id_distribuidora,
	nombre_distribuidora 
	from distribuidora
	order by nombre_distribuidora 
end
