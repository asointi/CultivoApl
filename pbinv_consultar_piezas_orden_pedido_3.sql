set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv_consultar_piezas_orden_pedido_3]

@id_farm int,
@id_tapa int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tipo_caja int,
@unidades_por_pieza int,
@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime 

AS

select max(id_orden_pedido) as id_orden_pedido into #temp
from orden_pedido 
group by id_orden_pedido_padre

select 
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
cliente_despacho.id_despacho,
cliente_despacho.idc_cliente_despacho,
cliente_despacho.nombre_cliente,
transportador.id_transportador,
transportador.idc_transportador,
transportador.nombre_transportador,
tipo_factura.id_tipo_factura,
tipo_factura.idc_tipo_factura,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
grado_flor.nombre_grado_flor,
farm.id_farm,
farm.idc_farm,
farm.nombre_farm,
orden_pedido.unidades_por_pieza,
orden_pedido.marca,
orden_pedido.valor_unitario,
orden_pedido.fecha_inicial,
orden_pedido.cantidad_piezas,
orden_pedido.comentario,
orden_pedido.id_orden_pedido_padre,
vendedor.id_vendedor,
vendedor.idc_vendedor,
vendedor.nombre,
orden_pedido.fecha_para_aprobar,
cliente_factura.idc_cliente_factura,
orden_pedido.numero_po
from orden_pedido, 
tapa, 
tipo_caja, 
variedad_flor, 
grado_flor, 
farm, 
tipo_flor, 
cliente_despacho, 
cliente_factura,
transportador, 
tipo_factura, 
vendedor
where tipo_factura.idc_tipo_factura = '4'
and fecha_inicial > = @fecha_disponible_distribuidora_inicial 
and fecha_inicial < = @fecha_disponible_distribuidora_final
and orden_pedido.disponible = 1
and orden_pedido.id_tapa = tapa.id_tapa
and tapa.id_tapa = @id_tapa
and orden_pedido.id_tipo_caja = tipo_caja.id_tipo_caja
and tipo_caja.id_tipo_caja = @id_tipo_caja
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and variedad_flor.id_variedad_flor = @id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and grado_flor.id_grado_flor = @id_grado_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and orden_pedido.id_farm = farm.id_farm
and farm.id_farm = @id_farm
and orden_pedido.id_despacho = cliente_despacho.id_despacho
and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
and orden_pedido.id_transportador = transportador.id_transportador
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and orden_pedido.id_vendedor = vendedor.id_vendedor
and orden_pedido.unidades_por_pieza = @unidades_por_pieza
and exists
(
	select *
	from #temp
	where #temp.id_orden_pedido = orden_pedido.id_orden_pedido
)

drop table #temp