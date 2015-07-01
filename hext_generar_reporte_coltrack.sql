set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[hext_generar_reporte_coltrack]

@fecha_inicial datetime,
@fecha_final datetime,
@accion nvarchar(255)

AS
if(@accion = 'generar_reporte')
begin
	select empleado.nombre, 
	empleado.cc as identificacion,
	convert(nvarchar,historial.fechahora,101) as fecha into #temp
	from empleado, 
	grupo, 
	historial
	where empleado.id_grupo = grupo.id
	and grupo.nombre = 'Coltrack'
	and empleado.id = historial.id_empleado
	and convert(datetime,convert(nvarchar,historial.fechahora,101)) between
	convert(datetime,convert(nvarchar,@fecha_inicial,101)) and convert(datetime,convert(nvarchar,@fecha_final,101))
	group by empleado.nombre, 
	empleado.cc,
	historial.fechahora
	order by empleado.nombre, 
	empleado.cc,
	historial.fechahora

	select nombre,identificacion,fecha into #temp2
	from #temp
	group by nombre,identificacion,fecha
	order by nombre,identificacion,convert(datetime,fecha)

	select empleado.nombre, 
	empleado.cc as identificacion,
	convert(nvarchar,historial.fechahora,101) as fecha,
	'hora' =
	case 
		when historial.id_biometrico = '0' then '**'+'['+replace(replace(replace(historial.tipo,'1','Ent:'),'2','Sal:'),'0','No Proc:') + left(convert(nvarchar,historial.fechahora,108),5)+']'
		else '['+replace(replace(replace(historial.tipo,'1','Ent:'),'2','Sal:'),'0','No Proc:') + left(convert(nvarchar,historial.fechahora,108),5)+']'
	end into #temp3
	from empleado, 
	grupo, 
	historial
	where empleado.id_grupo = grupo.id
	and grupo.nombre = 'Coltrack'
	and empleado.id = historial.id_empleado
	and convert(datetime,convert(nvarchar,historial.fechahora,101)) between
	convert(datetime,convert(nvarchar,@fecha_inicial,101)) and convert(datetime,convert(nvarchar,@fecha_final,101))
	group by empleado.nombre, 
	empleado.cc,
	historial.fechahora,
	historial.tipo,
	historial.id_biometrico
	order by empleado.nombre, 
	empleado.cc,
	historial.fechahora

	alter table #temp2
	add marcaciones nvarchar(255)

	DECLARE @identificacion nvarchar(255), @fecha nvarchar(255), @hora nvarchar(255)
	DECLARE marcaciones_cursor CURSOR FOR 
	SELECT identificacion, fecha, hora FROM #temp3
	OPEN marcaciones_cursor
	FETCH NEXT FROM marcaciones_cursor
	INTO @identificacion, @fecha, @hora
	WHILE @@FETCH_STATUS = 0
	BEGIN
		update #temp2
		set marcaciones = isnull(marcaciones,'') + space(2) + @hora
		where identificacion = @identificacion
		and fecha = @fecha

	FETCH NEXT FROM marcaciones_cursor 
	INTO @identificacion, @fecha, @hora
	END 
	CLOSE marcaciones_cursor
	DEALLOCATE marcaciones_cursor

	select nombre,
	identificacion,
	datename(dw,fecha) + space(1) + fecha as fecha,
	ltrim(rtrim(marcaciones)) as marcaciones 
	from #temp2

	drop table #temp
	drop table #temp2
	drop table #temp3
end
else
if(@accion = 'consultar_fechas')
begin
	declare @fecha_actual datetime

	set @fecha_actual = getdate()

	if(DAY(@fecha_actual) > 1 and DAY(@fecha_actual) < =16)
	begin
		set @fecha_inicial = convert(nvarchar, dateadd(dd, -DAY(@fecha_actual-1), @fecha_actual),101)
		set @fecha_final = convert(nvarchar, @fecha_actual-1,101)
		select convert(nvarchar,@fecha_inicial,101) as fecha_inicial_reporte, 
		convert(nvarchar,@fecha_final,101) as fecha_final_reporte
	end 
	else
	if(DAY(@fecha_actual) = 1)
	begin
		set @fecha_inicial =convert(nvarchar, dateadd(dd, -day(dateadd(dd, - 16, @fecha_actual)) , @fecha_actual),101)
		set @fecha_final = convert(nvarchar, @fecha_actual - 1,101)
		select convert(nvarchar,@fecha_inicial,101) as fecha_inicial_reporte, 
		convert(nvarchar,@fecha_final,101) as fecha_final_reporte
	end
	else
	begin
		set @fecha_inicial =convert(nvarchar, dateadd(dd, -day(dateadd(dd, - 16, @fecha_actual)) , @fecha_actual),101)
		set @fecha_final = convert(nvarchar, @fecha_actual - 1,101)
		select convert(nvarchar,@fecha_inicial,101) as fecha_inicial_reporte, 
		convert(nvarchar,@fecha_final,101) as fecha_final_reporte
	end
end

