set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010-07-01
-- Description:	Llevar control de impresión o envío por mail de facturas
-- =============================================

ALTER PROCEDURE [dbo].[na_editar_log_factura]

@usuario_cobol nvarchar(255),
@numero_factura nvarchar(255),
@id_tipo_log_factura int,
@accion nvarchar(255)

as

if(@accion = 'insertar')
begin
	declare @conteo int

	select @conteo = count(*)
	from factura
	where factura.idc_llave_factura + factura.idc_numero_factura = @numero_factura

	if(@conteo > 0)
	begin
		insert into log_factura (id_tipo_log_factura, id_factura, usuario_cobol, idc_llave_factura, idc_numero_factura)
		select tipo_log_factura.id_tipo_log_factura, factura.id_factura, @usuario_cobol, factura.idc_llave_factura, factura.idc_numero_factura
		from factura,
		tipo_log_factura
		where factura.idc_llave_factura + factura.idc_numero_factura = @numero_factura
		and  tipo_log_factura.id_tipo_log_factura = @id_tipo_log_factura
	end
	else
	begin
		insert into log_factura (id_tipo_log_factura, id_factura, usuario_cobol, idc_llave_factura, idc_numero_factura)
		select tipo_log_factura.id_tipo_log_factura, null, @usuario_cobol, left(@numero_factura, 2), right(@numero_factura,5)
		from tipo_log_factura
		where tipo_log_factura.id_tipo_log_factura = @id_tipo_log_factura
	end
end
else
if(@accion = 'consultar_log')
begin
	select tipo_log_factura.nombre_tipo_log_factura,
	log_factura.usuario_cobol,
	log_factura.fecha_transaccion,
	convert(nvarchar, log_factura.fecha_transaccion, 108) as hora_transaccion
	from log_factura,
	tipo_log_factura
	where tipo_log_factura.id_tipo_log_factura = log_factura.id_tipo_log_factura
	and log_factura.idc_llave_factura + log_factura.idc_numero_factura = @numero_factura
	order by log_factura.fecha_transaccion desc
end
else
if(@accion = 'consultar_tipo_log')
begin
	select id_tipo_log_factura,
	nombre_tipo_log_factura 
	from tipo_log_factura
	order by nombre_tipo_log_factura
end
