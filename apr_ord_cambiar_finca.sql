set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create PROCEDURE [dbo].[apr_ord_cambiar_finca]

@id_item_orden_sin_aprobar int,
@id_farm int,
@idc_tipo_factura nvarchar(1)

as

declare @id_item_orden_sin_aprobar_nuevo int,
@id_farm_aux int
 
select @id_farm_aux = farm.id_farm
from item_orden_sin_aprobar,
farm
where item_orden_sin_aprobar.id_farm = farm.id_farm
and item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar


if(@id_farm_aux <> @id_farm)
begin
	insert into item_orden_sin_aprobar 
	(
		id_item_orden_sin_aprobar_padre,
		id_transportador, 
		id_orden_sin_aprobar, 
		id_variedad_flor, 
		id_grado_flor, 
		id_farm, 
		id_tapa, 
		id_caja, 
		code, 
		comentario, 
		fecha_inicial, 
		fecha_final, 
		unidades_por_pieza, 
		cantidad_piezas, 
		valor_unitario, 
		valor_pactado_cobol,
		usuario_cobol,
		box_charges, 
		precio_mercado,
		observacion,
		valor_pactado_interno
	)
	select item_orden_sin_aprobar.id_item_orden_sin_aprobar_padre,
	item_orden_sin_aprobar.id_transportador, 
	item_orden_sin_aprobar.id_orden_sin_aprobar, 
	item_orden_sin_aprobar.id_variedad_flor, 
	item_orden_sin_aprobar.id_grado_flor, 
	farm.id_farm, 
	item_orden_sin_aprobar.id_tapa, 
	item_orden_sin_aprobar.id_caja, 
	item_orden_sin_aprobar.code, 
	item_orden_sin_aprobar.comentario, 
	item_orden_sin_aprobar.fecha_inicial, 
	item_orden_sin_aprobar.fecha_final, 
	item_orden_sin_aprobar.unidades_por_pieza, 
	item_orden_sin_aprobar.cantidad_piezas, 
	item_orden_sin_aprobar.valor_unitario, 
	item_orden_sin_aprobar.valor_pactado_cobol,
	'USUARIO SQL',
	item_orden_sin_aprobar.box_charges, 
	item_orden_sin_aprobar.precio_mercado,
	item_orden_sin_aprobar.observacion,
	item_orden_sin_aprobar.valor_pactado_interno
	from item_orden_sin_aprobar,
	farm
	where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar
	and farm.id_farm = @id_farm

	set @id_item_orden_sin_aprobar_nuevo = scope_identity()

	if(@idc_tipo_factura = '9')
	begin
		update aprobacion_orden
		set aceptada = 0
		where id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar

		declare @id_item_orden_sin_aprobar_aux int,
		@id_aprobacion_orden int

		set @id_item_orden_sin_aprobar_aux = scope_identity()

		insert into aprobacion_orden (id_item_orden_sin_aprobar, usuario_cobol, aceptada)
		select item_orden_sin_aprobar.id_item_orden_sin_aprobar, 'USUARIO SQL', 1
		from item_orden_sin_aprobar
		where item_orden_sin_aprobar.id_item_orden_sin_aprobar = @id_item_orden_sin_aprobar_aux

		set @id_aprobacion_orden = scope_identity()

		update aprobacion_orden
		set id_aprobacion_orden_padre = @id_aprobacion_orden
		where id_aprobacion_orden = @id_aprobacion_orden
	end
end
else
if(@id_farm_aux = @id_farm)
begin
	set @id_item_orden_sin_aprobar_nuevo = 0
end

select @id_item_orden_sin_aprobar_nuevo as id_item_orden_sin_aprobar_nuevo