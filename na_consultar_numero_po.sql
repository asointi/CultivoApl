set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_consultar_numero_po]

@id_cliente_despacho int,
@accion nvarchar(255)

as

set language english

if(@accion = 'consultar_numero_po')
begin
	declare @idc_tipo_factura nvarchar(2)

	set @idc_tipo_factura = '9'

	select max(id_orden_pedido) as id_orden_pedido into #orden_pedido
	from orden_pedido
	group by id_orden_pedido_padre

	select orden_pedido.id_orden_pedido,
	orden_pedido.idc_orden_pedido,
	idc_farm,
	ltrim(rtrim(farm.nombre_farm)) as nombre_farm,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	tipo_caja.idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	orden_pedido.fecha_inicial,
	orden_pedido.fecha_final,
	left(datename(dw,orden_pedido.fecha_inicial),3) as day,
	orden_pedido.marca,
	orden_pedido.unidades_por_pieza,
	orden_pedido.cantidad_piezas,
	orden_pedido.numero_po
	from orden_pedido,
	cliente_despacho,
	tipo_factura,
	tipo_flor,
	variedad_flor,
	grado_flor,
	tipo_caja,
	farm
	where exists
	(
		select *
		from #orden_pedido
		where #orden_pedido.id_orden_pedido = orden_pedido.id_orden_pedido
	)
	and cliente_despacho.id_despacho = orden_pedido.id_despacho
	and cliente_despacho.id_despacho = @id_cliente_despacho
	and tipo_factura.id_tipo_factura = orden_pedido.id_tipo_factura
	and tipo_factura.idc_tipo_factura = @idc_tipo_factura
	and tipo_flor.id_tipo_flor = variedad_flor.id_tipo_flor
	and tipo_flor.id_tipo_flor = grado_flor.id_tipo_flor
	and variedad_flor.id_variedad_flor = orden_pedido.id_variedad_flor
	and grado_flor.id_grado_flor = orden_pedido.id_grado_flor
	and tipo_caja.id_tipo_caja = orden_pedido.id_tipo_caja
	and farm.id_farm = orden_pedido.id_farm
	and orden_pedido.disponible = 1
	and convert(datetime, convert(nvarchar,getdate(),101)) between
	fecha_inicial and fecha_final
	order by marca,
	nombre_tipo_flor,
	nombre_variedad_flor,
	nombre_grado_flor,
	nombre_tipo_caja

	drop table #orden_pedido
end
else
if(@accion = 'consultar_cliente_despacho')
begin
	select cliente_despacho.id_despacho as id_cliente_despacho,
	ltrim(rtrim(idc_cliente_despacho)) + ' [' + ltrim(rtrim(nombre_cliente)) + ']' as nombre_cliente
	from cliente_despacho
	where disponible = 1
	order by idc_cliente_despacho
end