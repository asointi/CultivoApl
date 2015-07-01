set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[pbinv_registrar_preventa_web]

@id_temporada_ano int,
@id_farm int,
@id_cuenta_interna int,
@id_tapa int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tipo_caja int,
@unidades_por_pieza int,
@marca nvarchar(10),
@precio_minimo decimal(20,4),
@controla_saldos bit,
@empaque_principal bit,
@precio_finca decimal(20,4),
@fecha datetime,
@cantidad_piezas int

AS

declare @id_inventario_preventa int,
@id_item_inventario_preventa int,
@id_detalle_item_inventario_preventa  int,
@existe_empaque_principal int,
@empaque_principal_aux bit,
@precio_minimo_aux decimal(20,4)

select @id_inventario_preventa = inventario_preventa.id_inventario_preventa
from inventario_preventa
where inventario_preventa.id_temporada_año = @id_temporada_ano
and inventario_preventa.id_farm = @id_farm

select @id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa 
from item_inventario_preventa,
inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and inventario_preventa.id_farm = @id_farm 
and inventario_preventa.id_temporada_año = @id_temporada_ano
and id_variedad_flor = @id_variedad_flor
and id_grado_flor = @id_grado_flor
and id_tapa = @id_tapa 
and marca = @marca
and id_tipo_caja = @id_tipo_caja 
and unidades_por_pieza = @unidades_por_pieza

if(@id_inventario_preventa is null)
begin
	insert into inventario_preventa (id_farm, id_temporada_año)
	values (@id_farm, @id_temporada_ano)

	set @id_inventario_preventa = scope_identity()
end

select @existe_empaque_principal = sum(convert(int, empaque_principal))
from item_inventario_preventa,
inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and inventario_preventa.id_farm = @id_farm 
and inventario_preventa.id_temporada_año = @id_temporada_ano
and id_variedad_flor = @id_variedad_flor
and id_grado_flor = @id_grado_flor
and id_tapa = @id_tapa 
and marca = @marca

select @precio_minimo_aux = item_inventario_preventa.precio_minimo
from item_inventario_preventa,
inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and inventario_preventa.id_farm = @id_farm 
and inventario_preventa.id_temporada_año = @id_temporada_ano
and id_variedad_flor = @id_variedad_flor
and id_grado_flor = @id_grado_flor
and id_tapa = @id_tapa 
and marca = @marca
and item_inventario_preventa.empaque_principal = 1

begin transaction
	if(@id_item_inventario_preventa is null)
	begin
		insert into item_inventario_preventa (id_cuenta_interna, id_inventario_preventa, id_tapa, id_variedad_flor, id_grado_flor, id_tipo_caja, unidades_por_pieza, marca, precio_minimo, controla_saldos, empaque_principal, precio_finca)
		select @id_cuenta_interna, 
		@id_inventario_preventa, 
		@id_tapa, 
		@id_variedad_flor, 
		@id_grado_flor, 
		@id_tipo_caja, 
		@unidades_por_pieza, 
		@marca, 
		case
			when @existe_empaque_principal = 0 then @precio_minimo
			when @existe_empaque_principal is null then @precio_minimo
			when @existe_empaque_principal >= 1 then @precio_minimo_aux
		end,
		@controla_saldos, 
		case
			when @existe_empaque_principal = 0 then 1
			when @existe_empaque_principal is null then 1
			when @existe_empaque_principal >= 1 then 0
		end,
		@precio_finca

		set @id_item_inventario_preventa = scope_identity()
	end
	else
	begin
		if(@empaque_principal = 1)
		begin
			update item_inventario_preventa
			set empaque_principal = 0
			from inventario_preventa
			where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
			and inventario_preventa.id_farm = @id_farm 
			and inventario_preventa.id_temporada_año = @id_temporada_ano			
			and id_variedad_flor = @id_variedad_flor
			and id_grado_flor = @id_grado_flor
			and id_tapa = @id_tapa 
			and marca = @marca

			update item_inventario_preventa
			set empaque_principal = @empaque_principal
			where id_item_inventario_preventa = @id_item_inventario_preventa
		end
		else
		begin
			select @existe_empaque_principal = sum(convert(int, empaque_principal))
			from item_inventario_preventa,
			inventario_preventa
			where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
			and inventario_preventa.id_farm = @id_farm 
			and inventario_preventa.id_temporada_año = @id_temporada_ano			
			and id_variedad_flor = @id_variedad_flor
			and id_grado_flor = @id_grado_flor
			and id_tapa = @id_tapa 
			and marca = @marca

			select @empaque_principal_aux = empaque_principal
			from item_inventario_preventa,
			inventario_preventa
			where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
			and inventario_preventa.id_farm = @id_farm 
			and inventario_preventa.id_temporada_año = @id_temporada_ano	
			and id_variedad_flor = @id_variedad_flor
			and id_grado_flor = @id_grado_flor
			and id_tapa = @id_tapa 
			and marca = @marca
			and id_item_inventario_preventa = @id_item_inventario_preventa

			update item_inventario_preventa
			set empaque_principal = 
			case
				when @existe_empaque_principal >= 2 then 0
				when @existe_empaque_principal = 1 and @empaque_principal_aux = 0 then 0
				when @existe_empaque_principal = 0 and @empaque_principal_aux = 0 then 1
				when @existe_empaque_principal = 1 and @empaque_principal_aux = 1 then 1
				when @existe_empaque_principal = 0 then 1
				else 1
			end	
			where id_item_inventario_preventa = @id_item_inventario_preventa
		end

		update item_inventario_preventa
		set id_cuenta_interna = @id_cuenta_interna,
		controla_saldos = @controla_saldos,
		precio_finca = @precio_finca
		where id_item_inventario_preventa = @id_item_inventario_preventa
	end
commit transaction

set @empaque_principal_aux = null

select @empaque_principal_aux = empaque_principal
from item_inventario_preventa
where id_item_inventario_preventa = @id_item_inventario_preventa

if(@empaque_principal_aux = 0)
begin
	set @cantidad_piezas = 0
end

select @id_detalle_item_inventario_preventa = id_detalle_item_inventario_preventa 
from detalle_item_inventario_preventa
where id_item_inventario_preventa = @id_item_inventario_preventa
and fecha_disponible_distribuidora = @fecha

/*preguntar si solamente el empaque principal lleva piezas*/

if(@id_detalle_item_inventario_preventa is null)
begin
	insert into detalle_item_inventario_preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, cantidad_piezas_adicionales_finca, cantidad_piezas_ofertadas_finca)
	values (@id_item_inventario_preventa, @fecha, @cantidad_piezas, 0, 0)

	set @id_detalle_item_inventario_preventa = scope_identity()

	update detalle_item_inventario_preventa
	set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa
end
else
begin
	update detalle_item_inventario_preventa
	set cantidad_piezas = @cantidad_piezas
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa
end

select @id_item_inventario_preventa as id_item_inventario_preventa,
@id_detalle_item_inventario_preventa as id_detalle_item_inventario_preventa
