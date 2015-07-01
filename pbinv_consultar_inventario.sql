set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[pbinv_consultar_inventario]

@id_farm nvarchar(255), 
@id_tipo_flor nvarchar(255),
@id_variedad_flor nvarchar(255),
@id_grado_flor nvarchar(255),
@fecha_disponible_distribuidora datetime,
@fecha_disponible_distribuidora_final datetime

AS

select max(id_orden_pedido) as id_orden_pedido into #orden_pedido
from orden_pedido 
group by id_orden_pedido_padre

select id_farm,
id_tapa,
id_tipo_caja,
orden_pedido.id_variedad_flor,
orden_pedido.id_grado_flor,
unidades_por_pieza,
sum(cantidad_piezas) as cantidad_piezas into #facturado
from orden_pedido, 
variedad_flor, 
grado_flor, 
tipo_flor,
tipo_factura
where
orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
and  tipo_flor.id_tipo_flor > =
CASE 
	WHEN @id_tipo_flor is null THEN 1
	else @id_tipo_flor
END
and  tipo_flor.id_tipo_flor < =
CASE 
	WHEN @id_tipo_flor is null THEN 999999
	else @id_tipo_flor
END
and  variedad_flor.id_variedad_flor > =
CASE 
	WHEN @id_variedad_flor is null THEN 1
	else @id_variedad_flor
END
and  variedad_flor.id_variedad_flor < =
CASE 
	WHEN @id_variedad_flor is null THEN 999999
	else @id_variedad_flor
END
and  grado_flor.id_grado_flor > = 
CASE 
	WHEN @id_grado_flor is null THEN 1
	else @id_grado_flor
END
and  grado_flor.id_grado_flor < = 
CASE 
	WHEN @id_grado_flor is null THEN 999999
	else @id_grado_flor
END
and  id_farm > =
CASE 
	WHEN @id_farm is null THEN 0
	else @id_farm
END
and  id_farm < =
CASE 
	WHEN @id_farm is null THEN 999999
	else @id_farm
END
and orden_pedido.fecha_inicial > = @fecha_disponible_distribuidora 
and orden_pedido.fecha_inicial < = @fecha_disponible_distribuidora_final
and exists
(
	select *
	from #orden_pedido 
	where #orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido
)
and orden_pedido.disponible = 1
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
group by
id_farm,
id_tapa,
id_tipo_caja,
orden_pedido.id_variedad_flor,
orden_pedido.id_grado_flor,
unidades_por_pieza

select 
item_inventario_preventa.id_item_inventario_preventa,
Farm.id_farm,
farm.idc_farm,
Tapa.id_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.nombre_grado_flor,
item_inventario_preventa.unidades_por_pieza, 
marca,
item_inventario_preventa.precio_minimo,
item_inventario_preventa.controla_saldos,
sum(detalle_item_inventario_preventa.cantidad_piezas) as cantidad_piezas into #inventario
from detalle_item_inventario_preventa, 
item_inventario_preventa, 
Inventario_Preventa, 
Tapa, 
Tipo_Caja, 
Variedad_Flor, 
Grado_Flor, 
Tipo_Flor, 
Farm
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora > = @fecha_disponible_distribuidora 
and detalle_Item_Inventario_Preventa.fecha_disponible_distribuidora < = @fecha_disponible_distribuidora_final
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_tipo_caja = Tipo_Caja.id_tipo_caja
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
and Variedad_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Grado_Flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
and Inventario_Preventa.id_farm = farm.id_farm
and  tipo_flor.id_tipo_flor > = 
CASE 
	WHEN @id_tipo_flor is null THEN 1
	ELSE @id_tipo_flor
END
and  tipo_flor.id_tipo_flor < = 
CASE 
	WHEN @id_tipo_flor is null THEN 999999
	ELSE @id_tipo_flor
END
and  variedad_flor.id_variedad_flor > = 
CASE 
	WHEN @id_variedad_flor is null THEN 1
	ELSE @id_variedad_flor
END
and  variedad_flor.id_variedad_flor < = 
CASE 
	WHEN @id_variedad_flor is null THEN 999999
	ELSE @id_variedad_flor
END
and  grado_flor.id_grado_flor > = 
CASE 
	WHEN @id_grado_flor is null THEN 1
	ELSE @id_grado_flor
END
and  grado_flor.id_grado_flor < = 
CASE 
	WHEN @id_grado_flor is null THEN 999999
	ELSE @id_grado_flor
END
and  farm.id_farm > =
CASE 
	WHEN @id_farm is null THEN 1
	ELSE @id_farm
END
and  farm.id_farm < =
CASE 
	WHEN @id_farm is null THEN 999999
	ELSE @id_farm
END
group by 
item_inventario_preventa.id_item_inventario_preventa,
Farm.id_farm,
farm.idc_farm,
Tapa.id_tapa,
Tapa.nombre_tapa,
Tipo_Caja.id_tipo_caja,
Tipo_Caja.nombre_tipo_caja,
Tipo_Flor.id_tipo_flor,
Tipo_FLor.nombre_tipo_flor,
Variedad_Flor.id_variedad_flor,
Variedad_Flor.nombre_variedad_flor,
Grado_Flor.id_grado_flor,
Grado_Flor.nombre_grado_flor,
item_inventario_preventa.unidades_por_pieza, 
marca,
item_inventario_preventa.precio_minimo,
item_inventario_preventa.controla_saldos

alter table #inventario
add cantidad_piezas_facturado int, 
cantidad_piezas_saldo int

update 	#inventario
set cantidad_piezas_facturado = #facturado.cantidad_piezas
from #facturado, #inventario
where #inventario.id_tapa = #facturado.id_tapa
and #inventario.id_farm = #facturado.id_farm
and #inventario.id_tipo_caja = #facturado.id_tipo_caja
and #inventario.id_variedad_flor = #facturado.id_variedad_flor
and #inventario.id_grado_flor = #facturado.id_grado_flor
and #inventario.unidades_por_pieza = #facturado.unidades_por_pieza

update #inventario
set cantidad_piezas_facturado = 0
where cantidad_piezas_facturado is null

update #inventario
set cantidad_piezas_saldo = cantidad_piezas - cantidad_piezas_facturado

select id_item_inventario_preventa,
idc_farm,
id_tapa,
nombre_tapa,
id_tipo_caja,
nombre_tipo_caja,
id_tipo_flor,
nombre_tipo_flor,
id_variedad_flor,
nombre_variedad_flor,
id_grado_flor,
nombre_grado_flor,
unidades_por_pieza, 
marca,
precio_minimo,
controla_saldos,
cantidad_piezas as inventario,
cantidad_piezas_facturado as facturado,
cantidad_piezas_saldo as saldo
from #inventario
order by nombre_tipo_flor, 
nombre_variedad_flor, 
nombre_grado_flor

drop table #facturado
drop table #inventario
drop table #orden_pedido