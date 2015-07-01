set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/11
-- Description:	maneja todo lo relacionado con el proceso de instalacion de Weblabels - (Manipular informacion de Instalacion)
-- =============================================

alter PROCEDURE [dbo].[wbl_editar_proceso_instalacion_finca] 

@accion nvarchar(255),
@id_estado_finca int, 
@id_finca_distribuidora int, 
@id_cuenta_interna int, 
@comentario nvarchar(1024),
@id_distribuidora int

as

if(@accion = 'consultar_estado_finca')
begin
	select estado_finca.id_estado_finca,
	estado_finca.nombre_estado_finca
	from estado_finca
	where estado_finca.id_estado_finca > = 
	case
		when @id_estado_finca = 0 then 1
		else @id_estado_finca
	end
	and  estado_finca.id_estado_finca < = 
	case
		when @id_estado_finca = 0 then 10
		else @id_estado_finca
	end
end
else
if(@accion = 'insertar_proceso_instalacion_finca')
begin
	insert proceso_instalacion_finca (id_estado_finca, id_finca_distribuidora, id_cuenta_interna, comentario)
	values (@id_estado_finca, @id_finca_distribuidora, @id_cuenta_interna, @comentario)
end
else
if(@accion = 'consultar_proceso_instalacion_finca')
begin
	if(@id_estado_finca > 0)
	begin
		select finca_distribuidora.idc_finca,
		max(proceso_instalacion_finca.id_proceso_instalacion_finca) as id_proceso_instalacion_finca into #temp
		from proceso_instalacion_finca,
		finca_distribuidora,
		distribuidora
		where distribuidora.id_distribuidora = finca_distribuidora.id_distribuidora
		and finca_distribuidora.id_finca_distribuidora = proceso_instalacion_finca.id_finca_distribuidora
		and distribuidora.id_distribuidora = @id_distribuidora
		group by finca_distribuidora.idc_finca

		select	finca_distribuidora.id_finca_distribuidora,
		finca_distribuidora.nombre_finca,
		impresora.id_impresora,
		impresora.nombre_impresora,
		estado_finca.id_estado_finca,
		estado_finca.nombre_estado_finca,
		cuenta_interna.nombre as nombre_cuenta,
		proceso_instalacion_finca.id_proceso_instalacion_finca,
		proceso_instalacion_finca.fecha_transaccion,
		proceso_instalacion_finca.comentario
		from proceso_instalacion_finca,
		estado_finca,
		cuenta_interna,
		finca_distribuidora,
		impresora,
		distribuidora
		where estado_finca.id_estado_finca = proceso_instalacion_finca.id_estado_finca
		and cuenta_interna.id_cuenta_interna = proceso_instalacion_finca.id_cuenta_interna
		and finca_distribuidora.id_finca_distribuidora = proceso_instalacion_finca.id_finca_distribuidora
		and finca_distribuidora.id_impresora = impresora.id_impresora
		and finca_distribuidora.id_distribuidora = distribuidora.id_distribuidora
		and distribuidora.id_distribuidora = @id_distribuidora
		and estado_finca.id_estado_finca = @id_estado_finca
		and exists
		(
			select *
			from #temp
			where #temp.id_proceso_instalacion_finca = proceso_instalacion_finca.id_proceso_instalacion_finca
		)

		drop table #temp

	end
	else
	if(@id_estado_finca = 0)
	begin
		select	finca_distribuidora.id_finca_distribuidora,
		finca_distribuidora.nombre_finca,
		impresora.id_impresora,
		impresora.nombre_impresora,
		0 as id_estado_finca,
		'' as nombre_estado_finca,
		'' as nombre_cuenta,
		0 as id_proceso_instalacion_finca,
		'' as fecha_transaccion,
		'' as comentario
		from finca_distribuidora,
		impresora,
		distribuidora
		where finca_distribuidora.id_impresora = impresora.id_impresora
		and finca_distribuidora.id_distribuidora = distribuidora.id_distribuidora
		and distribuidora.id_distribuidora = @id_distribuidora
		and not exists
		(
			select *
			from proceso_instalacion_finca
			where finca_distribuidora.id_finca_distribuidora = proceso_instalacion_finca.id_finca_distribuidora
		)
	end
end