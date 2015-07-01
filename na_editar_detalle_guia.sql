/****** Object:  StoredProcedure [dbo].[gc_editar_cuenta_interna_grupo]    Script Date: 10/06/2007 11:25:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[na_editar_detalle_guia]

@fecha_inicial nvarchar(255), 
@fecha_final nvarchar(255),
@idc_guia nvarchar(255),
@accion nvarchar(255)

AS

if(@accion = 'guias')
begin
	select guia.id_guia,
	guia.idc_guia,
	guia.fecha_guia,
	isnull(sum(tipo_caja.factor_a_full), 0) as fulles
	from guia left join pieza on guia.id_guia = pieza.id_guia
	left join caja on pieza.id_caja = caja.id_caja
	left join tipo_caja on caja.id_tipo_caja = tipo_caja.id_tipo_caja
	where guia.fecha_guia between
	convert(datetime,@fecha_inicial) and convert(datetime,@fecha_final)
	group by guia.id_guia,
	guia.idc_guia,
	guia.fecha_guia
	order by guia.fecha_guia
end
else
if(@accion = 'detalle_guia')
begin
	select tipo_caja.idc_tipo_caja,
	ltrim(rtrim(tipo_caja.nombre_tipo_caja)) as nombre_tipo_caja,
	farm.idc_farm,
	count(pieza.id_pieza) as cantidad_piezas,
	sum(tipo_caja.factor_a_full) as fulles,
	cliente_despacho.idc_cliente_despacho
	from guia,
	pieza left join detalle_item_factura on pieza.id_pieza = detalle_item_factura.id_pieza 
	left join item_factura on detalle_item_factura.id_item_factura = item_factura.id_item_factura
	left join factura on item_factura.id_factura = factura.id_factura
	left join cliente_despacho on factura.id_despacho = cliente_despacho.id_despacho,
	caja,
	tipo_caja,
	farm
	where guia.idc_guia = @idc_guia
	and pieza.id_guia = guia.id_guia
	and pieza.id_caja = caja.id_caja
	and caja.id_tipo_caja = tipo_caja.id_tipo_caja
	and pieza.id_farm = farm.id_farm
	group by tipo_caja.nombre_tipo_caja,
	tipo_caja.idc_tipo_caja,
	farm.idc_farm,
	cliente_despacho.idc_cliente_despacho
end