set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[prod_editar_compra_sin_clasificar]

@id_cuenta_interna int,
@id_finca int,
@fecha datetime,
@cantidad_tallos int,
@id_compra_sin_clasificar int,
@id_variedad_flor int,
@numero_pedido nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select compra_sin_clasificar.id_compra_sin_clasificar,
	finca.id_finca,
	finca.idc_finca,
	finca.nombre_finca,
	compra_sin_clasificar.fecha,
	compra_sin_clasificar.cantidad_tallos,
	compra_sin_clasificar.numero_pedido,
	cuenta_interna.nombre as nombre_cuenta,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + space(1) + '[' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + space(1) + '[' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor
	from compra_sin_clasificar,
	finca,
	cuenta_interna,
	variedad_flor,
	tipo_flor
	where compra_sin_clasificar.id_finca = finca.id_finca
	and compra_sin_clasificar.fecha = @fecha
	and compra_sin_clasificar.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and compra_sin_clasificar.id_variedad_flor = variedad_flor.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
end
else
if(@accion = 'insertar')
begin
	insert into compra_sin_clasificar (id_variedad_flor, id_cuenta_interna, id_finca, fecha, cantidad_tallos, numero_pedido)
	select variedad_flor.id_variedad_flor, cuenta_interna.id_cuenta_interna, finca.id_finca, @fecha, @cantidad_tallos, @numero_pedido
	from finca,
	cuenta_interna,
	variedad_flor
	where finca.id_finca = @id_finca
	and variedad_flor.id_variedad_flor = @id_variedad_flor
	and cuenta_interna.id_cuenta_interna = @id_cuenta_interna
end
else
if(@accion = 'eliminar')
begin
	delete from compra_sin_clasificar
	where id_compra_sin_clasificar = @id_compra_sin_clasificar
end