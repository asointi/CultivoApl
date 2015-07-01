set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[preorden_modificar_comentario]

@fecha datetime,
@idc_farm nvarchar(5),
@idc_tipo_flor nvarchar(5),
@codigo nvarchar(5),
@comentario nvarchar(512)

as

declare @id_tipo_flor int,
@id_farm int,
@fecha_inicial datetime,
@fecha_final datetime

select @id_tipo_flor = id_tipo_flor from tipo_flor where idc_tipo_flor = @idc_tipo_flor
select @id_farm = id_farm from farm where idc_farm = @idc_farm

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final
from temporada,
año,
temporada_año,
temporada_cubo
where temporada.id_temporada = temporada_año.id_temporada
and año.id_año = temporada_año.id_año
and temporada.id_temporada = temporada_cubo.id_temporada
and año.id_año = temporada_cubo.id_año
and @fecha between
temporada_cubo.fecha_inicial and temporada_cubo.fecha_final

select max(id_orden_pedido) as id_orden_pedido into #orden_pedido
from orden_pedido
group by id_orden_pedido_padre

select orden_pedido.id_orden_pedido into #ordenes_a_modificar
from orden_pedido,
tipo_factura,
tipo_flor,
variedad_flor,
grado_flor,
farm
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and exists
(
	select *
	from #orden_pedido
	where #orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido
)
and orden_pedido.disponible = 1
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and farm.id_farm = orden_pedido.id_farm
and farm.id_farm = @id_farm
and orden_pedido.marca = @codigo
and tipo_flor.id_tipo_flor = @id_tipo_flor

update orden_pedido
set comentario = @comentario
from #ordenes_a_modificar
where orden_pedido.id_orden_pedido = #ordenes_a_modificar.id_orden_pedido

drop table #orden_pedido
drop table #ordenes_a_modificar