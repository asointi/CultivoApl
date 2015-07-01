set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv2_registrar_inventario]

@accion nvarchar(255),
@id_farm int,
@id_temporada_año int,
@id_cuenta_interna int, 
@id_tapa int, 
@id_variedad_flor int, 
@id_grado_flor int, 
@id_tipo_caja int, 
@unidades_por_pieza int, 
@marca nvarchar(10), 
@controla_saldos bit, 
@empaque_principal bit, 
@precio_finca decimal(20,2),
@id_item_inventario_preventa int,
@id_tipo_flor int = null

AS

if(@accion = 'insertar')
begin
	declare @empaque_principal_aux int,
	@id_inventario_preventa int

	select @id_inventario_preventa = id_inventario_preventa 
	from inventario_preventa
	where id_farm = @id_farm 
	and id_temporada_año = @id_temporada_año

	if(@id_inventario_preventa is null)
	begin
		insert into inventario_preventa (id_farm, id_temporada_año)
		values (@id_farm, @id_temporada_año)

		set @id_inventario_preventa = scope_identity()
	end

	select item_inventario_preventa.id_item_inventario_preventa,
	item_inventario_preventa.empaque_principal into #empaque_principal
	from item_inventario_preventa
	where id_inventario_preventa = @id_inventario_preventa
	and id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor
	and id_tapa = @id_tapa

	if(@empaque_principal = 1)
	begin
		select @empaque_principal_aux = sum(convert(int,empaque_principal))
		from #empaque_principal 

		if(@empaque_principal_aux > 0)
		begin
			update item_inventario_preventa
			set empaque_principal = 0
			where id_inventario_preventa = @id_inventario_preventa
			and id_variedad_flor = @id_variedad_flor
			and id_grado_flor = @id_grado_flor
			and id_tapa = @id_tapa
		end
	end

	select @id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
	from item_inventario_preventa
	where id_inventario_preventa = @id_inventario_preventa
	and id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor
	and id_tipo_caja = @id_tipo_caja
	and unidades_por_pieza = @unidades_por_pieza
	and id_tapa = @id_tapa

	if(@id_item_inventario_preventa is null)
	begin
		insert into item_inventario_preventa (id_cuenta_interna, id_inventario_preventa, id_tapa, id_variedad_flor, id_grado_flor, id_tipo_caja, unidades_por_pieza, marca, controla_saldos, empaque_principal, precio_finca)
		values (@id_cuenta_interna, @id_inventario_preventa, @id_tapa, @id_variedad_flor, @id_grado_flor, @id_tipo_caja, @unidades_por_pieza, @marca, @controla_saldos, @empaque_principal, @precio_finca)

		set @id_item_inventario_preventa = scope_identity()
	end
	else
	begin
		update item_inventario_preventa
		set id_cuenta_interna = @id_cuenta_interna,
		marca = @marca,
		controla_saldos = @controla_saldos, 
		empaque_principal = @empaque_principal, 
		precio_finca = @precio_finca
		where id_item_inventario_preventa = @id_item_inventario_preventa
	end

	if(@empaque_principal = 1)
	begin
		if(@empaque_principal_aux > 0)
		begin
			update detalle_item_inventario_preventa
			set id_item_inventario_preventa = @id_item_inventario_preventa
			where exists
			(
				select *
				from #empaque_principal
				where #empaque_principal.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
				and #empaque_principal.empaque_principal = 1
			)
		end
	end

	drop table #empaque_principal

	select @id_item_inventario_preventa as id_item_inventario_preventa
end
else
if(@accion = 'modificar_control_saldos')
begin
	select @id_inventario_preventa = id_inventario_preventa,
	@id_tapa = id_tapa,
	@id_variedad_flor = id_variedad_flor,
	@id_grado_flor = id_grado_flor
	from item_inventario_preventa
	where id_item_inventario_preventa = @id_item_inventario_preventa

	update item_inventario_preventa
	set controla_saldos = @controla_saldos
	where id_inventario_preventa = @id_inventario_preventa
	and id_tapa = @id_tapa
	and id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor
end
else
if(@accion = 'modificar_control_saldos_varios_items')
begin
	update item_inventario_preventa
	set controla_saldos = @controla_saldos
	from inventario_preventa,
	tipo_flor,
	variedad_flor,
	grado_flor
	where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
	and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
	and inventario_preventa.id_temporada_año = @id_temporada_año
	and inventario_preventa.id_farm = @id_farm
	and tipo_flor.id_tipo_flor > =
	case
		when @id_tipo_flor is null then 1
		else @id_tipo_flor
	end
	and tipo_flor.id_tipo_flor < =
	case
		when @id_tipo_flor is null then 99999999
		else @id_tipo_flor
	end
	and variedad_flor.id_variedad_flor > = 
	case
		when @id_variedad_flor is null then 1
		else @id_variedad_flor
	end
	and variedad_flor.id_variedad_flor < = 
	case
		when @id_variedad_flor is null then 99999999
		else @id_variedad_flor
	end
	and grado_flor.id_grado_flor > = 
	case
		when @id_grado_flor is null then 1
		else @id_grado_flor
	end
	and grado_flor.id_grado_flor < = 
	case
		when @id_grado_flor is null then 99999999
		else @id_grado_flor
	end
end
else
if(@accion = 'modificar_precio_finca')
begin
	select @id_inventario_preventa = id_inventario_preventa,
	@id_tapa = id_tapa,
	@id_variedad_flor = id_variedad_flor,
	@id_grado_flor = id_grado_flor
	from item_inventario_preventa
	where id_item_inventario_preventa = @id_item_inventario_preventa

	update item_inventario_preventa
	set precio_finca = @precio_finca
	where id_inventario_preventa = @id_inventario_preventa
	and id_tapa = @id_tapa
	and id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor
end
else
if(@accion = 'eliminar_producto')
begin
	select @id_inventario_preventa = id_inventario_preventa,
	@id_tapa = id_tapa,
	@id_variedad_flor = id_variedad_flor,
	@id_grado_flor = id_grado_flor
	from item_inventario_preventa
	where id_item_inventario_preventa = @id_item_inventario_preventa

	select item_inventario_preventa.id_item_inventario_preventa as id_item_inventario_preventa into #item_inventario_preventa
	from item_inventario_preventa
	where id_inventario_preventa = @id_inventario_preventa
	and id_tapa = @id_tapa
	and id_variedad_flor = @id_variedad_flor
	and id_grado_flor = @id_grado_flor

	delete from detalle_item_inventario_preventa
	where exists
	(
		select *
		from #item_inventario_preventa
		where detalle_item_inventario_preventa.id_item_inventario_preventa = #item_inventario_preventa.id_item_inventario_preventa
	)

	delete from pantalla_inventario_cobol
	where exists
	(
		select *
		from #item_inventario_preventa
		where pantalla_inventario_cobol.id_item_inventario_preventa = #item_inventario_preventa.id_item_inventario_preventa	
	)

	delete from pantalla_preorden
	where exists
	(
		select *
		from #item_inventario_preventa
		where pantalla_preorden.id_item_inventario_preventa = #item_inventario_preventa.id_item_inventario_preventa	
	)

	delete from pantalla_saldo_cobol
	where exists
	(
		select *
		from #item_inventario_preventa
		where pantalla_saldo_cobol.id_item_inventario_preventa = #item_inventario_preventa.id_item_inventario_preventa	
	)

	delete from item_inventario_preventa
	where exists
	(
		select *
		from #item_inventario_preventa
		where item_inventario_preventa.id_item_inventario_preventa = #item_inventario_preventa.id_item_inventario_preventa
	)

	begin try
		delete from inventario_preventa
		where id_inventario_preventa = @id_inventario_preventa
	end try
	begin catch
	end catch

	drop table #item_inventario_preventa
end
else
if(@accion = 'eliminar_item')
begin
	delete from detalle_item_inventario_preventa
	where id_item_inventario_preventa = @id_item_inventario_preventa

	select @id_inventario_preventa = id_inventario_preventa
	from item_inventario_preventa
	where id_item_inventario_preventa = @id_item_inventario_preventa

	delete from pantalla_inventario_cobol
	where id_item_inventario_preventa = @id_item_inventario_preventa

	delete from pantalla_preorden
	where id_item_inventario_preventa = @id_item_inventario_preventa

	delete from pantalla_saldo_cobol
	where id_item_inventario_preventa = @id_item_inventario_preventa

	delete from item_inventario_preventa
	where id_item_inventario_preventa = @id_item_inventario_preventa
	
	begin try
		delete from inventario_preventa
		where id_inventario_preventa = @id_inventario_preventa
	end try
	begin catch
	end catch
end