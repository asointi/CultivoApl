set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[fs_consultar_reporte_flora_stats]

@fecha_reporte_string nvarchar(255)

AS
BEGIN
declare @fecha_reporte datetime
set @fecha_reporte = convert(datetime, @fecha_reporte_string,101)

declare @datefirst int,@weekday int
select @datefirst = @@datefirst, @weekday = datepart(weekday,@fecha_reporte)

	IF @datefirst + @weekday = 8
	BEGIN
---------------------------------Fixed
		select item_factura.id_item_factura,
		item_Factura.cargo_incluido,
		pieza.id_variedad_flor,
		pieza.id_grado_flor,
		isnull(sum(pieza.unidades_por_pieza),0) as fixed_units,
		isnull(sum(Item_Factura.valor_unitario * Pieza.unidades_por_pieza), 0) as valor_inicial
		into #fixed
		from
		pieza,
		detalle_item_factura,
		item_factura,
		factura,
		tipo_factura,
		cliente_despacho
		where
		pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and factura.id_tipo_factura = tipo_factura.id_tipo_factura
		and factura.id_despacho = cliente_despacho.id_despacho
		and tipo_factura.idc_tipo_factura in ('7','9')
		and factura.fecha_factura between @fecha_reporte and @fecha_reporte + 6
		group by
		item_factura.id_item_factura,
		item_Factura.cargo_incluido,
		pieza.id_variedad_flor,
		pieza.id_grado_flor
		------------------------Cargos
		SELECT 
		Item_Factura.id_item_factura, 
		Cargo.id_cargo, 
		Cargo.valor_cargo * COUNT(Pieza.Id_pieza) AS valor_cargo
		into #cargo1
		FROM 
		Cargo, 
		Item_Factura, 
		Detalle_Item_Factura, 
		Pieza
		where Cargo.id_item_factura = Item_Factura.id_item_factura
		and Item_Factura.id_item_factura = Detalle_Item_Factura.id_item_factura
		and Detalle_Item_Factura.Id_pieza = Pieza.Id_pieza
		GROUP BY 
		Item_Factura.id_item_factura, 
		Cargo.id_cargo,
		Cargo.valor_cargo
		--agrego columnas cargo y valor unitario
		alter table #fixed
		add valor_cargo decimal(20,4) NOT NULL default (0),
		valor_unitario decimal(20,4) NOT NULL default (0)
		--agregro cargo
		update #fixed
		set valor_cargo = isnull(#cargo1.valor_cargo, 0)
		from #fixed, #cargo1
		where #fixed.id_item_factura=#cargo1.id_item_factura
		and #fixed.cargo_incluido = 0
		---agrego valor unitario
		update #fixed
		set valor_unitario = (valor_inicial + valor_cargo)/fixed_units
		-------------------------------------------------------------
		---------------------Open Market
		select item_factura.id_item_factura,
		item_Factura.cargo_incluido,
		pieza.id_variedad_flor,
		pieza.id_grado_flor,
		isnull(sum(pieza.unidades_por_pieza),0) as open_market_units,
		isnull(sum(Item_Factura.valor_unitario * Pieza.unidades_por_pieza), 0) as valor_inicial
		into #open_market
		from
		pieza,
		detalle_item_factura,
		item_factura,
		factura,
		tipo_factura,
		cliente_despacho
		where
		pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and factura.id_tipo_factura = tipo_factura.id_tipo_factura
		and factura.id_despacho = cliente_despacho.id_despacho
		and tipo_factura.idc_tipo_factura not in ('7','9')
		and factura.fecha_factura between @fecha_reporte and @fecha_reporte + 6
		group by
		item_factura.id_item_factura,
		item_Factura.cargo_incluido,
		pieza.id_variedad_flor,
		pieza.id_grado_flor
		------------------------Cargos
		SELECT 
		Item_Factura.id_item_factura, 
		Cargo.id_cargo, 
		Cargo.valor_cargo * COUNT(Pieza.Id_pieza) AS valor_cargo
		into #cargo2
		FROM 
		Cargo, 
		Item_Factura, 
		Detalle_Item_Factura, 
		Pieza
		where Cargo.id_item_factura = Item_Factura.id_item_factura
		and Item_Factura.id_item_factura = Detalle_Item_Factura.id_item_factura
		and Detalle_Item_Factura.Id_pieza = Pieza.Id_pieza
		GROUP BY 
		Item_Factura.id_item_factura, 
		Cargo.id_cargo,
		Cargo.valor_cargo
		--agrego columnas cargo y valor unitario
		alter table #open_market
		add valor_cargo decimal(20,4) NOT NULL default (0),
		valor_unitario decimal(20,4) NOT NULL default (0)
		--agregro cargo
		update #open_market
		set valor_cargo = isnull(#cargo2.valor_cargo, 0)
		from #open_market, #cargo2
		where #open_market.id_item_factura=#cargo2.id_item_factura
		and #open_market.cargo_incluido = 0
		---agrego valor unitario
		update #open_market
		set valor_unitario = (valor_inicial + valor_cargo)/open_market_units
		-------------------------------------------------------
		---------------------Dumped
		select
		Item_Factura.id_item_factura,
		pieza.id_variedad_flor,
		pieza.id_grado_flor,
		isnull(sum(pieza.unidades_por_pieza),0) as dumped_units 
		into #dumped
		from
		pieza,
		detalle_item_factura,
		item_factura,
		factura,
		cliente_despacho
		where
		pieza.id_pieza = detalle_item_factura.id_pieza
		and detalle_item_factura.id_item_factura = item_factura.id_item_factura
		and item_factura.id_factura = factura.id_factura
		and factura.id_despacho = cliente_despacho.id_despacho
		and cliente_despacho.idc_cliente_despacho = 'ZDUMPMI'
		and factura.fecha_factura between @fecha_reporte and @fecha_reporte + 6
		group by
		Item_Factura.id_item_factura,
		pieza.id_variedad_flor,
		pieza.id_grado_flor
		--------------------------------------------------------------------
		-----------FloraStatsReport
		select 
		flora_stats_registro.id_flora_stats,
		isnull(sum(cast(#fixed.fixed_units as bigint)),0) as fixed_units,
		isnull(avg(#fixed.valor_unitario),0) as fixed_price,
		isnull(sum(cast(#open_market.open_market_units as bigint)),0) as open_market_units,
		isnull(avg(#open_market.valor_unitario),0) as open_market_price,
		isnull(sum(cast(#dumped.dumped_units as bigint)),0)as dumped_units into #flora_stats_registro
		from 
		flora_stats_registro
		join #fixed on
		flora_stats_registro.id_variedad_flor = #fixed.id_variedad_flor
		and flora_stats_registro.id_grado_flor = #fixed.id_grado_flor
		full join #open_market on
		flora_stats_registro.id_variedad_flor = #open_market.id_variedad_flor
		and flora_stats_registro.id_grado_flor = #open_market.id_grado_flor
		full join #dumped on
		flora_stats_registro.id_variedad_flor = #dumped.id_variedad_flor
		and flora_stats_registro.id_grado_flor = #dumped.id_grado_flor
		group by
		flora_stats_registro.id_flora_stats
		order by
		flora_stats_registro.id_flora_stats
		-----------FloraStats
		select 
		flora_stats.id_flora_stats,
		flora_stats.numero_flora_stats,
		flora_stats.nombre_flora_stats_flower,
		flora_stats.nombre_flora_stats_grade,
		flora_stats.nombre_flora_stats_color,
		flora_stats_packaging.nombre_packaging,
		isnull(sum(#flora_stats_registro.fixed_units),0) as fixed_units,
		isnull(avg(#flora_stats_registro.fixed_price),0) as fixed_price,
		isnull(sum(#flora_stats_registro.open_market_units),0) as open_market_units,
		isnull(avg(#flora_stats_registro.open_market_price),0) as open_market_price,
		isnull(sum(#flora_stats_registro.dumped_units),0)as dumped_units
		from 
		flora_stats
		join flora_stats_packaging on 
		flora_stats.id_packaging = flora_stats_packaging.id_packaging
		left join #flora_stats_registro on
		flora_stats.id_flora_stats = #flora_stats_registro.id_flora_stats
		group by
		flora_stats.id_flora_stats,
		flora_stats.numero_flora_stats,
		flora_stats.nombre_flora_stats_flower,
		flora_stats.nombre_flora_stats_grade,
		flora_stats.nombre_flora_stats_color,
		flora_stats_packaging.nombre_packaging
		order by flora_stats.numero_flora_stats
		--------------------------------
		drop table #cargo1
		drop table #cargo2

		drop table #fixed
		drop table #open_market
		drop table #dumped
		drop table #flora_stats_registro
	END
END