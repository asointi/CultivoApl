set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[hext_editar_horas_salida]

@accion nvarchar(255),
@cantidad_minutos_gracia int,
@id_salida_general int,
@id_empleado int,
@id_grupo nvarchar(255),
@fecha_hora_anterior datetime,
@fecha_hora_modificada datetime, 
@administracion bit

AS

set language us_english

declare @nombre_dependencia nvarchar(255), @nombre_coltrack nvarchar(255)
set @nombre_dependencia = 'administracion'
set @nombre_coltrack = 'Coltrack'

if(@id_grupo is null)
	set @id_grupo = '%%'

if(@accion = 'consultar_detalle')
begin
	declare @fecha datetime, @hora_inicio_nocturna nvarchar(255), @hora_fin_nocturna nvarchar(255), @hora_inicio_diurno nvarchar(255), @cantidad_minutos int
	/*extraer la fecha de la salida general a traves del id de la salida general ingresado como parámetro*/
	select @fecha = fecha_hora from salida_general where id_salida_general = @id_salida_general
	/*indicar el comienzo del turno diurno*/
	set @hora_inicio_diurno = '06:30'	
	/*indicar el comienzo del turno de la noche*/
	set @hora_inicio_nocturna = '18:00'
	/*indicar el comienzo del turno de la noche*/
	select @hora_fin_nocturna = HoraFin from horario where HoraIni = @hora_inicio_nocturna
	/*indicar la cantidad de minutos que se restarán a la hora anterior para que la entrada sea catalogada como entrada a turno nocturno*/
	set @cantidad_minutos = -30

	/*proceso realizado a empleados que no pertencen al grupo de administración*/
	if (@administracion = 0)
	begin
		/*extraer listado de todos los empleados que no pertenecen a administración*/
		select grupo.id as id_grupo, 
		grupo.nombre as nombre_grupo, 
		empleado.id as id_empleado, 
		empleado.nombre as nombre_empleado, 
		empleado.cc as identificacion into #empleados
		from empleado, grupo
		where grupo.id = empleado.id_grupo
		and not exists
		(select * from grupo, dependencia_grupo, dependencia
		where empleado.id_grupo = grupo.id
		and grupo.id = dependencia_grupo.id_grupo
		and dependencia.id_dependencia = dependencia_grupo.id_dependencia
		and dependencia.nombre_dependencia = @nombre_dependencia)
		and not exists
		(
		select * from grupo as g1
		where g1.nombre = 'Coltrack'
		and g1.id = grupo.id
		)
		and grupo.id like @id_grupo

		/*alterar tabla temporal para la inclusión de nuevos datos*/
		alter table #empleados
		add  entrada_real datetime, 
		salida_real datetime, 
		entrada_asignada datetime, 
		salida_asignada datetime, 
		biometrico nvarchar(255), 
		id_biometrico int,
		novedad nvarchar(255) 

		/*adicionar la entrada asignada a los empleados que tiene atado el turno diurno*/
		update  #empleados
		set entrada_asignada = convert(datetime,convert(nvarchar,@fecha,101)+space(1)+@hora_inicio_diurno)
		from asignacionturno, horario, empleado
		where asignacionturno.id_horario = horario.id
		and horario.horaini = @hora_inicio_diurno
		and asignacionturno.id_empleado = empleado.id
		and #empleados.id_empleado = empleado.id
		
		/*seleccionar las marcaciones de entrada de los empleados para la fecha indicada*/
		select empleado.id as id_empleado, 
		min(FechaHora) as entrada_real, 
		id_biometrico into #entrada_real
		from empleado, historial
		where empleado.id = historial.id_empleado
		and historial.tipo = 1
		and convert(nvarchar,FechaHora,101) = convert(nvarchar,@fecha,101)
		group by empleado.id, id_biometrico

		/*seleccionar las marcaciones de salida de los empleados y el lector sobre el cual realizaron la marcación en la fecha indicada*/
		select empleado.id as id_empleado, 
		max(FechaHora) as salida_real, 
		id_biometrico into #salida_real
		from empleado, historial
		where empleado.id = historial.id_empleado
		and historial.tipo = 2
		and convert(nvarchar,FechaHora,101) = convert(nvarchar,@fecha,101)
		group by empleado.id, id_biometrico

		/*adicionar la entrada real a la tabla temporal*/
		update #empleados
		set entrada_real = #entrada_real.entrada_real
		from #entrada_real
		where #entrada_real.id_empleado = #empleados.id_empleado

		/*adicionar la salida real y el lector donde se hizo la lectura a la tabla temporal*/
		update #empleados
		set salida_real = #salida_real.salida_real,
		id_biometrico = #salida_real.id_biometrico
		from #salida_real
		where #salida_real.id_empleado = #empleados.id_empleado

		/*adionar la descripcion del lector biometrico a la tabla temporal*/
		update #empleados
		set biometrico = biometrico.descripcion
		from biometrico
		where biometrico.id = #empleados.id_biometrico

		/*cuando el empleado no haya realizado la marcación de salida para la fecha solicitada se colocará la palabra "Sin datos"*/
		update #empleados
		set biometrico = 'Sin datos'
		where biometrico is null

		/*seleccionar las salidas por area o especificas que tenga el empleado*/
		select empleado.id as id_empleado, salida_especifica.fecha_hora as salida_asignada into #salida_asignada
		from salida_general, salida_especifica, empleado
		where salida_general.id_salida_general = salida_especifica.id_salida_general
		and salida_especifica.id_empleado = empleado.id
		and convert(nvarchar,salida_general.fecha_hora,101) = convert(nvarchar,@fecha,101)
		union
		select empleado.id, salida_general_area.fecha_hora
		from salida_general, salida_general_area, salida_especifica_salida_general_area, empleado
		where salida_general.id_salida_general = salida_general_area.id_salida_general
		and salida_general_area.id_salida_general_area = salida_especifica_salida_general_area.id_salida_general_area
		and salida_especifica_salida_general_area.id_empleado = empleado.id
		and convert(nvarchar,salida_general.fecha_hora,101) = convert(nvarchar,@fecha,101)

		/*adicionar a la tabla temporal la salida por area o especifica de cada uno de los empleados*/
		update #empleados
		set salida_asignada = #salida_asignada.salida_asignada
		from #salida_asignada
		where #salida_asignada.id_empleado = #empleados.id_empleado

		/*adicionar la salida general a los empleados que no tenían salida por área o específica*/
		update #empleados
		set salida_asignada = salida_general.fecha_hora
		from salida_general
		where salida_asignada is null
		and convert(nvarchar,salida_general.fecha_hora,101) = convert(nvarchar,@fecha,101)

		/*borrar los empleados para los cuales la marcación de salida Vs la salida aprobada no supera la cantidad de minutos parametrizados en la base de datos*/
		delete from #empleados 
		where (DATEDIFF("mi", salida_asignada,salida_real) < = (select cantidad_minutos_gracia from configuracion_bd)
		and DATEDIFF("mi", salida_asignada,salida_real) > = (select (cantidad_minutos_gracia)*-1 from configuracion_bd))
		and salida_real is not null

		/*seleccionar las marcaciones de entrada de los empleados que tienen atado el turno nocturno*/
		/*y que su marcación real de entrada esta entre el estipulado en el turno y la cantidad de minutos*/
		/*definidos en la variable @cantidad_minutos definida e inicializada al inicio de este procedimiento*/
		select historial.id as id_historial, empleado.id as id_empleado, historial.FechaHora as entrada_real into #salidas_nocturnas
		from asignacionturno, horario, empleado, historial
		where asignacionturno.id_horario = horario.id
		and horario.horaini = @hora_inicio_nocturna
		and asignacionturno.id_empleado = empleado.id
		and historial.id_empleado = empleado.id
		and historial.tipo = 1
		and convert(nvarchar,historial.FechaHora,101) = convert(nvarchar,@fecha,101)
		and historial.FechaHora > = dateadd(mi, @cantidad_minutos, convert(datetime,convert(nvarchar,@fecha,101)+space(1)+@hora_inicio_nocturna))

		/*adicionar la entrada asignada, entrada real y salida_asignada a los empleados que tienen atado el turno nocturno*/
		/*y que tienen marcaciones en éste, tomando siempre como día de salida asignada del turno, un día después de la fecha*/
		/*de la salida general almacenada en la variable @fecha, definida e inicializada al inicio del procedimiento*/
		update  #empleados
		set entrada_asignada = convert(datetime,convert(nvarchar,@fecha,101)+space(1)+@hora_inicio_nocturna),
		entrada_real = #salidas_nocturnas.entrada_real,
		salida_asignada = convert(datetime,convert(nvarchar,@fecha + 1,101)+space(1)+@hora_fin_nocturna) 
		from #salidas_nocturnas
		where #empleados.id_empleado = #salidas_nocturnas.id_empleado

		/*seleccionar las marcaciones de salida para los empleados que tienen el turno de noche*/
		select historial.id_empleado, min(historial.id) as id_historial, min(historial.FechaHora) as fecha_hora  into #salidas_definitivas
		from historial, #salidas_nocturnas
		where historial.id_empleado = #salidas_nocturnas.id_empleado
		and historial.id > #salidas_nocturnas.id_historial
		group by historial.id_empleado
		order by historial.id_empleado

		/*adicionar a tabla temporal las marcaciones de salida de los empleados con turno nocturno*/
		update #empleados
		set salida_real = #salidas_definitivas.fecha_hora
		from #salidas_definitivas
		where #empleados.id_empleado = #salidas_definitivas.id_empleado

		update #empleados
		set novedad = novedad.descripcion
		from novedad
		where #empleados.id_empleado = novedad.id_empleado
		and convert(datetime,convert(nvarchar,@fecha,101)) between
		Fecha_Ini and Fecha_Fin

		/*datos enviados a pantalla*/
		select id_grupo, 
		nombre_grupo, 
		id_empleado, 
		nombre_empleado, 
		identificacion, 
		entrada_real,
		entrada_asignada,
		'entrada_nomina' =
		case 
			when entrada_real is null then null
			when entrada_real >= entrada_asignada then entrada_real
			else entrada_asignada
		end,
		salida_real, 
		salida_asignada, 
		'salida_nomina' =
		case 
			when salida_real is null then null
			when salida_real <= salida_asignada then salida_real
			else salida_asignada
		end,
		dbo.datediffToWords((
		case 
			when entrada_real is null then null
			when entrada_real >= entrada_asignada then entrada_real
			else entrada_asignada
		end),
		(case 
			when salida_real is null then null
			when salida_real <= salida_asignada then dateadd(mi, -30, salida_real)
			else dateadd(mi, -30, salida_asignada)
		end)) as horas_nomina,
		dbo.datediffToWords(entrada_real,dateadd(mi, -30, salida_real)) as horas_cultivo,
		biometrico,
		isnull(convert(nvarchar,DATEDIFF("mi", salida_asignada,salida_real)),'Sin datos') as minutos_diferencia,
		convert(int,convert(nvarchar,DATEDIFF("mi", salida_asignada,salida_real))) as minutos_diferencia_ordenamiento,
		novedad into #empleados_final
		from #empleados
		order by nombre_grupo, minutos_diferencia

		select * from #empleados_final

		insert into Salida_General_Historial_Reporte_Autorizacion_Horas_Extras 
		(administracion,
		id_salida_general,
		id_grupo, 
		nombre_grupo, 
		id_empleado, 
		nombre_empleado, 
		identificacion, 
		entrada_real,
		entrada_asignada,
		entrada_nomina,
		salida_real, 
		salida_asignada, 
		salida_nomina,
		horas_nomina,
		horas_cultivo,
		biometrico,
		minutos_diferencia,
		minutos_diferencia_ordenamiento,
		novedad)
		select @administracion,
		@id_salida_general,
		id_grupo, 
		nombre_grupo, 
		id_empleado, 
		nombre_empleado, 
		identificacion, 
		entrada_real,
		entrada_asignada,
		entrada_nomina,
		salida_real, 
		salida_asignada, 
		salida_nomina,
		horas_nomina,
		horas_cultivo,
		biometrico,
		minutos_diferencia,
		minutos_diferencia_ordenamiento,
		novedad 
		from #empleados_final

		/*eliminación tablas temporales*/
		drop table #salida_real
		drop table #salida_asignada
		drop table #empleados
		drop table #empleados_final
		drop table #salidas_nocturnas
		drop table #salidas_definitivas
	end
	else
	begin
		select grupo.id as id_grupo, 
		grupo.nombre as nombre_grupo, 
		empleado.id as id_empleado, 
		empleado.nombre as nombre_empleado, 
		empleado.cc as identificacion into #empleados_admin
		from empleado, grupo
		where grupo.id = empleado.id_grupo
		and exists
		(select * from grupo, dependencia_grupo, dependencia
		where empleado.id_grupo = grupo.id
		and grupo.id = dependencia_grupo.id_grupo
		and dependencia.id_dependencia = dependencia_grupo.id_dependencia
		and dependencia.nombre_dependencia = @nombre_dependencia)

		alter table #empleados_admin
		add entrada_real datetime, salida_real datetime, biometrico nvarchar(255), id_biometrico int

		select empleado.id as id_empleado, min(FechaHora) as entrada_real, id_biometrico into #entrada_real_admin
		from empleado, historial
		where empleado.id = historial.id_empleado
		and historial.tipo = 1
		and convert(nvarchar,FechaHora,101) = convert(nvarchar,@fecha,101)
		group by empleado.id, id_biometrico

		select empleado.id as id_empleado, max(FechaHora) as salida_real, id_biometrico into #salida_real_admin
		from empleado, historial
		where empleado.id = historial.id_empleado
		and historial.tipo = 2
		and convert(nvarchar,FechaHora,101) = convert(nvarchar,@fecha,101)
		group by empleado.id, id_biometrico

		update #empleados_admin
		set entrada_real = #entrada_real_admin.entrada_real
		from #entrada_real_admin
		where #entrada_real_admin.id_empleado = #empleados_admin.id_empleado

		update #empleados_admin
		set salida_real = #salida_real_admin.salida_real,
		id_biometrico = #salida_real_admin.id_biometrico
		from #salida_real_admin
		where #salida_real_admin.id_empleado = #empleados_admin.id_empleado

		update #empleados_admin
		set biometrico = biometrico.descripcion
		from biometrico
		where #empleados_admin.id_biometrico = biometrico.id

		update #empleados_admin
		set biometrico = 'Sin datos'
		where biometrico is null

		select id_grupo, 
		nombre_grupo, 
		id_empleado, 
		nombre_empleado, 
		identificacion, 
		entrada_real, 
		salida_real, 
		biometrico,
		'horas_trabajadas' =
		case 
			when (entrada_real is null and salida_real is null) then 'Inasistencia'
			when salida_real is null then 'Sin datos'
			else dbo.datediffToWords(entrada_real,dateadd(mi, -30, salida_real))
		end,
		'salida_aprobada' =
		case
			when datepart(dw,@fecha) = 7 then
		(case 
			when convert(nvarchar,DATEDIFF("mi", entrada_real,salida_real)) >= 270 then 'OK'
			when convert(nvarchar,DATEDIFF("mi", entrada_real,salida_real)) < 270 then ''
			when convert(nvarchar,DATEDIFF("mi", entrada_real,salida_real)) is null then ''
			else ''
		end)
		else
		(case 
			when convert(nvarchar,DATEDIFF("mi", entrada_real,salida_real)) >= 510 then 'OK'
			when convert(nvarchar,DATEDIFF("mi", entrada_real,salida_real)) < 510 then ''
			when convert(nvarchar,DATEDIFF("mi", entrada_real,salida_real)) is null then ''
			else ''
		end)
		end into #empleados_admin_final
		from #empleados_admin
		order by nombre_grupo, nombre_empleado

		select * from #empleados_admin_final

		insert into Salida_General_Historial_Reporte_Autorizacion_Horas_Extras 
		(administracion,
		id_salida_general,
		id_grupo, 
		nombre_grupo, 
		id_empleado, 
		nombre_empleado, 
		identificacion, 
		entrada_real,
		salida_real, 
		biometrico,
		horas_trabajadas,
		salida_aprobada)
		select @administracion,
		@id_salida_general,
		id_grupo, 
		nombre_grupo, 
		id_empleado, 
		nombre_empleado, 
		identificacion, 
		entrada_real,
		salida_real, 
		biometrico,
		horas_trabajadas,
		salida_aprobada 
		from #empleados_admin_final

		drop table #entrada_real_admin		
		drop table #salida_real_admin
		drop table #empleados_admin
		drop table #empleados_admin_final
	end
end
else
if(@accion = 'consultar_detalle_reporte')
begin
	if(@administracion = 0)
	begin
		select salida_general_historial_reporte_autorizacion_horas_extras.administracion,
		salida_general_historial_reporte_autorizacion_horas_extras.id_salida_general,
		salida_general_historial_reporte_autorizacion_horas_extras.id_grupo, 
		salida_general_historial_reporte_autorizacion_horas_extras.nombre_grupo, 
		salida_general_historial_reporte_autorizacion_horas_extras.id_empleado, 
		salida_general_historial_reporte_autorizacion_horas_extras.nombre_empleado, 
		salida_general_historial_reporte_autorizacion_horas_extras.identificacion, 
		salida_general_historial_reporte_autorizacion_horas_extras.entrada_real,
		salida_general_historial_reporte_autorizacion_horas_extras.entrada_asignada,
		salida_general_historial_reporte_autorizacion_horas_extras.entrada_nomina,
		salida_general_historial_reporte_autorizacion_horas_extras.salida_real, 
		salida_general_historial_reporte_autorizacion_horas_extras.salida_asignada, 
		salida_general_historial_reporte_autorizacion_horas_extras.salida_nomina,
		salida_general_historial_reporte_autorizacion_horas_extras.horas_nomina,
		salida_general_historial_reporte_autorizacion_horas_extras.horas_cultivo,
		salida_general_historial_reporte_autorizacion_horas_extras.biometrico,
		salida_general_historial_reporte_autorizacion_horas_extras.minutos_diferencia,
		salida_general_historial_reporte_autorizacion_horas_extras.minutos_diferencia_ordenamiento,
		salida_general_historial_reporte_autorizacion_horas_extras.novedad
		from salida_general_historial_reporte_autorizacion_horas_extras,
		salida_general
		where salida_general_historial_reporte_autorizacion_horas_extras.id_salida_general = salida_general.id_salida_general
		and convert(nvarchar,salida_general.fecha_hora,101) = convert(nvarchar,@fecha_hora_anterior,101)
		and administracion = @administracion
		order by salida_general_historial_reporte_autorizacion_horas_extras.nombre_grupo, 
		salida_general_historial_reporte_autorizacion_horas_extras.nombre_empleado
	end
	else
	begin
		select salida_general_historial_reporte_autorizacion_horas_extras.administracion,
		salida_general_historial_reporte_autorizacion_horas_extras.id_salida_general,
		salida_general_historial_reporte_autorizacion_horas_extras.id_grupo, 
		salida_general_historial_reporte_autorizacion_horas_extras.nombre_grupo, 
		salida_general_historial_reporte_autorizacion_horas_extras.id_empleado, 
		salida_general_historial_reporte_autorizacion_horas_extras.nombre_empleado, 
		salida_general_historial_reporte_autorizacion_horas_extras.identificacion, 
		salida_general_historial_reporte_autorizacion_horas_extras.entrada_real,
		salida_general_historial_reporte_autorizacion_horas_extras.salida_real, 
		salida_general_historial_reporte_autorizacion_horas_extras.biometrico,
		salida_general_historial_reporte_autorizacion_horas_extras.horas_trabajadas,
		salida_general_historial_reporte_autorizacion_horas_extras.salida_aprobada
		from salida_general_historial_reporte_autorizacion_horas_extras,
		salida_general
		where salida_general_historial_reporte_autorizacion_horas_extras.id_salida_general = salida_general.id_salida_general
		and convert(nvarchar,salida_general.fecha_hora,101) = convert(nvarchar,@fecha_hora_anterior,101)
		and administracion = @administracion
		order by salida_general_historial_reporte_autorizacion_horas_extras.nombre_grupo, 
		salida_general_historial_reporte_autorizacion_horas_extras.nombre_empleado
	end
end
else
if(@accion = 'modificar_minutos_gracia')
begin
	update configuracion_bd
	set cantidad_minutos_gracia = @cantidad_minutos_gracia
end
else
if(@accion = 'consultar_minutos_gracia')
begin
	select isnull(cantidad_minutos_gracia, 0) as cantidad_minutos_gracia from configuracion_bd
end
else
if(@accion = 'modificar_horas')
begin
	declare @id_historial int

	select @id_historial = id from historial
	where id_empleado = @id_empleado
	and fechahora = @fecha_hora_anterior

	insert into historial_original (id_historial, nombre_empleado, nombre_biometrico, fechahora, tipo)
	select historial.id, empleado.nombre, biometrico.descripcion, historial.fechahora, historial.tipo
	from historial, empleado, biometrico
	where historial.id = @id_historial
	and empleado.id = historial.id_empleado
	and biometrico.id = historial.id_biometrico

	update historial
	set id_biometrico = -1,
	fechaHora = @fecha_hora_modificada
	where id = @id_historial
end
else
if(@accion = 'modificar_horas_admon')
begin
	insert into historial_original (id_historial, nombre_empleado, nombre_biometrico, fechahora, tipo)
	select historial.id, empleado.nombre, historial.id_biometrico, historial.fechahora, historial.tipo
	from historial , empleado
	where historial.id_empleado = @id_empleado
	and convert(nvarchar, fechahora,101) = convert(nvarchar, @fecha_hora_anterior, 101)
	and historial.id_empleado = empleado.id

	delete from historial
	where historial.id_empleado = @id_empleado
	and convert(nvarchar, fechahora,101) = convert(nvarchar, @fecha_hora_anterior, 101)

	insert into historial (id_empleado, id_biometrico, FechaHora, tipo)
	values (@id_empleado, -1, convert(datetime, convert(nvarchar, @fecha_hora_anterior,101)+space(1)+'06:30'), 1)

	if(datepart(dw, @fecha_hora_anterior) <> 7)
	begin
		insert into historial (id_empleado, id_biometrico, FechaHora, tipo)
		values (@id_empleado, -1, convert(datetime, convert(nvarchar, @fecha_hora_anterior,101)+space(1)+'15:30'), 2)
	end
	else
	if(datepart(dw, @fecha_hora_anterior) = 7)
	begin
		insert into historial (id_empleado, id_biometrico, FechaHora, tipo)
		values (@id_empleado, -1, convert(datetime, convert(nvarchar, @fecha_hora_anterior,101)+space(1)+'12:00'), 2)
	end
end
else
if(@accion = 'consultar_grupo')
begin
	select 'id_grupo' =
	case
		when dependencia_grupo.id_grupo is null then grupo.id
		else 0
	end,
	'nombre_grupo' =
	case
		when dependencia_grupo.id_grupo is null then grupo.nombre
		else 'Administración'
	end into #grupos
	from grupo left join dependencia_grupo
	on grupo.id = dependencia_grupo.id_grupo
	and not exists
	(
	select * from grupo as g1
	where g1.nombre = 'Coltrack'
	and g1.id = grupo.id
	)

	select id_grupo, nombre_grupo 
	from #grupos
	where not exists
	(
	select * 
	from salida_general_procesada, salida_general, tipo_proceso
	where salida_general_procesada.id_salida_general = salida_general.id_salida_general
	and salida_general.id_salida_general = @id_salida_general
	and salida_general_procesada.id_tipo_proceso = tipo_proceso.id_tipo_proceso
	and tipo_proceso.nombre_tipo_proceso = 'modificar_horas'
	and #grupos.id_grupo = salida_general_procesada.id_grupo
	)
	group by id_grupo, nombre_grupo 
	order by nombre_grupo 
end
if(@accion = 'consultar')
begin

declare @fecha_inicial datetime,
@count int

set @count = 1

set @fecha_inicial = convert(nvarchar,getdate(),101)
set @fecha_inicial = @fecha_inicial - @count
while (@fecha_inicial in (select convert(nvarchar,fecha,101) from dia_no_laboral) or datepart(dw,@fecha_inicial) = 1)
	set @fecha_inicial = @fecha_inicial - @count

	select id_salida_general, 
	fecha_hora
	from salida_general
	where exists
	(select * 
	from salida_general_procesada, 
	tipo_proceso
	where salida_general_procesada.id_salida_general = salida_general.id_salida_general
	and salida_general_procesada.id_tipo_proceso = tipo_proceso.id_tipo_proceso
	and tipo_proceso.nombre_tipo_proceso = 'asignar_salidas'
	)
	and not exists
	(select * 
	from salida_general_procesada, 
	tipo_proceso
	where salida_general_procesada.id_salida_general = salida_general.id_salida_general
	and salida_general_procesada.id_tipo_proceso = tipo_proceso.id_tipo_proceso
	and tipo_proceso.nombre_tipo_proceso = 'procesar_dia'
	)
	and convert(nvarchar,fecha_hora,101) between 
	@fecha_inicial and convert(nvarchar,getdate(),101)
	order by fecha_hora
end