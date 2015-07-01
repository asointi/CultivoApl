SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[ped_consultar_cliente_transportador_por_temporada]

@id_temporada_año int

as

declare @fecha_inicial datetime,
@fecha_final datetime

select @fecha_inicial = temporada_cubo.fecha_inicial,
@fecha_final = temporada_cubo.fecha_final 
from temporada_año,
temporada_cubo
where temporada_año.id_temporada_año = @id_temporada_año
and temporada_año.id_temporada = temporada_cubo.id_temporada
and temporada_año.id_año = temporada_cubo.id_año

select cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador
from orden_pedido,
tipo_factura,
cliente_despacho,
transportador
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.fecha_inicial between
@fecha_inicial and @fecha_final
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and orden_pedido.disponible = 1
group by cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador))

union

select cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador)) as nombre_transportador
from orden_pedido,
tipo_factura,
cliente_despacho,
transportador
where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
and tipo_factura.idc_tipo_factura = '4'
and orden_pedido.fecha_inicial = convert(datetime, '19990101')
and orden_pedido.fecha_para_aprobar between
@fecha_inicial and @fecha_final
and transportador.id_transportador = orden_pedido.id_transportador
and cliente_despacho.id_despacho = orden_pedido.id_despacho
and orden_pedido.disponible = 1
group by cliente_despacho.idc_cliente_despacho,
ltrim(rtrim(cliente_despacho.nombre_cliente)),
transportador.idc_transportador,
ltrim(rtrim(transportador.nombre_transportador))
order by cliente_despacho.idc_cliente_despacho,
transportador.idc_transportador
