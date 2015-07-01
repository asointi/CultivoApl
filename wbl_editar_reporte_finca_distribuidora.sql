set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/18
-- Description:	maneja todo lo relacionado con el proceso de reportes de atencion de Weblabels - (Manipular informacion de Reportes de Novedades)
-- =============================================

create PROCEDURE [dbo].[wbl_editar_reporte_finca_distribuidora] 

@accion nvarchar(255),
@id_estado_reporte_finca int,
@id_finca_distribuidora int, 
@id_cuenta_interna int, 
@comentario nvarchar(1024),
@id_distribuidora int,
@id_tipo_atencion int,
@nombre_tipo_atencion nvarchar(255),
@id_reporte_finca_distribuidora int

as

declare @id_reporte_finca_distribuidora_aux int

if(@accion = 'consultar_estado_reporte_finca')
begin
	select estado_reporte_finca.id_estado_reporte_finca,
	estado_reporte_finca.nombre_estado_reporte_finca 
	from estado_reporte_finca
	where estado_reporte_finca.id_estado_reporte_finca > = 
	case 
		when @id_estado_reporte_finca = 0 then 1
		else @id_estado_reporte_finca
	end
	and estado_reporte_finca.id_estado_reporte_finca < = 
	case 
		when @id_estado_reporte_finca = 0 then 99
		else @id_estado_reporte_finca
	end 
	order by estado_reporte_finca.id_estado_reporte_finca
end
else
if(@accion = 'insertar_reporte_finca_distribuidora')
begin
	if(@id_reporte_finca_distribuidora = 0)
	begin
		insert into reporte_finca_distribuidora (id_estado_reporte_finca, id_finca_distribuidora, id_cuenta_interna, comentario, id_tipo_atencion)
		values (@id_estado_reporte_finca, @id_finca_distribuidora, @id_cuenta_interna, @comentario, @id_tipo_atencion)

		set @id_reporte_finca_distribuidora_aux = scope_identity()

		update reporte_finca_distribuidora	
		set id_reporte_finca_distribuidora_padre = @id_reporte_finca_distribuidora_aux
		where id_reporte_finca_distribuidora = @id_reporte_finca_distribuidora_aux
	end
	else
	begin
		select @id_reporte_finca_distribuidora_aux = reporte_finca_distribuidora.id_reporte_finca_distribuidora_padre
		from reporte_finca_distribuidora
		where id_reporte_finca_distribuidora = @id_reporte_finca_distribuidora

		insert into reporte_finca_distribuidora (id_estado_reporte_finca, id_finca_distribuidora, id_cuenta_interna, comentario, id_tipo_atencion, id_reporte_finca_distribuidora_padre)
		values (@id_estado_reporte_finca, @id_finca_distribuidora, @id_cuenta_interna, @comentario, @id_tipo_atencion, @id_reporte_finca_distribuidora_aux)
	end
end
else
if(@accion = 'consultar_reporte_finca_distribuidora')
begin
	select reporte_finca_distribuidora.id_reporte_finca_distribuidora,
	estado_reporte_finca.id_estado_reporte_finca,
	estado_reporte_finca.nombre_estado_reporte_finca,
	finca_distribuidora.id_finca_distribuidora,
	finca_distribuidora.idc_finca,
	finca_distribuidora.nombre_finca,
	impresora.id_impresora,
	impresora.nombre_impresora,
	distribuidora.id_distribuidora,
	distribuidora.nombre_distribuidora,
	cuenta_interna.id_cuenta_interna,
	cuenta_interna.nombre as nombre_cuenta,
	reporte_finca_distribuidora.fecha_transaccion,
	reporte_finca_distribuidora.comentario,
	tipo_atencion.id_tipo_atencion,
	tipo_atencion.nombre_tipo_atencion
	from reporte_finca_distribuidora,
	reporte_finca_distribuidora as rfd,
	estado_reporte_finca,
	finca_distribuidora,
	impresora,
	distribuidora,
	cuenta_interna,
	tipo_atencion
	where impresora.id_impresora = finca_distribuidora.id_impresora
	and distribuidora.id_distribuidora = finca_distribuidora.id_distribuidora
	and finca_distribuidora.id_finca_distribuidora = reporte_finca_distribuidora.id_finca_distribuidora
	and cuenta_interna.id_cuenta_interna = reporte_finca_distribuidora.id_cuenta_interna
	and estado_reporte_finca.id_estado_reporte_finca = reporte_finca_distribuidora.id_estado_reporte_finca
	and tipo_atencion.id_tipo_atencion = reporte_finca_distribuidora.id_tipo_atencion
	and estado_reporte_finca.id_estado_reporte_finca = @id_estado_reporte_finca
	and distribuidora.id_distribuidora = @id_distribuidora
	and reporte_finca_distribuidora.id_reporte_finca_distribuidora < = rfd.id_reporte_finca_distribuidora
	and reporte_finca_distribuidora.id_reporte_finca_distribuidora_padre = rfd.id_reporte_finca_distribuidora_padre
	group by reporte_finca_distribuidora.id_reporte_finca_distribuidora,
	estado_reporte_finca.id_estado_reporte_finca,
	estado_reporte_finca.nombre_estado_reporte_finca,
	finca_distribuidora.id_finca_distribuidora,
	finca_distribuidora.idc_finca,
	finca_distribuidora.nombre_finca,
	impresora.id_impresora,
	impresora.nombre_impresora,
	distribuidora.id_distribuidora,
	distribuidora.nombre_distribuidora,
	cuenta_interna.id_cuenta_interna,
	cuenta_interna.nombre,
	reporte_finca_distribuidora.fecha_transaccion,
	reporte_finca_distribuidora.comentario,
	tipo_atencion.id_tipo_atencion,
	tipo_atencion.nombre_tipo_atencion
	having
	reporte_finca_distribuidora.id_reporte_finca_distribuidora = max(rfd.id_reporte_finca_distribuidora)
end
if(@accion = 'consultar_finca_distribuidora')
begin
	select finca_distribuidora.id_finca_distribuidora,
	'[' + finca_distribuidora.idc_finca + ']' + space(1) + finca_distribuidora.nombre_finca as nombre_finca
	from finca_distribuidora,
	proceso_instalacion_finca,
	estado_finca,
	distribuidora
	where estado_finca.id_estado_finca = proceso_instalacion_finca.id_estado_finca
	and finca_distribuidora.id_finca_distribuidora = proceso_instalacion_finca.id_finca_distribuidora
	and estado_finca.id_estado_finca = 4
	and distribuidora.id_distribuidora = finca_distribuidora.id_distribuidora
	and distribuidora.id_distribuidora = @id_distribuidora
	order by finca_distribuidora.idc_finca
end
else
if(@accion = 'consultar_tipo_atencion')
begin
	select tipo_atencion.id_tipo_atencion,
	tipo_atencion.nombre_tipo_atencion 
	from tipo_atencion
	order by tipo_atencion.nombre_tipo_atencion
end
else
if(@accion = 'insertar_tipo_atencion')
begin
	declare @conteo int	

	select @conteo = count(*)
	from tipo_atencion
	where ltrim(rtrim(nombre_tipo_atencion)) = ltrim(rtrim(@nombre_tipo_atencion))

	if(@conteo = 0)
	begin
		insert into tipo_atencion (nombre_tipo_atencion)
		values (@nombre_tipo_atencion)

		select 1 as id_tipo_atencion
	end
	else
	begin
		select -1 as id_tipo_atencion
	end
end