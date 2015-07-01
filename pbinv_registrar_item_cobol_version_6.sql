set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv_registrar_item_cobol_version_6]

@idc_farm nvarchar(255),
@idc_tipo_flor nvarchar(255),
@idc_variedad_flor nvarchar(255),
@idc_grado_flor nvarchar(255),
@idc_tapa nvarchar(255),
@idc_tipo_caja nvarchar(255),
@unidades_por_pieza int,
@marca nvarchar(255),
@fecha_inicial nvarchar(255),
@cantidad_piezas int,
@cantidad_piezas_adcionales_finca int,
@cantidad_piezas_ofertadas_finca int,
@empaque_principal bit,
@id_item_inventario_preventa int,
@controla_saldos bit,
@precio_finca decimal(20,4),
@precio_minimo decimal(20,4)

AS

if(@id_item_inventario_preventa = 0)
begin
if(@empaque_principal = 0)
	set @cantidad_piezas = 0
	
	declare @id_farm int,
	@id_variedad_flor int,
	@id_grado_flor int,
	@id_tapa int,
	@id_tipo_caja int,
	@id_inventario_preventa int,
	@id_cuenta_interna int,
	@id_item_inventario_preventa_aux int,
	@id_detalle_item_inventario_preventa int,
	@id_item int,
	@fecha_inicial_temporada datetime

	set @marca = 'PB'

	select @id_farm = id_farm from farm where idc_farm = @idc_farm

	select @id_variedad_flor = variedad_flor.id_variedad_flor 
	from variedad_flor, tipo_flor 
	where variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor

	select @id_grado_flor = grado_flor.id_grado_flor 
	from grado_flor, tipo_flor 
	where grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor 
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and grado_flor.idc_grado_flor = @idc_grado_flor

	select @id_tapa = id_tapa from tapa where @idc_tapa = idc_tapa

	select @id_tipo_caja = id_tipo_caja from tipo_caja where left(@idc_tipo_caja,1) = idc_tipo_caja

	select @id_cuenta_interna = id_cuenta_interna from cuenta_interna where cuenta = 'cobol'

	select @fecha_inicial_temporada = fecha_inicial 
	from temporada_cubo where convert(datetime,@fecha_inicial) 
	between fecha_inicial and fecha_final

	select @id_item = detalle_item_inventario_preventa.id_detalle_item_inventario_preventa
	from inventario_preventa,
	item_inventario_preventa,
	detalle_item_inventario_preventa
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
	and inventario_preventa.id_farm = @id_farm
	and item_inventario_preventa.id_tapa = @id_tapa
	and item_inventario_preventa.id_tipo_caja = @id_tipo_caja
	and item_inventario_preventa.id_variedad_flor = @id_variedad_flor
	and item_inventario_preventa.id_grado_flor = @id_grado_flor
	and item_inventario_preventa.unidades_por_pieza = @unidades_por_pieza
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora = @fecha_inicial_temporada
	order by item_inventario_preventa.fecha_transaccion desc

	if(@id_item is null)
	begin
		insert into Inventario_Preventa (id_farm)
		select id_farm from farm where idc_farm = @idc_farm

		set @id_inventario_preventa = scope_identity()

		insert into Item_Inventario_Preventa (id_cuenta_interna, id_inventario_preventa, id_tapa, id_variedad_flor, id_grado_flor, unidades_por_pieza, marca, id_tipo_caja, empaque_principal, controla_saldos, precio_finca, precio_minimo)
		values (@id_cuenta_interna, @id_inventario_preventa, @id_tapa, @id_variedad_flor, @id_grado_flor, @unidades_por_pieza, @marca, @id_tipo_caja, @empaque_principal, @controla_saldos, @precio_finca, @precio_minimo)

		set @id_item_inventario_preventa_aux = scope_identity()

		insert into Detalle_Item_Inventario_Preventa (id_item_inventario_preventa, fecha_disponible_distribuidora, cantidad_piezas, cantidad_piezas_adicionales_finca, cantidad_piezas_ofertadas_finca)
		select @id_item_inventario_preventa_aux, @fecha_inicial_temporada, @cantidad_piezas, @cantidad_piezas_adcionales_finca, @cantidad_piezas_ofertadas_finca

		set @id_detalle_item_inventario_preventa = scope_identity()

		update detalle_item_inventario_preventa
		set id_detalle_item_inventario_preventa_padre = @id_detalle_item_inventario_preventa
		where id_detalle_item_inventario_preventa = @id_detalle_item_inventario_preventa
	end
	else
	begin
		update detalle_item_inventario_preventa
		set cantidad_piezas = @cantidad_piezas,
		cantidad_piezas_adicionales_finca = @cantidad_piezas_adcionales_finca,
		cantidad_piezas_ofertadas_finca	= @cantidad_piezas_ofertadas_finca
		where id_detalle_item_inventario_preventa = @id_item
	 end
end
else
begin
	update item_inventario_preventa
	set unidades_por_pieza = @unidades_por_pieza,
	id_tipo_caja = tipo_caja.id_tipo_caja,
	controla_saldos = 
	case
		when @empaque_principal = 1 then @controla_saldos
		else controla_saldos
	end,
	precio_minimo = @precio_minimo,
	precio_finca = @precio_finca
	from tipo_caja
	where id_item_inventario_preventa = @id_item_inventario_preventa
	and tipo_caja.idc_tipo_caja = left(@idc_tipo_caja, 1)

	update detalle_item_inventario_preventa
	set cantidad_piezas = 
	case
		when @empaque_principal = 1 then @cantidad_piezas
		else 0
	end,
	cantidad_piezas_adicionales_finca = 
	case
		when @empaque_principal = 1 then @cantidad_piezas_adcionales_finca
		else 0
	end,
	cantidad_piezas_ofertadas_finca	= 
	case
		when @empaque_principal = 1 then @cantidad_piezas_ofertadas_finca
		else 0
	end
	where detalle_item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora = convert(datetime, @fecha_inicial)
end