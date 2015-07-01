SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_generar_gross_profit]

@fecha_inicial datetime, 
@fecha_final datetime,
@accion nvarchar(255)

as

if(@accion = 'mes_finca')
begin
	select tipo_farm.nombre_tipo_farm,
	farm.idc_farm,
	farm.id_farm,
	farm.nombre_farm,
	ciudad.id_ciudad,
	ciudad.idc_ciudad,
	sum(tipo_caja.factor_a_full) as fulls_recibidas,
	(
		select sum(tipo_caja.factor_a_full)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm
	) as fulls_vendidas,
	(
		select sum(pieza.unidades_por_pieza)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm
	) as unidades_vendidas,
	(
		select sum(pieza.unidades_por_pieza * pieza.costo_por_unidad)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm
	) as gross_cost_directas_terceros,
	(
		select sum(pieza.unidades_por_pieza * pieza.costo_por_unidad) + (sum(tipo_caja.factor_a_full) * max(ciudad.impuesto_por_caja))
		from 
		pieza,
		caja, 
		tipo_caja,
		ciudad,
		farm as f,
		guia
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and f.id_ciudad = ciudad.id_ciudad
		and pieza.id_guia = guia.id_guia
		and not exists
		(
			select * from detalle_item_factura
			where detalle_item_factura.id_pieza = pieza.id_pieza
		)
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm
	) as inventory_cost_directas_terceros,
	(
		select sum(item_factura.valor_unitario * pieza.unidades_por_pieza)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm
	) as valor,
	(
		select sum(cargo.valor_cargo)
		from 
		detalle_item_factura,
		item_factura,
		cargo,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and item_factura.id_item_factura = cargo.id_item_factura
		and item_factura.cargo_incluido = 0
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm
	) as cargo_no_incluido,
	(
		select sum(cargo.valor_cargo)
		from 
		detalle_item_factura,
		item_factura,
		cargo,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and item_factura.id_item_factura = cargo.id_item_factura
		and item_factura.cargo_incluido = 1
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm
	) as cargo_incluido into #temp
	from 
	pieza,
	farm,
	tipo_farm,
	guia,
	estado_guia,
	tipo_caja,
	caja,
	ciudad
	where guia.fecha_guia between
	@fecha_inicial and @fecha_final
	and pieza.id_farm = farm.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and pieza.id_guia = guia.id_guia
	and estado_guia.id_estado_guia = guia.id_estado_guia
	and pieza.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and farm.id_ciudad = ciudad.id_ciudad
	group by tipo_farm.nombre_tipo_farm,
	farm.idc_farm,
	ciudad.id_ciudad,
	ciudad.idc_ciudad,
	farm.id_farm,
	farm.nombre_farm

	alter table #temp
	add valor_credito decimal(20,4),
	freight decimal(20,4),
	gross_cost decimal(20,4),
	inventory_cost decimal(20,4),
	farm_credit decimal(20,4)

	select farm.idc_farm, 
	detalle_credito.valor_credito into #temp2
	from guia, 
	pieza, 
	farm, 
	detalle_item_factura, 
	item_factura, 
	detalle_credito
	where pieza.id_guia = guia.id_guia
	and guia.fecha_guia between
	@fecha_inicial and @fecha_final
	and pieza.id_farm = farm.id_farm
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and detalle_item_factura.id_item_factura = item_factura.id_item_factura
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and detalle_credito.id_guia in 
	(
		select id_guia from guia
		where fecha_guia between
		@fecha_inicial and @fecha_final
	)
	group by farm.idc_farm, 
	detalle_credito.id_detalle_credito,
	detalle_credito.id_tipo_detalle_credito,
	detalle_credito.id_guia,
	detalle_credito.id_credito,
	detalle_credito.id_item_factura,
	detalle_credito.valor_credito,
	detalle_credito.cantidad_credito

	select idc_farm, 
	sum(valor_credito) as valor_credito into #temp3
	from #temp2
	group by idc_farm

	update #temp
	set valor_credito = #temp3.valor_credito
	from #temp3
	where #temp.idc_farm = #temp3.idc_farm

	SELECT guia.id_guia,
	f.id_farm,
	f.idc_farm,
	((CASE 
	  WHEN estado_guia.idc_estado_guia = 'C' THEN guia.valor_impuesto + guia.valor_flete
	  ELSE ciudad.impuesto_por_caja
	END) * sum(tipo_caja.factor_a_full)) / 
	(
		select sum(tipo_caja.factor_a_full) 
		from guia as g, 
		pieza, 
		caja, 
		tipo_caja
		where pieza.id_guia = g.id_guia
		and pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and guia.id_guia = g.id_guia
	) as impuesto_guia,
	(
		select sum(valor_credito_farm)
		from guia as g,
		credito_farm,
		farm 
		where guia.id_guia = g.id_guia
		and farm.id_farm = f.id_farm
		and g.id_guia = credito_farm.id_guia
		and farm.id_farm = credito_farm.id_farm
	) as farm_credit  into #impuesto_guia
	FROM guia,
	farm as f,
	ciudad,
	estado_guia,
	pieza,
	caja,
	tipo_caja
	where pieza.id_guia = guia.id_guia
	and pieza.id_farm = f.id_farm
	and f.id_ciudad = ciudad.id_ciudad
	and guia.id_estado_guia = estado_guia.id_estado_guia
	and pieza.id_caja = caja.id_caja
	and caja.id_tipo_caja = tipo_caja.id_tipo_caja
	and guia.fecha_guia between
	@fecha_inicial and @fecha_final
	group by
	f.id_farm,
	ciudad.impuesto_por_caja,
	guia.id_guia,
	CASE 
	  WHEN estado_guia.idc_estado_guia = 'C' THEN guia.valor_impuesto + guia.valor_flete
	  ELSE ciudad.impuesto_por_caja
	END,
	f.idc_farm

	select id_farm, 
	idc_farm, 
	sum(farm_credit) as farm_credit,
	sum(impuesto_guia) as impuesto_guia into #impuesto_guia_final
	from #impuesto_guia
	group by id_farm, idc_farm

	update #temp
	set freight = #impuesto_guia_final.impuesto_guia,
	farm_credit = #impuesto_guia_final.farm_credit
	from #impuesto_guia_final
	where #impuesto_guia_final.id_farm = #temp.id_farm

	update #temp
	set gross_cost = (((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0)) - (isnull(cargo_no_incluido,0) + isnull(cargo_incluido,0))) * (1 - (farm.comision_farm / 100)) - isnull(fulls_vendidas,0) * configuracion_bd.impuesto_carga,
	inventory_cost = 0
	from farm, configuracion_bd
	where farm.id_farm = #temp.id_farm
	and #temp.nombre_tipo_farm = 'Natuflora'

	update #temp
	set gross_cost = (isnull(valor,0) + isnull(cargo_no_incluido,0)) * (1 - (farm.comision_farm / 100)),
	inventory_cost = 0
	from farm
	where farm.id_farm = #temp.id_farm
	and #temp.nombre_tipo_farm = 'Natuflora BOUQUETS'

	update #temp
	set gross_cost = isnull(gross_cost_directas_terceros,0),
	inventory_cost = isnull(inventory_cost_directas_terceros,0)
	where #temp.nombre_tipo_farm in ('Directas', 'Terceros')

	select nombre_tipo_farm,
	idc_farm,
	nombre_farm,
	idc_ciudad,
	fulls_vendidas,
	unidades_vendidas,
	gross_cost,
	farm_credit,
	isnull(gross_cost, 0) + isnull(farm_credit, 0) as net_cost,
	(isnull(gross_cost, 0) + isnull(farm_credit, 0)) / isnull(unidades_vendidas,1) as cost_average,
	freight,
	freight / isnull(fulls_vendidas,1) as freight_by_box,
	isnull(valor,0) + isnull(cargo_no_incluido,0) as gross_sales,
	isnull(valor_credito, 0) as credits,
	(isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0) as net_sales,
	((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0)) / isnull(unidades_vendidas,1) as sales_average,
	((isnull(gross_cost, 0) + isnull(farm_credit, 0)) + freight - ((isnull(valor ,0)+ isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0))) * -1 as profit_loss,
	case
		when ((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0)) = 0 then null
		else ((((isnull(gross_cost, 0) + isnull(farm_credit, 0)) + freight - ((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0))) * -1) /((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0))) * 100
	end as profit_loss_porcentaje,
	isnull(fulls_recibidas, 0) - isnull(fulls_vendidas, 0) as fulls_inventory,
	inventory_cost
	from #temp 
	order by nombre_tipo_farm, idc_farm

	drop table #temp
	drop table #temp2
	drop table #temp3
	drop table #impuesto_guia
	drop table #impuesto_guia_final
end
else
if(@accion = 'mes_tipo')
begin
	select tipo_farm.nombre_tipo_farm,
	farm.idc_farm,
	farm.id_farm,
	farm.nombre_farm,
	ciudad.id_ciudad,
	ciudad.idc_ciudad,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	sum(tipo_caja.factor_a_full) as fulls_recibidas,
	(
		select sum(tipo_caja.factor_a_full)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia,
		tipo_flor as tf,
		variedad_flor as vf,
		grado_flor as gf
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and pieza.id_variedad_flor = vf.id_variedad_flor
		and pieza.id_grado_flor = gf.id_grado_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and tipo_flor.id_tipo_flor = tf.id_tipo_flor
		and variedad_flor.id_variedad_flor = vf.id_variedad_flor
		and grado_flor.id_grado_flor = gf.id_grado_flor
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm,
		tf.id_tipo_flor,
		vf.id_variedad_flor,
		gf.id_grado_flor
	) as fulls_vendidas,
	(
		select sum(pieza.unidades_por_pieza)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia,
		tipo_flor as tf,
		variedad_flor as vf,
		grado_flor as gf
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and pieza.id_variedad_flor = vf.id_variedad_flor
		and pieza.id_grado_flor = gf.id_grado_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and tipo_flor.id_tipo_flor = tf.id_tipo_flor
		and variedad_flor.id_variedad_flor = vf.id_variedad_flor
		and grado_flor.id_grado_flor = gf.id_grado_flor
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm,
		tf.id_tipo_flor,
		vf.id_variedad_flor,
		gf.id_grado_flor
	) as unidades_vendidas,
	(
		select sum(pieza.unidades_por_pieza * pieza.costo_por_unidad)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia,
		tipo_flor as tf,
		variedad_flor as vf,
		grado_flor as gf
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and pieza.id_variedad_flor = vf.id_variedad_flor
		and pieza.id_grado_flor = gf.id_grado_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and tipo_flor.id_tipo_flor = tf.id_tipo_flor
		and variedad_flor.id_variedad_flor = vf.id_variedad_flor
		and grado_flor.id_grado_flor = gf.id_grado_flor
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm,
		tf.id_tipo_flor,
		vf.id_variedad_flor,
		gf.id_grado_flor
	) as gross_cost_directas_terceros,
	(
		select sum(pieza.unidades_por_pieza * pieza.costo_por_unidad) + (sum(tipo_caja.factor_a_full) * max(ciudad.impuesto_por_caja))
		from 
		pieza,
		caja, 
		tipo_caja,
		ciudad,
		farm as f,
		guia,
		tipo_flor as tf,
		variedad_flor as vf,
		grado_flor as gf
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and f.id_ciudad = ciudad.id_ciudad
		and pieza.id_guia = guia.id_guia
		and pieza.id_variedad_flor = vf.id_variedad_flor
		and pieza.id_grado_flor = gf.id_grado_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and tipo_flor.id_tipo_flor = tf.id_tipo_flor
		and variedad_flor.id_variedad_flor = vf.id_variedad_flor
		and grado_flor.id_grado_flor = gf.id_grado_flor
		and not exists
		(
			select * from detalle_item_factura
			where detalle_item_factura.id_pieza = pieza.id_pieza
		)
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm,
		tf.id_tipo_flor,
		vf.id_variedad_flor,
		gf.id_grado_flor
	) as inventory_cost_directas_terceros,
	(
		select sum(item_factura.valor_unitario * pieza.unidades_por_pieza)
		from 
		detalle_item_factura,
		item_factura,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia,
		tipo_flor as tf,
		variedad_flor as vf,
		grado_flor as gf
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and pieza.id_variedad_flor = vf.id_variedad_flor
		and pieza.id_grado_flor = gf.id_grado_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and tipo_flor.id_tipo_flor = tf.id_tipo_flor
		and variedad_flor.id_variedad_flor = vf.id_variedad_flor
		and grado_flor.id_grado_flor = gf.id_grado_flor
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm,
		tf.id_tipo_flor,
		vf.id_variedad_flor,
		gf.id_grado_flor
	) as valor,
	(
		select sum(cargo.valor_cargo)
		from 
		detalle_item_factura,
		item_factura,
		cargo,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia,
		tipo_flor as tf,
		variedad_flor as vf,
		grado_flor as gf
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and item_factura.id_item_factura = cargo.id_item_factura
		and pieza.id_variedad_flor = vf.id_variedad_flor
		and pieza.id_grado_flor = gf.id_grado_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and tipo_flor.id_tipo_flor = tf.id_tipo_flor
		and variedad_flor.id_variedad_flor = vf.id_variedad_flor
		and grado_flor.id_grado_flor = gf.id_grado_flor
		and item_factura.cargo_incluido = 0
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm,
		tf.id_tipo_flor,
		vf.id_variedad_flor,
		gf.id_grado_flor
	) as cargo_no_incluido,
	(
		select sum(cargo.valor_cargo)
		from 
		detalle_item_factura,
		item_factura,
		cargo,
		factura,
		pieza,
		caja, 
		tipo_caja,
		farm as f,
		guia,
		tipo_flor as tf,
		variedad_flor as vf, 
		grado_flor as gf
		where pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and pieza.id_farm = f.id_farm
		and f.idc_farm = farm.idc_farm
		and pieza.id_guia = guia.id_guia
		and item_factura.id_item_factura = cargo.id_item_factura
		and pieza.id_variedad_flor = vf.id_variedad_flor
		and pieza.id_grado_flor = gf.id_grado_flor
		and tf.id_tipo_flor = vf.id_tipo_flor
		and tf.id_tipo_flor = gf.id_tipo_flor
		and tipo_flor.id_tipo_flor = tf.id_tipo_flor
		and variedad_flor.id_variedad_flor = vf.id_variedad_flor
		and grado_flor.id_grado_flor = gf.id_grado_flor
		and item_factura.cargo_incluido = 1
		and guia.fecha_guia between
		@fecha_inicial and @fecha_final
		group by
		f.idc_farm,
		tf.id_tipo_flor,
		vf.id_variedad_flor,
		gf.id_grado_flor
	) as cargo_incluido into #temp_tipo
	from 
	pieza,
	farm,
	tipo_farm,
	guia,
	estado_guia,
	tipo_caja,
	caja,
	ciudad,
	tipo_flor,
	variedad_flor,
	grado_flor
	where guia.fecha_guia between
	@fecha_inicial and @fecha_final
	and pieza.id_farm = farm.id_farm
	and tipo_farm.id_tipo_farm = farm.id_tipo_farm
	and pieza.id_guia = guia.id_guia
	and estado_guia.id_estado_guia = guia.id_estado_guia
	and pieza.id_caja = caja.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and farm.id_ciudad = ciudad.id_ciudad
	and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	group by tipo_farm.nombre_tipo_farm,
	farm.idc_farm,
	ciudad.id_ciudad,
	ciudad.idc_ciudad,
	farm.id_farm,
	farm.nombre_farm,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	variedad_flor.id_variedad_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	grado_flor.id_grado_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor))

	alter table #temp_tipo
	add valor_credito decimal(20,4),
	freight decimal(20,4),
	gross_cost decimal(20,4),
	inventory_cost decimal(20,4),
	farm_credit decimal(20,4)

	select farm.idc_farm, 
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	detalle_credito.valor_credito into #temp2_tipo
	from guia, 
	pieza, 
	farm, 
	detalle_item_factura, 
	item_factura, 
	detalle_credito,
	tipo_flor,
	variedad_flor,
	grado_flor
	where pieza.id_guia = guia.id_guia
	and guia.fecha_guia between
	@fecha_inicial and @fecha_final
	and pieza.id_farm = farm.id_farm
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and detalle_item_factura.id_item_factura = item_factura.id_item_factura
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza.id_grado_flor = grado_flor.id_grado_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and detalle_credito.id_guia in 
	(
		select id_guia from guia
		where fecha_guia between
		@fecha_inicial and @fecha_final
	)
	group by farm.idc_farm, 
	tipo_flor.id_tipo_flor,
	variedad_flor.id_variedad_flor,
	grado_flor.id_grado_flor,
	detalle_credito.id_detalle_credito,
	detalle_credito.id_tipo_detalle_credito,
	detalle_credito.id_guia,
	detalle_credito.id_credito,
	detalle_credito.id_item_factura,
	detalle_credito.valor_credito,
	detalle_credito.cantidad_credito

	select idc_farm, 
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	sum(valor_credito) as valor_credito into #temp3_tipo
	from #temp2_tipo
	group by idc_farm,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor

	update #temp_tipo
	set valor_credito = #temp3_tipo.valor_credito
	from #temp3_tipo
	where #temp_tipo.idc_farm = #temp3_tipo.idc_farm
	and #temp_tipo.id_tipo_flor = #temp3_tipo.id_tipo_flor
	and #temp_tipo.id_variedad_flor = #temp3_tipo.id_variedad_flor
	and #temp_tipo.id_grado_flor = #temp3_tipo.id_grado_flor

	SELECT guia.id_guia,
	f.id_farm,
	f.idc_farm,
	tf.id_tipo_flor,
	vf.id_variedad_flor,
	gf.id_grado_flor,
	((CASE 
	  WHEN estado_guia.idc_estado_guia = 'C' THEN guia.valor_impuesto + guia.valor_flete
	  ELSE ciudad.impuesto_por_caja
	END) * sum(tipo_caja.factor_a_full)) / 
	(
		select sum(tipo_caja.factor_a_full) 
		from guia as g, 
		pieza, 
		caja, 
		tipo_caja,
		tipo_flor,
		variedad_flor,
		grado_flor
		where pieza.id_guia = g.id_guia
		and pieza.id_caja = caja.id_caja
		and caja.id_tipo_caja = tipo_caja.id_tipo_caja
		and guia.id_guia = g.id_guia
		and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
		and pieza.id_grado_flor = grado_flor.id_grado_flor
		and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
		and tf.id_tipo_flor = tipo_flor.id_tipo_flor
		and vf.id_variedad_flor = variedad_flor.id_variedad_flor
		and gf.id_grado_flor = grado_flor.id_grado_flor
	) as impuesto_guia,
	(
		select sum(valor_credito_farm)
		from guia as g,
		credito_farm,
		farm 
		where guia.id_guia = g.id_guia
		and farm.id_farm = f.id_farm
		and g.id_guia = credito_farm.id_guia
		and farm.id_farm = credito_farm.id_farm
	) as farm_credit  into #impuesto_guia_tipo
	FROM guia,
	farm as f,
	ciudad,
	estado_guia,
	pieza,
	caja,
	tipo_caja,
	tipo_flor as tf,
	variedad_flor as vf,
	grado_flor as gf
	where pieza.id_guia = guia.id_guia
	and pieza.id_farm = f.id_farm
	and f.id_ciudad = ciudad.id_ciudad
	and guia.id_estado_guia = estado_guia.id_estado_guia
	and pieza.id_caja = caja.id_caja
	and caja.id_tipo_caja = tipo_caja.id_tipo_caja
	and pieza.id_variedad_flor = vf.id_variedad_flor
	and pieza.id_grado_flor = gf.id_grado_flor
	and tf.id_tipo_flor = vf.id_tipo_flor
	and tf.id_tipo_flor = gf.id_tipo_flor
	and guia.fecha_guia between
	@fecha_inicial and @fecha_final
	group by
	f.id_farm,
	tf.id_tipo_flor,
	vf.id_variedad_flor,
	gf.id_grado_flor,
	ciudad.impuesto_por_caja,
	guia.id_guia,
	CASE 
	  WHEN estado_guia.idc_estado_guia = 'C' THEN guia.valor_impuesto + guia.valor_flete
	  ELSE ciudad.impuesto_por_caja
	END,
	f.idc_farm

	select id_farm, 
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor,
	idc_farm, 
	sum(farm_credit) as farm_credit,
	sum(impuesto_guia) as impuesto_guia into #impuesto_guia_final_tipo
	from #impuesto_guia_tipo
	group by id_farm, 
	idc_farm,
	id_tipo_flor,
	id_variedad_flor,
	id_grado_flor

	update #temp_tipo
	set freight = #impuesto_guia_final_tipo.impuesto_guia,
	farm_credit = #impuesto_guia_final_tipo.farm_credit
	from #impuesto_guia_final_tipo
	where #impuesto_guia_final_tipo.id_farm = #temp_tipo.id_farm
	and #impuesto_guia_final_tipo.id_tipo_flor = #temp_tipo.id_tipo_flor
	and #impuesto_guia_final_tipo.id_variedad_flor = #temp_tipo.id_variedad_flor
	and #impuesto_guia_final_tipo.id_grado_flor = #temp_tipo.id_grado_flor

	update #temp_tipo
	set gross_cost = (((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0)) - (isnull(cargo_no_incluido,0) + isnull(cargo_incluido,0))) * (1 - (farm.comision_farm / 100)) - isnull(fulls_vendidas,0) * configuracion_bd.impuesto_carga,
	inventory_cost = 0
	from farm, configuracion_bd
	where farm.id_farm = #temp_tipo.id_farm
	and #temp_tipo.nombre_tipo_farm = 'Natuflora'

	update #temp_tipo
	set gross_cost = (isnull(valor,0) + isnull(cargo_no_incluido,0)) * (1 - (farm.comision_farm / 100)),
	inventory_cost = 0
	from farm
	where farm.id_farm = #temp_tipo.id_farm
	and #temp_tipo.nombre_tipo_farm = 'Natuflora BOUQUETS'

	update #temp_tipo
	set gross_cost = isnull(gross_cost_directas_terceros,0),
	inventory_cost = isnull(inventory_cost_directas_terceros,0)
	where #temp_tipo.nombre_tipo_farm in ('Directas', 'Terceros')

	select nombre_tipo_farm,
	idc_farm,
	nombre_farm,
	idc_ciudad,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	fulls_vendidas,
	unidades_vendidas,
	gross_cost,
	farm_credit,
	isnull(gross_cost, 0) + isnull(farm_credit, 0) as net_cost,
	(isnull(gross_cost, 0) + isnull(farm_credit, 0)) / isnull(unidades_vendidas,1) as cost_average,
	freight,
	freight / isnull(fulls_vendidas,1) as freight_by_box,
	isnull(valor,0) + isnull(cargo_no_incluido,0) as gross_sales,
	isnull(valor_credito, 0) as credits,
	(isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0) as net_sales,
	((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0)) / isnull(unidades_vendidas,1) as sales_average,
	((isnull(gross_cost, 0) + isnull(farm_credit, 0)) + freight - ((isnull(valor ,0)+ isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0))) * -1 as profit_loss,
	case
		when ((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0)) = 0 then null
		else ((((isnull(gross_cost, 0) + isnull(farm_credit, 0)) + freight - ((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0))) * -1) /((isnull(valor,0) + isnull(cargo_no_incluido,0)) + isnull(valor_credito, 0))) * 100
	end as profit_loss_porcentaje,
	isnull(fulls_recibidas, 0) - isnull(fulls_vendidas, 0) as fulls_inventory,
	inventory_cost
	from #temp_tipo 
	order by nombre_tipo_farm, 
	idc_farm,
	idc_tipo_flor,
	idc_variedad_flor,
	idc_grado_flor

	drop table #temp_tipo
	drop table #temp2_tipo
	drop table #temp3_tipo
	drop table #impuesto_guia_tipo
	drop table #impuesto_guia_final_tipo
end