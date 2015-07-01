USE [BD_Cultivo]
GO
/****** Object:  StoredProcedure [dbo].[mmk_reporte_PEPR]    Script Date: 10/15/2014 11:13:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[mmk_reporte_PEPR] 

as

declare @fecha datetime

set @fecha = convert(datetime, convert(nvarchar, dateadd(dd, -1, getdate()), 101))

select tipo_flor.idc_tipo_flor,
ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
variedad_flor.idc_variedad_flor,
ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
grado_flor.idc_grado_flor,
ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
tapa.idc_tapa,
ltrim(rtrim(tapa.nombre_tapa)) as nombre_tapa,
tipo_caja.idc_tipo_caja + caja.idc_caja as idc_caja,
ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
Tipo_Pedido.nombre_tipo_pedido + ' [' + tipo_pedido.idc_tipo_pedido + ']' as nombre_tipo_pedido,
Pedido_PEPR.fecha_pedido,
Pedido_PEPR.marca,
Pedido_PEPR.unidades_por_pieza,
Pedido_PEPR.cantidad_piezas,
ltrim(rtrim(Pedido_PEPR.comentario)) as comentario,
usuario_cobol.nombre_usuario_cobol,
pedido_pepr.fecha_confirmacion
from pedido_pepr left join usuario_cobol on usuario_cobol.id_usuario_cobol = pedido_pepr.id_usuario_cobol,
Cliente_Despacho,
Tipo_Pedido,
tipo_flor,
variedad_flor,
grado_flor,
catalogo,
tapa,
caja,
Tipo_Caja
where fecha_pedido > = @fecha
and Cliente_Despacho.id_cliente_despacho = pedido_pepr.id_cliente_despacho
and Cliente_Despacho.idc_cliente_despacho = 'NAUSFFR'
and Pedido_PEPR.numero_solicitud = 0
and Catalogo.id_catalogo = Pedido_PEPR.id_catalogo
and Catalogo.nombre_catalogo = 'BOUQUETERA'
and Tipo_Pedido.id_tipo_pedido = Pedido_PEPR.id_tipo_pedido
and Tipo_Pedido.idc_tipo_pedido <> '1'
and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
and Tipo_Flor.id_tipo_flor = Grado_Flor.id_tipo_flor
and variedad_flor.id_variedad_flor = Pedido_PEPR.id_variedad_flor
and Grado_Flor.id_grado_flor = Pedido_PEPR.id_grado_flor
and tapa.id_tapa = Pedido_PEPR.id_tapa
and caja.id_caja = Pedido_PEPR.id_caja
and tipo_caja.id_tipo_caja = caja.id_tipo_caja
and Pedido_PEPR.pedido_confirmado = 1