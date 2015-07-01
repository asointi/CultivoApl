set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[preorden_consultar_orden_pedido_prebook]

@idc_vendedor nvarchar(10),
@idc_transportador nvarchar(10),
@numero_po nvarchar(50),
@fecha_inicial datetime,
@fecha_final datetime,
@idc_cliente nvarchar(20)

as

select max(id_orden_pedido) as id_orden_pedido into #ordenes
from orden_pedido
group by id_orden_pedido_padre

select max(id_item_orden_sin_aprobar) as id_item_orden_sin_aprobar into #orden_sin_confirmar
from item_orden_sin_aprobar
group by id_item_orden_sin_aprobar_padre

select cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
orden_pedido.fecha_inicial as fecha,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
sum(tipo_caja.factor_a_full * orden_pedido.cantidad_piezas) as factor_a_full,
sum(orden_pedido.valor_unitario * orden_pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as fob_miami_price,
isnull(orden_pedido.numero_po, '') as numero_po,
'' as fecha_para_aprobar,
sum(orden_pedido.cantidad_piezas) as cantidad_piezas,
1 as estado INTO #temp
from orden_pedido,
tipo_factura,
cliente_despacho,
cliente_factura,
vendedor,
transportador,
tipo_caja
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #ordenes
	where #ordenes.id_orden_pedido = orden_pedido.id_orden_pedido
)
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and transportador.id_transportador = orden_pedido.id_transportador
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and vendedor.idc_vendedor >= 
case
	when @idc_vendedor = '' then '   '
	else @idc_vendedor
end
and vendedor.idc_vendedor <= 
case
	when @idc_vendedor = '' then 'ZZZ'
	else @idc_vendedor
end
and transportador.id_transportador = transportador.id_transportador
and transportador.idc_transportador >=
case 
	when @idc_transportador = '' then '   '
	else @idc_transportador
end
and transportador.idc_transportador <=
case 
	when @idc_transportador = '' then 'ZZZ'
	else @idc_transportador
end
and isnull(orden_pedido.numero_po, '') >=
case
	when @numero_po = '' then '               '
	else @numero_po
end
and isnull(orden_pedido.numero_po, '') <=
case
	when @numero_po = '' then 'ZZZZZZZZZZZZZZZ'
	else @numero_po
end
and cliente_despacho.idc_cliente_despacho >=
case
	when @idc_cliente = '' then '               '
	else @idc_cliente
end
and cliente_despacho.idc_cliente_despacho <=
case
	when @idc_cliente = '' then 'ZZZZZZZZZZZZZZZ'
	else @idc_cliente
end
group by cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
orden_pedido.fecha_inicial,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)),
isnull(orden_pedido.numero_po, ''),
isnull(orden_pedido.fecha_para_aprobar, '')

union all

select cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
orden_pedido.fecha_inicial as fecha,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
sum(tipo_caja.factor_a_full * orden_pedido.cantidad_piezas) as factor_a_full,
sum(orden_pedido.valor_unitario * orden_pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as fob_miami_price,
isnull(orden_pedido.numero_po, '') as numero_po,
isnull(orden_pedido.fecha_para_aprobar, '') as fecha_para_aprobar,
sum(orden_pedido.cantidad_piezas) as cantidad_piezas,
2 as estado
from orden_pedido,
tipo_factura,
cliente_despacho,
cliente_factura,
vendedor,
transportador,
tipo_caja
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #ordenes
	where #ordenes.id_orden_pedido = orden_pedido.id_orden_pedido
)
and orden_pedido.fecha_para_aprobar between
@fecha_inicial and @fecha_final
and Orden_Pedido.fecha_inicial = convert(datetime, '1999/01/01')
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and transportador.id_transportador = orden_pedido.id_transportador
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and vendedor.idc_vendedor >= 
case
	when @idc_vendedor = '' then '   '
	else @idc_vendedor
end
and vendedor.idc_vendedor <= 
case
	when @idc_vendedor = '' then 'ZZZ'
	else @idc_vendedor
end
and transportador.id_transportador = transportador.id_transportador
and transportador.idc_transportador >=
case 
	when @idc_transportador = '' then '   '
	else @idc_transportador
end
and transportador.idc_transportador <=
case 
	when @idc_transportador = '' then 'ZZZ'
	else @idc_transportador
end
and isnull(orden_pedido.numero_po, '') >=
case
	when @numero_po = '' then '               '
	else @numero_po
end
and isnull(orden_pedido.numero_po, '') <=
case
	when @numero_po = '' then 'ZZZZZZZZZZZZZZZ'
	else @numero_po
end
and cliente_despacho.idc_cliente_despacho >=
case
	when @idc_cliente = '' then '               '
	else @idc_cliente
end
and cliente_despacho.idc_cliente_despacho <=
case
	when @idc_cliente = '' then 'ZZZZZZZZZZZZZZZ'
	else @idc_cliente
end
group by cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
orden_pedido.fecha_inicial,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)),
isnull(orden_pedido.numero_po, ''),
isnull(orden_pedido.fecha_para_aprobar, '')

UNION ALL

/*Extraer Orden_sin_aprobar - Not sent to farm*/
select cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
item_orden_sin_aprobar.fecha_inicial as fecha,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
sum(tipo_caja.factor_a_full * item_orden_sin_aprobar.cantidad_piezas) as factor_a_full,
sum(item_orden_sin_aprobar.valor_unitario * item_orden_sin_aprobar.unidades_por_pieza * item_orden_sin_aprobar.cantidad_piezas) as fob_miami_price,
isnull(item_orden_sin_aprobar.numero_po, '') as numero_po,
'',
sum(item_orden_sin_aprobar.cantidad_piezas) as cantidad_piezas,
3 as estado
from orden_sin_aprobar,
item_orden_sin_aprobar,
tipo_factura,
caja,
tipo_caja,
transportador,
cliente_despacho,
cliente_factura,
vendedor
where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and tipo_factura.idc_tipo_factura = '4'
and exists
(
	select *
	from #orden_sin_confirmar
	where #orden_sin_confirmar.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and caja.id_caja = item_orden_sin_aprobar.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and transportador.id_transportador = item_orden_sin_aprobar.id_transportador
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and item_orden_sin_aprobar.fecha_inicial between
@fecha_inicial and @fecha_final
and not exists
(
	select * 
	from solicitud_confirmacion_orden_especial
	where solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and vendedor.idc_vendedor >= 
case
	when @idc_vendedor = '' then '   '
	else @idc_vendedor
end
and vendedor.idc_vendedor <= 
case
	when @idc_vendedor = '' then 'ZZZ'
	else @idc_vendedor
end
and transportador.idc_transportador >=
case 
	when @idc_transportador = '' then '   '
	else @idc_transportador
end
and transportador.idc_transportador <=
case 
	when @idc_transportador = '' then 'ZZZ'
	else @idc_transportador
end
and isnull(item_orden_sin_aprobar.numero_po, '') >=
case
	when @numero_po = '' then '               '
	else @numero_po
end
and isnull(item_orden_sin_aprobar.numero_po, '') <=
case
	when @numero_po = '' then 'ZZZZZZZZZZZZZZZ'
	else @numero_po
end
and cliente_despacho.idc_cliente_despacho >=
case
	when @idc_cliente = '' then '               '
	else @idc_cliente
end
and cliente_despacho.idc_cliente_despacho <=
case
	when @idc_cliente = '' then 'ZZZZZZZZZZZZZZZ'
	else @idc_cliente
end
group by cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
item_orden_sin_aprobar.fecha_inicial,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)),
isnull(item_orden_sin_aprobar.numero_po, '')

UNION ALL

/*Extraer Orden_sin_aprobar - Not Farm Confirmed*/
select cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
item_orden_sin_aprobar.fecha_inicial as fecha,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)) as nombre_vendedor,
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador,
sum(tipo_caja.factor_a_full * item_orden_sin_aprobar.cantidad_piezas) as factor_a_full,
sum(item_orden_sin_aprobar.valor_unitario * item_orden_sin_aprobar.unidades_por_pieza * item_orden_sin_aprobar.cantidad_piezas) as fob_miami_price,
isnull(item_orden_sin_aprobar.numero_po, '') as numero_po,
'',
sum(item_orden_sin_aprobar.cantidad_piezas) as cantidad_piezas,
4 as estado
from orden_sin_aprobar,
item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
tipo_factura,
caja,
tipo_caja,
transportador,
cliente_despacho,
cliente_factura,
vendedor
where cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
and vendedor.id_vendedor = cliente_factura.id_vendedor
and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and tipo_factura.idc_tipo_factura = '4'
and exists
(
	select *
	from #orden_sin_confirmar
	where #orden_sin_confirmar.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and caja.id_caja = item_orden_sin_aprobar.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and transportador.id_transportador = item_orden_sin_aprobar.id_transportador
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and item_orden_sin_aprobar.fecha_inicial between
@fecha_inicial and @fecha_final
and solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.aceptada = 1
and not exists
(
	select * 
	from confirmacion_orden_especial_cultivo
	where confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial = solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial
)
and vendedor.idc_vendedor >= 
case
	when @idc_vendedor = '' then '   '
	else @idc_vendedor
end
and vendedor.idc_vendedor <= 
case
	when @idc_vendedor = '' then 'ZZZ'
	else @idc_vendedor
end
and transportador.idc_transportador >=
case 
	when @idc_transportador = '' then '   '
	else @idc_transportador
end
and transportador.idc_transportador <=
case 
	when @idc_transportador = '' then 'ZZZ'
	else @idc_transportador
end
and isnull(item_orden_sin_aprobar.numero_po, '') >=
case
	when @numero_po = '' then '               '
	else @numero_po
end
and isnull(item_orden_sin_aprobar.numero_po, '') <=
case
	when @numero_po = '' then 'ZZZZZZZZZZZZZZZ'
	else @numero_po
end
and cliente_despacho.idc_cliente_despacho >=
case
	when @idc_cliente = '' then '               '
	else @idc_cliente
end
and cliente_despacho.idc_cliente_despacho <=
case
	when @idc_cliente = '' then 'ZZZZZZZZZZZZZZZ'
	else @idc_cliente
end
group by cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
item_orden_sin_aprobar.fecha_inicial,
vendedor.idc_vendedor,
ltrim(rtrim(vendedor.nombre)),
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)),
isnull(item_orden_sin_aprobar.numero_po, '')

select idc_cliente_despacho,
nombre_cliente,
fecha,
idc_vendedor,
nombre_vendedor,
idc_transportador,
nombre_transportador,
sum(factor_a_full) as factor_a_full,
sum(fob_miami_price) as fob_miami_price,
numero_po,
fecha_para_aprobar,
sum(cantidad_piezas) as cantidad_piezas,
(
	select isnull(sum(t.cantidad_piezas), 0)
	from #temp as t
	where t.idc_cliente_despacho = #temp.idc_cliente_despacho
	and t.fecha = #temp.fecha
	and t.idc_vendedor = #temp.idc_vendedor
	and t.idc_transportador = #temp.idc_transportador
	and t.numero_po = #temp.numero_po
	and estado in (1)
) as piezas_confirmadas,
(
	select isnull(sum(t.cantidad_piezas), 0)
	from #temp as t
	where t.idc_cliente_despacho = #temp.idc_cliente_despacho
	and t.fecha = #temp.fecha
	and t.idc_vendedor = #temp.idc_vendedor
	and t.idc_transportador = #temp.idc_transportador
	and t.numero_po = #temp.numero_po
	and estado in (2,3,4)
) as piezas_sin_confirmar
from #temp
group by idc_cliente_despacho,
nombre_cliente,
fecha,
idc_vendedor,
nombre_vendedor,
idc_transportador,
nombre_transportador,
numero_po,
fecha_para_aprobar

drop table #ordenes
drop table #orden_sin_confirmar
drop table #temp