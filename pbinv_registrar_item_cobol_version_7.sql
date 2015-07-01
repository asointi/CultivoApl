set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv_registrar_item_cobol_version_7]

@idc_farm nvarchar(5),
@idc_tipo_flor nvarchar(5),
@idc_variedad_flor nvarchar(5),
@idc_grado_flor nvarchar(5),
@idc_tapa nvarchar(5),
@idc_tipo_caja nvarchar(5),
@unidades_por_pieza int,
@marca nvarchar(10),
@fecha_inicial nvarchar(15),
@cantidad_piezas int,
@cantidad_piezas_adcionales_finca int,
@cantidad_piezas_ofertadas_finca int,
@id_item_inventario_preventa int,
@controla_saldos bit,
@precio_finca decimal(20,4),
@precio_minimo decimal(20,4)

AS

declare @empaque_principal int,
@id_cuenta_interna int,
@fecha_inicial_temporada datetime,
@id_inventario_preventa int,
@id_item_inventario_preventa_aux int,
@id_detalle_item_inventario_preventa int,
@id_temporada_año int,
@id_farm int,
@id_tipo_flor int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tapa int,
@id_tipo_caja int,
@precio_minimo_aux decimal(20,4)

select @id_temporada_año = temporada_año.id_temporada_año 
from temporada_cubo,
temporada_año,
temporada,
año
where convert(datetime,@fecha_inicial) between
temporada_cubo.fecha_inicial and temporada_cubo.fecha_final
and año.id_año = temporada_año.id_año
and temporada.id_temporada = temporada_año.id_temporada
and año.id_año = temporada_cubo.id_año
and temporada.id_temporada = temporada_cubo.id_temporada

select @fecha_inicial_temporada = min(fecha)
from fecha_inventario
where id_temporada_año = @id_temporada_año

select @id_farm = id_farm from farm where idc_farm = @idc_farm
select @id_tipo_flor = id_tipo_flor from tipo_flor where idc_tipo_flor = @idc_tipo_flor
select @id_variedad_flor = id_variedad_flor from variedad_flor where variedad_flor.id_tipo_flor = @id_tipo_flor and variedad_flor.idc_variedad_flor = @idc_variedad_flor
select @id_grado_flor = id_grado_flor from grado_flor where grado_flor.id_tipo_flor = @id_tipo_flor and grado_flor.idc_grado_flor = @idc_grado_flor
select @id_tapa = id_tapa from tapa where idc_tapa = @idc_tapa
select @id_tipo_caja = id_tipo_caja from tipo_caja where idc_tipo_caja = left(@idc_tipo_caja, 1)
select @id_cuenta_interna = id_cuenta_interna from cuenta_interna where cuenta = 'cobol'
set @marca = 'PB'

if(@fecha_inicial_temporada is not null)
begin
	/*verificar que el producto tenga o no empaque principal*/
	select @empaque_principal = max(convert(int,item_inventario_preventa.empaque_principal))
	from inventario_preventa,
	item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_variedad_flor = @id_variedad_flor
	and item_inventario_preventa.id_grado_flor = @id_grado_flor
	and inventario_preventa.id_farm = @id_farm
	and item_inventario_preventa.id_tapa = @id_tapa
	and inventario_preventa.id_temporada_año = @id_temporada_año

	/*Extraer el precio de finca del empaque principal*/
	select @precio_minimo_aux = item_inventario_preventa.precio_minimo
	from inventario_preventa,
	item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_variedad_flor = @id_variedad_flor
	and item_inventario_preventa.id_grado_flor = @id_grado_flor
	and inventario_preventa.id_farm = @id_farm
	and item_inventario_preventa.id_tapa = @id_tapa
	and inventario_preventa.id_temporada_año = @id_temporada_año
	and item_inventario_preventa.empaque_principal = 1
	
	select @id_inventario_preventa = max(id_inventario_preventa)
	from inventario_preventa
	where inventario_preventa.id_farm = @id_farm
	and inventario_preventa.id_temporada_año = @id_temporada_año
	
	if(@id_inventario_preventa is null)
	begin
		insert into Inventario_Preventa (id_farm, id_temporada_año)
		values (@id_farm, @id_temporada_año)
		
		set @id_inventario_preventa = scope_identity()
	end
			
	insert into Item_Inventario_Preventa (id_cuenta_interna, id_inventario_preventa, id_tapa, id_variedad_flor, id_grado_flor, unidades_por_pieza, marca, id_tipo_caja, empaque_principal, controla_saldos, precio_finca, precio_minimo)
	select @id_cuenta_interna, 
	@id_inventario_preventa, 
	@id_tapa, 
	@id_variedad_flor, 
	@id_grado_flor, 
	@unidades_por_pieza, 
	@marca, 
	@id_tipo_caja, 
	case
		when @empaque_principal = 0 then 1
		when @empaque_principal is null then 1
		else 0
	end,
	@controla_saldos, 
	@precio_finca,
	case
		when @empaque_principal = 0 then @precio_minimo
		when @empaque_principal is null then @precio_minimo
		else @precio_minimo_aux
	end

	set @id_item_inventario_preventa_aux = scope_identity()

	insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, cantidad_piezas_adicionales_finca, cantidad_piezas_ofertadas_finca)
	select @id_item_inventario_preventa_aux, 
	@fecha_inicial_temporada, 
	case
		when @empaque_principal = 0 then @cantidad_piezas
		when @empaque_principal is null then @cantidad_piezas
		else 0
	end,
	0,
	0

	set @id_detalle_item_inventario_preventa = scope_identity()

	update detalle_item_inventario_preventa
	set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
	where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa

	select 1 as result
end
else
begin
	select -1 as result
end