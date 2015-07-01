alter PROCEDURE [dbo].[na_editar_factura_anulada_version2]

@accion nvarchar(255),
@idc_llave_factura nvarchar(10), 
@idc_numero_factura nvarchar(20), 
@fecha_factura datetime, 
@fecha_anulacion nvarchar(8), 
@hora_anulacion nvarchar(8), 
@comentario nvarchar(255),
@valor decimal(20,4),
@usuario_cobol nvarchar(255)

AS

if(@accion = 'consultar')
begin
	select factura_anulada.id_factura_anulada,
	factura_anulada.idc_llave_factura,
	factura_anulada.idc_numero_factura,
	factura_anulada.fecha_factura,
	factura_anulada.fecha_anulacion,
	factura_anulada.comentario,
	factura_anulada.valor,
	factura_anulada.usuario_cobol
	from factura_anulada
	order by factura_anulada.fecha_factura
end
else
if(@accion = 'insertar')
begin
	begin try
		declare @id_factura_anulada int

		insert into factura_anulada (idc_llave_factura, idc_numero_factura, fecha_factura, fecha_anulacion, comentario, valor, usuario_cobol)
		values (@idc_llave_factura, @idc_numero_factura, @fecha_factura, dbo.concatenar_fecha_hora_COBOL(@fecha_anulacion, @hora_anulacion), @comentario, @valor, @usuario_cobol)

		set @id_factura_anulada = scope_identity()

		select @id_factura_anulada as id_factura_anulada
	end try
	begin catch
		select -1 as id_factura_anulada
	end catch
end