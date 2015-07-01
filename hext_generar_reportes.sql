set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[hext_generar_reportes]

@accion nvarchar(255),
@fecha nvarchar(255),
@@control int output

AS

set language spanish
declare @conteo int, 
@hora_inicio_nocturna nvarchar(255), 
@cantidad_minutos int

/*indicar la cantidad de minutos que se restarán a la hora anterior para que la entrada sea catalogada como entrada a turno nocturno*/
set @cantidad_minutos = -30
/*indicar la hora de entrada del turno nocturno*/
set @hora_inicio_nocturna = '06:00PM'

if(@accion = 'generar_datos')
begin
	/*seleccionar las horas de entrada de los empleados*/
	select grupo.id as id_grupo, 
	grupo.nombre as nombre_grupo, 
	empleado.id as id_empleado, 
	empleado.nombre as nombre_empleado, 
	empleado.cc as identificacion, 
	min(FechaHora) as hora_entrada into #temp_entrada
	from historial, 
	empleado, 
	grupo
	where convert(nvarchar,fechahora,101) = convert(nvarchar, convert(datetime,@fecha),101)
	and historial.id_empleado = empleado.id
	and empleado.id_grupo = grupo.id
	and historial.tipo = 1
	group by grupo.id, 
	grupo.nombre, 
	empleado.id, 
	empleado.nombre, 
	empleado.cc

	alter table #temp_entrada
	add hora_salida datetime

	/*seleccionar las marcaciones de entrada de los empleados que tienen atado el turno nocturno*/
	/*y que su marcación real de entrada esta entre el estipulado en el turno y la cantidad de minutos*/
	/*definidos en la variable @cantidad_minutos definida e inicializada al inicio de este procedimiento*/
	select grupo.id as id_grupo, 
	historial.id as id_historial, 
	empleado.id as id_empleado, 
	historial.FechaHora as entrada_real into #salidas_nocturnas
	from asignacionturno, 
	horario, 
	empleado, 
	historial, 
	grupo
	where asignacionturno.id_horario = horario.id
	and horario.horaini = @hora_inicio_nocturna
	and asignacionturno.id_empleado = empleado.id
	and historial.id_empleado = empleado.id
	and grupo.id = empleado.id_grupo
	and historial.tipo = 1
	and convert(nvarchar,historial.FechaHora,101) = convert(nvarchar, convert(datetime,@fecha),101)
	and historial.FechaHora > = dateadd(mi, @cantidad_minutos, convert(datetime,convert(nvarchar,convert(datetime,@fecha),103)+space(1)+@hora_inicio_nocturna))

	/*seleccionar las marcaciones de salida para los empleados que tienen el turno de noche*/
	select historial.id_empleado, 
	min(historial.id) as id_historial, 
	min(historial.FechaHora) as fecha_hora  into #salidas_definitivas
	from historial, #salidas_nocturnas
	where historial.id_empleado = #salidas_nocturnas.id_empleado
	and historial.id > #salidas_nocturnas.id_historial
	group by historial.id_empleado
	order by historial.id_empleado

	/*seleccionar las horas de salida de los empleados*/
	select grupo.id as id_grupo, 
	grupo.nombre as nombre_grupo, 
	empleado.id as id_empleado, 
	empleado.nombre as nombre_empleado, 
	empleado.cc as identificacion, 
	null as hora_entrada, 
	max(FechaHora) as hora_salida into #temp_salida
	from historial, empleado, grupo
	where convert(nvarchar,fechahora,101) = convert(nvarchar, convert(datetime,@fecha),101)
	and historial.id_empleado = empleado.id
	and empleado.id_grupo = grupo.id
	and historial.tipo = 2
	group by grupo.id, grupo.nombre, empleado.id, empleado.nombre, empleado.cc

	/*adicionar la hora de salida de los empleados a la primera tabla en donde se encuentra la hora de entrada*/
	update #temp_entrada
	set hora_salida = #temp_salida.hora_salida
	from #temp_salida
	where #temp_entrada.id_grupo = #temp_salida.id_grupo
	and #temp_entrada.id_empleado = #temp_salida.id_empleado

	/*actualizar los datos con las salidas del turno nocturno que caerán en el dia siguiente al consultado*/
	update #temp_entrada
	set hora_salida = #salidas_definitivas.fecha_hora
	from #salidas_definitivas
	where #temp_entrada.id_empleado = #salidas_definitivas.id_empleado

	/*enviar datos a pantalla*/
	select #temp_entrada.id_grupo, 
	#temp_entrada.nombre_grupo, 
	#temp_entrada.id_empleado, 
	#temp_entrada.nombre_empleado, 
	#temp_entrada.identificacion, 
	left(convert(nvarchar,#temp_entrada.hora_entrada,108),5) as hora_entrada, 
	left(convert(nvarchar,#temp_entrada.hora_salida,108),5) as hora_salida, 
	dbo.datediffToWords(#temp_entrada.hora_entrada, dateadd(mi, -30, #temp_entrada.hora_salida)) as horas_laboradas,
	salida_general.id_salida_general
	from #temp_entrada,
	salida_general	
	where convert(datetime, salida_general.fecha_hora, 101) = convert(datetime, @fecha, 101)
	order by #temp_entrada.nombre_grupo, 
	#temp_entrada.nombre_empleado

	drop table #temp_entrada
	drop table #temp_salida
	drop table #salidas_nocturnas
	drop table #salidas_definitivas
end
else
if(@accion = 'verificar_fecha')
begin
	select @conteo = count(*) 
	from salida_general_procesada, 
	salida_general,
	tipo_proceso
	where salida_general_procesada.id_salida_general = salida_general.id_salida_general
	and convert(nvarchar,salida_general.fecha_hora, 101) = convert(nvarchar,convert(datetime,@fecha), 101)
	and salida_general_procesada.id_tipo_proceso = tipo_proceso.id_tipo_proceso
	and tipo_proceso.nombre_tipo_proceso = 'procesar_dia'

	if(@conteo = 0)
	begin
		set @@control = -2
		return @@control
	end
	else 
	begin
		set @@control = 1
		return @@control
	end
end
else
if(@accion = 'generar_reporte')
begin
	select salida_general_historico_reporte_horas_laboradas.id_grupo, 
	salida_general_historico_reporte_horas_laboradas.nombre_grupo,
	salida_general_historico_reporte_horas_laboradas.id_empleado,
	salida_general_historico_reporte_horas_laboradas.nombre_empleado,
	salida_general_historico_reporte_horas_laboradas.identificacion,
	salida_general_historico_reporte_horas_laboradas.hora_entrada,
	salida_general_historico_reporte_horas_laboradas.hora_salida,
	salida_general_historico_reporte_horas_laboradas.horas_laboradas
	from salida_general_historico_reporte_horas_laboradas,
	salida_general
	where salida_general_historico_reporte_horas_laboradas.id_salida_general = salida_general.id_salida_general
	and convert(nvarchar, salida_general.fecha_hora, 101) = convert(nvarchar, @fecha, 101)
end