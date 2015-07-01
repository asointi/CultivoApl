set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[pbinv2_consultar_piezas_prevendidas]

@id_temporada_año int

AS

declare @fecha_inicial datetime,
@fecha_final datetime

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final
from temporada_año,
temporada_cubo
where id_temporada_año = @id_temporada_año
and temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_año = temporada_cubo.id_año

select max(id_orden_pedido) as id_orden_pedido into #orden_pedido
from orden_pedido
group by id_orden_pedido_padre

select tapa.id_tapa,
farm.id_farm,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
orden_pedido.fecha_inicial,
tipo_caja.id_tipo_caja,
orden_pedido.unidades_por_pieza,
sum(orden_pedido.cantidad_piezas * orden_pedido.unidades_por_pieza) as unidades into #preventa
from orden_pedido,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
tipo_caja,
farm
where orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and id_tipo_factura = 2
and orden_pedido.disponible = 1
and tapa.id_tapa = orden_pedido.id_tapa
and farm.id_farm = orden_pedido.id_farm
and exists
(
	select *
	from #orden_pedido
	where orden_pedido.id_orden_pedido = #orden_pedido.id_orden_pedido
)
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja 
group by tapa.id_tapa,
farm.id_farm,
tipo_flor.id_tipo_flor,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
orden_pedido.fecha_inicial,
tipo_caja.id_tipo_caja,
orden_pedido.unidades_por_pieza

select item_inventario_preventa.id_item_inventario_preventa,
tapa.id_tapa,
farm.id_farm,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_caja.id_tipo_caja,
item_inventario_preventa.unidades_por_pieza,
detalle_item_inventario_preventa.fecha_disponible_distribuidora as fecha into #inventario
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
tipo_caja
where inventario_preventa.id_temporada_año = @id_temporada_año
and inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and farm.id_farm = inventario_preventa.id_farm
and tapa.id_tapa = item_inventario_preventa.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
and tipo_caja.id_tipo_caja = item_inventario_preventa.id_tipo_caja
and item_inventario_preventa.empaque_principal = 1
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
group by item_inventario_preventa.id_item_inventario_preventa,
tapa.id_tapa,
farm.id_farm,
variedad_flor.id_variedad_flor,
grado_flor.id_grado_flor,
tipo_caja.id_tipo_caja,
item_inventario_preventa.unidades_por_pieza,
detalle_item_inventario_preventa.fecha_disponible_distribuidora

select #preventa.id_farm,
#preventa.id_variedad_flor,
#preventa.id_grado_flor,
#preventa.id_tapa,
#inventario.unidades_por_pieza as empaque_inventario,
#inventario.id_tipo_caja,
#preventa.fecha_inicial,
datepart(dy,#preventa.fecha_inicial) as dia,
max(#inventario.fecha) inventario_fecha_max,
min(#inventario.fecha) inventario_fecha_min,
sum(#preventa.unidades) as unidades_prevendidas into #preventa_agrupada
from #preventa,
#inventario
where #preventa.id_farm = #inventario.id_farm
and #preventa.id_variedad_flor = #inventario.id_variedad_flor
and #preventa.id_grado_flor = #inventario.id_grado_flor
and #preventa.id_tapa = #inventario.id_tapa
group by #preventa.id_farm,
#preventa.id_variedad_flor,
#preventa.id_grado_flor,
#preventa.id_tapa,
#inventario.unidades_por_pieza,
#inventario.id_tipo_caja,
#preventa.fecha_inicial

alter table #inventario 
add unidades_prevendidas int

select IDENTITY(INT,1,1) AS id,
datepart(dy,fecha) as dia into #fecha
from fecha_inventario
where id_temporada_año = @id_temporada_año
order by fecha

declare @conteo int,
@dia nvarchar(5),
@query nvarchar(max),
@id int,
@dia_anterior nvarchar(5),
@dia_maximo nvarchar(5)

select @dia_maximo = dia 
from #fecha
where id = (select max(id) from #fecha)

select @id = count(*)
from #fecha

set @conteo = 1

while(@conteo < = @id)
begin
	select @dia = dia
	from #fecha
	where id = @conteo

	IF(@conteo = 1)
	begin
		set @dia_anterior = 1
	end
	else 
	begin
		select @dia_anterior = dia
		from #fecha
		where id = @conteo - 1
	end

	set @query	= 'update #inventario
	set unidades_prevendidas = (select sum(#preventa_agrupada.unidades_prevendidas)
	from #preventa_agrupada
	where #preventa_agrupada.id_farm = #inventario.id_farm
	and #preventa_agrupada.id_tapa = #inventario.id_tapa
	and #preventa_agrupada.id_variedad_flor = #inventario.id_variedad_flor
	and #preventa_agrupada.id_grado_flor = #inventario.id_grado_flor
	and #preventa_agrupada.id_tipo_caja = #inventario.id_tipo_caja
	and #preventa_agrupada.empaque_inventario = #inventario.unidades_por_pieza
	and #preventa_agrupada.dia > ' + @dia_anterior +
	'and #preventa_agrupada.dia < = 
	case
		when ' + @dia + ' = ' + @dia_maximo + ' then 364
		else ' + @dia +
	' end)
	from #preventa_agrupada
	where #preventa_agrupada.id_farm = #inventario.id_farm
	and #preventa_agrupada.id_tapa = #inventario.id_tapa
	and #preventa_agrupada.id_variedad_flor = #inventario.id_variedad_flor
	and #preventa_agrupada.id_grado_flor = #inventario.id_grado_flor
	and #preventa_agrupada.id_tipo_caja = #inventario.id_tipo_caja
	and #preventa_agrupada.empaque_inventario = #inventario.unidades_por_pieza
	and datepart(dy, #inventario.fecha) = ' + @dia

	exec (@query)

	set @query	= 'update #inventario
	set unidades_prevendidas = (select sum(#preventa_agrupada.unidades_prevendidas)
	from #preventa_agrupada
	where #preventa_agrupada.id_farm = #inventario.id_farm
	and #preventa_agrupada.id_tapa = #inventario.id_tapa
	and #preventa_agrupada.id_variedad_flor = #inventario.id_variedad_flor
	and #preventa_agrupada.id_grado_flor = #inventario.id_grado_flor
	and #preventa_agrupada.id_tipo_caja = #inventario.id_tipo_caja
	and #preventa_agrupada.empaque_inventario = #inventario.unidades_por_pieza
	and #preventa_agrupada.inventario_fecha_max = #preventa_agrupada.inventario_fecha_min
	and #preventa_agrupada.inventario_fecha_max > ' + @dia_maximo +
	')
	from #preventa_agrupada
	where #preventa_agrupada.id_farm = #inventario.id_farm
	and #preventa_agrupada.id_tapa = #inventario.id_tapa
	and #preventa_agrupada.id_variedad_flor = #inventario.id_variedad_flor
	and #preventa_agrupada.id_grado_flor = #inventario.id_grado_flor
	and #preventa_agrupada.id_tipo_caja = #inventario.id_tipo_caja
	and #preventa_agrupada.empaque_inventario = #inventario.unidades_por_pieza
	and datepart(dy, #inventario.fecha) = ' + @dia

	exec (@query)

	set @conteo = @conteo + 1
end

update #inventario
set unidades_prevendidas = 0
where unidades_prevendidas is null

select id_item_inventario_preventa,
Fecha_Inventario.id_fecha_inventario,
Fecha_Inventario.fecha,
unidades_prevendidas into #resultado
from #inventario,
Fecha_Inventario
where Fecha_Inventario.id_temporada_año = @id_temporada_año
and Fecha_Inventario.fecha = #inventario.fecha

select id_item_inventario_preventa,
id_fecha_inventario,
fecha,
unidades_prevendidas
from #resultado
union all
select id_item_inventario_preventa,
Fecha_Inventario.id_fecha_inventario,
Fecha_Inventario.fecha,
0
from #inventario,
Fecha_Inventario
where Fecha_Inventario.id_temporada_año = @id_temporada_año
and not exists
(
	select *
	from #resultado
	where #resultado.id_fecha_inventario = fecha_inventario.id_fecha_inventario
	and #resultado.id_item_inventario_preventa = #inventario.id_item_inventario_preventa
)
group by id_item_inventario_preventa,
Fecha_Inventario.id_fecha_inventario,
Fecha_Inventario.fecha
order by fecha

select #inventario.id_item_inventario_preventa,
#preventa.unidades_por_pieza,
#preventa.id_tipo_caja
from #preventa,
#inventario
where #preventa.id_farm = #inventario.id_farm
and #preventa.id_variedad_flor = #inventario.id_variedad_flor
and #preventa.id_grado_flor = #inventario.id_grado_flor
group by #inventario.id_item_inventario_preventa,
#preventa.unidades_por_pieza,
#preventa.id_tipo_caja

drop table #inventario
drop table #preventa
drop table #orden_pedido
drop table #preventa_agrupada
drop table #fecha
drop table #resultado