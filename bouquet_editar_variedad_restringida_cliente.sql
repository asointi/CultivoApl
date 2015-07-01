set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2013/09/13
-- Description:	maneja la informacion de las variedades del cultivo restringidas por cliente
-- =============================================

alter PROCEDURE [dbo].[bouquet_editar_variedad_restringida_cliente] 

@accion nvarchar(50),
@id_variedad_flor_cultivo int, 
@id_cuenta_interna int,
@id_despacho int, 
@id_variedad_restringida_cliente int,
@observacion nvarchar(1024)

as

declare @conteo int

if(@accion = 'insertar')
begin
	select @conteo = count(*)
	from variedad_restringida_cliente
	where id_despacho = @id_despacho
	and id_variedad_flor_cultivo = @id_variedad_flor_cultivo
	and not exists
	(
		select *
		from cancela_variedad_restringida_cliente
		where variedad_restringida_cliente.id_variedad_restringida_cliente = cancela_variedad_restringida_cliente.id_variedad_restringida_cliente
	)

	if(@conteo = 0)
	begin
		insert into variedad_restringida_cliente (id_variedad_flor_cultivo, id_despacho, observacion, id_cuenta_interna)
		values (@id_variedad_flor_cultivo, @id_despacho, @observacion, @id_cuenta_interna)
	end
end
else
if(@accion = 'deshabilitar')
begin
	insert into cancela_variedad_restringida_cliente (id_variedad_restringida_cliente, id_cuenta_interna)
	values (@id_variedad_restringida_cliente, @id_cuenta_interna)
end
else
if(@accion = 'consultar')
begin
	select variedad_restringida_cliente.id_variedad_restringida_cliente,
	tipo_flor_cultivo.idc_tipo_flor,
	ltrim(rtrim(tipo_flor_cultivo.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor_cultivo.idc_variedad_flor,
	ltrim(rtrim(variedad_flor_cultivo.nombre_variedad_flor)) as nombre_variedad_flor,
	cliente_despacho.id_despacho,
	cliente_despacho.idc_cliente_despacho,
	variedad_restringida_cliente.observacion,
	cuenta_interna.nombre as nombre_cuenta_interna,
	variedad_restringida_cliente.fecha_transaccion,
	isnull((
		select cancela_variedad_restringida_cliente.id_cancela_variedad_restringida_cliente
		from cancela_variedad_restringida_cliente
		where variedad_restringida_cliente.id_variedad_restringida_cliente = cancela_variedad_restringida_cliente.id_variedad_restringida_cliente
	), 0) as id_cancela_variedad_restringida_cliente,
	(
		select cancela_variedad_restringida_cliente.fecha_transaccion
		from cancela_variedad_restringida_cliente
		where variedad_restringida_cliente.id_variedad_restringida_cliente = cancela_variedad_restringida_cliente.id_variedad_restringida_cliente
	) as fecha_transaccion_cancelacion,
	(
		select c.nombre
		from cancela_variedad_restringida_cliente,
		cuenta_interna as c
		where variedad_restringida_cliente.id_variedad_restringida_cliente = cancela_variedad_restringida_cliente.id_variedad_restringida_cliente
		and c.id_cuenta_interna = cancela_variedad_restringida_cliente.id_cuenta_interna
	) as nombre_cuenta_interna_cancelacion into #temp
	from variedad_restringida_cliente,
	cuenta_interna,
	cliente_despacho,
	variedad_flor_cultivo,
	tipo_flor_cultivo
	where tipo_flor_cultivo.id_tipo_flor_cultivo = variedad_flor_cultivo.id_tipo_flor_cultivo
	and variedad_flor_cultivo.id_variedad_flor_cultivo = variedad_restringida_cliente.id_variedad_flor_cultivo
	and cliente_despacho.id_despacho = variedad_restringida_cliente.id_despacho
	and cuenta_interna.id_cuenta_interna = variedad_restringida_cliente.id_cuenta_interna		

	select *
	from #temp
	order by idc_cliente_despacho,
	nombre_tipo_flor,
	nombre_variedad_flor

	select id_despacho,
	idc_cliente_despacho
	from #temp
	group by id_despacho,
	idc_cliente_despacho
	order by idc_cliente_despacho

	drop table #temp
end