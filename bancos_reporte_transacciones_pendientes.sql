SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[bancos_reporte_transacciones_pendientes] 

@accion nvarchar(255)

as

if(@accion = 'consultar_transacciones')
begin
	select max(id_modifica_transaccion_bancaria) as id_modifica_transaccion_bancaria into #temp
	from modifica_transaccion_bancaria
	group by id_transaccion_bancaria


	select concepto_contable.idc_concepto,
	concepto_contable.descripcion,
	(
		select c.idc_concepto 
		from modifica_transaccion_bancaria as m,
		concepto_contable as c
		where c.id_concepto = m.id_concepto
		and m.id_modifica_transaccion_bancaria = modifica_transaccion_bancaria.id_modifica_transaccion_bancaria
	)as idc_concepto_modificado,
	(
		select c.descripcion 
		from modifica_transaccion_bancaria as m,
		concepto_contable as c
		where c.id_concepto = m.id_concepto
		and m.id_modifica_transaccion_bancaria = modifica_transaccion_bancaria.id_modifica_transaccion_bancaria
	)as idc_descripcion_modificada,
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
	and concepto_contable.id_concepto = transaccion_bancaria.id_concepto
	and concepto_contable.id_concepto <> modifica_transaccion_bancaria.id_concepto
	and transaccion_bancaria.id_estado_transaccion = estado_transaccion.id_estado_transaccion
	and transaccion_bancaria.id_naturaleza = naturaleza_contable.id_naturaleza
	and transaccion_bancaria.id_cuenta_bancaria = cuenta_bancaria.id_cuenta_bancaria
	and banco.id_banco = cuenta_bancaria.id_banco
	and transaccion_bancaria.id_persona_contable = persona_contable.id_persona_contable
	and exists
	(
		select * 
		from #temp
		where #temp.id_modifica_transaccion_bancaria = modifica_transaccion_bancaria.id_modifica_transaccion_bancaria
	)
	order by modifica_transaccion_bancaria.fecha_modificacion

	drop table #temp
end
else
if(@accion = 'enviar_mail')
begin
	exec bd_cultivo.ReportServer2.dbo.AddEvent @EventType='TimedSubscription', @EventData='a5fb8839-9331-4701-9b57-c5b4841ef4d1' 
end