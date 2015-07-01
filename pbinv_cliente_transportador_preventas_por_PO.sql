USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[pbinv_cliente_transportador_preventas_por_PO]    Script Date: 29/12/2014 2:32:50 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_cliente_transportador_preventas_por_PO]

@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime,
@idc_cliente_despacho nvarchar(20),
@idc_transportador nvarchar(20)
as

declare @id_temporada_año int

select @id_temporada_año = id_temporada_año 
from temporada_año
where fecha_inicial = @fecha_disponible_distribuidora_inicial

select precio_minimo,
controla_saldos,
id_variedad_flor,
id_grado_flor,
id_farm,
id_tapa into #empaque_principal
from Inventario_Preventa,
Item_Inventario_Preventa
where Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and Inventario_Preventa.id_temporada_año = @id_temporada_año
and Item_Inventario_Preventa.empaque_principal = 1
and exists 
(
	select * 
	from Pantalla_Saldo_cobol,
	Item_Inventario_Preventa as iip,
	inventario_preventa as ip
	where Pantalla_Saldo_cobol.id_item_inventario_preventa = iip.id_item_inventario_preventa
	and ip.id_inventario_preventa = iip.id_inventario_preventa
	and iip.id_variedad_flor = Item_Inventario_Preventa.id_variedad_flor
	and iip.id_grado_flor = Item_Inventario_Preventa.id_grado_flor
	and ip.id_farm = Inventario_Preventa.id_farm
	and iip.id_tapa = Item_Inventario_Preventa.id_tapa
	and Pantalla_Saldo_cobol.idc_cliente_despacho = @idc_cliente_despacho
	and Pantalla_Saldo_cobol.idc_transportador = @idc_transportador
)
group by precio_minimo,
controla_saldos,
id_variedad_flor,
id_grado_flor,
id_farm,
id_tapa

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
cantidad_piezas_inventario int,
cantidad_unidades_inventario_total int,
cantidad_unidades_prebook_total int,
cantidad_piezas_ofertadas_finca int,
cantidad_piezas_prebook int,
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
controla_saldos bit,
empaque_principal bit,
numero_po varchar(20) collate SQL_Latin1_General_CP1_CI_AS,
comentario nvarchar(512) collate SQL_Latin1_General_CP1_CI_AS,
inventario int,
saldo int
)

select max(id_orden_pedido) as id_orden_pendiente into #ordenes
from orden_pedido 
where Orden_Pedido.id_tipo_factura = 2 
and Orden_Pedido.disponible = 1 
group by id_orden_pedido_padre

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
cantidad_unidades_prebook_total,
cantidad_piezas_ofertadas_finca,
cantidad_piezas_prebook,
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
id_item_inventario_preventa,
fecha_para_aprobar,
controla_saldos,
empaque_principal,
numero_po,
comentario,
inventario,
saldo,
orden
)
SELECT  
farm.id_farm, 
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
0,
Detalle_Item_Inventario_Preventa.cantidad_piezas_ofertadas_finca,
0,
Item_Inventario_Preventa.marca, 
Item_Inventario_Preventa.precio_minimo, 
Detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora,
null, 
null, 
null, 
null,
null,
null, 
null, 
null, 
null,
null,
null,
1,
null,
null,
Item_Inventario_Preventa.id_item_inventario_preventa,
null,
controla_saldos,
Item_Inventario_Preventa.empaque_principal,
'',
null,
0,
0,
grado_flor.orden
FROM         
Grado_Flor, 
Inventario_Preventa,
Item_Inventario_Preventa left join Detalle_Item_Inventario_Preventa on
(
	Item_Inventario_Preventa.id_item_inventario_preventa = Detalle_Item_Inventario_Preventa.id_item_inventario_preventa
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora > = @fecha_disponible_distribuidora_inicial 
	and detalle_item_inventario_preventa.fecha_disponible_distribuidora < =  @fecha_disponible_distribuidora_final
),     
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
and inventario_preventa.id_temporada_año = @id_temporada_año
and exists
(
	select *
	from pantalla_saldo_cobol,
	item_inventario_preventa as iip,
	Inventario_Preventa as ip
	where pantalla_saldo_cobol.id_item_inventario_preventa = iip.id_item_inventario_preventa
	and ip.id_inventario_preventa = iip.id_inventario_preventa
	and ip.id_farm = Inventario_Preventa.id_farm
	and iip.id_variedad_flor = item_inventario_preventa.id_variedad_flor
	and iip.id_grado_flor = item_inventario_preventa.id_grado_flor
	and iip.id_tapa = item_inventario_preventa.id_tapa
	and Pantalla_Saldo_cobol.idc_cliente_despacho = @idc_cliente_despacho
	and Pantalla_Saldo_cobol.idc_transportador = @idc_transportador
)


update #temp
set precio_minimo = #empaque_principal.precio_minimo,
controla_saldos = #empaque_principal.controla_saldos
from #empaque_principal
where #empaque_principal.id_farm = #temp.id_farm
and #empaque_principal.id_variedad_flor = #temp.id_variedad_flor
and #empaque_principal.id_grado_flor = #temp.id_grado_flor
and #empaque_principal.id_tapa = #temp.id_tapa
and #temp.empaque_principal = 0

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
cantidad_unidades_prebook_total,
cantidad_piezas_ofertadas_finca,
cantidad_piezas_prebook,
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
id_item_inventario_preventa,
fecha_para_aprobar,
controla_saldos,
empaque_principal,
numero_po,
comentario,
inventario,
saldo,
orden
)
SELECT     
farm.id_farm, 
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
0 AS cantidad_piezas_inventario,
0 as cantidad_unidades_inventario_total,
Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas,
0,
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
0,
orden_pedido.fecha_para_aprobar,
null,
null,
orden_pedido.numero_po,
orden_pedido.comentario,
0,
0,
grado_flor.orden
FROM         
Orden_Pedido, 
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
WHERE orden_pedido.fecha_inicial > = @fecha_disponible_distribuidora_inicial 
and orden_pedido.fecha_inicial < = @fecha_disponible_distribuidora_final
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
and exists
(
	select *
	from #temp
	where #temp.id_farm = farm.id_farm
	and #temp.id_variedad_flor = variedad_flor.id_variedad_flor
	and #temp.id_grado_flor = grado_flor.id_grado_flor
	and #temp.id_tapa = tapa.id_tapa 
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
cantidad_unidades_prebook_total,
cantidad_piezas_ofertadas_finca,
cantidad_piezas_prebook,
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
id_item_inventario_preventa,
fecha_para_aprobar,
controla_saldos,
empaque_principal,
numero_po,
comentario,
inventario,
saldo,
orden
)
SELECT     
farm.id_farm, 
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
0,
0,
Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas,
0,
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
null,
orden_pedido.fecha_para_aprobar,
null,
null,
orden_pedido.numero_po,
orden_pedido.comentario,
0,
0,
grado_flor.orden
FROM         
Orden_Pedido, 
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
WHERE orden_pedido.fecha_para_aprobar > = @fecha_disponible_distribuidora_inicial 
and  orden_pedido.fecha_para_aprobar < = @fecha_disponible_distribuidora_final
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
and not exists
(
	select *
	from #temp
	where #temp.id_orden_pedido = orden_pedido.id_orden_pedido
)
and exists
(
	select *
	from #temp
	where #temp.id_farm = farm.id_farm
	and #temp.id_variedad_flor = variedad_flor.id_variedad_flor
	and #temp.id_grado_flor = grado_flor.id_grado_flor
	and #temp.id_tapa = tapa.id_tapa 
)

select id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
sum(cantidad_unidades_inventario_total) as cantidad_unidades_inventario_total into #inventario
from #temp
group by id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa

select id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
sum(cantidad_unidades_prebook_total) as cantidad_unidades_prebook_total into #preventa
from #temp
group by id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa

update #temp 
set inventario = isnull(#inventario.cantidad_unidades_inventario_total / #temp.unidades_por_pieza, 0)
from #inventario
where #temp.id_farm = #inventario.id_farm
and #temp.id_variedad_flor = #inventario.id_variedad_flor
and #temp.id_grado_flor = #inventario.id_grado_flor
and #temp.id_tapa = #inventario.id_tapa

update #temp
set saldo = isnull((#inventario.cantidad_unidades_inventario_total - #preventa.cantidad_unidades_prebook_total) / #temp.unidades_por_pieza, 0)
from #inventario,
#preventa
where #inventario.id_farm = #preventa.id_farm
and #inventario.id_variedad_flor = #preventa.id_variedad_flor
and #inventario.id_grado_flor = #preventa.id_grado_flor
and #inventario.id_tapa = #preventa.id_tapa
and #inventario.id_farm = #temp.id_farm
and #inventario.id_variedad_flor = #temp.id_variedad_flor
and #inventario.id_grado_flor = #temp.id_grado_flor
and #inventario.id_tapa = #temp.id_tapa

select *, 
cantidad_piezas_prebook as prebook 
from #temp
order by
idc_tipo_flor,
prioridad_color,
idc_variedad_flor,
idc_grado_flor,
nombre_tipo_caja,
tipo_orden,
fecha_disponible_distribuidora

delete from Pantalla_Saldo_cobol
where Pantalla_Saldo_cobol.idc_cliente_despacho = @idc_cliente_despacho
and Pantalla_Saldo_cobol.idc_transportador = @idc_transportador

drop table #temp
drop table #inventario
drop table #preventa
drop table #ordenes
drop table #empaque_principal