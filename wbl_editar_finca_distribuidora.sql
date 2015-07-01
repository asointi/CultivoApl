set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2011/08/08
-- Description:	maneja todo lo relacionado con el seguimiento al proceso de Weblabels - (Manipular informacion de Fincas)
-- =============================================

alter PROCEDURE [dbo].[wbl_editar_finca_distribuidora] 

@accion nvarchar(255),
@id_distribuidora int,
@id_impresora int, 
@id_finca_distribuidora int,
@id_finca_distribuidora_contacto int,
@id_finca_distribuidora_usuario_aplicacion int,
@idc_finca nvarchar(255), 
@nombre_finca nvarchar(255), 
@nombre_comercial_finca nvarchar(255), 
@correo_electronico nvarchar(255), 
@nombre_contacto nvarchar(255), 
@usuario_asignado nvarchar(255), 
@telefono_fijo nvarchar(255), 
@telefono_movil  nvarchar(255)

as

declare @conteo int

if(@accion = 'consultar_impresora')
begin
	select impresora.id_impresora,
	impresora.nombre_impresora
	from impresora
	order by impresora.nombre_impresora
end
else
if(@accion = 'consultar_distribuidora')
begin
	select distribuidora.id_distribuidora,
	distribuidora.nombre_distribuidora,
	distribuidora.logo
	from distribuidora
	order by distribuidora.nombre_distribuidora
end
else
if(@accion = 'consultar_finca_fresca')
begin
	select idc_farm,
	'[' + idc_farm + ']' + space(1) + ltrim(rtrim(nombre_farm)) as nombre_farm
	from bd_fresca.dbo.farm
	where disponible = 1
	and not exists
	(
		select *
		from finca_distribuidora,
		distribuidora
		where distribuidora.id_distribuidora = finca_distribuidora.id_distribuidora
		and distribuidora.nombre_distribuidora = 'FRESCA FARMS'
		and farm.idc_farm = finca_distribuidora.idc_finca
	)
	order by idc_farm
end
else
if(@accion = 'consultar_finca_natural')
begin
	select idc_farm,
	'[' + idc_farm + ']' + space(1) + ltrim(rtrim(nombre_farm)) as nombre_farm
	from bd_nf.dbo.farm
	where disponible = 1
	and not exists
	(
		select *
		from finca_distribuidora,
		distribuidora
		where distribuidora.id_distribuidora = finca_distribuidora.id_distribuidora
		and distribuidora.nombre_distribuidora = 'NATURAL FLOWERS'
		and farm.idc_farm = finca_distribuidora.idc_finca
	)
	order by idc_farm
end
else
if(@accion = 'consultar_finca_asignada')
begin
	select finca_distribuidora.id_finca_distribuidora,
	finca_distribuidora.idc_finca,
	'[' + finca_distribuidora.idc_finca + ']' + space(1) + finca_distribuidora.nombre_finca as nombre_finca,
	finca_distribuidora.nombre_comercial_finca,
	impresora.id_impresora,
	impresora.nombre_impresora
	from finca_distribuidora,
	impresora,
	distribuidora
	where impresora.id_impresora = finca_distribuidora.id_impresora
	and distribuidora.id_distribuidora = finca_distribuidora.id_distribuidora
	and distribuidora.id_distribuidora = @id_distribuidora
	order by finca_distribuidora.idc_finca
end
else
if(@accion = 'insertar_finca')
begin
	declare @id_finca_distribuidora_aux int

	insert into finca_distribuidora (id_impresora, id_distribuidora, idc_finca, nombre_finca, nombre_comercial_finca)
	values (@id_impresora, @id_distribuidora, @idc_finca, @nombre_finca, @nombre_comercial_finca)

	set @id_finca_distribuidora_aux = scope_identity()

	select @id_finca_distribuidora_aux as id_finca_distribuidora
end
else
if(@accion = 'actualizar_finca')
begin
	update finca_distribuidora 
	set id_impresora = @id_impresora,
	nombre_comercial_finca = @nombre_comercial_finca
	where finca_distribuidora.id_finca_distribuidora = @id_finca_distribuidora
end
else
if(@accion = 'insertar_contacto_finca')
begin
	select @conteo = count(*)
	from finca_distribuidora_contacto,
	finca_distribuidora
	where finca_distribuidora.id_finca_distribuidora = finca_distribuidora_contacto.id_finca_distribuidora
	and finca_distribuidora.id_finca_distribuidora = @id_finca_distribuidora
	and finca_distribuidora_contacto.correo_electronico = @correo_electronico

	if(@conteo = 0)
	begin
		insert into finca_distribuidora_contacto (id_finca_distribuidora, correo_electronico, nombre_contacto, telefono_fijo, telefono_movil)
		values (@id_finca_distribuidora, @correo_electronico, @nombre_contacto, @telefono_fijo, @telefono_movil)

		select 1 as resultado
	end
	else
	begin
		select -1 as resultado
	end
end
else
if(@accion = 'actualizar_contacto_finca')
begin
	update finca_distribuidora_contacto
	set correo_electronico = @correo_electronico, 
	nombre_contacto = @nombre_contacto, 
	telefono_fijo = @telefono_fijo, 
	telefono_movil = @telefono_movil
	where id_finca_distribuidora_contacto = @id_finca_distribuidora_contacto
end
else
if(@accion = 'eliminar_contacto_finca')
begin
	delete from finca_distribuidora_contacto
	where id_finca_distribuidora_contacto = @id_finca_distribuidora_contacto
end
else
if(@accion = 'consultar_contacto_finca')
begin
	select finca_distribuidora_contacto.id_finca_distribuidora_contacto,
	finca_distribuidora_contacto.correo_electronico,
	finca_distribuidora_contacto.nombre_contacto,
	finca_distribuidora_contacto.telefono_fijo,
	finca_distribuidora_contacto.telefono_movil
	from finca_distribuidora,
	finca_distribuidora_contacto
	where finca_distribuidora.id_finca_distribuidora = finca_distribuidora_contacto.id_finca_distribuidora
	and finca_distribuidora.id_finca_distribuidora = @id_finca_distribuidora
	order by finca_distribuidora_contacto.correo_electronico
end
else
if(@accion = 'insertar_usuario_asignado_finca')
begin
	select @conteo = count(*)
	from finca_distribuidora_usuario_aplicacion,
	finca_distribuidora
	where finca_distribuidora.id_finca_distribuidora = finca_distribuidora_usuario_aplicacion.id_finca_distribuidora
	and finca_distribuidora.id_finca_distribuidora = @id_finca_distribuidora
	and finca_distribuidora_usuario_aplicacion.usuario_asignado = @usuario_asignado

	if(@conteo = 0)
	begin
	insert into finca_distribuidora_usuario_aplicacion (id_finca_distribuidora, usuario_asignado)
	values (@id_finca_distribuidora, @usuario_asignado)

		select 1 as resultado
	end
	else
	begin
		select -1 as resultado
	end
end
else
if(@accion = 'actualizar_usuario_asignado_finca')
begin
	update finca_distribuidora_usuario_aplicacion
	set usuario_asignado = @usuario_asignado 
	where id_finca_distribuidora_usuario_aplicacion = @id_finca_distribuidora_usuario_aplicacion
end
else
if(@accion = 'eliminar_usuario_asignado_finca')
begin
	delete from finca_distribuidora_usuario_aplicacion
	where id_finca_distribuidora_usuario_aplicacion = @id_finca_distribuidora_usuario_aplicacion
end
else
if(@accion = 'consultar_usuario_asignado_finca')
begin
	select finca_distribuidora_usuario_aplicacion.id_finca_distribuidora_usuario_aplicacion,
	finca_distribuidora_usuario_aplicacion.usuario_asignado
	from finca_distribuidora,
	finca_distribuidora_usuario_aplicacion
	where finca_distribuidora.id_finca_distribuidora = finca_distribuidora_usuario_aplicacion.id_finca_distribuidora
	and finca_distribuidora.id_finca_distribuidora = @id_finca_distribuidora
	order by finca_distribuidora_usuario_aplicacion.usuario_asignado
end