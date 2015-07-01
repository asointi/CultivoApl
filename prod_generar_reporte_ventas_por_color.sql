set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_ventas_por_color]

@accion nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime,
@id_tipo_flor int,
@id_color nvarchar(255)

AS


create table #temp (id int)

/*crear la insercion para los valores separados por comas*/
declare @sql varchar(8000)
select @sql = 'insert into #temp select '+	replace(@id_color,',',' union all select ')

/*cargar todos los valores de la variable @id_color en la tabla temporal*/
exec (@SQL)

if(@accion = 'consultar_detalle')
begin
	select cliente_factura.idc_cliente_factura,
	(
		select top 1 ltrim(rtrim(cd.nombre_cliente ))
		from cliente_despacho as cd
		where cliente_factura.idc_cliente_factura = cd.idc_cliente_despacho
	) as nombre_cliente,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	sum(pieza.unidades_por_pieza) as unidades,
	sum(tipo_caja.factor_a_full) as fulles,
	isnull((
	  select sum(ifac.valor_unitario * p.unidades_por_pieza)
	  from Detalle_Item_Factura as dif,
	  item_factura as ifac,
	  factura as f,
	  pieza as p
	  where ifac.id_factura = f.id_factura
	  and dif.id_item_factura = ifac.id_item_factura
	  and dif.Id_pieza = p.Id_pieza
	  and pieza.id_pieza = p.Id_pieza
	), 0) as valor,
	isnull((
	  select sum(c.valor_cargo)
	  from Detalle_Item_Factura as dif,
	  item_factura as ifac,
	  factura as f,
	  cargo as c
	  where ifac.id_factura = f.id_factura
	  and dif.id_item_factura = ifac.id_item_factura
	  and dif.Id_pieza = Pieza.Id_pieza
	  and ifac.cargo_incluido = 0
	  and c.id_item_factura = ifac.id_item_factura
	), 0) as valor_cargo_no_incluido,
	isnull((
		select sum(dc.valor_credito)
		from credito as c,
		detalle_credito as dc,
		factura as f,
		item_factura as ifac,
		detalle_item_factura as dif
		where c.id_credito = dc.id_credito
		and c.id_factura = f.id_factura
		and dc.id_item_factura = ifac.id_item_factura
		and f.id_factura = ifac.id_factura
		and ifac.id_item_factura = dif.id_item_factura
		and pieza.id_pieza = dif.id_pieza
		and dc.id_guia = guia.id_guia
	), 0) as valor_credito into #resultado
	from pieza,
	detalle_item_factura,
	item_factura,
	factura,
	tipo_flor,
	caja,
	tipo_caja,
	color,
	variedad_flor,
	tipo_factura,
	cliente_despacho,
	cliente_factura,
	guia
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
	and caja.id_caja = pieza.id_caja
	and tipo_caja.id_tipo_caja = caja.id_tipo_caja
	and color.id_color = variedad_flor.id_color
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and item_factura.id_item_factura = detalle_item_factura.id_item_factura
	and factura.id_factura = item_factura.id_factura
	and factura.fecha_factura between
	@fecha_inicial and @fecha_final
	and color.id_color in (select id from #temp)
	and tipo_flor.id_tipo_flor = @id_tipo_flor
	and tipo_factura.id_tipo_factura = factura.id_tipo_factura
	and tipo_factura.idc_tipo_factura in ('1', '4')
	and cliente_despacho.id_despacho = factura.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and guia.id_guia = pieza.id_guia
	group by cliente_factura.idc_cliente_factura,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	pieza.id_pieza,
	guia.id_guia

	select idc_cliente_factura,
	nombre_cliente,
	valor_credito,
	sum(fulles) as fulles,
	sum(valor) + sum(valor_cargo_no_incluido) as gross_sales,
	sum(unidades) as unidades into #resultado2
	from #resultado
	group by idc_cliente_factura,
	nombre_cliente,
	valor_credito

	select idc_cliente_factura,
	nombre_cliente,
	sum(fulles) as fulles,
	sum(gross_sales) + sum(valor_credito) as net_sales,
	sum(unidades) as unidades
	from #resultado2
	group by idc_cliente_factura,
	nombre_cliente,
	valor_credito
	order by unidades desc,
	idc_cliente_factura

	drop table #resultado
	drop table #resultado2
end
else
if(@accion = 'consultar_color')
begin
	select color.id_color,
	color.idc_color,
	ltrim(rtrim(color.nombre_color)) as nombre_color,
	ltrim(rtrim(color.nombre_color)) + space(1) + '[' + color.idc_color + ']' as nombre_completo
	from tipo_flor,
	variedad_flor,
	color
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and color.id_color = variedad_flor.id_color
	and tipo_flor.id_tipo_flor = @id_tipo_flor
	and variedad_flor.disponible = 1
	group by color.id_color,
	color.idc_color,
	ltrim(rtrim(color.nombre_color))
	order by nombre_color
end
else
if(@accion = 'consultar_todos_color')
begin
	select idc_color,
	ltrim(rtrim(color.nombre_color)) as nombre_color
	from color
	where color.id_color in (select id from #temp)
	group by idc_color,
	ltrim(rtrim(color.nombre_color))
end

drop table #temp