set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_generar_reporte_preventas_por_color]

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

if(@accion = 'consultar_todos_color')
begin
	select idc_color,
	ltrim(rtrim(color.nombre_color)) as nombre_color
	from color
	where color.id_color in (select id from #temp)
	group by idc_color,
	ltrim(rtrim(color.nombre_color))
end
else
if(@accion = 'consultar_detalle')
begin
	select max(id_orden_pedido) as id_orden_pedido into #orden_maxima
	from orden_pedido
	group by id_orden_pedido_padre

	select cliente_factura.idc_cliente_factura,
	(
		select top 1 ltrim(rtrim(cd.nombre_cliente ))
		from cliente_despacho as cd
		where cliente_factura.idc_cliente_factura = cd.idc_cliente_despacho
	) as nombre_cliente,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	sum(orden_pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as unidades,
	sum(tipo_caja.factor_a_full * orden_pedido.cantidad_piezas) as fulles,
	sum(orden_pedido.valor_unitario * orden_pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as valor
	from orden_pedido,
	tipo_flor,
	tipo_caja,
	color,
	variedad_flor,
	tipo_factura,
	cliente_despacho,
	cliente_factura
	where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and color.id_color = variedad_flor.id_color
	and orden_pedido.fecha_inicial between
	@fecha_inicial and @fecha_final
	and color.id_color in (select id from #temp)
	and tipo_flor.id_tipo_flor = @id_tipo_flor
	and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
	and tipo_factura.idc_tipo_factura = '4'
	and orden_pedido.disponible = 1
	and exists
	(
		select * 
		from #orden_maxima
		where #orden_maxima.id_orden_pedido = orden_pedido.id_orden_pedido
	)
	and cliente_despacho.id_despacho = orden_pedido.id_despacho
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	group by cliente_factura.idc_cliente_factura,
	tipo_flor.id_tipo_flor,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor))
	order by unidades desc,
	cliente_factura.idc_cliente_factura

	drop table #orden_maxima
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

drop table #temp