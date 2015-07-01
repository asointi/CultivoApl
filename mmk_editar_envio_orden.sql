set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[mmk_editar_envio_orden] 

@id_farm int,
@archivo image, 
@extension_archivo nvarchar(255),
@id_cuenta_interna int, 
@fecha_vuelo datetime,
@cantidad_piezas int,
@accion nvarchar(50),
@numero_solicitud int,
@po_number nvarchar(255),
@marca nvarchar(25),
@nombre_hoja nvarchar(255)

as

if(@accion = 'crear_detalle')
begin
	insert into detalle_solicitud_confirmacion_mass_market (numero_solicitud, id_farm, fecha_vuelo, cantidad_piezas, marca, nombre_hoja)
	select solicitud_confirmacion_mass_market.numero_solicitud,
	farm.id_farm,
	@fecha_vuelo, 
	@cantidad_piezas,
	@marca, 
	@nombre_hoja
	from solicitud_confirmacion_mass_market,
	farm
	where solicitud_confirmacion_mass_market.numero_solicitud = @numero_solicitud
	and farm.id_farm = solicitud_confirmacion_mass_market.id_farm
	and farm.id_farm = @id_farm

	select scope_identity() as id_detalle_solicitud_confirmacion_mass_market
end
else
if(@accion = 'generar_consecutivo')
begin
	declare @id_solicitud_confirmacion_mass_market int

	select @numero_solicitud = [dbo].[calcular_numero_solicitud] (@id_farm)

	insert into solicitud_confirmacion_mass_market (id_farm, numero_solicitud, archivo, id_cuenta_interna, extension_archivo, po_number)
	values (@id_farm, @numero_solicitud, @archivo, @id_cuenta_interna, @extension_archivo, @po_number)

	set @id_solicitud_confirmacion_mass_market = scope_identity()

	select solicitud_confirmacion_mass_market.id_solicitud_confirmacion_mass_market,
	numero_solicitud,
	fecha_transaccion
	from solicitud_confirmacion_mass_market
	where id_solicitud_confirmacion_mass_market = @id_solicitud_confirmacion_mass_market
end
else
if(@accion = 'consultar_archivo')
begin
	select cuenta_interna.nombre as nombre_cuenta,
	solicitud_confirmacion_mass_market.fecha_transaccion as fecha_envio,
	solicitud_confirmacion_mass_market.archivo,
	solicitud_confirmacion_mass_market.extension_archivo,
	solicitud_confirmacion_mass_market.numero_solicitud,
	solicitud_confirmacion_mass_market.po_number
	from solicitud_confirmacion_mass_market,
	farm,
	cuenta_interna
	where farm.id_farm = solicitud_confirmacion_mass_market.id_farm
	and farm.id_farm = @id_farm
	and solicitud_confirmacion_mass_market.numero_solicitud = @numero_solicitud
	and cuenta_interna.id_cuenta_interna = solicitud_confirmacion_mass_market.id_cuenta_interna

	select detalle_solicitud_confirmacion_mass_market.fecha_vuelo,
	detalle_solicitud_confirmacion_mass_market.cantidad_piezas,
	detalle_solicitud_confirmacion_mass_market.marca,
	detalle_solicitud_confirmacion_mass_market.nombre_hoja
	from solicitud_confirmacion_mass_market,
	detalle_solicitud_confirmacion_mass_market,
	farm
	where farm.id_farm = solicitud_confirmacion_mass_market.id_farm
	and farm.id_farm = @id_farm
	and solicitud_confirmacion_mass_market.numero_solicitud = @numero_solicitud
	and solicitud_confirmacion_mass_market.numero_solicitud = detalle_solicitud_confirmacion_mass_market.numero_solicitud
	and solicitud_confirmacion_mass_market.id_farm = detalle_solicitud_confirmacion_mass_market.id_farm
	order by detalle_solicitud_confirmacion_mass_market.id_detalle_solicitud_confirmacion_mass_market
end