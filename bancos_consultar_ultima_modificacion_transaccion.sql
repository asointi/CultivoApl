SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bancos_consultar_ultima_modificacion_transaccion] 

@accion nvarchar(255),
@idc_transaccion_bancaria nvarchar(255),
@fecha_inicial datetime,
@fecha_final datetime

as

if(@accion = 'consultar_transacciones')
begin
	select max(id_modifica_transaccion_bancaria) as id_modifica_transaccion_bancaria into #temp
	from modifica_transaccion_bancaria
	group by id_transaccion_bancaria

	select concepto_contable.idc_concepto,
	concepto_contable.descripcion,
	transaccion_bancaria.idc_transaccion_bancaria,
	estado_transaccion.nombre_estado_transaccion,
	naturaleza_contable.nombre_naturaleza,
	banco.idc_banco,
	cuenta_bancaria.numero_cuenta,
	persona_contable.idc_persona_contable,
	persona_contable.nombre_persona,
	transaccion_bancaria.valor_transaccion,
	transaccion_bancaria.notas,
	transaccion_bancaria.fecha,
	modifica_transaccion_bancaria.fecha_modificacion,
	convert(nvarchar,modifica_transaccion_bancaria.fecha_modificacion, 108) as hora_modificacion,
	modifica_transaccion_bancaria.usuario_cobol
	from transaccion_bancaria,
	modifica_transaccion_bancaria,
	concepto_contable,
	estado_transaccion,
	naturaleza_contable,
	cuenta_bancaria,
	banco,
	persona_contable
	where transaccion_bancaria.id_transaccion_bancaria = modifica_transaccion_bancaria.id_transaccion_bancaria
	and concepto_contable.id_concepto = modifica_transaccion_bancaria.id_concepto
	and transaccion_bancaria.id_estado_transaccion = estado_transaccion.id_estado_transaccion
	and transaccion_bancaria.id_naturaleza = naturaleza_contable.id_naturaleza
	and transaccion_bancaria.id_cuenta_bancaria = cuenta_bancaria.id_cuenta_bancaria
	and banco.id_banco = cuenta_bancaria.id_banco
	and transaccion_bancaria.id_persona_contable = persona_contable.id_persona_contable
	and modifica_transaccion_bancaria.id_modifica_transaccion_bancaria in
	(
		select id_modifica_transaccion_bancaria
		from #temp
	)
	and transaccion_bancaria.idc_transaccion_bancaria > =
	case
		when @idc_transaccion_bancaria = '' then ''
		else @idc_transaccion_bancaria
	end
	and transaccion_bancaria.idc_transaccion_bancaria < =
	case
		when @idc_transaccion_bancaria = '' then 'ZZZZZZZZZZZZZZZ'
		else @idc_transaccion_bancaria
	end
	and transaccion_bancaria.fecha between 
	@fecha_inicial and @fecha_final

	drop table #temp
end
ELSE
if(@accion = 'consultar_modificacion_persona')
begin
	select max(id_modifica_persona_transaccion_bancaria) as id_modifica_persona_transaccion_bancaria into #temp_persona
	from modifica_persona_transaccion_bancaria
	group by id_transaccion_bancaria

	select transaccion_bancaria.idc_transaccion_bancaria,
	concepto_contable.idc_concepto,
	concepto_contable.descripcion,
	estado_transaccion.nombre_estado_transaccion,
	naturaleza_contable.nombre_naturaleza,
	banco.idc_banco,
	cuenta_bancaria.numero_cuenta,
	persona_contable.idc_persona_contable,
	persona_contable.nombre_persona,
	transaccion_bancaria.valor_transaccion,
	transaccion_bancaria.notas,
	transaccion_bancaria.fecha,
	modifica_persona_transaccion_bancaria.fecha_modificacion,
	convert(nvarchar,modifica_persona_transaccion_bancaria.fecha_modificacion, 108) as hora_modificacion,
	modifica_persona_transaccion_bancaria.usuario_cobol
	from transaccion_bancaria,
	modifica_persona_transaccion_bancaria,
	concepto_contable,
	estado_transaccion,
	naturaleza_contable,
	cuenta_bancaria,
	banco,
	persona_contable
	where transaccion_bancaria.id_transaccion_bancaria = modifica_persona_transaccion_bancaria.id_transaccion_bancaria
	and persona_contable.id_persona_contable = modifica_persona_transaccion_bancaria.id_persona_contable
	and transaccion_bancaria.id_estado_transaccion = estado_transaccion.id_estado_transaccion
	and concepto_contable.id_concepto = transaccion_bancaria.id_concepto
	and transaccion_bancaria.id_naturaleza = naturaleza_contable.id_naturaleza
	and transaccion_bancaria.id_cuenta_bancaria = cuenta_bancaria.id_cuenta_bancaria
	and banco.id_banco = cuenta_bancaria.id_banco
	and modifica_persona_transaccion_bancaria.id_modifica_persona_transaccion_bancaria in
	(
		select id_modifica_persona_transaccion_bancaria
		from #temp_persona
	)
	and transaccion_bancaria.idc_transaccion_bancaria > =
	case
		when @idc_transaccion_bancaria = '' then ''
		else @idc_transaccion_bancaria
	end
	and transaccion_bancaria.idc_transaccion_bancaria < =
	case
		when @idc_transaccion_bancaria = '' then 'ZZZZZZZZZZZZZZZ'
		else @idc_transaccion_bancaria
	end
	and transaccion_bancaria.fecha between 
	@fecha_inicial and @fecha_final

	drop table #temp_persona
end