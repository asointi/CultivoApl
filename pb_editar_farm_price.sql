-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2015/02/02
-- Description:	SP para editar precio de finca de OFPV desde un formulario de Windows Form en .Net
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[pb_editar_farm_price]

@accion nvarchar(50),
@fecha_inicial datetime,
@fecha_final datetime,
@precio_finca decimal(20,4),
@usuario_cobol nvarchar(25),
@id_orden_pedido int

as

if(@accion = 'consultar')
begin
	declare @orden_pedido table
	(
		id_orden_pedido int
	)

	insert into @orden_pedido (id_orden_pedido)
	select max(id_orden_pedido) 
	from orden_pedido,
	tipo_factura
	where tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
	and tipo_factura.idc_tipo_factura = '4'
	and orden_pedido.disponible = 1
	and orden_pedido.fecha_inicial between
	@fecha_inicial and @fecha_final
	group by id_orden_pedido_padre

	select orden_pedido.id_orden_pedido,
	orden_pedido.idc_orden_pedido,
	farm.id_farm,
	farm.idc_farm + ' [' + ltrim(rtrim(farm.nombre_farm)) + ']' as nombre_farm,
	tipo_flor.id_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) + ' [' + tipo_flor.idc_tipo_flor + ']' as nombre_tipo_flor,
	variedad_flor.id_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) + ' [' + variedad_flor.idc_variedad_flor + ']' as nombre_variedad_flor,
	grado_flor.id_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) + ' [' + grado_flor.idc_grado_flor + ']' as nombre_grado_flor,
	tipo_caja.id_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	cliente_despacho.id_despacho as id_cliente_despacho,
	cliente_despacho.idc_cliente_despacho + ' [' + ltrim(rtrim(cliente_despacho.nombre_cliente)) + ']' as nombre_cliente,
	vendedor.id_vendedor,
	ltrim(rtrim(vendedor.nombre)) + ' [' + vendedor.idc_vendedor + ']' as nombre_vendedor,
	orden_pedido.unidades_por_pieza,
	orden_pedido.marca,
	orden_pedido.comentario,
	orden_pedido.fecha_inicial as fecha,
	orden_pedido.cantidad_piezas,
	tapa.idc_tapa,
	orden_pedido.fecha_creacion_orden,
	(
		select top 1 precio_finca
		from historia_precio_finca
		where orden_pedido.id_orden_pedido = historia_precio_finca.id_orden_pedido
		order by id_historia_precio_finca desc
	) as precio_finca
	from orden_pedido,
	farm,
	tapa,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_caja,
	cliente_despacho,
	cliente_factura,
	vendedor
	where tapa.id_tapa = orden_pedido.id_tapa
	and farm.id_farm = orden_pedido.id_farm
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and cliente_despacho.id_despacho = orden_pedido.id_despacho
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and exists
	(
		select *
		from @orden_pedido as op
		where orden_pedido.id_orden_pedido = op.id_orden_pedido
	)
end
else
if(@accion = 'insertar_precio_finca')
begin
	insert into historia_precio_finca (precio_finca, usuario_cobol, id_orden_pedido)
	values (@precio_finca, @usuario_cobol, @id_orden_pedido)

	select precio_finca, usuario_cobol, fecha_transaccion
	from historia_precio_finca
	where historia_precio_finca.id_historia_precio_finca = @@identity 
end