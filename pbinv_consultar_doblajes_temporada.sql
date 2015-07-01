Alter PROCEDURE [dbo].[pbinv_consultar_doblajes_temporada]

@idc_orden_pedido nvarchar(255),
@fecha nvarchar(255)

as

declare @id_farm int,
@id_despacho int,
@id_variedad_flor int,
@id_grado_flor int,
@id_tapa int,
@unidades_por_pieza int,
@id_tipo_caja int,
@fecha_inicial_temporada datetime,
@fecha_final_temporada datetime,
@comentario nvarchar(512)

select @fecha_inicial_temporada = fecha_inicial,
@fecha_final_temporada = fecha_final
from temporada_cubo where convert(datetime,@fecha) 
between fecha_inicial and fecha_final

select @id_despacho = orden_pedido.id_despacho,
@id_variedad_flor = orden_pedido.id_variedad_flor,
@id_grado_flor = orden_pedido.id_grado_flor,
@id_farm = orden_pedido.id_farm,
@id_tapa = orden_pedido.id_tapa,
@unidades_por_pieza = orden_pedido.unidades_por_pieza,
@id_tipo_caja = orden_pedido.id_tipo_caja,
@comentario = orden_pedido.comentario
from orden_pedido
where orden_pedido.idc_orden_pedido = @idc_orden_pedido

select isnull(sum(cantidad_piezas), 0) as cantidad_piezas
from orden_pedido,
tipo_factura
where orden_pedido.id_despacho = @id_despacho
and orden_pedido.id_variedad_flor = @id_variedad_flor
and orden_pedido.id_grado_flor = @id_grado_flor
and orden_pedido.id_farm = @id_farm
and orden_pedido.id_tapa = @id_tapa
and orden_pedido.unidades_por_pieza = @unidades_por_pieza
and orden_pedido.id_tipo_caja = @id_tipo_caja
and orden_pedido.comentario = @comentario
and orden_pedido.disponible = 1
and orden_pedido.fecha_inicial between
@fecha_inicial_temporada and @fecha_final_temporada
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = '7'
and orden_pedido.id_orden_pedido in
(select max(id_orden_pedido) from orden_pedido group by id_orden_pedido_padre)