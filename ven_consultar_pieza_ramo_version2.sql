alter PROCEDURE [dbo].[ven_consultar_pieza_ramo_version2]

@id_despacho nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime,
@accion nvarchar(255),
@id_pieza int,
@idc_pieza nvarchar(255)

as

declare @idc_farm nvarchar(255)

set @idc_farm = 'N4'

if(@accion = 'consultar_pieza')
begin
	select pieza.id_pieza,
	pieza.idc_pieza,
	factura.idc_llave_factura+factura.idc_numero_factura as numero_factura,
	factura.fecha_factura,
	guia.fecha_guia,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	ltrim(rtrim(caja.nombre_caja)) as nombre_caja,
	pieza.unidades_por_pieza,
	pieza.marca as code,
	item_factura.valor_unitario
	from pieza, 
	farm, 
	detalle_item_factura, 
	item_factura, 
	factura, 
	guia,
	cliente_despacho, 
	tipo_flor, 
	variedad_flor, 
	grado_flor,
	caja,
	tapa
	where pieza.id_farm = farm.id_farm
	and farm.idc_farm = @idc_farm
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and detalle_item_factura.id_item_factura = item_factura.id_item_factura 
	and item_factura.id_factura = factura.id_factura
	and factura.id_despacho = cliente_despacho.id_despacho
	and pieza.id_guia = guia.id_guia
	and cliente_despacho.id_despacho = @id_despacho
	and factura.fecha_factura between 
	@fecha_inicial and @fecha_final
	and pieza.id_variedad_flor = variedad_flor.id_variedad_flor
	and pieza.id_grado_flor = grado_flor.id_grado_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and pieza.id_caja = caja.id_caja
	and pieza.id_tapa = tapa.id_tapa
	order by 
	factura.fecha_factura,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	ltrim(rtrim(grado_flor.nombre_grado_flor)),
	ltrim(rtrim(caja.nombre_caja)),
	pieza.unidades_por_pieza,
	pieza.marca,
	ltrim(rtrim(tapa.nombre_tapa))
end
else
if(@accion = 'consultar_ramo')
begin
	select
	ramo.idc_ramo,
	ramo.fecha_entrada,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	ramo.tallos_por_ramo,
	DATEDIFF(day,guia.fecha_guia, factura.fecha_factura) as vejez_miami,
	DATEDIFF(day,ramo.fecha_entrada, factura.fecha_factura) as vejez_customer
	from pieza, 
	ramo, 
	variedad_flor, 
	grado_flor, 
	tipo_flor, 
	guia, 
	detalle_item_factura, 
	item_factura, 
	factura
	where pieza.id_pieza = ramo.id_pieza
	and pieza.id_pieza = @id_pieza
	and ramo.id_variedad_flor = variedad_flor.id_variedad_flor
	and ramo.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and pieza.id_guia = guia.id_guia
	and pieza.id_pieza = detalle_item_factura.id_pieza
	and detalle_item_factura.id_item_factura = item_factura.id_item_factura
	and item_factura.id_factura = factura.id_factura
	order by
	ramo.fecha_entrada,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	ltrim(rtrim(grado_flor.nombre_grado_flor))
end
else
if(@accion = 'consultar_ramo_idc_pieza')
begin
	select
	ramo.idc_ramo,
	convert(nvarchar, ramo.fecha_entrada, 111) as fecha_lectura,
	convert(nvarchar, ramo.fecha_entrada, 108) as hora_lectura,
	tipo_flor.idc_tipo_flor,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)) as nombre_tipo_flor,
	variedad_flor.idc_variedad_flor,
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)) as nombre_variedad_flor,
	grado_flor.idc_grado_flor,
	ltrim(rtrim(grado_flor.nombre_grado_flor)) as nombre_grado_flor,
	ramo.tallos_por_ramo
	from pieza, 
	ramo, 
	variedad_flor, 
	grado_flor, 
	tipo_flor
	where pieza.id_pieza = ramo.id_pieza
	and pieza.idc_pieza = @idc_pieza
	and ramo.id_variedad_flor = variedad_flor.id_variedad_flor
	and ramo.id_grado_flor = grado_flor.id_grado_flor
	and grado_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	and variedad_flor.id_tipo_flor = tipo_flor.id_tipo_flor
	order by
	ramo.fecha_entrada,
	ltrim(rtrim(tipo_flor.nombre_tipo_flor)),
	ltrim(rtrim(variedad_flor.nombre_variedad_flor)),
	ltrim(rtrim(grado_flor.nombre_grado_flor))
end