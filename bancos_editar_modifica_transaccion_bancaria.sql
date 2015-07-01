SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bancos_editar_modifica_transaccion_bancaria] 

@accion nvarchar(255),
@usuario_cobol nvarchar(255),
@idc_transaccion_bancaria nvarchar(255),
@idc_concepto nvarchar(255),
@id_modifica_transaccion_bancaria int

AS

if(@accion = 'insertar')
begin
	insert into modifica_transaccion_bancaria (id_transaccion_bancaria, id_concepto, usuario_cobol)
	select transaccion_bancaria.id_transaccion_bancaria, 
	concepto_contable.id_concepto,
	@usuario_cobol
	from concepto_contable,
	transaccion_bancaria
	where transaccion_bancaria.idc_transaccion_bancaria = @idc_transaccion_bancaria
	and concepto_contable.idc_concepto = @idc_concepto
end
else
if(@accion = 'consultar')
begin
	select modifica_transaccion_bancaria.id_modifica_transaccion_bancaria,
	concepto_contable.id_concepto,
	concepto_contable.idc_concepto,
	concepto_contable.descripcion,
	transaccion_bancaria.id_transaccion_bancaria,
	transaccion_bancaria.idc_transaccion_bancaria,
	transaccion_bancaria.valor_transaccion,
	transaccion_bancaria.notas,
	transaccion_bancaria.fecha,
	convert(datetime, convert(nvarchar,modifica_transaccion_bancaria.fecha_modificacion, 101)) as fecha_modificacion,
	convert(nvarchar,modifica_transaccion_bancaria.fecha_modificacion, 108) as hora_modificacion,
	modifica_transaccion_bancaria.usuario_cobol
	from transaccion_bancaria,
	concepto_contable,
	modifica_transaccion_bancaria
	where transaccion_bancaria.id_transaccion_bancaria = modifica_transaccion_bancaria.id_transaccion_bancaria
	and concepto_contable.id_concepto = modifica_transaccion_bancaria.id_concepto
	and concepto_contable.idc_concepto > =
	case
		when @idc_concepto = '' then '          '
		else @idc_concepto
	end
	and concepto_contable.idc_concepto < =
	case
		when @idc_concepto = '' then 'ZZZZZZZZZZ'
		else @idc_concepto
	end
	and transaccion_bancaria.idc_transaccion_bancaria > =
	case
		when @idc_transaccion_bancaria = '' then '          '
		else @idc_transaccion_bancaria
	end
	and transaccion_bancaria.idc_transaccion_bancaria < =
	case
		when @idc_transaccion_bancaria = '' then 'ZZZZZZZZZZ'
		else @idc_transaccion_bancaria
	end
	order by modifica_transaccion_bancaria.fecha_modificacion desc
end
else
if(@accion = 'eliminar')
begin
	delete from modifica_transaccion_bancaria
	where id_modifica_transaccion_bancaria = @id_modifica_transaccion_bancaria
end
