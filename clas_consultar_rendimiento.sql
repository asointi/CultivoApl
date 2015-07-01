set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 05/10/2009
-- =============================================
alter PROCEDURE [dbo].[clas_consultar_rendimiento] 

@accion nvarchar(255)

AS

declare @id_item int

select @id_item = id_ramo_despatado from configuracion_bd

if(@accion = 'rendimiento_ramo_despatado_ultima_hora')
begin
	select identity(int,1,1) as id,
	persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + mesa.idc_mesa + ')' as nombre,
	(sum(tallos_por_ramo)/25) as cantidad_ramos, 
	min(ramo_despatado.fecha_lectura) as fecha_minima,
	max(ramo_despatado.fecha_lectura) as fecha_maxima,
	mesa.idc_mesa,
	mesa.id_mesa into #rendimiento_despate_ultima_hora
	from ramo_despatado,
	persona,
	mesa,
	mesa_trabajo_persona
	where persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and mesa_trabajo_persona.id_persona = ramo_despatado.id_persona
	and ramo_despatado.fecha_lectura > = dateadd(mi, -60, getdate())
	and ramo_despatado.id_ramo_despatado > @id_item
	group by persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + mesa.idc_mesa + ')',
	mesa.idc_mesa,
	mesa.id_mesa
	order by cantidad_ramos desc

	update #rendimiento_despate_ultima_hora 
	set idc_mesa = '99'
	where isnumeric(idc_mesa) = 0

	select * from #rendimiento_despate_ultima_hora 
	order by convert(int,idc_mesa), id_mesa

	drop table #rendimiento_despate_ultima_hora
end
else
if(@accion = 'rendimiento_ramo_despatado')
begin
	select identity(int,1,1) as id,
	persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + mesa.idc_mesa + ')' as nombre,
	(sum(tallos_por_ramo)/25) as cantidad_ramos, 
	min(ramo_despatado.fecha_lectura) as fecha_minima,
	max(ramo_despatado.fecha_lectura) as fecha_maxima,
	mesa.idc_mesa,
	mesa.id_mesa into #rendimiento_despate
	from ramo_despatado,
	persona,
	mesa,
	mesa_trabajo_persona
	where persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and mesa_trabajo_persona.id_persona = ramo_despatado.id_persona
	and convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) = convert(datetime,convert(nvarchar,getdate(),101))
	and ramo_despatado.id_ramo_despatado > @id_item
	group by persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + mesa.idc_mesa + ')',
	mesa.idc_mesa,
	mesa.id_mesa
	order by cantidad_ramos desc

	update #rendimiento_despate 
	set idc_mesa = '99'
	where isnumeric(idc_mesa) = 0

	select * from #rendimiento_despate 
	order by convert(int,idc_mesa), id_mesa

	drop table #rendimiento_despate
end
else
if(@accion = 'rendimiento_ramo')
begin
	declare @fecha datetime,
	@fecha_aux datetime,
	@conteo int,
	@id_persona int,
	@id_persona1 int,
	@id_persona_aux int,
	@id int,
	@valor_rendimiento int,
	@factor decimal(20,4)

	set @valor_rendimiento = 15
	set @factor = 1.25
	set @fecha = convert(datetime, convert(nvarchar, getdate(),101))
	
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
	convert(int,floor(max(cantidad_ramos) -  (convert(decimal(20,4),sum(tiempo))/60 * @valor_rendimiento))) as maxipuntos into #resultado
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
	
	select rendimiento,
	cantidad_ramos,
	nombre
	from #resultado
	where maxipuntos > 0
	order by nombre

	drop table #temp
	drop table #persona
	drop table #temp2
	drop table #devolucion
	drop table #union_ramos
	drop table #resultado
end