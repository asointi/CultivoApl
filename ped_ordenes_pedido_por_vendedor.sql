/****** Object:  StoredProcedure [dbo].[ped_ordenes_pedido_por_cliente]    Script Date: 03/14/2008 12:29:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[ped_ordenes_pedido_por_vendedor]

@idc_tipo_factura nvarchar(255), 
@id_vendedor integer, 
@fecha_despacho_cultivo datetime

AS
BEGIN

IF @id_vendedor > 0
	BEGIN
	select 
	substring(Orden_Pedido.idc_orden_pedido,1,len(Orden_Pedido.idc_orden_pedido) - 2) as idc_orden_pedido,
	convert(int,substring(Orden_Pedido.idc_orden_pedido,len(Orden_Pedido.idc_orden_pedido) - 1,len(Orden_Pedido.idc_orden_pedido))) as idc_orden_pedido_item,
	tipo_factura.idc_tipo_factura,
	vendedor.idc_vendedor,
	vendedor.nombre as nombre_vendedor,
	cliente_despacho.idc_cliente_despacho,
	datename(dw, orden_pedido.fecha_inicial) as dia_semana,
	orden_pedido.fecha_inicial, 
	orden_pedido.fecha_final, 
	farm.idc_farm,
	farm.nombre_farm,
	tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor+grado_flor.idc_grado_flor as flower_code,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	orden_pedido.marca, 
	transportador.idc_transportador,
	orden_pedido.cantidad_piezas,
	orden_pedido.unidades_por_pieza, 
	orden_pedido.valor_unitario,
	orden_pedido.comentario
	from Orden_Pedido, 
	farm, 
	tipo_flor,
	variedad_flor, 
	grado_flor,
	tapa,
	tipo_caja,
	tipo_factura,
	cliente_despacho,
	cliente_factura,
	vendedor,
	transportador
	where (@fecha_despacho_cultivo between
	Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final
	or 
	@fecha_despacho_cultivo+6 between
	Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final)
	and farm.id_farm = Orden_Pedido.id_farm
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and transportador.id_transportador = orden_pedido.id_transportador
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and orden_pedido.id_despacho = cliente_despacho.id_despacho
	and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor
	and vendedor.id_vendedor = @id_vendedor
	and orden_pedido.disponible = 1
	order by datepart(dw,Orden_Pedido.fecha_inicial), nombre_tipo_flor, nombre_variedad_flor, nombre_grado_flor
	END
ELSE 
	BEGIN
	select 
	substring(Orden_Pedido.idc_orden_pedido,1,len(Orden_Pedido.idc_orden_pedido) - 2) as idc_orden_pedido,
	convert(int,substring(Orden_Pedido.idc_orden_pedido,len(Orden_Pedido.idc_orden_pedido) - 1,len(Orden_Pedido.idc_orden_pedido))) as idc_orden_pedido_item,
	tipo_factura.idc_tipo_factura,
	vendedor.idc_vendedor,
	vendedor.nombre as nombre_vendedor,
	cliente_despacho.idc_cliente_despacho,
	datename(dw, orden_pedido.fecha_inicial) as dia_semana,
	orden_pedido.fecha_inicial, 
	orden_pedido.fecha_final, 
	farm.idc_farm,
	farm.nombre_farm,
	tipo_flor.idc_tipo_flor+variedad_flor.idc_variedad_flor+grado_flor.idc_grado_flor as flower_code,
	tipo_flor.nombre_tipo_flor,
	variedad_flor.nombre_variedad_flor,
	grado_flor.nombre_grado_flor,
	tapa.idc_tapa,
	tipo_caja.idc_tipo_caja,
	tipo_caja.nombre_tipo_caja,
	orden_pedido.marca, 
	transportador.idc_transportador,
	orden_pedido.cantidad_piezas,
	orden_pedido.unidades_por_pieza, 
	orden_pedido.valor_unitario,
	orden_pedido.comentario
	from Orden_Pedido, 
	farm, 
	tipo_flor,
	variedad_flor, 
	grado_flor,
	tapa,
	tipo_caja,
	tipo_factura,
	cliente_despacho,
	cliente_factura,
	vendedor,
	transportador
	where (@fecha_despacho_cultivo between
	Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final
	or 
	@fecha_despacho_cultivo+6 between
	Orden_Pedido.fecha_inicial and Orden_Pedido.fecha_final)
	and farm.id_farm = Orden_Pedido.id_farm
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and variedad_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and grado_flor.id_tipo_flor = Tipo_Flor.id_tipo_flor
	and tapa.id_tapa = orden_pedido.id_tapa
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and orden_pedido.id_tipo_factura = tipo_factura.id_tipo_factura
	and transportador.id_transportador = orden_pedido.id_transportador
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and orden_pedido.id_despacho = cliente_despacho.id_despacho
	and cliente_despacho.id_cliente_factura = cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor
	and orden_pedido.disponible = 1
	order by vendedor.idc_vendedor, datepart(dw,Orden_Pedido.fecha_inicial), cliente_despacho.idc_cliente_despacho, nombre_tipo_flor, nombre_variedad_flor, nombre_grado_flor
	END

END