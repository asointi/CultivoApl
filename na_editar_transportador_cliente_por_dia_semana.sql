set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_transportador_cliente_por_dia_semana]

@accion nvarchar(255),
@idc_vendedor nvarchar(10)

as

if(@accion = 'consultar_dia_semana')
begin
	select id_dia_semana,
	nombre_dia 
	from dia_semana
	order by id_dia_semana
end
else
if(@accion = 'consultar_transportador_cliente_por_dia_semana')
begin
	select transportador.id_transportador into #temp
	from transportador_cliente_por_dia_semana,
	cliente_despacho,
	transportador,
	vendedor,
	cliente_factura
	where transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	and cliente_despacho.id_despacho = transportador_cliente_por_dia_semana.id_despacho
	and vendedor.idc_vendedor > = 
	case
		when @idc_vendedor = '' then '   '
		else @idc_vendedor
	end
	and vendedor.idc_vendedor < = 
	case
		when @idc_vendedor = '' then 'ZZZ'
		else @idc_vendedor
	end
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	group by transportador.id_transportador


	select cliente_despacho.idc_cliente_despacho,
	cliente_despacho.nombre_cliente,
	cliente_despacho.contacto,
	cliente_despacho.direccion,
	cliente_despacho.telefono,
	isnull((
		select transportador.idc_transportador
		from transportador_cliente_por_dia_semana,
		dia_semana,
		transportador
		where dia_semana.id_dia_semana = transportador_cliente_por_dia_semana.id_dia_semana
		and dia_semana.id_dia_semana = 1
		and transportador_cliente_por_dia_semana.id_despacho = cliente_despacho.id_despacho
		and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	), '') as Monday,
	isnull((
		select transportador.idc_transportador
		from transportador_cliente_por_dia_semana,
		dia_semana,
		transportador
		where dia_semana.id_dia_semana = transportador_cliente_por_dia_semana.id_dia_semana
		and dia_semana.id_dia_semana = 2
		and transportador_cliente_por_dia_semana.id_despacho = cliente_despacho.id_despacho
		and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	), '') as Tuesday,
	isnull((
		select transportador.idc_transportador
		from transportador_cliente_por_dia_semana,
		dia_semana,
		transportador
		where dia_semana.id_dia_semana = transportador_cliente_por_dia_semana.id_dia_semana
		and dia_semana.id_dia_semana = 3
		and transportador_cliente_por_dia_semana.id_despacho = cliente_despacho.id_despacho
		and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	), '') as Wednesday,
	isnull((
		select transportador.idc_transportador
		from transportador_cliente_por_dia_semana,
		dia_semana,
		transportador
		where dia_semana.id_dia_semana = transportador_cliente_por_dia_semana.id_dia_semana
		and dia_semana.id_dia_semana = 4
		and transportador_cliente_por_dia_semana.id_despacho = cliente_despacho.id_despacho
		and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	), '') as Thursday,
	isnull((
		select transportador.idc_transportador
		from transportador_cliente_por_dia_semana,
		dia_semana,
		transportador
		where dia_semana.id_dia_semana = transportador_cliente_por_dia_semana.id_dia_semana
		and dia_semana.id_dia_semana = 5
		and transportador_cliente_por_dia_semana.id_despacho = cliente_despacho.id_despacho
		and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	), '') as Friday,
	isnull((
		select transportador.idc_transportador
		from transportador_cliente_por_dia_semana,
		dia_semana,
		transportador
		where dia_semana.id_dia_semana = transportador_cliente_por_dia_semana.id_dia_semana
		and dia_semana.id_dia_semana = 6
		and transportador_cliente_por_dia_semana.id_despacho = cliente_despacho.id_despacho
		and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	), '') as Saturday,
	isnull((
		select transportador.idc_transportador
		from transportador_cliente_por_dia_semana,
		dia_semana,
		transportador
		where dia_semana.id_dia_semana = transportador_cliente_por_dia_semana.id_dia_semana
		and dia_semana.id_dia_semana = 7
		and transportador_cliente_por_dia_semana.id_despacho = cliente_despacho.id_despacho
		and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	), '') as Sunday
	from cliente_despacho,
	transportador,
	transportador_cliente_por_dia_semana,
	cliente_factura,
	vendedor,
	#temp
	where cliente_despacho.id_despacho = transportador_cliente_por_dia_semana.id_despacho
	and transportador.id_transportador = transportador_cliente_por_dia_semana.id_transportador
	and transportador.id_transportador = #temp.id_transportador
	and cliente_factura.id_cliente_factura = cliente_despacho.id_cliente_factura
	and vendedor.id_vendedor = cliente_factura.id_vendedor
	and vendedor.idc_vendedor > = 
	case
		when @idc_vendedor = '' then '   '
		else @idc_vendedor
	end
	and vendedor.idc_vendedor < = 
	case
		when @idc_vendedor = '' then 'ZZZ'
		else @idc_vendedor
	end
	group by cliente_despacho.idc_cliente_despacho,
	cliente_despacho.id_despacho,
	cliente_despacho.nombre_cliente,
	cliente_despacho.contacto,
	cliente_despacho.direccion,
	cliente_despacho.telefono
	order by cliente_despacho.idc_cliente_despacho

	drop table #temp
end