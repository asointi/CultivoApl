/****** Object:  StoredProcedure [dbo].[na_consultar_despachos_cliente]    Script Date: 10/06/2007 11:56:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[na_consultar_despachos_cliente]

@id_cliente_factura int,
@orden nvarchar(255)

AS

if(@id_cliente_factura = -3)
begin
	select cliente_despacho.id_despacho,
	cliente_despacho.id_cliente_factura,
	cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente,
	cliente_despacho.contacto,
	cliente_despacho.direccion,
	cliente_despacho.ciudad,
	cliente_despacho.estado,
	cliente_despacho.telefono,
	cliente_despacho.fax,
	convert(datetime,convert(nvarchar,cliente_despacho.fecha_apertura_cuenta,105)) as fecha_apertura_cuenta,
	vendedor.id_vendedor,
	vendedor.idc_vendedor,
	vendedor.nombre as nombre_vendedor,
	(select convert(datetime,convert(nvarchar,min(fecha_factura),105))
	from factura 
	where factura.id_despacho = cliente_despacho.id_despacho) as fecha_factura,
	cliente_factura.limite_credito
	from cliente_despacho,
	cliente_factura,
	vendedor
	where cliente_despacho.id_cliente_factura =	cliente_factura.id_cliente_factura
	and cliente_factura.id_vendedor = vendedor.id_vendedor
end
else
IF (@id_cliente_factura > 0)
BEGIN
	SELECT cd.*,cd.estado + ' ' + LTRIM(RTRIM(cd.direccion)) + ' [' + LTRIM(RTRIM(cd.idc_cliente_despacho)) + ']'  as direccion_completa,
	cd1.nombre_cliente as nombre_cliente_factura
	FROM cliente_despacho as cd, cliente_factura as cf, cliente_despacho as cd1
	WHERE cf.id_cliente_factura = cd.id_cliente_factura
	and cf.id_cliente_factura = cd1.id_cliente_factura
	and cf.idc_cliente_factura = cd1.idc_cliente_despacho
	and cf.id_cliente_factura = @id_cliente_factura
	and cf.disponible = 1
	ORDER BY 
	CASE @orden WHEN 'id_despacho' THEN cd.id_despacho ELSE NULL END,
	CASE @orden	WHEN 'id_cliente_factura' THEN cd.id_cliente_factura ELSE NULL END,
	CASE @orden	WHEN 'idc_cliente_despacho' THEN cd.idc_cliente_despacho ELSE NULL END,
	CASE @orden	WHEN 'nombre_cliente' THEN cd.nombre_cliente ELSE NULL END,
	CASE @orden	WHEN 'nombre_cliente_factura' THEN cd1.nombre_cliente  ELSE NULL END,
	CASE @orden	WHEN 'ciudad' THEN cd.ciudad ELSE NULL END,
	CASE @orden	WHEN 'estado' THEN cd.estado ELSE NULL END,
	CASE @orden	WHEN '' THEN cd.nombre_cliente ELSE NULL END

END
ELSE IF (@id_cliente_factura = -1)
BEGIN

	SELECT cd.*,cd.estado + ' ' + LTRIM(RTRIM(cd.direccion)) + ' [' + LTRIM(RTRIM(cd.idc_cliente_despacho)) + ']'  as direccion_completa,
	cd1.nombre_cliente as nombre_cliente_factura
	FROM cliente_despacho as cd, cliente_factura as cf, cliente_despacho as cd1
	WHERE cf.id_cliente_factura = cd.id_cliente_factura
	and cf.id_cliente_factura = cd1.id_cliente_factura
	and cf.idc_cliente_factura = cd1.idc_cliente_despacho
	and cf.disponible = 1
	ORDER BY 
	CASE @orden WHEN 'id_despacho' THEN cd.id_despacho ELSE NULL END,
	CASE @orden	WHEN 'id_cliente_factura' THEN cd.id_cliente_factura ELSE NULL END,
	CASE @orden	WHEN 'idc_cliente_despacho' THEN cd.idc_cliente_despacho ELSE NULL END,
	CASE @orden	WHEN 'nombre_cliente' THEN cd.nombre_cliente ELSE NULL END,
	CASE @orden	WHEN 'nombre_cliente_factura' THEN cd1.nombre_cliente ELSE NULL END,
	CASE @orden	WHEN 'ciudad' THEN cd.ciudad ELSE NULL END,
	CASE @orden	WHEN 'estado' THEN cd.estado ELSE NULL END,
	CASE @orden	WHEN '' THEN cd.nombre_cliente ELSE NULL END

END
ELSE IF (@id_cliente_factura = -2)
BEGIN

	SELECT cd.*, LTRIM(RTRIM(cd.nombre_cliente)) + ' [' + LTRIM(RTRIM(cd.idc_cliente_despacho)) +']' as nombre_cliente_idc 
	FROM cliente_factura as cf, cliente_despacho as cd
	WHERE cf.id_cliente_factura = cd.id_cliente_factura 
	and cf.idc_cliente_factura = cd.idc_cliente_despacho
	and cf.disponible = 1
	ORDER BY 
	CASE @orden WHEN 'id_despacho' THEN id_despacho ELSE NULL END,
	CASE @orden	WHEN 'id_cliente_factura' THEN cf.id_cliente_factura ELSE NULL END,
	CASE @orden	WHEN 'idc_cliente_despacho' THEN idc_cliente_despacho ELSE NULL END,
	CASE @orden	WHEN 'nombre_cliente' THEN nombre_cliente ELSE NULL END,
	CASE @orden	WHEN 'nombre_cliente_factura' THEN nombre_cliente ELSE NULL END,
	CASE @orden	WHEN 'ciudad' THEN ciudad ELSE NULL END,
	CASE @orden	WHEN 'estado' THEN estado ELSE NULL END,
	CASE @orden	WHEN '' THEN nombre_cliente ELSE NULL END
END