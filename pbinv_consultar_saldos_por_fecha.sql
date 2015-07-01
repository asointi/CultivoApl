/****** Object:  StoredProcedure [dbo].[pbinv_consultar_piezas_inventario]    Script Date: 05/14/2008 11:39:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[pbinv_consultar_saldos_por_fecha]

@id_item_inventario_preventa int,
@fecha_disponible_distribuidora_inicial datetime,
@fecha_disponible_distribuidora_final datetime 

AS

declare @id_variedad_flor int,
@id_grado_flor int,
@id_farm int,
@id_tapa int,
@unidades_por_pieza int,
@base_datos nvarchar(50),
@conteo int,
@cantidad_dias int,
@fecha datetime,
@id int,
@unidades int,
@id_temporada_año int,
@preventas int 

select @id_temporada_año = temporada_año.id_temporada_año,
@cantidad_dias = datediff(dd, temporada_cubo.fecha_inicial, temporada_cubo.fecha_final)
from temporada_año,
temporada_cubo
where temporada_año.fecha_inicial = @fecha_disponible_distribuidora_inicial
and temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_año = temporada_cubo.id_año

set @fecha = @fecha_disponible_distribuidora_inicial

create table #dias 
(
	id int identity (1,1),
	fecha datetime,
	unidades_inventario int default (0)
)


insert into #dias (fecha)
values (@fecha)

set @conteo = 1

while(@conteo < = @cantidad_dias)
begin
	insert into #dias (fecha)
	values (dateadd(dd, 1, @fecha))

	set @fecha = dateadd(dd, 1, @fecha)
	set @conteo = @conteo + 1
end

set @base_datos = db_name()

select @id_variedad_flor = item_inventario_preventa.id_variedad_flor,
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

select @preventas = isnull(sum(Orden_Pedido.unidades_por_pieza * orden_pedido.cantidad_piezas),0)
from orden_pedido,
tapa, 
variedad_flor, 
grado_flor, 
farm, 
tipo_factura
where tipo_factura.idc_tipo_factura = '4'
and orden_pedido.fecha_inicial between
@fecha_disponible_distribuidora_inicial and @fecha_disponible_distribuidora_final
and orden_pedido.disponible = 1
and orden_pedido.id_tapa = tapa.id_tapa
and orden_pedido.id_variedad_flor = variedad_flor.id_variedad_flor
and orden_pedido.id_grado_flor = grado_flor.id_grado_flor
and orden_pedido.id_farm = farm.id_farm
and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
and farm.id_farm = @id_farm
and variedad_flor.id_variedad_flor = @id_variedad_flor
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
and exists
(
	select *
	from #ordenes
	where orden_pedido.id_orden_pedido = #ordenes.id_orden_pedido
)

select sum(item_inventario_preventa.unidades_por_pieza * detalle_item_inventario_preventa.cantidad_piezas) as unidades_inventario,
detalle_item_inventario_preventa.fecha_disponible_distribuidora into #inventario
from detalle_item_inventario_preventa, 
item_inventario_preventa, 
Inventario_Preventa, 
Tapa, 
Variedad_Flor, 
Grado_Flor, 
Farm
where detalle_item_inventario_preventa.id_item_inventario_preventa = item_inventario_preventa.id_item_inventario_preventa
and Inventario_Preventa.id_inventario_preventa = Item_Inventario_Preventa.id_inventario_preventa
and farm.id_farm = @id_farm
and variedad_flor.id_variedad_flor = @id_variedad_flor
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
and inventario_preventa.id_temporada_año = @id_temporada_año 
and Inventario_Preventa.id_farm = farm.id_farm
and Item_Inventario_Preventa.id_tapa = Tapa.id_tapa
and Item_Inventario_Preventa.id_variedad_flor = Variedad_Flor.id_variedad_flor
and Item_Inventario_Preventa.id_grado_flor = Grado_Flor.id_grado_flor
group by detalle_item_inventario_preventa.fecha_disponible_distribuidora

update #dias
set unidades_inventario = #inventario.unidades_inventario
from #inventario
where fecha = #inventario.fecha_disponible_distribuidora

update #dias
set unidades_inventario = isnull((select sum(#inventario.unidades_inventario) from #inventario where fecha_disponible_distribuidora >= @fecha),0)
where fecha = @fecha

set @conteo = null
set @unidades = 0

select @conteo = count(*) from #dias
set @id = 1

while(@conteo > = @id)
begin
	select @unidades = @unidades + unidades_inventario
	from #dias
	where id = @id
	
	update #dias
	set unidades_inventario = @unidades
	where id = @id

	set @id = @id + 1
end

select fecha,
unidades_inventario - @preventas as unidades_saldo,
(unidades_inventario - @preventas)/@unidades_por_pieza as saldo
from #dias

drop table #ordenes
drop table #dias
drop table #inventario