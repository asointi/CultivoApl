/****** Object:  StoredProcedure [dbo].[pbinv_consultar_piezas_inventario]    Script Date: 05/14/2008 11:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pbinv_consultar_piezas_inventario_version5]

@id_item_inventario_preventa int,
@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime 

AS

declare @id_variedad_flor int,
@id_grado_flor int,
@id_farm int,
@id_tapa int,
@unidades_por_pieza int,
@unidades_inventario int,
@unidades_prevendidas int,
@controla_saldos bit,
@base_datos nvarchar(50)

set @base_datos = db_name()

select @controla_saldos = item_inventario_preventa.controla_saldos,
@id_variedad_flor = item_inventario_preventa.id_variedad_flor,
@id_grado_flor = item_inventario_preventa.id_grado_flor,
@id_farm = inventario_preventa.id_farm,
@id_tapa = item_inventario_preventa.id_tapa,
@unidades_por_pieza = item_inventario_preventa.unidades_por_pieza
from inventario_preventa,
item_inventario_preventa
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa

select max(id_orden_pedido) as id_orden_pedido into #ordenes
from orden_pedido
group by id_orden_pedido_padre

create table #resultado
(
	unidades_inventario int,
	unidades_prevendidas int,
	id_item_inventario_preventa int,
	id_tapa int,
	idc_tapa nvarchar(10),
	nombre_tapa nvarchar(50),
	id_tipo_caja int,
	idc_tipo_caja nvarchar(10),
	nombre_tipo_caja nvarchar(50),
	id_tipo_flor int,
	idc_tipo_flor nvarchar(10),
	nombre_tipo_flor nvarchar(50),
	id_variedad_flor int,
	idc_variedad_flor nvarchar(10),
	nombre_variedad_flor nvarchar(50),
	id_grado_flor int,
	idc_grado_flor nvarchar(10),
	nombre_grado_flor nvarchar(50),
	id_farm int,
	idc_farm nvarchar(10),
	nombre_farm nvarchar(50),
	unidades_por_pieza int, 
	marca nvarchar(10),
	precio_minimo decimal(20,4), 
	fecha_disponible_distribuidora datetime,
	controla_saldos bit,
	cantidad_piezas int,
	cantidad_piezas_ofertadas_finca int
)

insert into #resultado
(
	unidades_inventario,
	unidades_prevendidas,
	id_item_inventario_preventa,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	id_farm,
	idc_farm,
	nombre_farm,
	unidades_por_pieza, 
	marca,
	precio_minimo, 
	fecha_disponible_distribuidora,
	controla_saldos,
	cantidad_piezas,
	cantidad_piezas_ofertadas_finca
)
select 0 as unidades_inventario,
sum(Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas) as unidades_prevendidas,
0 as id_item_inventario_preventa,
Tapa.id_tapa,
Tapa.idc_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.idc_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_Flor.idc_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.idc_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
orden_pedido.unidades_por_pieza, 
orden_pedido.marca,
orden_pedido.valor_unitario as precio_minimo, 
orden_pedido.fecha_inicial as fecha_disponible_distribuidora,
@controla_saldos as controla_saldos,
sum(orden_pedido.cantidad_piezas) as cantidad_piezas,
0 as cantidad_piezas_ofertadas_finca
from orden_pedido,
tapa, 
variedad_flor, 
grado_flor, 
farm, 
tipo_factura,
tipo_caja,
tipo_flor
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.fecha_inicial between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and orden_pedido.disponible = 1
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and orden_pedido.id_farm = farm.id_farm
and farm.id_farm = @id_farm
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa > = 
case
	when @base_datos = 'BD_NF' then 0
	else @id_tapa
end
and tapa.id_tapa < = 
case
	when @base_datos = 'BD_NF' then 99999
	else @id_tapa
end
and variedad_flor.id_variedad_flor = @id_variedad_flor
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and exists
(
	select *
	from #ordenes
	where orden_pedido.id_orden_pedido = #ordenes.id_orden_pedido
)
group by Tapa.id_tapa,
Tapa.idc_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.idc_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_Flor.idc_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.idc_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
orden_pedido.unidades_por_pieza, 
orden_pedido.marca,
orden_pedido.fecha_inicial,
orden_pedido.valor_unitario

insert into #resultado
(
	unidades_inventario,
	unidades_prevendidas,
	id_item_inventario_preventa,
	id_tapa,
	idc_tapa,
	nombre_tapa,
	id_tipo_caja,
	idc_tipo_caja,
	nombre_tipo_caja,
	id_tipo_flor,
	idc_tipo_flor,
	nombre_tipo_flor,
	id_variedad_flor,
	idc_variedad_flor,
	nombre_variedad_flor,
	id_grado_flor,
	idc_grado_flor,
	nombre_grado_flor,
	id_farm,
	idc_farm,
	nombre_farm,
	unidades_por_pieza, 
	marca,
	precio_minimo, 
	fecha_disponible_distribuidora,
	controla_saldos,
	cantidad_piezas,
	cantidad_piezas_ofertadas_finca
)
select sum(item_inventario_preventa.unidades_por_pieza * detalle_item_inventario_preventa.cantidad_piezas) as unidades_inventario,
0 as unidades_prevendidas,
item_inventario_preventa.id_item_inventario_preventa,
Tapa.id_tapa,
Tapa.idc_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.idc_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_Flor.idc_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.idc_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
item_inventario_preventa.unidades_por_pieza, 
marca,
item_inventario_preventa.precio_minimo, 
detalle_item_inventario_preventa.fecha_disponible_distribuidora,
item_inventario_preventa.controla_saldos, 
sum(detalle_item_inventario_preventa.cantidad_piezas) as cantidad_piezas,
sum(Detalle_Item_Inventario_Preventa.cantidad_piezas_ofertadas_finca) as cantidad_piezas_ofertadas_finca
from detalle_item_inventario_preventa, 
item_inventario_preventa, 
Inventario_Preventa, 
Tapa, 
Variedad_Flor, 
Grado_Flor, 
Tipo_Flor, 
Farm, 
Tipo_Caja
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and farm.id_farm = @id_farm
and grado_flor.id_grado_flor = @id_grado_flor
and tapa.id_tapa > = 
case
	when @base_datos = 'BD_NF' then 0
	else @id_tapa
end
and tapa.id_tapa < = 
case
	when @base_datos = 'BD_NF' then 99999
	else @id_tapa
end
and variedad_flor.id_variedad_flor = @id_variedad_flor
and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
group by 
item_inventario_preventa.id_item_inventario_preventa,
Tapa.id_tapa,
Tapa.idc_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.idc_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_Flor.idc_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.idc_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.idc_grado_flor,
Grado_Flor.nombre_grado_flor,
Farm.id_farm,
Farm.idc_farm,
Farm.nombre_farm,
item_inventario_preventa.unidades_por_pieza, 
marca,
item_inventario_preventa.precio_minimo, 
detalle_item_inventario_preventa.fecha_disponible_distribuidora,
item_inventario_preventa.controla_saldos,
item_inventario_preventa.fecha_transaccion

select * 
from #resultado
order by fecha_disponible_distribuidora

drop table #ordenes
drop table #resultado