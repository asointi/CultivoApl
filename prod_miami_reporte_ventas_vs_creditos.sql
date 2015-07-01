set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[prod_miami_reporte_ventas_vs_creditos]

@fecha_inicial datetime,
@fecha_final datetime,
@id_variedad_flor int,
@id_farm int

AS

select sum(pieza.unidades_por_pieza) as unidades_por_pieza,
cliente_factura.idc_cliente_factura,
cliente_factura.id_cliente_factura,
item_factura.valor_unitario * sum(pieza.unidades_por_pieza) as valor,
isnull((
	select sum(detalle_credito.valor_credito)
	from credito,
	detalle_credito,
	tipo_credito,
	tipo_detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and tipo_credito.id_tipo_credito = credito.id_tipo_credito
	and tipo_credito.aplica_a_farm = 1
	and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
	and tipo_detalle_credito.id_tipo_detalle_credito = 2
), 0) as valor_credito,
isnull((
	select sum(detalle_credito.cantidad_credito)
	from credito,
	detalle_credito,
	tipo_credito,
	tipo_detalle_credito
	where credito.id_credito = detalle_credito.id_credito
	and item_factura.id_item_factura = detalle_credito.id_item_factura
	and tipo_credito.id_tipo_credito = credito.id_tipo_credito
	and tipo_credito.aplica_a_farm = 1
	and tipo_detalle_credito.id_tipo_detalle_credito = detalle_credito.id_tipo_detalle_credito
	and tipo_detalle_credito.id_tipo_detalle_credito = 2
), 0) as unidades_credito into #temp
from pieza,
detalle_item_factura,
item_factura,
factura,
farm,
tipo_flor,
variedad_flor,
cliente_factura
where farm.id_farm = pieza.id_farm
and variedad_flor.id_variedad_flor = pieza.id_variedad_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and pieza.id_pieza = detalle_item_factura.id_pieza
and item_factura.id_item_factura = detalle_item_factura.id_item_factura
and factura.id_factura = item_factura.id_factura
and factura.fecha_factura between
@fecha_inicial and @fecha_final
and variedad_flor.id_variedad_flor = @id_variedad_flor
and farm.id_farm = @id_farm
and cliente_factura.id_cliente_factura = factura.id_cliente_factura
group by item_factura.valor_unitario,
item_factura.id_item_factura,
cliente_factura.id_cliente_factura,
cliente_factura.idc_cliente_factura

alter table #temp
add nombre_cliente nvarchar(255)

update #temp
set nombre_cliente = ltrim(rtrim(cliente_despacho.nombre_cliente))
from cliente_despacho
where cliente_despacho.id_cliente_factura = #temp.id_cliente_factura
and ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) = ltrim(rtrim(#temp.idc_cliente_factura))

select sum(unidades_por_pieza) as unidades_por_pieza,
idc_cliente_factura,
nombre_cliente,
sum(valor) as valor,
sum(valor_credito) as valor_credito,
sum(unidades_credito) as unidades_credito,
case
	when sum(valor) = 0 then 0
	when sum(valor_credito) = 0 then 0
	else sum(valor_credito)/sum(valor) 
end as porcentaje
from #temp
group by idc_cliente_factura,
nombre_cliente

drop table #temp