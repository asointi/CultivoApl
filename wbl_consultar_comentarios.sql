set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/11
-- Description:	Consulta los comentarios que se van dando a traves del proceso de instalacion y/o reportes de novedades
-- =============================================

create PROCEDURE [dbo].[wbl_consultar_comentarios] 

@id_finca_distribuidora int,
@id_reporte_finca_distribuidora int

as

if(@id_reporte_finca_distribuidora is null)
begin
	select estado_finca.id_estado_finca,
	estado_finca.nombre_estado_finca,
	cuenta_interna.nombre as nombre_cuenta,
	proceso_instalacion_finca.fecha_transaccion,
	proceso_instalacion_finca.comentario 
	from proceso_instalacion_finca,
	finca_distribuidora,
	estado_finca,
	cuenta_interna
	where finca_distribuidora.id_finca_distribuidora = proceso_instalacion_finca.id_finca_distribuidora
	and finca_distribuidora.id_finca_distribuidora = @id_finca_distribuidora
	and estado_finca.id_estado_finca = proceso_instalacion_finca.id_estado_finca
	and cuenta_interna.id_cuenta_interna = proceso_instalacion_finca.id_cuenta_interna
	order by estado_finca.id_estado_finca
end
else
begin
	declare @id_reporte_finca_distribuidora_padre int

	select @id_reporte_finca_distribuidora_padre = id_reporte_finca_distribuidora_padre
	from reporte_finca_distribuidora
	where reporte_finca_distribuidora.id_reporte_finca_distribuidora = @id_reporte_finca_distribuidora

	select estado_reporte_finca.id_estado_reporte_finca,
	estado_reporte_finca.nombre_estado_reporte_finca,
	cuenta_interna.nombre as nombre_cuenta,
	reporte_finca_distribuidora.fecha_transaccion,
	reporte_finca_distribuidora.comentario 
	from reporte_finca_distribuidora,
	cuenta_interna,
	estado_reporte_finca
	where reporte_finca_distribuidora.id_reporte_finca_distribuidora_padre = @id_reporte_finca_distribuidora_padre
	and estado_reporte_finca.id_estado_reporte_finca = reporte_finca_distribuidora.id_estado_reporte_finca
	and cuenta_interna.id_cuenta_interna = reporte_finca_distribuidora.id_cuenta_interna
end