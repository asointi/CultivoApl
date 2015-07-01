set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_generar_reporte_concurso_ordenes_fijas]

as

select max(id_orden_pedido) as id_orden_pedido into #ordenes
from orden_pedido, 
tipo_factura 
where orden_pedido.disponible = 1
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
group by id_orden_pedido_padre


select '[' + vendedor.idc_vendedor + ']' + space(1) + ltrim(rtrim(vendedor.nombre)) as SalesPerson,
'[' + cliente_despacho.idc_cliente_despacho + ']' + space(1) + ltrim(rtrim(cliente_despacho.nombre_cliente)) as Customer,
'[' + tipo_flor.idc_tipo_flor + ']' + space(1) + ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as "Flower Type",
'[' + variedad_flor.idc_variedad_flor + ']' + space(1) + ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as "Flower Variety",
'[' + grado_flor.idc_grado_flor + ']' + space(1) + ltrim(rtrim(grado_flor.nombre_grado_flor)) as "Flower Grade",
'[' + farm.idc_farm + ']' + space(1) + ltrim(rtrim(farm.nombre_farm)) as "Farm",
'[' + ciudad.idc_ciudad + ']' + space(1) + ltrim(rtrim(ciudad.nombre_ciudad)) as "City",
tipo_caja.factor_a_full * sum(orden_pedido.cantidad_piezas) as "Fulls",
orden_pedido.unidades_por_pieza as "Units",
sum(orden_pedido.cantidad_piezas) as "Pieces",
orden_pedido.unidades_por_pieza * sum(orden_pedido.cantidad_piezas) as Total,
(
	select isnull(sum(op.cantidad_piezas), 0)
	from orden_pedido as op
	where op.disponible = 1
	and	
	(
		convert(datetime,'25/08/2011') between
		op.fecha_inicial and op.fecha_final
		or 
		convert(datetime,'31/08/2011') between
		op.fecha_inicial and op.fecha_final
		or op.fecha_inicial between
		convert(datetime,'25/08/2011') and convert(datetime,'31/08/2011')
	)
	and exists
	(
		select * 
		from #ordenes
		where #ordenes.id_orden_pedido = op.id_orden_pedido
	)
	and cliente_despacho.id_despacho = op.id_despacho
	and variedad_flor.id_variedad_flor = op.id_variedad_flor
	and grado_flor.id_grado_flor = op.id_grado_flor
	and farm.id_farm = op.id_farm
	and tipo_factura.id_tipo_factura = op.id_tipo_factura
) as "Week 08/25 - 08/31",
(
	select isnull(sum(op.cantidad_piezas), 0)
	from orden_pedido as op
	where op.disponible = 1
	and	
	(
		convert(datetime,'01/09/2011') between
		op.fecha_inicial and op.fecha_final
		or 
		convert(datetime,'07/09/2011') between
		op.fecha_inicial and op.fecha_final
		or op.fecha_inicial between
		convert(datetime,'01/09/2011') and convert(datetime,'07/09/2011')
	)
	and exists
	(
		select * 
		from #ordenes
		where #ordenes.id_orden_pedido = op.id_orden_pedido
	)
	and cliente_despacho.id_despacho = op.id_despacho
	and variedad_flor.id_variedad_flor = op.id_variedad_flor
	and grado_flor.id_grado_flor = op.id_grado_flor
	and farm.id_farm = op.id_farm
	and tipo_factura.id_tipo_factura = op.id_tipo_factura
) as "Week 09/01 - 09/07",
(
	select isnull(sum(op.cantidad_piezas), 0)
	from orden_pedido as op
	where op.disponible = 1
	and	
	(
		convert(datetime,'08/09/2011') between
		op.fecha_inicial and op.fecha_final
		or 
		convert(datetime,'14/09/2011') between
		op.fecha_inicial and op.fecha_final
		or op.fecha_inicial between
		convert(datetime,'08/09/2011') and convert(datetime,'14/09/2011')
	)
	and exists
	(
		select * 
		from #ordenes
		where #ordenes.id_orden_pedido = op.id_orden_pedido
	)
	and cliente_despacho.id_despacho = op.id_despacho
	and variedad_flor.id_variedad_flor = op.id_variedad_flor
	and grado_flor.id_grado_flor = op.id_grado_flor
	and farm.id_farm = op.id_farm
	and tipo_factura.id_tipo_factura = op.id_tipo_factura
) as "Week 09/08 - 09/14",
(
	select isnull(sum(op.cantidad_piezas), 0)
	from orden_pedido as op
	where op.disponible = 1
	and	
	(
		convert(datetime,'15/09/2011') between
		op.fecha_inicial and op.fecha_final
		or 
		convert(datetime,'21/09/2011') between
		op.fecha_inicial and op.fecha_final
		or op.fecha_inicial between
		convert(datetime,'15/09/2011') and convert(datetime,'21/09/2011')
	)
	and exists
	(
		select * 
		from #ordenes
		where #ordenes.id_orden_pedido = op.id_orden_pedido
	)
	and cliente_despacho.id_despacho = op.id_despacho
	and variedad_flor.id_variedad_flor = op.id_variedad_flor
	and grado_flor.id_grado_flor = op.id_grado_flor
	and farm.id_farm = op.id_farm
	and tipo_factura.id_tipo_factura = op.id_tipo_factura
) as "Week 09/15 - 09/21"
from orden_pedido,
tipo_factura,
vendedor,
cliente_despacho,
cliente_factura,
tipo_flor,
variedad_flor,
grado_flor,
farm,
ciudad,
tipo_caja
where tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and orden_pedido.disponible = 1
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '9'
--and convert(datetime,convert(nvarchar,getdate(), 103)) between
--orden_pedido.fecha_inicial and orden_pedido.fecha_final.
and	
(
	convert(datetime,'25/08/2011') between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or 
	convert(datetime,'21/09/2011') between
	orden_pedido.fecha_inicial and orden_pedido.fecha_final
	or orden_pedido.fecha_inicial between
	convert(datetime,'25/08/2011') and convert(datetime,'21/09/2011')
)
and exists
(
	select * 
	from #ordenes
	where #ordenes.id_orden_pedido = orden_pedido.id_orden_pedido
)
and vendedor.id_vendedor = cliente_factura.id_vendedor
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and farm.id_farm = orden_pedido.id_farm
and ciudad.id_ciudad = farm.id_ciudad
group by
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
ciudad.idc_ciudad,
ltrim(rtrim(ciudad.nombre_ciudad)),
orden_pedido.unidades_por_pieza,
tipo_factura.id_tipo_factura,
vendedor.id_vendedor,
cliente_despacho.id_despacho,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
farm.id_farm,
tipo_caja.factor_a_full
order by 
cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
tipo_flor.idc_tipo_flor,
variedad_flor.idc_variedad_flor,
grado_flor.idc_grado_flor,
farm.idc_farm,
ciudad.idc_ciudad,
orden_pedido.unidades_por_pieza

drop table #ordenes