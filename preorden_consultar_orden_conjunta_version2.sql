set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[preorden_consultar_orden_conjunta_version2]

@fecha datetime,
@idc_transportador nvarchar(10),
@idc_cliente_despacho nvarchar(15),
@numero_po nvarchar(50)

as

/*Declaracion de variables globales*/
declare @estado_inventario int,
@estado_prevendido int,
@estado_orden_sin_aprobar_not_sent_to_farm int,
@estado_orden_sin_aprobar_no_farm_confirmed int,
@estado_prevendido_sin_confirmar int,
@estado_orden_aprobada int,
@nombre_base_datos nvarchar(255),
@id_tapa int,
@idc_tapa nvarchar(3),
@nombre_tapa nvarchar(20),
@fecha_inicial datetime,
@fecha_final datetime

/* RMR */

set @nombre_base_datos = DB_NAME()
set @id_tapa = NULL
set @idc_tapa = NULL
set @nombre_tapa = NULL

if(@nombre_base_datos = 'BD_NF')
	begin
		select @id_tapa = tapa.id_tapa,
		@idc_tapa = tapa.idc_tapa,
		@nombre_tapa = tapa.nombre_tapa    
		from grupo_cliente_factura,
		cliente_factura,
		cliente_despacho,
		tapa
		where grupo_cliente_factura.id_grupo_cliente_factura = cliente_factura.id_grupo_cliente_factura
		and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
		and tapa.id_tapa = grupo_cliente_factura.id_tapa
		and ltrim(rtrim(cliente_despacho.idc_cliente_despacho)) = ltrim(rtrim(@idc_cliente_despacho))
		if (@id_tapa is null)
		begin
			select @id_tapa = tapa.id_tapa,
			 @idc_tapa = tapa.idc_tapa,
			 @nombre_tapa = tapa.nombre_tapa
			from tapa 
			where idc_tapa = 'NA'
		end
	end

/* RMR */

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

/*Asignar el nombre de los diferentes estados que se manejarán*/
/*Asignar el nombre de los diferentes estados que se manejarán*/
set @estado_inventario = 1
set @estado_prevendido = 2
set @estado_prevendido_sin_confirmar = 3
set @estado_orden_aprobada = 4
set @estado_orden_sin_aprobar_not_sent_to_farm = 5
set @estado_orden_sin_aprobar_no_farm_confirmed = 6

/*Extraer las últimas versiones de las ordenes de pedido*/
select max(id_orden_pedido) as id_orden_pedido into #ordenes
from orden_pedido
group by id_orden_pedido_padre

select id_orden_pedido into #ordenes_especiales
from #ordenes
where exists
(
	select *
	from orden_especial_confirmada
	where orden_especial_confirmada.id_orden_pedido = #ordenes.id_orden_pedido
)

select id_orden_pedido into #preventas
from #ordenes
where not exists
(
	select *
	from #ordenes_especiales
	where #ordenes_especiales.id_orden_pedido = #ordenes.id_orden_pedido
)

/*Extraer las últimas versiones de las ordenes sin aprobar*/
select max(id_item_orden_sin_aprobar) as id_item_orden_sin_aprobar into #orden_sin_confirmar
from item_orden_sin_aprobar
group by id_item_orden_sin_aprobar_padre

/*Extraer Orden_sin_aprobar - Not sent to farm*/
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
item_orden_sin_aprobar.code as marca,
item_orden_sin_aprobar.unidades_por_pieza,
@estado_orden_sin_aprobar_not_sent_to_farm as estado,
sum(item_orden_sin_aprobar.cantidad_piezas) as piezas_sin_aprobar,
grado_flor.medidas as medidas_grado_flor,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.numero_po,
item_orden_sin_aprobar.comentario,
cliente_despacho.id_despacho,
cliente_despacho.nombre_cliente,
cliente_despacho.idc_cliente_despacho,
transportador.idc_transportador,
item_orden_sin_aprobar.fecha_inicial into #aprobacion_not_sent_to_farm
from orden_sin_aprobar,
item_orden_sin_aprobar,
tipo_factura,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
caja,
tipo_caja,
transportador,
cliente_despacho
where color.id_color = variedad_flor.id_color
and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and tipo_factura.idc_tipo_factura = '4'
and exists
(
	select *
	from #orden_sin_confirmar
	where #orden_sin_confirmar.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and farm.id_farm = item_orden_sin_aprobar.id_farm
and tapa.id_tapa = item_orden_sin_aprobar.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = item_orden_sin_aprobar.id_variedad_flor
and grado_flor.id_grado_flor = item_orden_sin_aprobar.id_grado_flor
and caja.id_caja = item_orden_sin_aprobar.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and transportador.id_transportador = item_orden_sin_aprobar.id_transportador
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and item_orden_sin_aprobar.fecha_inicial BETWEEN 
@fecha_inicial AND @fecha_final 
and not exists
(
	select * 
	from solicitud_confirmacion_orden_especial
	where solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
group by farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.unidades_por_pieza,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)),
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.numero_po,
item_orden_sin_aprobar.comentario,
cliente_despacho.id_despacho,
cliente_despacho.nombre_cliente,
cliente_despacho.idc_cliente_despacho,
transportador.idc_transportador,
item_orden_sin_aprobar.fecha_inicial

/*Extraer Orden_sin_aprobar - Not Farm Confirmed*/
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
item_orden_sin_aprobar.code as marca,
item_orden_sin_aprobar.unidades_por_pieza,
@estado_orden_sin_aprobar_no_farm_confirmed as estado,
sum(item_orden_sin_aprobar.cantidad_piezas) as piezas_sin_aprobar,
grado_flor.medidas as medidas_grado_flor,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color ,
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.numero_po,
item_orden_sin_aprobar.comentario,
cliente_despacho.id_despacho,
cliente_despacho.nombre_cliente,
cliente_despacho.idc_cliente_despacho,
transportador.idc_transportador,
item_orden_sin_aprobar.fecha_inicial into #aprobacion_no_farm_confirmed
from orden_sin_aprobar,
item_orden_sin_aprobar,
solicitud_confirmacion_orden_especial,
tipo_factura,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
caja,
tipo_caja,
transportador,
cliente_despacho
where color.id_color = variedad_flor.id_color
and tipo_factura.id_tipo_factura = orden_sin_aprobar.id_tipo_factura
and orden_sin_aprobar.id_orden_sin_aprobar = item_orden_sin_aprobar.id_orden_sin_aprobar
and tipo_factura.idc_tipo_factura = '4'
and exists
(
	select *
	from #orden_sin_confirmar
	where #orden_sin_confirmar.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
)
and farm.id_farm = item_orden_sin_aprobar.id_farm
and tapa.id_tapa = item_orden_sin_aprobar.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = item_orden_sin_aprobar.id_variedad_flor
and grado_flor.id_grado_flor = item_orden_sin_aprobar.id_grado_flor
and caja.id_caja = item_orden_sin_aprobar.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and transportador.id_transportador = item_orden_sin_aprobar.id_transportador
and cliente_despacho.id_despacho = orden_sin_aprobar.id_despacho
and item_orden_sin_aprobar.fecha_inicial BETWEEN 
@fecha_inicial AND @fecha_final 
and solicitud_confirmacion_orden_especial.id_item_orden_sin_aprobar = item_orden_sin_aprobar.id_item_orden_sin_aprobar
and solicitud_confirmacion_orden_especial.aceptada = 1
and not exists
(
	select * 
	from confirmacion_orden_especial_cultivo
	where confirmacion_orden_especial_cultivo.id_solicitud_confirmacion_orden_especial = solicitud_confirmacion_orden_especial.id_solicitud_confirmacion_orden_especial
)
group by farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
item_orden_sin_aprobar.code,
item_orden_sin_aprobar.unidades_por_pieza,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)),
item_orden_sin_aprobar.valor_unitario,
item_orden_sin_aprobar.id_item_orden_sin_aprobar,
item_orden_sin_aprobar.numero_po,
item_orden_sin_aprobar.comentario,
cliente_despacho.id_despacho,
cliente_despacho.nombre_cliente,
cliente_despacho.idc_cliente_despacho,
transportador.idc_transportador,
item_orden_sin_aprobar.fecha_inicial

/*crear tabla de inventarios sobre la cual se realizarán la mayoría de los cálculos*/
create table #inventario
(
	id int identity (1,1),
	id_farm int, 
	idc_farm nvarchar(10), 
	nombre_farm nvarchar(50), 
	id_tapa int, 
	idc_tapa nvarchar(10), 
	nombre_tapa nvarchar(50), 
	id_tipo_flor int, 
	idc_tipo_flor nvarchar(10), 
	nombre_tipo_flor nvarchar(50), 
	id_variedad_flor int, 
	idc_variedad_flor nvarchar(10), 
	nombre_variedad_flor nvarchar(50), 
	id_grado_flor int, 
	idc_grado_flor nvarchar(10), 
	nombre_grado_flor nvarchar(50), 
	id_tipo_caja int, 
	idc_tipo_caja nvarchar(10), 
	nombre_tipo_caja nvarchar(50), 
	marca nvarchar(10), 
	empaque_principal bit null, 
	unidades_por_pieza int, 
	precio_minimo decimal(20,4) null, 
	estado nvarchar(50), 
	piezas_inventario int null, 
	saldo int null,
	piezas_prevendidas int null, 
	valor_unitario decimal(20,4) null,
	id_orden_especial_confirmada int null,
	medidas_grado_flor nvarchar(50) null,
	idc_color nvarchar(10) null,
	prioridad_color int null,
	nombre_color nvarchar(50) null,
	id_item_inventario_preventa int null,
	id_orden_pedido int null,
	idc_orden_pedido nvarchar(20) null,
	controla_saldos bit null,
	fecha_para_aprobar datetime null,
	idc_transportador nvarchar(10) null,
	idc_cliente_despacho nvarchar(15) null,
	numero_po nvarchar(50) null,
	comentario nvarchar(512) null,
	tipo_orden int null,
	fecha_inicial datetime,
	tipo_orden_no_orden_pedido int null,
	id_item_orden_sin_aprobar int null
)

insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	valor_unitario, 
	estado, 
	piezas_inventario, 
	id_orden_especial_confirmada,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	id_orden_pedido,
	idc_orden_pedido,
	fecha_para_aprobar,
	idc_transportador,
	idc_cliente_despacho,
	numero_po,
	comentario,
	tipo_orden,
	id_item_inventario_preventa,
	precio_minimo
)
select 	farm.id_farm, 
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
grado_flor.id_grado_flor, 
grado_flor.idc_grado_flor, 
grado_flor.nombre_grado_flor, 
tipo_caja.id_tipo_caja, 
tipo_caja.idc_tipo_caja, 
tipo_caja.nombre_tipo_caja, 
item_inventario_preventa.marca, 
item_inventario_preventa.unidades_por_pieza, 
null,--valor_unitario, 
@estado_inventario, 
detalle_item_inventario_preventa.cantidad_piezas, 
null,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
color.nombre_color,
null,
null,
detalle_item_inventario_preventa.fecha_disponible_distribuidora, 
null,
null,
null,
null,
1,
Item_inventario_preventa.id_item_inventario_preventa,
item_inventario_preventa.precio_minimo
from inventario_preventa,
item_inventario_preventa,
detalle_item_inventario_preventa,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
tipo_caja,
color
where inventario_preventa.id_inventario_preventa = item_inventario_preventa.id_inventario_preventa
and item_inventario_preventa.id_item_inventario_preventa = detalle_item_inventario_preventa.id_item_inventario_preventa
and detalle_item_inventario_preventa.fecha_disponible_distribuidora between
@fecha_inicial and @fecha
and farm.id_farm = inventario_preventa.id_farm
and tapa.id_tapa = item_inventario_preventa.id_tapa
and variedad_flor.id_variedad_flor = item_inventario_preventa.id_variedad_flor
and grado_flor.id_grado_flor = item_inventario_preventa.id_grado_flor
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and tipo_caja.id_tipo_caja = item_inventario_preventa.id_tipo_caja
and color.id_color = variedad_flor.id_color

/*Extraer las órdenes de pedido*/
insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	valor_unitario, 
	estado, 
	piezas_prevendidas, 
	id_orden_especial_confirmada,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	id_orden_pedido,
	idc_orden_pedido,
	fecha_para_aprobar,
	idc_transportador,
	idc_cliente_despacho,
	numero_po,
	comentario,
	tipo_orden,
	fecha_inicial
)
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
@estado_orden_aprobada as estado,
sum(orden_pedido.cantidad_piezas) as piezas_prevendidas,
null,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
NULL,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
2,
orden_pedido.fecha_inicial
from orden_pedido,
transportador,
tipo_factura,
cliente_despacho,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
tipo_caja
where color.id_color = variedad_flor.id_color
and orden_pedido.fecha_inicial = @fecha
and farm.id_farm = orden_pedido.id_farm 
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #ordenes_especiales
	where #ordenes_especiales.id_orden_pedido = orden_pedido.id_orden_pedido
)
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho
group by farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)),
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
orden_pedido.fecha_inicial

union all
/*Extraer las órdenes de pedido pendientes de aprobación*/
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
@estado_prevendido_sin_confirmar as estado,
sum(orden_pedido.cantidad_piezas) as piezas_prevendidas,
null,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
orden_pedido.fecha_para_aprobar,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
2,
orden_pedido.fecha_inicial
from orden_pedido,
transportador,
tipo_factura,
cliente_despacho,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
tipo_caja
where color.id_color = variedad_flor.id_color
and orden_pedido.fecha_para_aprobar between
@fecha_inicial and @fecha_final
and Orden_Pedido.fecha_inicial = convert(datetime, '1999/01/01')
and farm.id_farm = orden_pedido.id_farm 
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #ordenes_especiales
	where #ordenes_especiales.id_orden_pedido = orden_pedido.id_orden_pedido
)
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho
group by farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)),
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
orden_pedido.fecha_para_aprobar,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
orden_pedido.fecha_inicial

/*Extraer las órdenes de pedido*/
insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	valor_unitario, 
	estado, 
	piezas_prevendidas, 
	id_orden_especial_confirmada,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	id_orden_pedido,
	idc_orden_pedido,
	fecha_para_aprobar,
	idc_transportador,
	idc_cliente_despacho,
	numero_po,
	comentario,
	tipo_orden,
	fecha_inicial
)
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
@estado_prevendido as estado,
sum(orden_pedido.cantidad_piezas) as piezas_prevendidas,
null,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
NULL,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
1,
orden_pedido.fecha_inicial
from orden_pedido,
transportador,
tipo_factura,
cliente_despacho,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
tipo_caja
where color.id_color = variedad_flor.id_color
and orden_pedido.fecha_inicial = @fecha
and farm.id_farm = orden_pedido.id_farm 
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #preventas
	where #preventas.id_orden_pedido = orden_pedido.id_orden_pedido
)
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho
group by farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)),
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
orden_pedido.fecha_inicial

union all
/*Extraer las órdenes de pedido pendientes de aprobación*/
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
@estado_prevendido_sin_confirmar as estado,
sum(orden_pedido.cantidad_piezas) as piezas_prevendidas,
null,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
orden_pedido.fecha_para_aprobar,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
1,
orden_pedido.fecha_inicial
from orden_pedido,
transportador,
tipo_factura,
cliente_despacho,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
tipo_caja
where color.id_color = variedad_flor.id_color
and orden_pedido.fecha_para_aprobar between
@fecha_inicial and @fecha_final
and Orden_Pedido.fecha_inicial = convert(datetime, '1999/01/01')
and farm.id_farm = orden_pedido.id_farm 
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #preventas
	where #preventas.id_orden_pedido = orden_pedido.id_orden_pedido
)
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho
group by farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)),
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
orden_pedido.fecha_para_aprobar,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
orden_pedido.fecha_inicial

insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	valor_unitario, 
	estado, 
	piezas_prevendidas, 
	id_orden_especial_confirmada,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	id_orden_pedido,
	idc_orden_pedido,
	fecha_para_aprobar,
	idc_transportador,
	idc_cliente_despacho,
	numero_po,
	comentario,
	tipo_orden,
	fecha_inicial
)
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
@estado_inventario as estado,
orden_pedido.cantidad_piezas as piezas_prevendidas,
null,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
ORDEN_PEDIDO.FECHA_INICIAL,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
2,
orden_pedido.fecha_inicial
from orden_pedido,
transportador,
tipo_factura,
cliente_despacho,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
tipo_caja
where color.id_color = variedad_flor.id_color
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and farm.id_farm = orden_pedido.id_farm 
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #ordenes_especiales
	where #ordenes_especiales.id_orden_pedido = orden_pedido.id_orden_pedido
)
and not exists
(
	select *
	from #inventario
	where #inventario.id_orden_pedido = orden_pedido.id_orden_pedido
)
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho

insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	valor_unitario, 
	estado, 
	piezas_prevendidas, 
	id_orden_especial_confirmada,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	id_orden_pedido,
	idc_orden_pedido,
	fecha_para_aprobar,
	idc_transportador,
	idc_cliente_despacho,
	numero_po,
	comentario,
	tipo_orden,
	fecha_inicial
)
select farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
@estado_prevendido as estado,
sum(orden_pedido.cantidad_piezas) as piezas_prevendidas,
null,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)) as nombre_color,
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
NULL,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
1,
orden_pedido.fecha_inicial
from orden_pedido,
transportador,
tipo_factura,
cliente_despacho,
farm,
tapa,
tipo_flor,
variedad_flor,
grado_flor,
color,
tipo_caja
where color.id_color = variedad_flor.id_color
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and farm.id_farm = orden_pedido.id_farm 
and tapa.id_tapa = orden_pedido.id_tapa
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.disponible = 1
and exists
(
	select *
	from #preventas
	where #preventas.id_orden_pedido = orden_pedido.id_orden_pedido
)
and not exists
(
	select *
	from #inventario
	where #inventario.id_orden_pedido = orden_pedido.id_orden_pedido
)
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho
group by farm.id_farm,
farm.idc_farm,
ltrim(rtrim(farm.nombre_farm)),
tapa.id_tapa,
tapa.idc_tapa,
tapa.nombre_tapa,
tipo_flor.id_tipo_flor,
tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
variedad_flor.id_variedad_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
grado_flor.id_grado_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)),
tipo_caja.id_tipo_caja,
tipo_caja.idc_tipo_caja,
ltrim(rtrim(tipo_caja.nombre_tipo_caja)),
orden_pedido.marca,
orden_pedido.unidades_por_pieza,
orden_pedido.valor_unitario,
grado_flor.medidas,
color.idc_color,
color.prioridad_color,
ltrim(rtrim(color.nombre_color)),
orden_pedido.id_orden_pedido,
orden_pedido.idc_orden_pedido,
transportador.idc_transportador,
cliente_despacho.idc_cliente_despacho,
orden_pedido.numero_po,
orden_pedido.comentario,
orden_pedido.fecha_inicial

/*Ingresar a la tabla inventario las ordenes especiales que están en el proceso - Not Sent to Farm*/
insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	estado, 
	piezas_prevendidas,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	valor_unitario,
	id_orden_pedido,
	numero_po,
	comentario,
	tipo_orden,
	idc_cliente_despacho,
	idc_transportador,
	tipo_orden_no_orden_pedido,
	id_item_orden_sin_aprobar,
	fecha_inicial
)
select id_farm, 
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
id_grado_flor, 
idc_grado_flor, 
nombre_grado_flor, 
id_tipo_caja, 
idc_tipo_caja, 
nombre_tipo_caja, 
marca, 
unidades_por_pieza, 
estado, 
piezas_sin_aprobar,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
valor_unitario,
id_item_orden_sin_aprobar,
numero_po,
comentario,
2,
idc_cliente_despacho,
idc_transportador,
1,
id_item_orden_sin_aprobar,
fecha_inicial
from #aprobacion_not_sent_to_farm
WHERE idc_transportador = @idc_transportador
AND numero_po = @numero_po
AND idc_cliente_despacho = @idc_cliente_despacho
and fecha_inicial = @fecha

/*Ingresar a la tabla inventario las ordenes especiales que están en el proceso - No Farm Confirmed*/
insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	estado, 
	piezas_prevendidas,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	valor_unitario,
	id_orden_pedido,
	numero_po,
	comentario,
	tipo_orden,
	idc_cliente_despacho,
	idc_transportador,
	tipo_orden_no_orden_pedido,
	id_item_orden_sin_aprobar,
	fecha_inicial
)
select id_farm, 
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
id_grado_flor, 
idc_grado_flor, 
nombre_grado_flor, 
id_tipo_caja, 
idc_tipo_caja, 
nombre_tipo_caja, 
marca, 
unidades_por_pieza, 
estado, 
piezas_sin_aprobar,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
valor_unitario,
id_item_orden_sin_aprobar,
numero_po,
comentario,
2,
idc_cliente_despacho,
idc_transportador,
1,
id_item_orden_sin_aprobar,
fecha_inicial
from #aprobacion_no_farm_confirmed
WHERE idc_transportador = @idc_transportador
AND numero_po = @numero_po
AND idc_cliente_despacho = @idc_cliente_despacho
and fecha_inicial = @fecha

-----------------------------------
insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	estado, 
	piezas_prevendidas,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	valor_unitario,
	id_orden_pedido,
	numero_po,
	comentario,
	tipo_orden,
	idc_cliente_despacho,
	idc_transportador,
	tipo_orden_no_orden_pedido,
	id_item_orden_sin_aprobar,
	fecha_inicial
)
select id_farm, 
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
id_grado_flor, 
idc_grado_flor, 
nombre_grado_flor, 
id_tipo_caja, 
idc_tipo_caja, 
nombre_tipo_caja, 
marca, 
unidades_por_pieza, 
@estado_inventario, 
piezas_sin_aprobar,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
valor_unitario,
id_item_orden_sin_aprobar,
numero_po,
comentario,
2,
idc_cliente_despacho,
idc_transportador,
1,
id_item_orden_sin_aprobar,
fecha_inicial
from #aprobacion_not_sent_to_farm
where not exists
(
	select * 
	from #inventario
	where #aprobacion_not_sent_to_farm.id_farm = #inventario.id_farm
	and #aprobacion_not_sent_to_farm.id_tapa = #inventario.id_tapa
	and #aprobacion_not_sent_to_farm.id_variedad_flor = #inventario.id_variedad_flor
	and #aprobacion_not_sent_to_farm.id_grado_flor = #inventario.id_grado_flor
	and #aprobacion_not_sent_to_farm.id_tipo_caja = #inventario.id_tipo_caja
	and #aprobacion_not_sent_to_farm.unidades_por_pieza = #inventario.unidades_por_pieza
	and #inventario.tipo_orden = 1
)

/*Ingresar a la tabla inventario las ordenes especiales que están en el proceso - No Farm Confirmed*/
insert into #inventario 
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
	id_grado_flor, 
	idc_grado_flor, 
	nombre_grado_flor, 
	id_tipo_caja, 
	idc_tipo_caja, 
	nombre_tipo_caja, 
	marca, 
	unidades_por_pieza, 
	estado, 
	piezas_prevendidas,
	medidas_grado_flor,
	idc_color,
	prioridad_color,
	nombre_color,
	valor_unitario,
	id_orden_pedido,
	numero_po,
	comentario,
	tipo_orden,
	idc_cliente_despacho,
	idc_transportador,
	tipo_orden_no_orden_pedido,
	fecha_inicial
)
select id_farm, 
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
id_grado_flor, 
idc_grado_flor, 
nombre_grado_flor, 
id_tipo_caja, 
idc_tipo_caja, 
nombre_tipo_caja, 
marca, 
unidades_por_pieza, 
@estado_inventario, 
piezas_sin_aprobar,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
valor_unitario,
id_item_orden_sin_aprobar,
numero_po,
comentario,
2,
idc_cliente_despacho,
idc_transportador,
1,
fecha_inicial
from #aprobacion_no_farm_confirmed
where not exists
(
	select * 
	from #inventario
	where #aprobacion_no_farm_confirmed.id_farm = #inventario.id_farm
	and #aprobacion_no_farm_confirmed.id_tapa = #inventario.id_tapa
	and #aprobacion_no_farm_confirmed.id_variedad_flor = #inventario.id_variedad_flor
	and #aprobacion_no_farm_confirmed.id_grado_flor = #inventario.id_grado_flor
	and #aprobacion_no_farm_confirmed.id_tipo_caja = #inventario.id_tipo_caja
	and #aprobacion_no_farm_confirmed.unidades_por_pieza = #inventario.unidades_por_pieza
	and #inventario.tipo_orden = 1
)

/*creación de tablas para extraer los datos de las unidades agrupadas por finca, tapa y flor*/
create table #inventario_agrupado
(
	id_farm int, 
	id_tapa int null, 
	id_variedad_flor int, 
	id_grado_flor int, 
	unidades_agrupadas_inventario int,
	piezas_inventario int null
)

create table #orden_pedido_agrupado
(
	id_farm int, 
	id_tapa int null, 
	id_variedad_flor int, 
	id_grado_flor int, 
	unidades_agrupadas_prevendidas int,
	piezas_prevendidas int null,
	idc_orden_pedido nvarchar(50) null
)

create table #empaque_principal
(
	id_farm int, 
	id_tapa int null, 
	id_variedad_flor int, 
	id_grado_flor int, 
	precio_minimo decimal(20,4)
)

/*Si se trabaja sobre Natural, no se tendrá en cuenta la tapa*/
if(@nombre_base_datos = 'BD_NF')
begin
	insert into #inventario_agrupado (id_farm, id_variedad_flor, id_grado_flor, unidades_agrupadas_inventario)
	select id_farm, id_variedad_flor, id_grado_flor, sum(unidades_por_pieza * piezas_inventario)
	from #inventario
	where tipo_orden = 1
	and id_item_inventario_preventa is not null
	group by id_farm, id_variedad_flor, id_grado_flor

	insert into #orden_pedido_agrupado (id_farm, id_variedad_flor, id_grado_flor, unidades_agrupadas_prevendidas)
	select id_farm, id_variedad_flor, id_grado_flor, sum(unidades_por_pieza * piezas_prevendidas)
	from #inventario
	where id_orden_pedido is not null
	and tipo_orden_no_orden_pedido is null
	and fecha_inicial < = @fecha
	group by id_farm, id_variedad_flor, id_grado_flor

	update #inventario
	set saldo = isnull(unidades_agrupadas_inventario, 0) - isnull(unidades_agrupadas_prevendidas, 0)
	from #orden_pedido_agrupado,
	#inventario_agrupado
	where #orden_pedido_agrupado.id_farm = #inventario_agrupado.id_farm
	and #orden_pedido_agrupado.id_variedad_flor = #inventario_agrupado.id_variedad_flor
	and #orden_pedido_agrupado.id_grado_flor = #inventario_agrupado.id_grado_flor
	and #inventario.id_farm = #inventario_agrupado.id_farm
	and #inventario.id_variedad_flor = #inventario_agrupado.id_variedad_flor
	and #inventario.id_grado_flor = #inventario_agrupado.id_grado_flor 

	/*Colocar el saldo con el valor del inventario cuando después del proceso anterior éste es nulo*/
	update #inventario
	set saldo = isnull(unidades_agrupadas_inventario, 0)
	from #inventario_agrupado
	where #inventario.id_farm = #inventario_agrupado.id_farm
	and #inventario.id_variedad_flor = #inventario_agrupado.id_variedad_flor
	and #inventario.id_grado_flor = #inventario_agrupado.id_grado_flor 
	and #inventario.saldo is null

	delete from #orden_pedido_agrupado

	insert into #orden_pedido_agrupado (id_farm, id_variedad_flor, id_grado_flor, piezas_prevendidas, idc_orden_pedido)
	select id_farm, id_variedad_flor, id_grado_flor, piezas_prevendidas, idc_orden_pedido
	from #inventario
	where id_orden_pedido is not null
	and tipo_orden_no_orden_pedido is null
    and fecha_inicial = @fecha
	and idc_transportador = @idc_transportador
	and idc_cliente_despacho = @idc_cliente_despacho	
	and isnull(numero_po, '') = @numero_po
	group by id_farm, id_variedad_flor, id_grado_flor, idc_orden_pedido, piezas_prevendidas

	update #inventario
	set piezas_prevendidas = #orden_pedido_agrupado.piezas_prevendidas
	from #orden_pedido_agrupado
	where #orden_pedido_agrupado.id_farm = #inventario.id_farm
	and #orden_pedido_agrupado.id_variedad_flor = #inventario.id_variedad_flor
	and #orden_pedido_agrupado.id_grado_flor = #inventario.id_grado_flor
	and #orden_pedido_agrupado.idc_orden_pedido = #inventario.idc_orden_pedido
end
else
/*Si NO se trabaja sobre Natural, se tendrá en cuenta la tapa*/
begin
	insert into #inventario_agrupado (id_farm, id_tapa, id_variedad_flor, id_grado_flor, unidades_agrupadas_inventario)
	select id_farm, id_tapa, id_variedad_flor, id_grado_flor, sum(unidades_por_pieza * piezas_inventario)
	from #inventario
	where tipo_orden = 1
	and id_item_inventario_preventa is not null
	group by id_farm, id_tapa, id_variedad_flor, id_grado_flor

	insert into #orden_pedido_agrupado (id_farm, id_tapa, id_variedad_flor, id_grado_flor, unidades_agrupadas_prevendidas)
	select id_farm, id_tapa, id_variedad_flor, id_grado_flor, sum(unidades_por_pieza * piezas_prevendidas)
	from #inventario
	where id_orden_pedido is not null
	and tipo_orden_no_orden_pedido is null
	and fecha_inicial < = @fecha
	group by id_farm, id_tapa, id_variedad_flor, id_grado_flor

	update #inventario
	set saldo = isnull(unidades_agrupadas_inventario, 0) - isnull(unidades_agrupadas_prevendidas, 0)
	from #orden_pedido_agrupado,
	#inventario_agrupado
	where #orden_pedido_agrupado.id_farm = #inventario_agrupado.id_farm
	and #orden_pedido_agrupado.id_tapa = #inventario_agrupado.id_tapa
	and #orden_pedido_agrupado.id_variedad_flor = #inventario_agrupado.id_variedad_flor
	and #orden_pedido_agrupado.id_grado_flor = #inventario_agrupado.id_grado_flor
	and #inventario.id_farm = #inventario_agrupado.id_farm
	and #inventario.id_tapa = #inventario_agrupado.id_tapa
	and #inventario.id_variedad_flor = #inventario_agrupado.id_variedad_flor
	and #inventario.id_grado_flor = #inventario_agrupado.id_grado_flor 

	/*Colocar el saldo con el valor del inventario cuando después del proceso anterior éste es nulo*/
	update #inventario
	set saldo = isnull(unidades_agrupadas_inventario, 0)
	from #inventario_agrupado
	where #inventario.id_farm = #inventario_agrupado.id_farm
	and #inventario.id_tapa = #inventario_agrupado.id_tapa
	and #inventario.id_variedad_flor = #inventario_agrupado.id_variedad_flor
	and #inventario.id_grado_flor = #inventario_agrupado.id_grado_flor 
	and #inventario.saldo is null

	delete from #orden_pedido_agrupado

	insert into #orden_pedido_agrupado (id_farm, id_tapa, id_variedad_flor, id_grado_flor, piezas_prevendidas, idc_orden_pedido)
	select id_farm, id_tapa, id_variedad_flor, id_grado_flor, piezas_prevendidas, idc_orden_pedido
	from #inventario
	where id_orden_pedido is not null
	and tipo_orden_no_orden_pedido is null
	and fecha_inicial = @fecha
	and idc_transportador = @idc_transportador
	and idc_cliente_despacho = @idc_cliente_despacho	
	and isnull(numero_po, '') = @numero_po
	group by id_farm, id_tapa, id_variedad_flor, id_grado_flor, idc_orden_pedido, piezas_prevendidas

	update #inventario
	set piezas_prevendidas = #orden_pedido_agrupado.piezas_prevendidas
	from #orden_pedido_agrupado
	where #orden_pedido_agrupado.id_farm = #inventario.id_farm
	and #orden_pedido_agrupado.id_variedad_flor = #inventario.id_variedad_flor
	and #orden_pedido_agrupado.id_grado_flor = #inventario.id_grado_flor
	and #orden_pedido_agrupado.id_tapa = #inventario.id_tapa
	and #orden_pedido_agrupado.idc_orden_pedido = #inventario.idc_orden_pedido
end

insert into #empaque_principal (id_farm, id_tapa, id_variedad_flor, id_grado_flor, precio_minimo)
select id_farm, 
id_tapa, 
id_variedad_flor, 
id_grado_flor, 
precio_minimo
from #inventario
WHERE empaque_principal = 1
group by id_farm, 
id_tapa, 
id_variedad_flor, 
id_grado_flor,
precio_minimo

update #inventario
set precio_minimo = #empaque_principal.precio_minimo
from #empaque_principal
where #inventario.id_farm = #empaque_principal.id_farm
and #inventario.id_tapa = #empaque_principal.id_tapa
and #inventario.id_variedad_flor = #empaque_principal.id_variedad_flor
and #inventario.id_grado_flor = #empaque_principal.id_grado_flor 
and #inventario.empaque_principal = 0

/*Retornar los datos al usuario*/
select idc_farm, 
nombre_farm, 
/*Si se trabaja en Natural, se encontró tapa asignada al cliente ingresado y la finca es N4, se colocará la tapa que está asignada al cliente*/
/*en caso contrario, la que venga con el inventario*/
case
	when @id_tapa is not null and idc_farm = 'N4' then @idc_tapa
	else idc_tapa
end as idc_tapa,
case
	when @id_tapa is not null and idc_farm = 'N4' then @nombre_tapa
	else nombre_tapa
end as nombre_tapa,
idc_tipo_flor, 
nombre_tipo_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
idc_grado_flor, 
nombre_grado_flor, 
idc_tipo_caja, 
nombre_tipo_caja, 
marca, 
empaque_principal, 
unidades_por_pieza, 
precio_minimo, 
estado, 
piezas_inventario, 
null as saldo,
piezas_prevendidas, 
valor_unitario as precio_venta,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
id_item_inventario_preventa,
id_orden_pedido,
idc_orden_pedido,
controla_saldos,
fecha_para_aprobar,
comentario,
tipo_orden
from #inventario
WHERE estado NOT IN (@estado_prevendido, @estado_prevendido_sin_confirmar, @estado_inventario)
and idc_transportador = @idc_transportador
and idc_cliente_despacho = @idc_cliente_despacho
and isnull(numero_po, '') = @numero_po
and fecha_inicial = @fecha
UNION ALL
select idc_farm, 
nombre_farm, 
/*Si se trabaja en Natural, se encontró tapa asignada al cliente ingresado y la finca es N4, se colocará la tapa que está asignada al cliente*/
/*en caso contrario, la que venga con el inventario*/
case
	when @id_tapa is not null and idc_farm = 'N4' then @idc_tapa
	else idc_tapa
end as idc_tapa,
case
	when @id_tapa is not null and idc_farm = 'N4' then @nombre_tapa
	else nombre_tapa
end as nombre_tapa,
idc_tipo_flor, 
nombre_tipo_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
idc_grado_flor, 
nombre_grado_flor, 
idc_tipo_caja, 
nombre_tipo_caja, 
'' as marca, 
0, 
unidades_por_pieza, 
precio_minimo, 
estado, 
sum(piezas_inventario) as piezas_inventario, 
saldo,
sum(piezas_prevendidas) as piezas_prevendidas, 
0 as precio_venta,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
id_item_inventario_preventa,
0,
'',
0 as controla_saldos,
fecha_para_aprobar,
comentario,
tipo_orden
from #inventario
WHERE estado IN (@estado_inventario)
group by idc_farm, 
nombre_farm, 
idc_tapa,
nombre_tapa,
idc_tipo_flor, 
nombre_tipo_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
idc_grado_flor, 
nombre_grado_flor, 
idc_tipo_caja, 
nombre_tipo_caja, 
unidades_por_pieza, 
estado, 
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
comentario,
tipo_orden,
id_item_inventario_preventa,
saldo,
precio_minimo,
fecha_para_aprobar
union all
select idc_farm, 
nombre_farm, 
/*Si se trabaja en Natural, se encontró tapa asignada al cliente ingresado y la finca es N4, se colocará la tapa que está asignada al cliente*/
/*en caso contrario, la que venga con el inventario*/
case
	when @id_tapa is not null and idc_farm = 'N4' then @idc_tapa
	else idc_tapa
end as idc_tapa,
case
	when @id_tapa is not null and idc_farm = 'N4' then @nombre_tapa
	else nombre_tapa
end as nombre_tapa,
idc_tipo_flor, 
nombre_tipo_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
idc_grado_flor, 
nombre_grado_flor, 
idc_tipo_caja, 
nombre_tipo_caja, 
marca, 
empaque_principal, 
unidades_por_pieza, 
precio_minimo, 
estado, 
piezas_inventario, 
null as saldo,
piezas_prevendidas, 
valor_unitario as precio_venta,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
id_item_inventario_preventa,
id_orden_pedido,
idc_orden_pedido,
controla_saldos,
fecha_para_aprobar,
comentario,
tipo_orden
from #inventario
where estado in (@estado_prevendido_sin_confirmar)
and idc_transportador = @idc_transportador
and idc_cliente_despacho = @idc_cliente_despacho
and isnull(numero_po, '') = @numero_po
UNION ALL
select idc_farm, 
nombre_farm, 
/*Si se trabaja en Natural, se encontró tapa asignada al cliente ingresado y la finca es N4, se colocará la tapa que está asignada al cliente*/
/*en caso contrario, la que venga con el inventario*/
case
	when @id_tapa is not null and idc_farm = 'N4' then @idc_tapa
	else idc_tapa
end as idc_tapa,
case
	when @id_tapa is not null and idc_farm = 'N4' then @nombre_tapa
	else nombre_tapa
end as nombre_tapa,
idc_tipo_flor, 
nombre_tipo_flor, 
idc_variedad_flor, 
nombre_variedad_flor, 
idc_grado_flor, 
nombre_grado_flor, 
idc_tipo_caja, 
nombre_tipo_caja, 
marca, 
empaque_principal, 
unidades_por_pieza, 
precio_minimo, 
estado, 
piezas_inventario, 
null as saldo,
piezas_prevendidas, 
valor_unitario as precio_venta,
medidas_grado_flor,
idc_color,
prioridad_color,
nombre_color,
id_item_inventario_preventa,
id_orden_pedido,
idc_orden_pedido,
controla_saldos,
fecha_para_aprobar,
comentario,
tipo_orden
from #inventario
where estado in (@estado_prevendido)
and idc_transportador = @idc_transportador
and idc_cliente_despacho = @idc_cliente_despacho
and isnull(numero_po, '') = @numero_po
and fecha_inicial = @fecha
order by estado, NOMBRE_VARIEDAD_FLOR, NOMBRE_GRADO_FLOR

/*eliminación de tablas temporales*/

drop table #ordenes_especiales
drop table #ordenes
drop table #preventas
drop table #inventario
drop table #inventario_agrupado
drop table #orden_pedido_agrupado
drop table #aprobacion_not_sent_to_farm
drop table #aprobacion_no_farm_confirmed
drop table #orden_sin_confirmar
drop table #empaque_principal
