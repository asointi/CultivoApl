set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

go

alter PROCEDURE [dbo].[pbinv_preventas_por_vendedor]

@rosa bit, 
@id_farm int, 
@id_temporada_año int 

as

declare @fecha_inicial datetime
declare @fecha_final datetime

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final
from temporada_cubo, temporada_año
where temporada_año.id_año = temporada_cubo.id_año
and temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_temporada_año = @id_temporada_año

select 
farm.id_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
farm.idc_farm,
tipo_caja.factor_a_full,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_caja.id_tipo_caja,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor))+space(1)+rtrim(ltrim(variedad_flor.nombre_variedad_flor))+space(1)+ltrim(rtrim(grado_flor.nombre_grado_flor))+space(1)+'('+tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor+grado_flor.idc_grado_flor+')' as flor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
vendedor.idc_vendedor, 
orden_pedido.fecha_inicial,
sum(cantidad_piezas) as cantidad_piezas_prebook into #preventa
from orden_pedido, vendedor, farm, variedad_flor, grado_flor, tipo_flor, tipo_caja, cliente_factura, cliente_despacho, tipo_factura
where vendedor.id_vendedor = cliente_factura.id_vendedor
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and orden_pedido.id_farm = farm.id_farm
and farm.id_farm = @id_farm
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and (orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
or orden_pedido.fecha_inicial between
@fecha_inicial - 7 and @fecha_final - 7)
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura > = '1'
and tipo_factura.idc_tipo_factura < = '4'
and orden_pedido.disponible = 1
and orden_pedido.id_orden_pedido in
(SELECT MAX(id_orden_pedido)
FROM Orden_Pedido
GROUP BY 
id_orden_pedido_padre)
group by 
farm.id_farm,
farm.nombre_farm,
farm.idc_farm,
tipo_caja.factor_a_full,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_caja.id_tipo_caja,
tipo_flor.nombre_tipo_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.nombre_grado_flor,
tipo_flor.idc_tipo_flor,
variedad_flor.idc_variedad_flor,
grado_flor.idc_grado_flor,
vendedor.nombre,
vendedor.idc_vendedor, 
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
orden_pedido.fecha_inicial

alter table #preventa
add cantidad_piezas_inventario decimal(20,4), 
total_inventario int

select farm.id_farm,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_caja.id_tipo_caja,
detalle_item_inventario_preventa.fecha_disponible_distribuidora,
sum(detalle_item_inventario_preventa.cantidad_piezas) as cantidad_piezas_inventario into #inventario
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa,
farm,
variedad_flor,
grado_flor,
tipo_caja
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and (detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_inicial and @fecha_final
or
detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_inicial - 7 and @fecha_final - 7)
and farm.id_farm = inventario_preventa.id_farm
and farm.id_farm = @id_farm
and item_inventario_preventa.id_variedad_flor = variedad_flor.id_variedad_flor
and item_inventario_preventa.id_grado_flor = grado_flor.id_grado_flor
and item_inventario_preventa.id_tipo_caja = tipo_caja.id_tipo_caja
and Detalle_Item_Inventario_Preventa.id_detalle_item_inventario_preventa IN
(
SELECT MAX(id_detalle_item_inventario_preventa)
FROM Detalle_Item_Inventario_Preventa
GROUP BY id_detalle_item_inventario_preventa_padre
)
group by 
farm.id_farm,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_caja.id_tipo_caja,
detalle_item_inventario_preventa.fecha_disponible_distribuidora

update #preventa
set cantidad_piezas_inventario = isnull(#inventario.cantidad_piezas_inventario,0)
from #preventa, #inventario
where #inventario.id_variedad_flor = #preventa.id_variedad_flor
and #inventario.id_grado_flor = #preventa.id_grado_flor
and #inventario.id_farm = #preventa.id_farm
and #inventario.id_tipo_caja = #preventa.id_tipo_caja
and #inventario.fecha_disponible_distribuidora = #preventa.fecha_inicial

update #preventa
set cantidad_piezas_inventario = 0
where cantidad_piezas_inventario is null

if(@rosa = 1)
begin
	select #preventa.*,  
	convert(nvarchar,@fecha_inicial,101)+space(1)+'-'+space(1)+convert(nvarchar,@fecha_final, 101) as fecha_temporada into #final_rosa
	from #preventa 
	where (#preventa.idc_tipo_flor = 'RO' or #preventa.idc_tipo_flor = 'RS')
	and fecha_inicial between
	@fecha_inicial and @fecha_final
	union
	select #preventa.*,  
	convert(nvarchar,@fecha_inicial - 7, 101)+space(1)+'-'+space(1)+convert(nvarchar,@fecha_final - 7, 101)
	from #preventa 
	where (#preventa.idc_tipo_flor = 'RO' or #preventa.idc_tipo_flor = 'RS')
	and fecha_inicial between
	@fecha_inicial - 7 and @fecha_final - 7
	
	select sum(cantidad_piezas_inventario) as total_inventario,
	fecha_temporada,
	id_tipo_caja into #inventario_total
	from #final_rosa
	group by fecha_temporada,
	id_tipo_caja,
	idc_vendedor

	update #final_rosa
	set total_inventario = #inventario_total.total_inventario
	from #final_rosa, #inventario_total
	where #final_rosa.fecha_temporada = #inventario_total.fecha_temporada
	and #final_rosa.id_tipo_caja = #inventario_total.id_tipo_caja

	select distinct fecha_temporada,
	flor,
	id_tipo_caja,
	convert(decimal(20,4),sum(cantidad_piezas_inventario)/
	convert(decimal(20,4),(select count(*)
	from #final_rosa as f1
	where #final_rosa.fecha_temporada = f1.fecha_temporada
	and #final_rosa.flor = f1.flor
	and #final_rosa.id_tipo_caja = f1.id_tipo_caja
	group by
	f1.fecha_temporada,
	f1.flor,
	f1.id_tipo_caja
	))) as inventario_parcial into #inventario_parcial_rosa
	from #final_rosa
	group by fecha_temporada,
	flor,
	id_tipo_caja,
	idc_vendedor

	update #final_rosa
	set cantidad_piezas_inventario = inventario_parcial
	from #final_rosa, #inventario_parcial_rosa
	where #final_rosa.fecha_temporada = #inventario_parcial_rosa.fecha_temporada
	and #final_rosa.flor = #inventario_parcial_rosa.flor
	and #final_rosa.id_tipo_caja = #inventario_parcial_rosa.id_tipo_caja

	select * from #final_rosa order by flor

	drop table #inventario_parcial_rosa
	drop table #final_rosa
end
else
begin
	select #preventa.*,  
	convert(nvarchar,@fecha_inicial,101)+space(1)+'-'+space(1)+convert(nvarchar,@fecha_final, 101) as fecha_temporada into #final_no_rosa
	from #preventa 
	where (#preventa.idc_tipo_flor <> 'RO' and #preventa.idc_tipo_flor <> 'RS')
	and fecha_inicial between
	@fecha_inicial and @fecha_final
	union
	select #preventa.*,  
	convert(nvarchar,@fecha_inicial - 7, 101)+space(1)+'-'+space(1)+convert(nvarchar,@fecha_final - 7, 101)
	from #preventa 
	where (#preventa.idc_tipo_flor <> 'RO' and #preventa.idc_tipo_flor <> 'RS')
	and fecha_inicial between
	@fecha_inicial - 7 and @fecha_final - 7
	
	select sum(cantidad_piezas_inventario) as total_inventario,
	fecha_temporada,
	id_tipo_caja into #inventario_total_no_rosa
	from #final_no_rosa
	group by fecha_temporada,
	id_tipo_caja,
	idc_vendedor

	update #final_no_rosa
	set total_inventario = #inventario_total_no_rosa.total_inventario
	from #final_no_rosa, #inventario_total_no_rosa
	where #final_no_rosa.fecha_temporada = #inventario_total_no_rosa.fecha_temporada
	and #final_no_rosa.id_tipo_caja = #inventario_total_no_rosa.id_tipo_caja

	select distinct fecha_temporada,
	flor,
	id_tipo_caja,
	convert(decimal(20,4),sum(cantidad_piezas_inventario)/
	convert(decimal(20,4),(select count(*)
	from #final_no_rosa as f1
	where #final_no_rosa.fecha_temporada = f1.fecha_temporada
	and #final_no_rosa.flor = f1.flor
	and #final_no_rosa.id_tipo_caja = f1.id_tipo_caja
	group by
	f1.fecha_temporada,
	f1.flor,
	f1.id_tipo_caja
	))) as inventario_parcial into #inventario_parcial
	from #final_no_rosa
	group by fecha_temporada,
	flor,
	id_tipo_caja,
	idc_vendedor

	update #final_no_rosa
	set cantidad_piezas_inventario = inventario_parcial
	from #final_no_rosa, #inventario_parcial
	where #final_no_rosa.fecha_temporada = #inventario_parcial.fecha_temporada
	and #final_no_rosa.flor = #inventario_parcial.flor
	and #final_no_rosa.id_tipo_caja = #inventario_parcial.id_tipo_caja

	select * from #final_no_rosa order by flor

	drop table #inventario_parcial
	drop table #final_no_rosa
end

drop table #inventario	
drop table #preventa