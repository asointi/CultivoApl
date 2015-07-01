/****** Object:  StoredProcedure [dbo].[pbinv_consultar_detalle_item]    Script Date: 01/05/2008 09:35:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[pbinv_consultar_detalle_item]

@id_item_inventario_preventa integer,
@fecha_disponible_distribuidora datetime

AS
set language 'english'

declare @cont int


create table #temp_inventario 
(id_farm int
, id_tapa int
, id_tipo_caja int
, id_variedad_flor int
, id_grado_flor int
, unidades_por_pieza int
, marca nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS not null
, fecha_disponible_distribuidora datetime
)

set @cont = -1

while (@cont < = 13)
begin
	set @cont = @cont + 1
	insert into #temp_inventario (id_farm, id_tapa, id_tipo_caja, id_variedad_flor, id_grado_flor, unidades_por_pieza, marca, fecha_disponible_distribuidora)
	select 
	inventario_preventa.id_farm,
	item_inventario_preventa.id_tapa,
	item_inventario_preventa.id_tipo_caja,
	item_inventario_preventa.id_variedad_flor,
	item_inventario_preventa.id_grado_flor,
	item_inventario_preventa.unidades_por_pieza,
	item_inventario_preventa.marca,
	@fecha_disponible_distribuidora + @cont as fecha_disponible_distribuidora
	from item_inventario_preventa, inventario_preventa
	where item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
	and item_inventario_preventa.id_inventario_preventa = inventario_preventa.id_inventario_preventa
end

alter table #temp_inventario
add cantidad_piezas int, id_detalle_item_inventario_preventa int

update #temp_inventario
set cantidad_piezas = 0

update #temp_inventario
set cantidad_piezas = detalle_item_inventario_preventa.cantidad_piezas,
id_detalle_item_inventario_preventa = detalle_item_inventario_preventa.id_detalle_item_inventario_preventa
from detalle_item_inventario_preventa
where detalle_item_inventario_preventa.id_item_inventario_preventa = @id_item_inventario_preventa
and convert(nvarchar, #temp_inventario.fecha_disponible_distribuidora,101) = convert(nvarchar,detalle_item_inventario_preventa.fecha_disponible_distribuidora,101)
and detalle_item_inventario_preventa.id_detalle_item_inventario_preventa in
(
select max(id_detalle_item_inventario_preventa) from detalle_item_inventario_preventa group by id_detalle_item_inventario_preventa_padre
)

select id_tapa,
id_tipo_caja,
id_variedad_flor,
id_grado_flor,
id_farm,
unidades_por_pieza,
marca,
fecha_inicial,
sum(cantidad_piezas) as cantidad_piezas into #temp_orden_pedido
from orden_pedido
where id_tipo_factura = 2
and fecha_inicial > = @fecha_disponible_distribuidora
and disponible = 1
group by 
id_tapa,
id_tipo_caja,
id_variedad_flor,
id_grado_flor,
id_farm,
unidades_por_pieza,
marca,
fecha_inicial

alter table #temp_inventario
add facturado integer

update #temp_inventario
set facturado = #temp_orden_pedido.cantidad_piezas
from #temp_orden_pedido, #temp_inventario
where #temp_orden_pedido.id_tapa = #temp_inventario.id_tapa
and #temp_orden_pedido.id_tipo_caja = #temp_inventario.id_tipo_caja
and #temp_orden_pedido.id_variedad_flor = #temp_inventario.id_variedad_flor
and #temp_orden_pedido.id_grado_flor = #temp_inventario.id_grado_flor
and #temp_orden_pedido.id_farm = #temp_inventario.id_farm
and #temp_orden_pedido.unidades_por_pieza = #temp_inventario.unidades_por_pieza
and rtrim(ltrim(#temp_orden_pedido.marca)) = rtrim(ltrim(#temp_inventario.marca))
and convert(nvarchar, #temp_orden_pedido.fecha_inicial,101) = convert(nvarchar, #temp_inventario.fecha_disponible_distribuidora, 101)

update #temp_inventario
set facturado = 0
where facturado is null	

select #temp_inventario.id_detalle_item_inventario_preventa,
#temp_inventario.fecha_disponible_distribuidora,
#temp_inventario.cantidad_piezas as inventario,
#temp_inventario.facturado,
#temp_inventario.cantidad_piezas-#temp_inventario.facturado as saldo
from #temp_inventario
order by #temp_inventario.fecha_disponible_distribuidora

drop table #temp_inventario
drop table #temp_orden_pedido
