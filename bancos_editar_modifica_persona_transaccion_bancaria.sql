SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[bancos_editar_modifica_persona_transaccion_bancaria] 

@accion nvarchar(255),
@usuario_cobol nvarchar(255),
@idc_transaccion_bancaria nvarchar(255),
@idc_persona nvarchar(255),
@id_modifica_persona_transaccion_bancaria int

AS

if(@accion = 'insertar')
begin
	insert into modifica_persona_transaccion_bancaria (id_transaccion_bancaria, id_persona_contable, usuario_cobol)
	select transaccion_bancaria.id_transaccion_bancaria, 
	persona_contable.id_persona_contable,
	@usuario_cobol
	from persona_contable,
	transaccion_bancaria
	where transaccion_bancaria.idc_transaccion_bancaria = @idc_transaccion_bancaria
	and persona_contable.idc_persona_contable = @idc_persona
end
else
if(@accion = 'consultar')
begin
	select modifica_persona_transaccion_bancaria.id_modifica_persona_transaccion_bancaria,
	persona_contable.id_persona_contable,
	persona_contable.idc_persona_contable as idc_persona,
	persona_contable.nombre_persona,
	persona_contable.direccion,
	persona_contable.telefono,
	transaccion_bancaria.id_transaccion_bancaria,
	transaccion_bancaria.idc_transaccion_bancaria,
	transaccion_bancaria.valor_transaccion,
	transaccion_bancaria.notas,
	transaccion_bancaria.fecha,
	convert(datetime, convert(nvarchar,modifica_persona_transaccion_bancaria.fecha_modificacion, 101)) as fecha_modificacion,
	convert(nvarchar,modifica_persona_transaccion_bancaria.fecha_modificacion, 108) as hora_modificacion,
	modifica_persona_transaccion_bancaria.usuario_cobol
	from transaccion_bancaria,
	persona_contable,
	modifica_persona_transaccion_bancaria
	where transaccion_bancaria.id_transaccion_bancaria = modifica_persona_transaccion_bancaria.id_transaccion_bancaria
	and persona_contable.id_persona_contable = modifica_persona_transaccion_bancaria.id_persona_contable
	and persona_contable.idc_persona_contable > =
	case
		when @idc_persona = '' then '               '
		else @idc_persona
	end
	and persona_contable.idc_persona_contable < =
	case
		when @idc_persona = '' then 'ZZZZZZZZZZZZZZZ'
		else @idc_persona
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
	order by modifica_persona_transaccion_bancaria.fecha_modificacion desc
end
else
if(@accion = 'eliminar')
begin
	delete from modifica_persona_transaccion_bancaria
	where id_modifica_persona_transaccion_bancaria = @id_modifica_persona_transaccion_bancaria
end
