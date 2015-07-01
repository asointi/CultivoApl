USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[pbinv_consultar_saldos_factura_por_fecha_version7]    Script Date: 03/05/2013 12:03:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_consultar_saldos_factura_por_fecha_version7]

@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime

AS

declare @id_temporada_año int

select @id_temporada_año = temporada_año.id_temporada_año
from temporada_año
where temporada_año.fecha_inicial between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final

create table #temp
(
id_farm int, 
idc_farm varchar(5) collate SQL_Latin1_General_CP1_CI_AS,
nombre_farm varchar(50) collate SQL_Latin1_General_CP1_CI_AS,
id_tapa int, 
idc_tapa varchar(5) collate SQL_Latin1_General_CP1_CI_AS,
nombre_tapa varchar(50) collate SQL_Latin1_General_CP1_CI_AS,
id_tipo_flor int, 
idc_tipo_flor varchar(5) collate SQL_Latin1_General_CP1_CI_AS, 
nombre_tipo_flor varchar(50) collate SQL_Latin1_General_CP1_CI_AS, 
id_variedad_flor int, 
idc_variedad_flor varchar(5) collate SQL_Latin1_General_CP1_CI_AS, 
nombre_variedad_flor varchar(50) collate SQL_Latin1_General_CP1_CI_AS, 
id_color int,
idc_color varchar(5) collate SQL_Latin1_General_CP1_CI_AS,
nombre_color varchar(50) collate SQL_Latin1_General_CP1_CI_AS,
prioridad_color int,
id_grado_flor int, 
idc_grado_flor varchar(5) collate SQL_Latin1_General_CP1_CI_AS, 
nombre_grado_flor varchar(50) collate SQL_Latin1_General_CP1_CI_AS, 
medidas varchar(20) collate SQL_Latin1_General_CP1_CI_AS, 
orden int,
id_tipo_caja int, 
idc_tipo_caja varchar(5) collate SQL_Latin1_General_CP1_CI_AS, 
nombre_tipo_caja varchar(50) collate SQL_Latin1_General_CP1_CI_AS, 
unidades_por_pieza int, 
cantidad_piezas_inventario int default(0),
cantidad_unidades_inventario_total int default(0),
cantidad_unidades_prebook_total int default(0),
cantidad_piezas_ofertadas_finca int default(0),
prebook int default(0),
marca varchar(10) collate SQL_Latin1_General_CP1_CI_AS, 
precio_minimo decimal(20,4), 
fecha_disponible_distribuidora datetime,
id_vendedor int, 
idc_vendedor varchar(10) collate SQL_Latin1_General_CP1_CI_AS, 
nombre_vendedor varchar(50) collate SQL_Latin1_General_CP1_CI_AS, 
id_cliente_factura int,
idc_cliente_factura varchar(15) collate SQL_Latin1_General_CP1_CI_AS,
id_despacho int, 
idc_cliente_despacho varchar(15) collate SQL_Latin1_General_CP1_CI_AS, 
nombre_cliente varchar(50) collate SQL_Latin1_General_CP1_CI_AS, 
id_transportador int,
idc_transportador varchar(10) collate SQL_Latin1_General_CP1_CI_AS,
nombre_transportador varchar(50) collate SQL_Latin1_General_CP1_CI_AS,
tipo_orden int,
id_orden_pedido int,
idc_orden_pedido varchar(20) collate SQL_Latin1_General_CP1_CI_AS,
id_item_inventario_preventa int,
fecha_para_aprobar datetime,
controla_saldos bit null,
empaque_principal bit null,
numero_po varchar(20) default('') collate SQL_Latin1_General_CP1_CI_AS,
comentario nvarchar(512) collate SQL_Latin1_General_CP1_CI_AS,
inventario int default(0),
saldo int default(0)
)

insert into #temp 
(
id_farm, 
idc_farm,
nombre_farm,
id_tapa, 
idc_tapa,
nombre_tapa,
id_tipo_flor, 
idc_tipo_flor, 
nombre_tipo_flor, 
id_variedad_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
id_color,
idc_color,
nombre_color,
prioridad_color,
id_grado_flor, 
idc_grado_flor, 
nombre_grado_flor, 
medidas, 
id_tipo_caja, 
idc_tipo_caja, 
nombre_tipo_caja, 
unidades_por_pieza, 
cantidad_piezas_inventario,
cantidad_unidades_inventario_total,
cantidad_piezas_ofertadas_finca,
marca, 
precio_minimo, 
fecha_disponible_distribuidora,
tipo_orden,
id_item_inventario_preventa,
controla_saldos,
empaque_principal,
orden
)
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
Item_Inventario_Preventa.unidades_por_pieza, 
Detalle_Item_Inventario_Preventa.cantidad_piezas,
Item_Inventario_Preventa.unidades_por_pieza * Detalle_Item_Inventario_Preventa.cantidad_piezas,
Detalle_Item_Inventario_Preventa.cantidad_piezas_ofertadas_finca,
Item_Inventario_Preventa.marca, 
Item_Inventario_Preventa.precio_minimo, 
Detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora,
1,
Item_Inventario_Preventa.id_item_inventario_preventa,
controla_saldos,
Item_Inventario_Preventa.empaque_principal,
grado_flor.orden
FROM Grado_Flor, 
Inventario_Preventa,
Item_Inventario_Preventa,     
Detalle_Item_Inventario_Preventa,     
Variedad_Flor,      
Tipo_Flor,               
Tipo_Caja,                
Farm,
Tapa,
Color
WHERE Inventario_Preventa.id_farm = Farm.id_farm
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Grado_Flor.id_grado_flor = Item_Inventario_Preventa.id_grado_flor
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor 
and variedad_flor.id_color = color.id_color
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and Item_Inventario_Preventa.id_item_inventario_preventa = Detalle_Item_Inventario_Preventa.id_item_inventario_preventa
and inventario_preventa.id_temporada_año = @id_temporada_año
and detalle_item_inventario_preventa.fecha_disponible_distribuidora > = @fecha_disponible_distribuidora_inicial 
and detalle_item_inventario_preventa.fecha_disponible_distribuidora < =  @fecha_disponible_distribuidora_final

insert into #temp 
(
id_farm, 
idc_farm,
nombre_farm,
id_tapa, 
idc_tapa,
nombre_tapa,
id_tipo_flor, 
idc_tipo_flor, 
nombre_tipo_flor, 
id_variedad_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
id_color,
idc_color,
nombre_color,
prioridad_color,
id_grado_flor, 
idc_grado_flor, 
nombre_grado_flor, 
medidas, 
id_tipo_caja, 
idc_tipo_caja, 
nombre_tipo_caja, 
unidades_por_pieza, 
cantidad_unidades_prebook_total,
prebook,
marca, 
precio_minimo, 
fecha_disponible_distribuidora,
id_vendedor, 
idc_vendedor, 
nombre_vendedor, 
id_cliente_factura,
idc_cliente_factura,
id_despacho, 
idc_cliente_despacho, 
nombre_cliente, 
id_transportador,
idc_transportador,
nombre_transportador,
tipo_orden,
id_orden_pedido,
idc_orden_pedido,
fecha_para_aprobar,
numero_po,
comentario,
orden
)
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
Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas,
orden_pedido.cantidad_piezas, 
orden_pedido.marca, 
orden_pedido.valor_unitario,
case
	when Orden_Pedido.fecha_inicial = convert(datetime, '1999/01/01') then orden_pedido.fecha_para_aprobar
	else Orden_Pedido.fecha_inicial
end,
vendedor.id_vendedor, 
vendedor.idc_vendedor, 
vendedor.nombre, 
cliente_factura.id_cliente_factura,
cliente_factura.idc_cliente_factura,
cliente_despacho.id_despacho, 
cliente_despacho.idc_cliente_despacho, 
cliente_despacho.nombre_cliente, 
transportador.id_transportador, 
transportador.idc_transportador,
transportador.nombre_transportador,
case
	when Orden_Pedido.fecha_inicial = convert(datetime, '1999/01/01') then 3
	else 2
end,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
orden_pedido.fecha_para_aprobar,
orden_pedido.numero_po,
orden_pedido.comentario,
grado_flor.orden
FROM Orden_Pedido, 
orden_pedido_maximo,
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
WHERE orden_pedido.id_orden_pedido = orden_pedido_maximo.id_orden_pedido
and 
(
	orden_pedido.fecha_inicial between
	@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
	or
	orden_pedido.fecha_para_aprobar between 
	@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
)
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

select id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
sum(cantidad_unidades_inventario_total) as cantidad_unidades_inventario_total,
sum(cantidad_unidades_prebook_total) as cantidad_unidades_prebook_total into #inventario
from #temp
group by id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa

update #temp 
set inventario = isnull(#inventario.cantidad_unidades_inventario_total / #temp.unidades_por_pieza, 0),
saldo = isnull((#inventario.cantidad_unidades_inventario_total - #inventario.cantidad_unidades_prebook_total) / #temp.unidades_por_pieza, 0)
from #inventario
where #temp.id_farm = #inventario.id_farm
and #temp.id_variedad_flor = #inventario.id_variedad_flor
and #temp.id_grado_flor = #inventario.id_grado_flor
and #temp.id_tapa = #inventario.id_tapa

select *,
prebook as cantidad_piezas_prebook 
from #temp
order by
idc_tipo_flor,
prioridad_color,
idc_variedad_flor,
idc_grado_flor,
tipo_orden,
fecha_disponible_distribuidora