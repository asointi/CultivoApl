set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 2010/04/28
-- =============================================
alter PROCEDURE [dbo].[prod_editar_maxipuntos] 

@fecha_inicial datetime,
@fecha datetime,
@accion nvarchar(255),
@id_cuenta_interna int, 
@id_persona int, 
@cantidad_puntos int, 
@descripcion nvarchar(512),
@id_tipo_transaccion_maxipunto int
	
AS

declare @fecha_aux datetime,
@conteo int,
@id_persona1 int,
@id_persona_aux int,
@id int,
@valor_rendimiento int,
@factor decimal(20,4)

set @valor_rendimiento = 15
set @factor = 1.25

if(@accion = 'consultar_maxipuntos')
begin
	select p.id_persona into #persona
	from detalle_labor as dl, 
	detalle_labor_persona as dlp, 
	persona as p
	where dl.id_detalle_labor = dlp.id_detalle_labor
	and dlp.id_persona = p.id_persona
	and dl.idc_detalle_labor = 'CLASRO'
	and convert(datetime, convert(nvarchar, dlp.fecha,101)) = @fecha
	group by p.id_persona 

	create table #temp
	(id int identity(1,1),
	id_persona int,
	idc_persona nvarchar(25),
	identificacion nvarchar(25),
	nombre nvarchar(100),
	id_labor int,
	idc_labor nvarchar(25),
	nombre_labor nvarchar(50),
	id_detalle_labor int,
	idc_detalle_labor nvarchar(25),
	nombre_detalle_labor nvarchar(50),
	id_detalle_labor_persona int,
	fecha datetime,
	comentario nvarchar(512)
	)

	CREATE INDEX Id_persona_index 
    ON #temp (id_persona) 

	CREATE INDEX Idc_detalle_labor_index 
    ON #temp (idc_detalle_labor) 

	insert into #temp 
	select persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) as nombre,
	labor.id_labor,
	labor.idc_labor,
	labor.nombre_labor,
	detalle_labor.id_detalle_labor,
	detalle_labor.idc_detalle_labor,
	detalle_labor.nombre_detalle_labor,
	detalle_labor_persona.id_detalle_labor_persona,
	detalle_labor_persona.fecha,
	detalle_labor_persona.comentario
	from labor, 
	detalle_labor, 
	detalle_labor_persona, 
	persona
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
	and detalle_labor_persona.id_persona = persona.id_persona
	and exists
	(
		select *
		from #persona
		where #persona.id_persona = persona.id_persona
	)
	and convert(datetime, convert(nvarchar, detalle_labor_persona.fecha,101)) = @fecha
	order by persona.idc_persona, detalle_labor_persona.fecha, detalle_labor.idc_detalle_labor

	alter table #temp
	add tiempo int,
	cantidad_ramos int,
	cantidad_ramos_despate int,
	devoluciones int

	select @id = max(id) from #temp
	set @conteo = 1

	while(@conteo < = @id)
	begin
		select @id_persona1 = id_persona from #temp where id = @conteo
		select @id_persona_aux = id_persona from #temp where id = @conteo + 1

		select @fecha_aux = fecha 
		from #temp where id = @conteo + 1 
		and @id_persona1 = @id_persona_aux

		update #temp
		set tiempo = datediff(mi, fecha, @fecha_aux)
		where id = @conteo

		set @conteo = @conteo + 1
	end

	select ramo.id_persona, 
	(sum(ramo.tallos_por_ramo)/25) as cantidad_ramos into #union_ramos
	from ramo
	where convert(datetime, convert(nvarchar, ramo.fecha_entrada,101)) = @fecha
	and (id_punto_corte <> 1 and id_punto_corte <> 4)
	group by ramo.id_persona
	union all
	select ramo.id_persona, 
	((sum(ramo.tallos_por_ramo) * @factor) /25) as cantidad_ramos
	from ramo
	where convert(datetime, convert(nvarchar, ramo.fecha_entrada,101)) = @fecha
	and (id_punto_corte = 1 or id_punto_corte = 4)
	group by ramo.id_persona
	union all
	select ramo_comprado.id_persona, 
	(sum(ramo_comprado.tallos_por_ramo)/25) as cantidad_ramos
	from ramo_comprado
	where convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura,101)) = @fecha
	and (id_punto_corte <> 1 and id_punto_corte <> 4)
	group by ramo_comprado.id_persona
	union all
	select ramo_comprado.id_persona, 
	((sum(ramo_comprado.tallos_por_ramo) * @factor) /25) as cantidad_ramos
	from ramo_comprado
	where convert(datetime, convert(nvarchar, ramo_comprado.fecha_lectura,101)) = @fecha
	and (id_punto_corte = 1 or id_punto_corte = 4)
	group by ramo_comprado.id_persona

	select id_persona,
	sum(cantidad_ramos) as cantidad_ramos into #temp2
	from #union_ramos
	group by id_persona

	select ramo_despatado.id_persona, 
	(sum(ramo_despatado.tallos_por_ramo)/25) as cantidad_ramos into #devolucion
	from ramo_despatado
	where convert(datetime, convert(nvarchar, ramo_despatado.fecha_lectura,101)) = @fecha
	group by ramo_despatado.id_persona

	update #temp 
	set tiempo = 0
	where left(tiempo, 1) = '-'

	update #temp 
	set tiempo = datediff(mi, #temp.fecha, getdate())
	where #temp.tiempo = 0
	and #temp.idc_detalle_labor = 'CLASRO'
	and convert(datetime, convert(nvarchar, #temp.fecha,101)) = @fecha

	update #temp
	set cantidad_ramos = #temp2.cantidad_ramos
	from #temp2
	where #temp.id_persona = #temp2.id_persona

	update #temp
	set devoluciones = #devolucion.cantidad_ramos - #temp.cantidad_ramos,
	cantidad_ramos_despate =  #devolucion.cantidad_ramos
	from #devolucion
	where #temp.id_persona = #devolucion.id_persona

	select id_persona,
	idc_persona,
	identificacion,
	nombre,
	convert(int,floor(max(cantidad_ramos)/(convert(decimal(20,4),sum(tiempo))/60))) as rendimiento,
	max(cantidad_ramos) as cantidad_ramos,
	convert(int,floor(max(cantidad_ramos) -  (convert(decimal(20,4),sum(tiempo))/60 * @valor_rendimiento))) as maxipuntos,
	convert(decimal(20,2),(sum(tiempo)/convert(decimal(20,2),60))) as tiempo_labor,
	(
		select tipo_transaccion_maxipunto.nombre_transaccion + space(1) + convert(nvarchar,@fecha, 101) + '. Rendimiento: ' + convert(nvarchar,convert(int,floor(max(cantidad_ramos)/(convert(decimal(20,4),sum(tiempo))/60))))
		from tipo_transaccion_maxipunto
		where tipo_transaccion_maxipunto.id_tipo_transaccion_maxipunto = 1
	) as observacion,
	max(devoluciones) as devoluciones,
	max(cantidad_ramos_despate) as cantidad_ramos_despate,
	convert(bit, case
	when
		(
			select count(*)
			from historial_maxipunto
			where historial_maxipunto.id_persona = #temp.id_persona
			and historial_maxipunto.cantidad_puntos = max(#temp.cantidad_ramos)
			and historial_maxipunto.fecha_aplicacion = @fecha
			and historial_maxipunto.descripcion = 		
			(
				select tipo_transaccion_maxipunto.nombre_transaccion + space(1) + convert(nvarchar,@fecha, 101) + '. Rendimiento: ' + convert(nvarchar,convert(int,floor(max(cantidad_ramos)/(convert(decimal(20,4),sum(tiempo))/60))))
				from tipo_transaccion_maxipunto
				where tipo_transaccion_maxipunto.id_tipo_transaccion_maxipunto = 1
			)
		) = 0 then 1
	else 0
	end) as sin_grabar into #resultado
	from #temp 
	where idc_detalle_labor = 'CLASRO'
	and (cantidad_ramos is not null
	or cantidad_ramos <> 0)
	group by id_persona,
	idc_persona,
	identificacion,
	nombre
	having sum(tiempo) <> 0
	and convert(int,floor(max(cantidad_ramos)/(convert(decimal(20,4),sum(tiempo))/60))) > = @valor_rendimiento
	order by rendimiento desc

	select *
	from #resultado
	where maxipuntos > 0

	drop table #temp
	drop table #persona
	drop table #temp2
	drop table #devolucion
	drop table #union_ramos
	drop table #resultado
end
else
if(@accion = 'consultar_detalle_tiempo')
begin
	select p.id_persona into #persona1
	from detalle_labor as dl, 
	detalle_labor_persona as dlp, 
	persona as p
	where dl.id_detalle_labor = dlp.id_detalle_labor
	and dlp.id_persona = p.id_persona
	and dl.idc_detalle_labor = 'CLASRO'
	and convert(datetime, convert(nvarchar, dlp.fecha,101)) = @fecha
	group by p.id_persona 

	create table #tiempo
	(id int identity(1,1),
	id_persona int,
	idc_persona nvarchar(25),
	idc_detalle_labor nvarchar(25),
	fecha datetime
	)

	CREATE INDEX Id_persona_index 
    ON #tiempo (id_persona) 

	CREATE INDEX Idc_detalle_labor_index 
    ON #tiempo (idc_detalle_labor) 

	insert into #tiempo 
	select persona.id_persona,
	persona.idc_persona,
	detalle_labor.idc_detalle_labor,
	detalle_labor_persona.fecha
	from labor, 
	detalle_labor, 
	detalle_labor_persona, 
	persona
	where labor.id_labor = detalle_labor.id_labor
	and detalle_labor.id_detalle_labor = detalle_labor_persona.id_detalle_labor
	and detalle_labor_persona.id_persona = persona.id_persona
	and persona.id_persona = @id_persona
	and exists
	(
		select *
		from #persona1
		where #persona1.id_persona = persona.id_persona
	)
	and convert(datetime, convert(nvarchar, detalle_labor_persona.fecha,101)) = @fecha
	order by persona.idc_persona, 
	detalle_labor_persona.fecha, 
	detalle_labor.idc_detalle_labor

	alter table #tiempo
	add tiempo int,
	hora_final datetime

	select @id = max(id) from #tiempo
	set @conteo = 1

	while(@conteo < = @id)
	begin
		select @id_persona1 = id_persona from #tiempo where id = @conteo
		select @id_persona_aux = id_persona from #tiempo where id = @conteo + 1

		select @fecha_aux = fecha 
		from #tiempo where id = @conteo + 1 
		and @id_persona1 = @id_persona_aux

		update #tiempo
		set tiempo = datediff(mi, fecha, @fecha_aux),
		hora_final = @fecha_aux
		where id = @conteo

		set @conteo = @conteo + 1
	end

	update #tiempo 
	set tiempo = datediff(mi, #tiempo.fecha, getdate()),
	hora_final = getdate()
	where #tiempo.tiempo = 0
	and #tiempo.idc_detalle_labor = 'CLASRO'
	and convert(datetime, convert(nvarchar, #tiempo.fecha,101)) = @fecha

	select convert(nvarchar,fecha, 8) as hora_inicio,
	convert(nvarchar,hora_final, 8) as hora_fin,
	convert(decimal(20,2), tiempo/convert(decimal(20,2),60)) as minutos
	from #tiempo
	where idc_detalle_labor = 'CLASRO'
	and id_persona = @id_persona
	order by fecha

	drop table #tiempo
	drop table #persona1
end
else
if(@accion = 'insertar_maxipuntos')
begin
	insert into historial_maxipunto (id_cuenta_interna, id_persona, cantidad_puntos, fecha_aplicacion, descripcion, id_tipo_transaccion_maxipunto)
	values (@id_cuenta_interna, @id_persona, @cantidad_puntos, @fecha, @descripcion, @id_tipo_transaccion_maxipunto)
end
else
if(@accion = 'Fecha Aplicación')
begin
	select ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.identificacion,
	persona.idc_persona,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor,
	historial_maxipunto.id_historial_maxipunto,
	historial_maxipunto.descripcion,
	historial_maxipunto.fecha_grabacion,
	historial_maxipunto.fecha_aplicacion,
	cuenta_interna.nombre as nombre_cuenta,
	historial_maxipunto.cantidad_puntos,
	tipo_transaccion_maxipunto.nombre_transaccion,
	case
		when historial_maxipunto.cantidad_puntos >= 0 then 1
		else 0
	end as tipo_transaccion,
	(	
		select sum(hm.cantidad_puntos) 
		from historial_maxipunto as hm
		where hm.id_historial_maxipunto < = historial_maxipunto.id_historial_maxipunto
		and hm.id_persona = historial_maxipunto.id_persona
		and hm.fecha_aplicacion between
		@fecha_inicial and @fecha
	) as subtotal,
	isnull((
		select sum(hm.cantidad_puntos)
		from historial_maxipunto as hm
		where persona.id_persona = hm.id_persona
		and  persona.id_persona LIKE 
		CASE 
			WHEN convert(nvarchar,@id_persona) = 0 THEN '%%' 
			ELSE convert(nvarchar,@id_persona)
		END
		and hm.fecha_aplicacion < @fecha_inicial
	), 0) as saldo_inicial
	from historial_maxipunto,
	persona,
	supervisor,
	cuenta_interna,
	tipo_transaccion_maxipunto
	where historial_maxipunto.id_persona = persona.id_persona
	and supervisor.id_supervisor = persona.id_supervisor
	and historial_maxipunto.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and  persona.id_persona LIKE 
	CASE 
		WHEN convert(nvarchar,@id_persona) = 0 THEN '%%' 
		ELSE convert(nvarchar,@id_persona)
	END	
	and historial_maxipunto.fecha_aplicacion between
	@fecha_inicial and @fecha
	and tipo_transaccion_maxipunto.id_tipo_transaccion_maxipunto = historial_maxipunto.id_tipo_transaccion_maxipunto
	order by persona.id_persona,
	historial_maxipunto.id_historial_maxipunto
end
else
if(@accion = 'Fecha Grabación')
begin
	select ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.identificacion,
	persona.idc_persona,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor,
	historial_maxipunto.id_historial_maxipunto,
	historial_maxipunto.descripcion,
	historial_maxipunto.fecha_grabacion,
	historial_maxipunto.fecha_aplicacion,
	cuenta_interna.nombre as nombre_cuenta,
	historial_maxipunto.cantidad_puntos,
	tipo_transaccion_maxipunto.nombre_transaccion,
	case
		when historial_maxipunto.cantidad_puntos >= 0 then 1
		else 0
	end as tipo_transaccion,
	(	
		select sum(hm.cantidad_puntos) 
		from historial_maxipunto as hm
		where hm.id_historial_maxipunto < = historial_maxipunto.id_historial_maxipunto
		and hm.id_persona = historial_maxipunto.id_persona
		and hm.fecha_grabacion between
		@fecha_inicial and @fecha
	) as subtotal,
	isnull((
		select sum(hm.cantidad_puntos)
		from historial_maxipunto as hm
		where persona.id_persona = hm.id_persona
		and  persona.id_persona LIKE 
		CASE 
			WHEN convert(nvarchar,@id_persona) = 0 THEN '%%' 
			ELSE convert(nvarchar,@id_persona)
		END
		and hm.fecha_grabacion < @fecha_inicial
	), 0) as saldo_inicial
	from historial_maxipunto,
	persona,
	supervisor,
	cuenta_interna,
	tipo_transaccion_maxipunto
	where historial_maxipunto.id_persona = persona.id_persona
	and supervisor.id_supervisor = persona.id_supervisor
	and historial_maxipunto.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and  persona.id_persona LIKE 
	CASE 
		WHEN convert(nvarchar,@id_persona) = 0 THEN '%%' 
		ELSE convert(nvarchar,@id_persona)
	END	
	and historial_maxipunto.fecha_grabacion between
	@fecha_inicial and @fecha
	and tipo_transaccion_maxipunto.id_tipo_transaccion_maxipunto = historial_maxipunto.id_tipo_transaccion_maxipunto
	order by persona.id_persona,
	historial_maxipunto.id_historial_maxipunto
end
else
if(@accion = 'consultar_extracto_consolidado_maxipuntos')
begin
	select persona.id_persona,
	sum(historial_maxipunto.cantidad_puntos) as cantidad_puntos into #saldo_inicial
	from historial_maxipunto,
	persona
	where persona.id_persona = historial_maxipunto.id_persona
	and historial_maxipunto.fecha_aplicacion < @fecha_inicial
	group by persona.id_persona

	select persona.id_persona,
	ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.identificacion,
	persona.idc_persona,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor,
	historial_maxipunto.cantidad_puntos,
	case
		when historial_maxipunto.cantidad_puntos >= 0 then 1
		else 0
	end as tipo_transaccion,
	historial_maxipunto.fecha_aplicacion into #consolidado
	from historial_maxipunto,
	persona,
	supervisor,
	cuenta_interna
	where historial_maxipunto.id_persona = persona.id_persona
	and supervisor.id_supervisor = persona.id_supervisor
	and historial_maxipunto.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and historial_maxipunto.fecha_aplicacion < = @fecha

	select id_persona,
	nombre,
	apellido,
	identificacion,
	idc_persona,
	idc_supervisor,
	nombre_supervisor,
	isnull((
		select sum(c.cantidad_puntos) 
		from #consolidado as c
		where c.tipo_transaccion = 1
		and c.id_persona = #consolidado.id_persona
		and c.fecha_aplicacion between
		@fecha_inicial and @fecha
	), 0) as puntos_ganados,
	isnull((
		select sum(c.cantidad_puntos) 
		from #consolidado as c
		where c.tipo_transaccion = 0
		and c.id_persona = #consolidado.id_persona
		and c.fecha_aplicacion between
		@fecha_inicial and @fecha
	), 0) as puntos_debitados,
	isnull((
		select #saldo_inicial.cantidad_puntos
		from #saldo_inicial
		where #saldo_inicial.id_persona = #consolidado.id_persona
	), 0) as saldo_inicial 
	from #consolidado
	group by id_persona,
	nombre,
	apellido,
	identificacion,
	idc_persona,
	idc_supervisor,
	nombre_supervisor,
	tipo_transaccion

	drop table #consolidado
	drop table #saldo_inicial
end
else
if(@accion = 'consultar_persona')
begin
	select persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + persona.identificacion + ')' as nombre_persona,
	ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.identificacion 
	from persona,
	historial_maxipunto
	where persona.id_persona = historial_maxipunto.id_persona
	group by persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	persona.identificacion
	order by nombre_persona
end
if(@accion = 'consultar_tipo_transaccion')
begin
	select id_tipo_transaccion_maxipunto,
	nombre_transaccion
	from tipo_transaccion_maxipunto
	order by nombre_transaccion
end
else
if(@accion = 'consultar_extracto_individual_maxipuntos')
begin
	select persona.id_persona,
	sum(historial_maxipunto.cantidad_puntos) as cantidad_puntos into #saldo_inicial_persona
	from historial_maxipunto,
	persona
	where persona.id_persona = historial_maxipunto.id_persona
	and historial_maxipunto.fecha_aplicacion < @fecha_inicial
	and  persona.id_persona LIKE 
	CASE 
		WHEN convert(nvarchar,@id_persona) = 0 THEN '%%' 
		ELSE convert(nvarchar,@id_persona)
	END
	group by persona.id_persona

	select ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	persona.identificacion,
	persona.idc_persona,
	persona.id_persona,
	supervisor.idc_supervisor,
	supervisor.nombre_supervisor,
	historial_maxipunto.id_historial_maxipunto,
	historial_maxipunto.descripcion,
	historial_maxipunto.fecha_grabacion,
	historial_maxipunto.fecha_aplicacion,
	cuenta_interna.nombre as nombre_cuenta,
	historial_maxipunto.cantidad_puntos,
	tipo_transaccion_maxipunto.nombre_transaccion,
	case
		when historial_maxipunto.cantidad_puntos >= 0 then 1
		else 0
	end as tipo_transaccion into #consolidado_persona
	from historial_maxipunto,
	persona,
	supervisor,
	cuenta_interna,
	tipo_transaccion_maxipunto
	where historial_maxipunto.id_persona = persona.id_persona
	and supervisor.id_supervisor = persona.id_supervisor
	and historial_maxipunto.id_cuenta_interna = cuenta_interna.id_cuenta_interna
	and  persona.id_persona LIKE 
	CASE 
		WHEN convert(nvarchar,@id_persona) = 0 THEN '%%' 
		ELSE convert(nvarchar,@id_persona)
	END	
	and historial_maxipunto.fecha_aplicacion < = @fecha
	and tipo_transaccion_maxipunto.id_tipo_transaccion_maxipunto = historial_maxipunto.id_tipo_transaccion_maxipunto
	order by persona.id_persona,
	historial_maxipunto.id_historial_maxipunto

	select nombre,
	apellido,
	identificacion,
	idc_persona, 
	id_persona,
	idc_supervisor,
	nombre_supervisor,
	id_historial_maxipunto,
	descripcion,
	fecha_grabacion,
	fecha_aplicacion,
	nombre_cuenta,
	isnull((
		select cantidad_puntos
		from #consolidado_persona as cp
		where cp.id_persona = #consolidado_persona.id_persona
		and cp.id_historial_maxipunto = #consolidado_persona.id_historial_maxipunto
		and cp.fecha_aplicacion between
		@fecha_inicial and @fecha
	), 0) as cantidad_puntos,
	isnull((
		select sum(cantidad_puntos)
		from #consolidado_persona as cp
		where cp.tipo_transaccion = 1
		and cp.id_persona = #consolidado_persona.id_persona
		and cp.fecha_aplicacion between
		@fecha_inicial and @fecha
	), 0) as cantidad_puntos_ganados,
	isnull((
		select sum(cantidad_puntos)
		from #consolidado_persona as cp
		where cp.tipo_transaccion = 0
		and cp.id_persona = #consolidado_persona.id_persona
		and cp.fecha_aplicacion between
		@fecha_inicial and @fecha
	),0) as cantidad_puntos_debitados,
	isnull((	
		select sum(hm.cantidad_puntos) 
		from historial_maxipunto as hm
		where hm.id_historial_maxipunto < = #consolidado_persona.id_historial_maxipunto
		and hm.id_persona = #consolidado_persona.id_persona
		and hm.fecha_aplicacion between
		@fecha_inicial and @fecha
	), 0) as subtotal,
	isnull((
		select sum(#saldo_inicial_persona.cantidad_puntos)
		from #saldo_inicial_persona
		where #saldo_inicial_persona.id_persona = #consolidado_persona.id_persona
	), 0) as saldo_inicial,
	nombre_transaccion,
	tipo_transaccion
	from #consolidado_persona

	drop table #consolidado_persona
	drop table #saldo_inicial_persona
end