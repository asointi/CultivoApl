USE [BD_Fresca]
GO
/****** Object:  StoredProcedure [dbo].[pbinv_cliente_transportador_preventas_por_PO_version3]    Script Date: 14/01/2015 12:14:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[na_reporte_faltantes_x_vender_preventas]

as

declare @id_temporada_año int,
@fecha_inicial datetime,
@fecha_final datetime

declare @empaque_principal table
(
	id_farm int, 
	id_variedad_flor int, 
	id_grado_flor int, 
	id_tapa int, 
	pack int,
	unidades int
)

declare @preventas table
(
	id_farm int, 
	id_variedad_flor int, 
	id_grado_flor int, 
	id_tapa int, 
	unidades int
)

declare @orden_pedido table
(
	id_orden_pedido int
)

insert into @orden_pedido (id_orden_pedido)
select max(id_orden_pedido)
from orden_pedido
where disponible = 1
and id_tipo_factura = 2
group by id_orden_pedido_padre

select @id_temporada_año = id_temporada_año_preventa from Configuracion_bd

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final
from Temporada_Año,
temporada_cubo
where Temporada_Año.id_Temporada = temporada_cubo.id_temporada
and Temporada_Año.id_Año = temporada_cubo.id_Año
and Temporada_Año.id_temporada_año = @id_temporada_año

insert into @empaque_principal (id_farm, id_variedad_flor, id_grado_flor, id_tapa, pack, unidades)
select id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
unidades_por_pieza,
sum(unidades_por_pieza * cantidad_piezas) as unidades
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa
where inventario_preventa.id_temporada_año = @id_temporada_año
and inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = Detalle_Item_Inventario_Preventa.id_item_inventario_preventa
and item_inventario_preventa.empaque_principal = 1
group by id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
unidades_por_pieza

insert into @preventas (id_farm, id_variedad_flor, id_grado_flor, id_tapa, unidades)
select id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
sum(unidades_por_pieza * cantidad_piezas) as unidades
from orden_pedido,
tipo_factura
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and exists
(
	select *
	from @orden_pedido as op
	where op.id_orden_pedido = orden_Pedido.id_orden_pedido
)
group by id_farm,
id_variedad_flor,
id_grado_flor,
id_tapa,
unidades_por_pieza

select '[' + farm.idc_farm + '] ' + ltrim(rtrim(farm.nombre_farm)) as farm,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as flower_type,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as variety,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as grade,
'[' + tapa.idc_tapa + '] ' + ltrim(rtrim(tapa.nombre_tapa)) as lid,
ep.pack,
ep.unidades / ep.pack as inventory,
p.unidades / ep.pack as sold,
(isnull(ep.unidades, 0) - isnull(p.unidades, 0)) / ep.pack as pending
from @empaque_principal as ep left join @preventas as p
on
(
	ep.id_farm = p.id_farm 
	and ep.id_variedad_flor = p.id_variedad_flor 
	and ep.id_grado_flor = p.id_grado_flor 
	and ep.id_tapa = p.id_tapa 
),
tipo_flor,
variedad_flor,
grado_flor,
tapa,
farm
where tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = ep.id_variedad_flor
and grado_flor.id_grado_flor = ep.id_grado_flor
and tapa.id_tapa = ep.id_tapa
and farm.id_farm = ep.id_farm