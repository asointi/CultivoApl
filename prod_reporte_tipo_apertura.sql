set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[prod_reporte_tipo_apertura]

@accion nvarchar(255)

as

declare @apertura_minima int,
@apertura_maxima int

select @apertura_minima = apertura_minima from configuracion_bd
select @apertura_maxima = apertura_maxima from configuracion_bd

if(@accion = 'apertura_quincenal')
begin
	SELECT convert(datetime,convert(nvarchar,Tallo_Clasificado.fecha_transaccion,101)) as fecha,    
	CASE 
		WHEN tallo_clasificado.apertura < apertura.apertura_minima THEN 'Muy Cerrado' 
		WHEN (tallo_clasificado.apertura >= apertura.apertura_minima AND tallo_clasificado.apertura <= apertura.apertura_maxima) THEN 'Normal' 
		WHEN tallo_clasificado.apertura > apertura.apertura_maxima THEN 'Muy Abierto' 
	END as tipo_apertura, 
	count(Tallo_Clasificado.id_tallo_clasificado) as cantidad_tallos
	FROM Tallo_Clasificado,
	regla,
	condicion,
	detalle_condicion,
	tiempo_ejecucion_detalle_condicion,
	variedad_flor,
	punto_corte,
	apertura
	where regla.id_regla = condicion.id_regla
	and regla.id_apertura = apertura.id_apertura
	and apertura.nombre_apertura = 'Normal'
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_variedad_flor = variedad_flor.id_variedad_flor
	and regla.id_punto_corte = punto_corte.id_punto_corte
	and variedad_flor.id_variedad_flor = 851
	and convert(datetime,convert(nvarchar,tallo_clasificado.fecha_transaccion, 101)) > = convert(datetime,convert(nvarchar,dateadd(dd, -15, getdate()),101))
	group by
	CASE 
		WHEN tallo_clasificado.apertura < apertura.apertura_minima THEN 'Muy Cerrado' 
		WHEN (tallo_clasificado.apertura >= apertura.apertura_minima AND tallo_clasificado.apertura <= apertura.apertura_maxima) THEN 'Normal' 
		WHEN tallo_clasificado.apertura > apertura.apertura_maxima THEN 'Muy Abierto' 
	END, 
	convert(datetime,convert(nvarchar,Tallo_Clasificado.fecha_transaccion,101))
	order by convert(datetime,convert(nvarchar,Tallo_Clasificado.fecha_transaccion,101)),
	tipo_apertura
end
else
if(@accion = 'apertura_diaria')
begin
	SELECT convert(datetime,convert(nvarchar,Tallo_Clasificado.fecha_transaccion,101)) as fecha,    
	CASE 
		WHEN tallo_clasificado.apertura < apertura.apertura_minima THEN 'Muy Cerrado' 
		WHEN (tallo_clasificado.apertura >= apertura.apertura_minima AND tallo_clasificado.apertura <= apertura.apertura_maxima) THEN 'Normal' 
		WHEN tallo_clasificado.apertura > apertura.apertura_maxima THEN 'Muy Abierto' 
	END as tipo_apertura, 
	count(Tallo_Clasificado.id_tallo_clasificado) as cantidad_tallos
	FROM Tallo_Clasificado,
	regla,
	condicion,
	detalle_condicion,
	tiempo_ejecucion_detalle_condicion,
	variedad_flor,
	punto_corte,
	apertura
	where regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_variedad_flor = variedad_flor.id_variedad_flor
	and regla.id_punto_corte = punto_corte.id_punto_corte
	and variedad_flor.id_variedad_flor = 851
	and regla.id_apertura = apertura.id_apertura
	and apertura.nombre_apertura = 'Normal'
	and convert(datetime,convert(nvarchar,tallo_clasificado.fecha_transaccion, 101)) = convert(datetime,convert(nvarchar,getdate(),101))
	group by
	CASE 
		WHEN tallo_clasificado.apertura < apertura.apertura_minima THEN 'Muy Cerrado' 
		WHEN (tallo_clasificado.apertura >= apertura.apertura_minima AND tallo_clasificado.apertura <= apertura.apertura_maxima) THEN 'Normal' 
		WHEN tallo_clasificado.apertura > apertura.apertura_maxima THEN 'Muy Abierto' 
	END, 
	convert(datetime,convert(nvarchar,Tallo_Clasificado.fecha_transaccion,101))
	order by tipo_apertura
end
else
if(@accion = 'consultar_subject')
begin
	SELECT convert(datetime,convert(nvarchar,Tallo_Clasificado.fecha_transaccion,101)) as fecha,    
	CASE 
		WHEN tallo_clasificado.apertura < apertura.apertura_minima THEN 'Muy Cerrado' 
		WHEN (tallo_clasificado.apertura >= apertura.apertura_minima AND tallo_clasificado.apertura <= apertura.apertura_maxima) THEN 'Normal' 
		WHEN tallo_clasificado.apertura > apertura.apertura_maxima THEN 'Muy Abierto' 
	END as tipo_apertura, 
	count(Tallo_Clasificado.id_tallo_clasificado) as cantidad_tallos into #temp
	FROM Tallo_Clasificado,
	regla,
	condicion,
	detalle_condicion,
	tiempo_ejecucion_detalle_condicion,
	variedad_flor,
	punto_corte,
	apertura
	where regla.id_regla = condicion.id_regla
	and condicion.id_condicion = detalle_condicion.id_condicion
	and detalle_condicion.id_detalle_condicion = tiempo_ejecucion_detalle_condicion.id_detalle_condicion
	and tiempo_ejecucion_detalle_condicion.id_tiempo_ejecucion_detalle_condicion = tallo_clasificado.id_tiempo_ejecucion_detalle_condicion
	and regla.id_variedad_flor = variedad_flor.id_variedad_flor
	and regla.id_punto_corte = punto_corte.id_punto_corte
	and variedad_flor.id_variedad_flor = 851
	and regla.id_apertura = apertura.id_apertura
	and apertura.nombre_apertura = 'Normal'
	and convert(datetime,convert(nvarchar,tallo_clasificado.fecha_transaccion, 101)) = convert(datetime,convert(nvarchar,getdate(),101))
	group by
	CASE 
		WHEN tallo_clasificado.apertura < apertura.apertura_minima THEN 'Muy Cerrado' 
		WHEN (tallo_clasificado.apertura >= apertura.apertura_minima AND tallo_clasificado.apertura <= apertura.apertura_maxima) THEN 'Normal' 
		WHEN tallo_clasificado.apertura > apertura.apertura_maxima THEN 'Muy Abierto' 
	END, 
	convert(datetime,convert(nvarchar,Tallo_Clasificado.fecha_transaccion,101))
	order by tipo_apertura
	
	alter table #temp
	add promedio decimal(20,4)

	update #temp
	set promedio = (cantidad_tallos/convert(decimal(20,4),(select sum(cantidad_tallos) from #temp))) * 100

	select 'Apertura no normal Freedom EEUU' + space(1) +  max(convert(nvarchar, fecha, 111)) + space(1) +
	convert(nvarchar,convert(decimal(20,1),(select sum(promedio) from #temp where tipo_apertura in ('Muy Abierto', 'Muy Cerrado')))) + '%' + space(1) +
	convert(nvarchar,(select left(convert(nvarchar, (convert(money, sum(cantidad_tallos))), 1), charindex('.', convert(nvarchar, (convert(money, sum(cantidad_tallos))), 1))-1) from #temp where tipo_apertura in ('Muy Abierto', 'Muy Cerrado'))) + space(1) + 'tallos' as subject
	from #temp

	drop table #temp
end