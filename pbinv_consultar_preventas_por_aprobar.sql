/****** Object:  StoredProcedure [dbo].[pbinv_consultar_saldos_factura]    Script Date: 09/04/2008 16:58:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pbinv_consultar_preventas_por_aprobar]

@fecha datetime,
@idc_cliente_despacho nvarchar(10),
@idc_transportador nvarchar(5)

AS

select max(id_orden_pedido) as id_orden_pendiente into #ordenes
from orden_pedido 
where Orden_Pedido.id_tipo_factura = 2 
and Orden_Pedido.disponible = 1 
group by id_orden_pedido_padre

SELECT farm.id_farm, 
farm.idc_farm, 
farm.nombre_farm,	
tapa.id_tapa, 
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
tipo_flor.nombre_tipo_flor,
variedad_flor.id_variedad_flor, 
variedad_flor.idc_variedad_flor,
variedad_flor.nombre_variedad_flor,
Color.id_color,
color.idc_color,
color.nombre_color,
color.prioridad_color,
grado_flor.id_grado_flor, 
grado_flor.idc_grado_flor, 
grado_flor.nombre_grado_flor, 
grado_flor.medidas, 
tipo_caja.id_tipo_caja, 
tipo_caja.idc_tipo_caja,
tipo_caja.nombre_tipo_caja,
Orden_Pedido.unidades_por_pieza, 
0 as cantidad_piezas_inventario,
0 as cantidad_unidades_inventario_total,
Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas as cantidad_unidades_prebook_total,
0 as cantidad_piezas_ofertadas_finca,
orden_pedido.cantidad_piezas as cantidad_piezas_prebook, 
orden_pedido.marca, 
orden_pedido.valor_unitario as precio_minimo,
orden_pedido.fecha_para_aprobar as fecha_disponible_distribuidora,
vendedor.id_vendedor, 
vendedor.idc_vendedor, 
vendedor.nombre as nombre_vendedor, 
cliente_factura.id_cliente_factura,
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho, 
cliente_despacho.idc_cliente_despacho, 
cliente_despacho.nombre_cliente, 
transportador.id_transportador, 
transportador.idc_transportador,
transportador.nombre_transportador,
3 as tipo_orden,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
null as id_item_inventario_preventa,
orden_pedido.fecha_para_aprobar,
null as controla_saldos,
null as empaque_principal,
orden_pedido.numero_po,
orden_pedido.comentario,
0 as inventario,
0 as saldo,
grado_flor.orden
FROM Orden_Pedido, 
Variedad_Flor, 
Tipo_Flor, 
Grado_Flor, 
Tipo_Caja, 
Cliente_Despacho, 
Cliente_Factura, 
Vendedor,
Transportador,
Farm,
Tapa,
color
WHERE orden_pedido.fecha_para_aprobar = @fecha 
and transportador.idc_transportador = @idc_transportador
and cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
and Orden_Pedido.fecha_inicial = convert(datetime, '1999/01/01')
and Orden_Pedido.id_tapa = Tapa.id_tapa
and Orden_Pedido.id_farm = Farm.id_farm
and Orden_Pedido.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Orden_Pedido.id_transportador = Transportador.id_transportador
and Cliente_Factura.id_vendedor = Vendedor.id_vendedor
and Cliente_Despacho.id_cliente_factura = Cliente_Factura.id_cliente_factura
and Orden_Pedido.id_despacho = Cliente_Despacho.id_despacho
and Orden_Pedido.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Orden_Pedido.id_grado_flor = Grado_Flor.id_grado_flor 
and Tipo_Flor.id_tipo_flor = Grado_Flor.id_tipo_flor
and Orden_Pedido.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and variedad_flor.id_color = color.id_color
and Orden_Pedido.id_tipo_factura = 2 
and Orden_Pedido.disponible = 1 
and exists
(
	select *
	from #ordenes
	where #ordenes.id_orden_pendiente = orden_pedido.id_orden_pedido
)

drop table #ordenes