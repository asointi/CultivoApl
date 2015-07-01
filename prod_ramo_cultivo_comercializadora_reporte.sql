set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_ramo_cultivo_comercializadora_reporte]

@fecha_inicial datetime,
@fecha_final datetime,
@id_tipo_flor int,
@id_variedad_flor_natural int,
@id_variedad_flor_fresca int,
@accion nvarchar(50)

as

set @fecha_inicial = dateadd(dd, -1, @fecha_inicial)

if(@accion = 'consultar_datos_reporte')
begin
	declare @idc_tipo_flor nvarchar(10),
	@idc_variedad_flor nvarchar(10),
	@natural nvarchar(50),
	@fresca nvarchar(50),
	@idc_finca_reembonche nvarchar(5),
	@idc_finca_inicial_natural nvarchar(5),
	@idc_finca_final_natural nvarchar(5),
	@idc_finca_inicial_fresca nvarchar(5),
	@idc_finca_final_fresca nvarchar(5),
	@idc_tipo_flor_fresca nvarchar(10),
	@idc_variedad_flor_fresca nvarchar(10),
	@nombre_tipo_flor_fresca nvarchar(100),
	@nombre_variedad_flor_fresca nvarchar(100),
	@nombre_tipo_flor nvarchar(100),
	@nombre_variedad_flor nvarchar(100),
	
	@tipo_credito_excluido_natural nvarchar(10)

	select @idc_tipo_flor_fresca = tipo_flor.idc_tipo_flor,
	@idc_variedad_flor_fresca = variedad_flor.idc_variedad_flor,
	@nombre_tipo_flor_fresca = ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	@nombre_variedad_flor_fresca = ltrim(rtrim(variedad_flor.nombre_variedad_flor))
	from bd_fresca.bd_fresca.dbo.tipo_flor,
	bd_fresca.bd_fresca.dbo.variedad_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = @id_variedad_flor_fresca

	select @idc_tipo_flor = tipo_flor.idc_tipo_flor,
	@idc_variedad_flor = variedad_flor.idc_variedad_flor,
	@nombre_tipo_flor = ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	@nombre_variedad_flor = ltrim(rtrim(variedad_flor.nombre_variedad_flor))
	from bd_nf.bd_nf.dbo.tipo_flor,
	bd_nf.bd_nf.dbo.variedad_flor
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = @id_variedad_flor_natural

	set @idc_finca_reembonche = 'ZX'
	set @natural = 'NATURAL'
	set @fresca = 'FRESCA'
	set @idc_finca_inicial_natural = 'N '
	set @idc_finca_final_natural = 'NZ'
	set @idc_finca_inicial_fresca = 'AM'
	set @idc_finca_final_fresca = 'AN'
	set @tipo_credito_excluido_natural = 'RB'

	create table #ramo
	(
		idc_finca nvarchar(10),
		nombre_finca nvarchar(50),
		fecha datetime,
		tallos_por_ramo int,
		idc_ramo nvarchar(25),
		comercializadora nvarchar(50) null,
		idc_cliente_factura nvarchar(25),
		nombre_cliente nvarchar(60),
		fecha_factura datetime,
		unidades_credito int,
		id_cliente_factura int
	)

	insert into #ramo (idc_finca, nombre_finca, fecha, tallos_por_ramo, idc_ramo)
	select 'NA' as idc_finca,
	'NATUFLORA' as nombre_finca,
	convert(datetime,convert(nvarchar,ramo.fecha_entrada, 101)) as fecha,
	ramo.tallos_por_ramo,
	ramo.idc_ramo
	from ramo,
	tipo_flor,
	variedad_flor
	where convert(datetime,convert(nvarchar,ramo.fecha_entrada, 101)) between
	dateadd(dd, -30, @fecha_inicial) and @fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = ramo.id_variedad_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor

	insert into #ramo (idc_finca, nombre_finca, fecha, tallos_por_ramo, idc_ramo)
	select finca.idc_finca,
	finca.nombre_finca,
	convert(datetime,convert(nvarchar,ramo_comprado.fecha_lectura, 101)) as fecha,
	ramo_comprado.tallos_por_ramo,
	ramo_comprado.idc_ramo_comprado
	from ramo_comprado,
	finca,
	finca_asignada,
	etiqueta_impresa_finca_asignada,
	tipo_flor,
	variedad_flor
	where finca.id_finca = finca_asignada.id_finca
	and finca_asignada.id_finca = etiqueta_impresa_finca_asignada.id_finca
	and etiqueta_impresa_finca_asignada.id_etiqueta_impresa_finca_asignada = ramo_comprado.id_etiqueta_impresa_finca_asignada
	and convert(datetime,convert(nvarchar,ramo_comprado.fecha_lectura, 101)) between
	dateadd(dd, -30, @fecha_inicial) and @fecha_final
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = ramo_comprado.id_variedad_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor

	select @fresca as comercializadora, 
	f.idc_llave_factura+f.idc_numero_factura as factura,
	f.fecha_factura, 
	r.idc_ramo, 
	cf.idc_cliente_factura,
	cf.id_cliente_factura,
	(
		select ltrim(rtrim(cd.nombre_cliente))
		from bd_fresca.bd_fresca.dbo.cliente_despacho as cd
		where cd.id_cliente_factura = cf.id_cliente_factura
		and ltrim(rtrim(cd.idc_cliente_despacho)) = ltrim(rtrim(cf.idc_cliente_factura))
	) as nombre_cliente into #fresca
	from bd_fresca.bd_fresca.dbo.ramo as r,
	bd_fresca.bd_fresca.dbo.pieza as p,
	bd_fresca.bd_fresca.dbo.detalle_item_factura as dif,
	bd_fresca.bd_fresca.dbo.item_factura as ifac,
	bd_fresca.bd_fresca.dbo.factura as f,
	bd_fresca.bd_fresca.dbo.cliente_factura as cf
	where p.id_pieza = r.id_pieza
	and p.id_pieza = dif.id_pieza
	and ifac.id_item_factura = dif.id_item_factura
	and f.id_factura = ifac.id_factura
	and cf.id_cliente_factura = f.id_cliente_factura
	and f.fecha_factura > =	@fecha_inicial 
	and f.fecha_factura < =	@fecha_final

	select @natural as comercializadora, 
	f.idc_llave_factura+f.idc_numero_factura as factura,
	f.fecha_factura, 
	r.idc_ramo, 
	cf.idc_cliente_factura,
	cf.id_cliente_factura,
	(
		select ltrim(rtrim(cd.nombre_cliente))
		from bd_nf.bd_nf.dbo.cliente_despacho as cd
		where cd.id_cliente_factura = cf.id_cliente_factura
		and ltrim(rtrim(cd.idc_cliente_despacho)) = ltrim(rtrim(cf.idc_cliente_factura))
	) as nombre_cliente into #natural
	from bd_nf.bd_nf.dbo.ramo as r,
	bd_nf.bd_nf.dbo.pieza as p,
	bd_nf.bd_nf.dbo.detalle_item_factura as dif,
	bd_nf.bd_nf.dbo.item_factura as ifac,
	bd_nf.bd_nf.dbo.factura as f,
	bd_nf.bd_nf.dbo.cliente_factura as cf
	where p.id_pieza = r.id_pieza
	and p.id_pieza = dif.id_pieza
	and ifac.id_item_factura = dif.id_item_factura
	and f.id_factura = ifac.id_factura
	and cf.id_cliente_factura = f.id_cliente_factura
	and f.fecha_factura > =	@fecha_inicial 
	and f.fecha_factura < =	@fecha_final

	select cliente_factura.idc_cliente_factura,
	factura.fecha_factura,
	detalle_credito.id_detalle_credito,
	detalle_credito.cantidad_credito into #credito_natural
	from bd_nf.bd_nf.dbo.credito,
	bd_nf.bd_nf.dbo.tipo_credito,
	bd_nf.bd_nf.dbo.detalle_credito,
	bd_nf.bd_nf.dbo.factura,
	bd_nf.bd_nf.dbo.item_factura,
	bd_nf.bd_nf.dbo.detalle_item_factura,
	bd_nf.bd_nf.dbo.pieza,
	bd_nf.bd_nf.dbo.variedad_flor,
	bd_nf.bd_nf.dbo.tipo_flor,
	bd_nf.bd_nf.dbo.farm,
	bd_nf.bd_nf.dbo.cliente_factura
	where credito.id_credito = detalle_credito.id_credito
	and tipo_credito.id_tipo_credito = credito.id_tipo_credito
	and tipo_credito.idc_tipo_credito <> @tipo_credito_excluido_natural
	and factura.id_factura = credito.id_factura
	and factura.id_factura = item_factura.id_factura
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and farm.id_farm = pieza.id_farm
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor
	and factura.fecha_factura > = @fecha_inicial 
	and factura.fecha_factura < = @fecha_final
	and cliente_factura.id_cliente_factura = factura.id_cliente_factura
	and farm.idc_farm > = @idc_finca_inicial_natural
	and farm.idc_farm < = @idc_finca_final_natural
	group by cliente_factura.idc_cliente_factura,
	factura.fecha_factura,
	detalle_credito.id_detalle_credito,
	detalle_credito.cantidad_credito

	select cliente_factura.idc_cliente_factura,
	factura.fecha_factura,
	detalle_credito.id_detalle_credito,
	detalle_credito.cantidad_credito into #credito_fresca
	from bd_fresca.bd_fresca.dbo.credito,
	bd_fresca.bd_fresca.dbo.detalle_credito,
	bd_fresca.bd_fresca.dbo.factura,
	bd_fresca.bd_fresca.dbo.item_factura,
	bd_fresca.bd_fresca.dbo.detalle_item_factura,
	bd_fresca.bd_fresca.dbo.pieza,
	bd_fresca.bd_fresca.dbo.variedad_flor,
	bd_fresca.bd_fresca.dbo.tipo_flor,
	bd_fresca.bd_fresca.dbo.farm,
	bd_fresca.bd_fresca.dbo.cliente_factura
	where credito.id_credito = detalle_credito.id_credito
	and factura.id_factura = credito.id_factura
	and factura.id_factura = item_factura.id_factura
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and farm.id_farm = pieza.id_farm
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.idc_tipo_flor = @idc_tipo_flor_fresca
	and variedad_flor.idc_variedad_flor = @idc_variedad_flor_fresca
	and factura.fecha_factura > = @fecha_inicial 
	and factura.fecha_factura < = @fecha_final
	and cliente_factura.id_cliente_factura = factura.id_cliente_factura
	and farm.idc_farm > = @idc_finca_inicial_fresca
	and farm.idc_farm < = @idc_finca_final_fresca
	group by cliente_factura.idc_cliente_factura,
	factura.fecha_factura,
	detalle_credito.id_detalle_credito,
	detalle_credito.cantidad_credito

	select idc_cliente_factura,
	fecha_factura,
	sum(cantidad_credito) as unidades_credito into #credito_fresca_agrupado
	from #credito_fresca
	group by idc_cliente_factura,
	fecha_factura

	select idc_cliente_factura,
	fecha_factura,
	sum(cantidad_credito) as unidades_credito into #credito_natural_agrupado
	from #credito_natural
	group by idc_cliente_factura,
	fecha_factura

	update #ramo
	set comercializadora = #fresca.comercializadora ,
	idc_cliente_factura  = #fresca.idc_cliente_factura,
	nombre_cliente = #fresca.nombre_cliente,
	fecha_factura = #fresca.fecha_factura,
	id_cliente_factura = #fresca.id_cliente_factura
	from #fresca
	where #fresca.idc_ramo = #ramo.idc_ramo

	update #ramo
	set comercializadora = #natural.comercializadora ,
	idc_cliente_factura  = #natural.idc_cliente_factura,
	nombre_cliente = #natural.nombre_cliente,
	fecha_factura = #natural.fecha_factura,
	id_cliente_factura = #natural.id_cliente_factura
	from #natural
	where #natural.idc_ramo = #ramo.idc_ramo

	select @fecha_inicial as fecha_inicial,
	@fecha_final as fecha_final,
	fecha, 
	comercializadora,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente,
	fecha_factura,
	sum(tallos_por_ramo) as tallos_por_ramo, 
	(
		select sum(tallos_por_ramo)
		from #ramo as r
		where r.idc_finca = #ramo.idc_finca
		and r.idc_finca = @idc_finca_reembonche
		and r.comercializadora = #ramo.comercializadora
		and r.idc_cliente_factura = #ramo.idc_cliente_factura
		and r.fecha_factura = #ramo.fecha_factura
	) as unidades_reembonche into #resultado
	from #ramo
	where comercializadora is not null
	group by idc_finca, 
	nombre_finca, 
	fecha, 
	comercializadora,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente,
	fecha_factura

	select fecha_inicial,
	fecha_final,
	fecha, 
	comercializadora,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente,
	fecha_factura,
	sum(tallos_por_ramo) as tallos_por_ramo, 
	sum(unidades_reembonche) as unidades_reembonche into #pantalla
	from #resultado
	group by fecha_inicial,
	fecha_final,
	fecha, 
	comercializadora,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente,
	fecha_factura

	alter table #pantalla
	add unidades_credito int

	update #pantalla
	set unidades_credito = #credito_fresca_agrupado.unidades_credito
	from #credito_fresca_agrupado
	where #pantalla.comercializadora = @fresca
	and #credito_fresca_agrupado.fecha_factura = #pantalla.fecha_factura
	and #credito_fresca_agrupado.idc_cliente_factura = #pantalla.idc_cliente_factura

	update #pantalla
	set unidades_credito = #credito_natural_agrupado.unidades_credito
	from #credito_natural_agrupado
	where #pantalla.comercializadora = @natural
	and #credito_natural_agrupado.fecha_factura = #pantalla.fecha_factura
	and #credito_natural_agrupado.idc_cliente_factura = #pantalla.idc_cliente_factura

	select fecha_inicial,
	fecha_final,
	fecha, 
	comercializadora,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente,
	fecha_factura,
	tallos_por_ramo, 
	unidades_reembonche,
	unidades_credito,
	0 as sombreado,
	case
		when comercializadora = @fresca then @fresca + ': ' + @nombre_tipo_flor_fresca + ' [' + @idc_tipo_flor_fresca + '] ' + @nombre_variedad_flor_fresca + ' [' + @idc_variedad_flor_fresca + ']'
		when comercializadora = @natural then @natural + ': ' + @nombre_tipo_flor + ' [' + @idc_tipo_flor + '] ' + @nombre_variedad_flor + ' [' + @idc_variedad_flor + ']'
	end as nombre_flor into #resultado_definitivo
	from #pantalla

	union all

	select @fecha_inicial,
	@fecha_final,
	fecha_factura as fecha,
	@fresca,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente,
	fecha_factura,
	0,
	null,
	null,
	1 as sombreado,
	@fresca + ': ' + @nombre_tipo_flor_fresca + ' [' + @idc_tipo_flor_fresca + '] ' + @nombre_variedad_flor_fresca + ' [' + @idc_variedad_flor_fresca + ']'
	from #pantalla
	group by fecha_factura,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente

	union all

	select @fecha_inicial,
	@fecha_final,
	fecha_factura as fecha,
	@natural,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente,
	fecha_factura,
	0,
	null,
	null,
	1 as sombreado,
	@natural + ': ' + @nombre_tipo_flor + ' [' + @idc_tipo_flor + '] ' + @nombre_variedad_flor + ' [' + @idc_variedad_flor + ']'
	from #pantalla
	group by fecha_factura,
	idc_cliente_factura,
	id_cliente_factura,
	nombre_cliente

	select *
	from #resultado_definitivo
	order by comercializadora,
	fecha_factura,
	idc_cliente_factura

	drop table #ramo
	drop table #fresca
	drop table #natural
	drop table #resultado
	drop table #pantalla
	drop table #credito_fresca
	drop table #credito_natural
	drop table #credito_natural_agrupado
	drop table #credito_fresca_agrupado
	drop table #resultado_definitivo
end