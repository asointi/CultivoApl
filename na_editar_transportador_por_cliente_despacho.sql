set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/07/18
-- Description:	Maneja la informacion de los transportadores asignados a los clientes de despacho
-- =============================================

alter PROCEDURE [dbo].[na_editar_transportador_por_cliente_despacho]

@accion nvarchar(255),
@id_despacho int

as 

if(@accion = 'consultar_cliente')
begin
	select cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho + ' [' + ltrim(rtrim(cliente_despacho.nombre_cliente)) + ']' as idc_cliente_despacho
	from cliente_despacho
	where disponible = 1
	order by idc_cliente_despacho
end
else
if(@accion = 'consultar_transportador')
begin
	select transportador.id_transportador,
	transportador.idc_transportador
	from cliente_despacho,
	transportador,
	transportador_por_cliente_despacho
	where cliente_despacho.id_despacho = transportador_por_cliente_despacho.id_despacho
	and transportador.id_transportador = transportador_por_cliente_despacho.id_transportador
	and cliente_despacho.id_despacho = @id_despacho
	group by transportador.id_transportador,
	transportador.idc_transportador
	order by transportador.idc_transportador
end