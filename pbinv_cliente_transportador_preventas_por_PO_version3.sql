USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[pbinv_cliente_transportador_preventas_por_PO_version3]    Script Date: 14/01/2015 12:14:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pbinv_cliente_transportador_preventas_por_PO_version3]

@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime,
@id_inventario nvarchar(1024)

as

declare @id_temporada_año int

select @id_temporada_año = id_temporada_año 
from temporada_año (NOLOCK)
where fecha_inicial = @fecha_disponible_distribuidora_inicial

declare @piezas_inventario table
(
	id_item_inventario_preventa int,
	cantidad_piezas int,
	fecha_disponible_distribuidora datetime
)

declare @inventario_agrupado table 
(
	id_farm int, 
	id_variedad_flor int, 
	id_grado_flor int, 
	id_tapa int
)

declare @empaque_principal table 
(
	precio_minimo decimal(20,4),
	controla_saldos bit,
	id_variedad_flor int,
	id_grado_flor int,
	id_farm int,
	id_tapa int
)

declare @ordenes table 
(
	id_orden_pendiente int
)

declare @unidades table
(
	id_farm int,
	id_variedad_flor int,
	id_grado_flor int,
	id_tapa int,
	unidades_preventas int,
	unidades_inventario int
)

declare @temp table
(
	id_farm int, 
	idc_farm varchar(5),
	nombre_farm varchar(50),
	id_tapa int, 
	idc_tapa varchar(5),
	nombre_tapa varchar(50),
	id_tipo_flor int, 
	idc_tipo_flor varchar(5), 
	nombre_tipo_flor varchar(50), 
	id_variedad_flor int, 
	idc_variedad_flor varchar(5), 
	nombre_variedad_flor varchar(50), 
	id_color int,
	idc_color varchar(5),
	nombre_color varchar(50),
	prioridad_color int,
	id_grado_flor int, 
	idc_grado_flor varchar(5), 
	nombre_grado_flor varchar(50), 
	medidas varchar(20), 
	orden int,
	id_tipo_caja int, 
	idc_tipo_caja varchar(5), 
	nombre_tipo_caja varchar(50), 
	unidades_por_pieza int, 
	cantidad_piezas_inventario int,
	cantidad_unidades_inventario_total int,
	cantidad_unidades_prebook_total int,
	cantidad_piezas_ofertadas_finca int,
	cantidad_piezas_prebook int,
	marca varchar(10), 
	precio_minimo decimal(20,4), 
	fecha_disponible_distribuidora datetime,
	id_vendedor int, 
	idc_vendedor varchar(10), 
	nombre_vendedor varchar(50), 
	id_cliente_factura int,
	idc_cliente_factura varchar(10),
	id_despacho int, 
	idc_cliente_despacho varchar(10), 
	nombre_cliente varchar(50), 
	id_transportador int,
	idc_transportador varchar(5),
	nombre_transportador varchar(50),
	tipo_orden int,
	id_orden_pedido int,
	idc_orden_pedido varchar(20),
	id_item_inventario_preventa int,
	fecha_para_aprobar datetime,
	controla_saldos bit,
	empaque_principal bit,
	numero_po varchar(20),
	comentario nvarchar(512),
	inventario int,
	saldo int
)

create table #id_inventario_concatenado 
(
	id int
)

/*crear la insercion para los valores separados por comas*/
declare @sql varchar(1250)
select @sql = 'insert into #id_inventario_concatenado select '+	replace(@id_inventario,',',' union all select ')
	
/*cargar todos los valores de la variable @id_inventario en la tabla temporal*/
exec (@SQL)

insert into @piezas_inventario (id_item_inventario_preventa, cantidad_piezas, fecha_disponible_distribuidora)
select Item_Inventario_Preventa.id_item_inventario_preventa,
isnull(Detalle_Item_Inventario_Preventa.cantidad_piezas, 0),
Detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora
from Inventario_Preventa (NOLOCK),
Item_Inventario_Preventa (NOLOCK) left join Detalle_Item_Inventario_Preventa (NOLOCK) on Item_Inventario_Preventa.id_item_inventario_preventa = Detalle_Item_Inventario_Preventa.id_item_inventario_preventa
where Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and Inventario_Preventa.id_temporada_año = @id_temporada_año

insert into @empaque_principal (precio_minimo,	controla_saldos, id_variedad_flor, id_grado_flor, id_farm, id_tapa)
select precio_minimo,
controla_saldos,
id_variedad_flor,
id_grado_flor,
id_farm,
id_tapa
from Inventario_Preventa (NOLOCK),
Item_Inventario_Preventa (NOLOCK)
where Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and Inventario_Preventa.id_temporada_año = @id_temporada_año
and Item_Inventario_Preventa.empaque_principal = 1
and exists 
(
	select * 
	from #id_inventario_concatenado as ic,
	Item_Inventario_Preventa as iip (NOLOCK),
	inventario_preventa as ip (NOLOCK)
	where ic.id = iip.id_item_inventario_preventa
	and ip.id_inventario_preventa = iip.id_inventario_preventa
	and iip.id_variedad_flor = Item_Inventario_Preventa.id_variedad_flor
	and iip.id_grado_flor = Item_Inventario_Preventa.id_grado_flor
	and ip.id_farm = Inventario_Preventa.id_farm
	and iip.id_tapa = Item_Inventario_Preventa.id_tapa
)
group by precio_minimo,
controla_saldos,
id_variedad_flor,
id_grado_flor,
id_farm,
id_tapa

insert into @ordenes (id_orden_pendiente)
select max(id_orden_pedido) as id_orden_pendiente
from orden_pedido (NOLOCK)
where Orden_Pedido.id_tipo_factura = 2 
and Orden_Pedido.disponible = 1 
and orden_pedido.fecha_inicial between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
group by id_orden_pedido_padre

insert into @ordenes (id_orden_pendiente)
select max(id_orden_pedido) as id_orden_pendiente
from orden_pedido (NOLOCK)
where Orden_Pedido.id_tipo_factura = 2 
and Orden_Pedido.disponible = 1 
and orden_pedido.fecha_para_aprobar between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
group by id_orden_pedido_padre

insert into @temp 
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
pin.cantidad_piezas,
Item_Inventario_Preventa.unidades_por_pieza * pin.cantidad_piezas,
0,
0,
0,
Item_Inventario_Preventa.marca, 
Item_Inventario_Preventa.precio_minimo, 
pin.fecha_disponible_distribuidora,
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
FROM Grado_Flor (NOLOCK), 
Inventario_Preventa (NOLOCK),
Item_Inventario_Preventa (NOLOCK),
@piezas_inventario as pin,     
Variedad_Flor (NOLOCK),      
Tipo_Flor (NOLOCK),               
Tipo_Caja (NOLOCK),                
Farm (NOLOCK),
Tapa (NOLOCK),
Color (NOLOCK)
WHERE Inventario_Preventa.id_farm = Farm.id_farm
and pin.id_item_inventario_preventa = Item_Inventario_Preventa.id_item_inventario_preventa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Grado_Flor.id_grado_flor = Item_Inventario_Preventa.id_grado_flor
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor 
and variedad_flor.id_color = color.id_color
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and exists
(
	select *
	from #id_inventario_concatenado as ic,
	item_inventario_preventa as iip (NOLOCK),
	Inventario_Preventa as ip (NOLOCK)
	where ic.id = iip.id_item_inventario_preventa
	and ip.id_inventario_preventa = iip.id_inventario_preventa
	and ip.id_farm = Inventario_Preventa.id_farm
	and iip.id_variedad_flor = item_inventario_preventa.id_variedad_flor
	and iip.id_grado_flor = item_inventario_preventa.id_grado_flor
	and iip.id_tapa = item_inventario_preventa.id_tapa
)

insert into @inventario_agrupado (id_farm, id_variedad_flor, id_grado_flor, id_tapa)
select t.id_farm,
t.id_variedad_flor,
t.id_grado_flor,
t.id_tapa
from @temp as t
group by t.id_farm,
t.id_variedad_flor,
t.id_grado_flor,
t.id_tapa

update @temp
set precio_minimo = ep.precio_minimo,
controla_saldos = ep.controla_saldos
from @empaque_principal as ep,
@temp as t
where ep.id_farm = t.id_farm
and ep.id_variedad_flor = t.id_variedad_flor
and ep.id_grado_flor = t.id_grado_flor
and ep.id_tapa = t.id_tapa
and t.empaque_principal = 0

insert into @temp 
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
Orden_Pedido (NOLOCK), 
Variedad_Flor (NOLOCK), 
Tipo_Flor (NOLOCK), 
Grado_Flor (NOLOCK), 
Tipo_Caja (NOLOCK), 
Cliente_Despacho (NOLOCK), 
Cliente_Factura (NOLOCK), 
Vendedor (NOLOCK),
Transportador (NOLOCK),
Farm (NOLOCK),
Tapa (NOLOCK),
color (NOLOCK)
WHERE Orden_Pedido.id_tapa = Tapa.id_tapa
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
and exists
(
	select *
	from @ordenes as o
	where o.id_orden_pendiente = orden_pedido.id_orden_pedido
)
and exists
(
	select *
	from @inventario_agrupado as i
	where i.id_farm = farm.id_farm
	and i.id_variedad_flor = variedad_flor.id_variedad_flor
	and i.id_grado_flor = grado_flor.id_grado_flor
	and i.id_tapa = tapa.id_tapa 
)

insert into @unidades (id_farm, id_variedad_flor, id_grado_flor, id_tapa,	unidades_inventario, unidades_preventas)
select id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
sum(cantidad_unidades_inventario_total),
sum(cantidad_unidades_prebook_total)
from @temp
group by id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa

update @temp 
set inventario = isnull(u.unidades_inventario / t.unidades_por_pieza, 0),
saldo = isnull((u.unidades_inventario - u.unidades_preventas) / t.unidades_por_pieza, 0)
from @unidades as u,
@temp as t
where t.id_farm = u.id_farm
and t.id_variedad_flor = u.id_variedad_flor
and t.id_grado_flor = u.id_grado_flor
and t.id_tapa = u.id_tapa

select *, 
cantidad_piezas_prebook as prebook 
from @temp
order by
idc_tipo_flor,
prioridad_color,
idc_variedad_flor,
idc_grado_flor,
nombre_tipo_caja,
tipo_orden,
fecha_disponible_distribuidora

drop table #id_inventario_concatenado