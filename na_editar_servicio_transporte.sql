/*
Este SP se realiza para alertar a los vendedores que estan facturando
si el cliente tiene servicio por una transportadora particular para una 
fecha o dia de la semana especificos.

Creado Por: DIEGO PIÑEROS
Fecha Creación: 2011/05/11

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[na_editar_servicio_transporte]

@accion nvarchar(255),
@id_transportador int,
@id_estado int,
@id_dia_semana int,
@id_temporada int,
@id_año int,
@id_ubicacion int,
@id_cuenta_interna int,
@fecha datetime, 
@id_temporada_año int,
@id_servicio_transporte int

AS

if(@accion = 'insertar_ubicacion')
begin
	insert into ubicacion (id_transportador, id_estado)
	values (@id_transportador, @id_estado)

	select scope_identity() as id_ubicacion
end
else
if(@accion = 'insertar_servicio_dia_semana')
begin
	insert into servicio_transporte (id_dia_despacho, id_transportador, id_estado, id_cuenta_interna)
	select @id_dia_semana, ubicacion.id_transportador, ubicacion.id_estado, @id_cuenta_interna
	from ubicacion
	where ubicacion.id_ubicacion = @id_ubicacion
end
else
if(@accion = 'eliminar_servicio_dia_semana')
begin
	delete from servicio_transporte where id_servicio_transporte = @id_servicio_transporte
end


else
if(@accion = 'insertar_servicio_day_ahead')
begin
	insert into servicio_transporte_day_ahead (id_transportador, id_estado, id_cuenta_interna, fecha, id_temporada_año)
	select ubicacion.id_transportador, ubicacion.id_estado, @id_cuenta_interna, @fecha, @id_temporada_año
	from ubicacion
	where ubicacion.id_ubicacion = @id_ubicacion
end
else
if(@accion = 'eliminar_servicio_day_ahead')
begin
	delete from servicio_transporte_day_ahead where id_servicio_transporte_day_ahead = @id_servicio_transporte
end


else
if(@accion = 'consultar_servicio_dia_semana')
begin
	select transportador.id_transportador,
	transportador.idc_transportador,
	ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
	estado.id_estado,
	estado.idc_estado,
	ltrim(rtrim(estado.nombre_estado)) as nombre_transportador,
	ubicacion.id_ubicacion,
	dia_despacho.id_dia_despacho,
	dia_despacho.nombre_dia_despacho,
	servicio_transporte.id_servicio_transporte,
	servicio_transporte.fecha_transaccion,
	cuenta_interna.id_cuenta_interna,
	ltrim(rtrim(cuenta_interna.nombre)) as nombre_cuenta
	from servicio_transporte,
	dia_despacho,
	ubicacion,
	transportador,
	estado,
	cuenta_interna
	where transportador.id_transportador = ubicacion.id_transportador
	and estado.id_estado = ubicacion.id_estado
	and ubicacion.id_transportador = servicio_transporte.id_transportador
	and ubicacion.id_estado = servicio_transporte.id_estado
	and dia_despacho.id_dia_despacho = servicio_transporte.id_dia_despacho
	and servicio_transporte.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and transportador.id_transportador = @id_transportador
	and dia_despacho.id_dia_despacho > = 
	case
		when @id_dia_semana = 0 then 1
		else @id_dia_semana
	end 
	and dia_despacho.id_dia_despacho < = 
	case
		when @id_dia_semana = 0 then 9999
		else @id_dia_semana
	end 
	and estado.id_estado > = 
	case
		when @id_estado = 0 then 1
		else @id_estado
	end 
	and estado.id_estado < = 
	case
		when @id_estado = 0 then 9999
		else @id_estado
	end 
end
else
if(@accion = 'consultar_servicio_day_ahead')
begin
	select transportador.id_transportador,
	transportador.idc_transportador,
	ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
	estado.id_estado,
	estado.idc_estado,
	ltrim(rtrim(estado.nombre_estado)) as nombre_transportador,
	ubicacion.id_ubicacion,
	temporada.id_temporada,
	temporada.nombre_temporada,
	año.id_año,
	año.nombre_año,
	temporada_año.fecha_inicial,
	servicio_transporte_day_ahead.id_servicio_transporte_day_ahead,
	servicio_transporte_day_ahead.fecha,
	servicio_transporte_day_ahead.fecha_transaccion,
	cuenta_interna.id_cuenta_interna,
	ltrim(rtrim(cuenta_interna.nombre)) as nombre_cuenta
	from ubicacion,
	transportador,
	estado,
	cuenta_interna,
	servicio_transporte_day_ahead,
	temporada_año,
	temporada,
	año
	where transportador.id_transportador = ubicacion.id_transportador
	and estado.id_estado = ubicacion.id_estado
	and ubicacion.id_transportador = servicio_transporte_day_ahead.id_transportador
	and ubicacion.id_estado = servicio_transporte_day_ahead.id_estado
	and servicio_transporte_day_ahead.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and servicio_transporte_day_ahead.id_temporada_año = temporada_año.id_temporada_año
	and transportador.id_transportador = @id_transportador
	and año.id_año = temporada_año.id_año
	and temporada.id_temporada = temporada_año.id_temporada
	and año.id_año > = 
	case
		when @id_año = 0 then 1
		else @id_año
	end 
	and año.id_año < = 
	case
		when @id_año = 0 then 9999
		else @id_año
	end 
	and temporada.id_temporada > = 
	case
		when @id_temporada = 0 then 1
		else @id_temporada
	end 
	and temporada.id_temporada < = 
	case
		when @id_temporada = 0 then 9999
		else @id_temporada
	end 
	and estado.id_estado > = 
	case
		when @id_estado = 0 then 1
		else @id_estado
	end 
	and estado.id_estado < = 
	case
		when @id_estado = 0 then 9999
		else @id_estado
	end 
end