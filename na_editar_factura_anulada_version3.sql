alter PROCEDURE [dbo].[na_editar_factura_anulada_version3]

@accion nvarchar(255),
@idc_llave_factura nvarchar(10), 
@idc_numero_factura nvarchar(20), 
@fecha_factura datetime, 
@fecha_anulacion nvarchar(8), 
@hora_anulacion nvarchar(8), 
@comentario nvarchar(255),
@valor decimal(20,4),
@usuario_cobol nvarchar(255),
@fecha_final_anulacion datetime,
@idc_cliente_despacho nvarchar(255),
@idc_vendedor nvarchar(255),
@numero_po nvarchar(255)

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
	factura_anulada.usuario_cobol,
	cliente_despacho.idc_cliente_despacho,
	ltrim(rtrim(cliente_despacho.nombre_cliente)) as nombre_cliente,
	vendedor.idc_vendedor,
	vendedor.nombre as nombre_vendedor,
	factura_anulada.numero_po
	from factura_anulada,
	cliente_despacho,
	vendedor
	where convert(datetime,convert(nvarchar, fecha_anulacion, 101)) between
	convert(datetime,@fecha_anulacion) and @fecha_final_anulacion
	and cliente_despacho.id_despacho = factura_anulada.id_despacho
	and vendedor.id_vendedor = factura_anulada.id_vendedor
	order by factura_anulada.fecha_factura
end
else
if(@accion = 'insertar')
begin
	begin try
		declare @id_factura_anulada int

		insert into factura_anulada (idc_llave_factura, idc_numero_factura, fecha_factura, fecha_anulacion, comentario, valor, usuario_cobol, id_despacho, id_vendedor, numero_po)
		select @idc_llave_factura, 
		@idc_numero_factura, 
		@fecha_factura, 
		dbo.concatenar_fecha_hora_COBOL(@fecha_anulacion, @hora_anulacion), 
		@comentario, 
		@valor, 
		@usuario_cobol,
		cliente_despacho.id_despacho, 
		vendedor.id_vendedor, 
		@numero_po
		from cliente_despacho,
		vendedor
		where cliente_despacho.idc_cliente_despacho = @idc_cliente_despacho
		and vendedor.idc_vendedor = @idc_vendedor

		set @id_factura_anulada = scope_identity()

		select @id_factura_anulada as id_factura_anulada
	end try
	begin catch
		select -1 as id_factura_anulada
	end catch
end