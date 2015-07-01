set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Diego Piñeros
-- Create date: 05/10/2009
-- =============================================
alter PROCEDURE [dbo].[clas_editar_rendimiento] 

@accion nvarchar(255),
@cantidad_ramos_meta int,
@hora datetime,
@id_ramo_despatado_inicial int,
@id_ramo_despatado_final int

AS

declare @id_ramo_despatado int,
@id_item int,
@conteo int,
@contador int

select @id_item = id_ramo_despatado from configuracion_bd

if(@accion = 'reporte_rendimiento_ramo_despatado')
begin
	select identity(int,1,1) as id,
	persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + mesa.idc_mesa + ')' as nombre,
	(sum(tallos_por_ramo)/25) as cantidad_ramos, 
	mesa.idc_mesa,
	case
		when convert(int,right(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2)) > = 0 
		and convert(int,right(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2)) <  60
		then left(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2) + ':00' + ' - ' + left(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2) + ':59'
	end as hora,
	mesa.id_mesa,
	convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101)) as fecha into #rendimiento_despate_temp
	from ramo_despatado,
	persona,
	mesa,
	mesa_trabajo_persona
	where persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and mesa_trabajo_persona.id_persona = ramo_despatado.id_persona
	and ramo_despatado.id_ramo_despatado >= @id_ramo_despatado_inicial
	and ramo_despatado.id_ramo_despatado <= @id_ramo_despatado_final
	group by persona.id_persona,
	persona.idc_persona,
	persona.identificacion,
	ltrim(rtrim(persona.nombre)) + space(1) + ltrim(rtrim(persona.apellido)) + space(1) + '(' + mesa.idc_mesa + ')',
	mesa.idc_mesa,
	mesa.id_mesa,
	case
		when convert(int,right(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2)) > = 0 
		and convert(int,right(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2)) <  60 
		then left(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2) + ':00' + ' - ' + left(left(convert(nvarchar,ramo_despatado.fecha_lectura,108), 5),2) + ':59'
	end,
	convert(datetime,convert(nvarchar,ramo_despatado.fecha_lectura,101))
	order by cantidad_ramos desc

	update #rendimiento_despate_temp
	set idc_mesa = '99'
	where isnumeric(idc_mesa) = 0

	select * from #rendimiento_despate_temp
	order by convert(int,idc_mesa), id_mesa

	drop table #rendimiento_despate_temp
end
else
if(@accion = 'consultar_cantidad_ramos_meta')
begin
	select cantidad_ramos_meta from configuracion_bd
end
else
if(@accion = 'actualizar_cantidad_ramos_meta')
begin
	update configuracion_bd
	set cantidad_ramos_meta = @cantidad_ramos_meta
end
else
if(@accion = 'reiniciar_rendimiento')
begin
	select @id_ramo_despatado = max(id_ramo_despatado)
	from ramo_despatado
	where datediff(mi, convert(datetime,convert(nvarchar,getdate(),101)), fecha_lectura) < = datediff(mi, convert(datetime,convert(nvarchar,getdate(),101)), @hora)
	and convert(datetime,convert(nvarchar,fecha_lectura, 101)) = convert(datetime,convert(nvarchar,getdate(),101))

	if(@id_ramo_despatado is not null)
	begin
		update configuracion_bd
		set id_ramo_despatado = @id_ramo_despatado

		insert into reinicio_rendimiento (id_ramo_despatado)
		values (@id_ramo_despatado)
	end
	else
	begin
		select @id_ramo_despatado = min(id_ramo_despatado)
		from ramo_despatado
		where datediff(mi, convert(datetime,convert(nvarchar,getdate(),101)), fecha_lectura) > = datediff(mi, convert(datetime,convert(nvarchar,getdate(),101)), @hora)
		and convert(datetime,convert(nvarchar,fecha_lectura, 101)) = convert(datetime,convert(nvarchar,getdate(),101))
								
		update configuracion_bd
		set id_ramo_despatado = @id_ramo_despatado

		insert into reinicio_rendimiento (id_ramo_despatado)
		values (@id_ramo_despatado)
	end
end
else
if(@accion = 'consultar_fechas_reinicio')
begin
	select ramo_despatado.id_ramo_despatado,
	ramo_despatado.fecha_lectura,
	1 as ramo_reiniciado into #temp
	from reinicio_rendimiento,
	ramo_despatado
	where ramo_despatado.id_ramo_despatado = reinicio_rendimiento.id_ramo_despatado
	and convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101)) >= convert(datetime,convert(nvarchar, getdate()-5, 101))

	insert into #temp (id_ramo_despatado, fecha_lectura, ramo_reiniciado)
	select min(ramo_despatado.id_ramo_despatado),
	min(ramo_despatado.fecha_lectura),
	0
	from ramo_despatado,
	#temp
	where convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101)) = convert(datetime,convert(nvarchar, #temp.fecha_lectura, 101))
	and #temp.ramo_reiniciado = 1
	group by convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101))

	insert into #temp (id_ramo_despatado, fecha_lectura, ramo_reiniciado)
	select max(ramo_despatado.id_ramo_despatado),
	max(ramo_despatado.fecha_lectura),
	0
	from ramo_despatado,
	#temp
	where convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101)) = convert(datetime,convert(nvarchar, #temp.fecha_lectura, 101))
	and #temp.ramo_reiniciado = 1
	group by convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101))

	select @conteo = count(*)
	from #temp
	where  convert(datetime,convert(nvarchar, fecha_lectura, 101)) = convert(datetime,convert(nvarchar, getdate(), 101))

	set @contador = 0

	while (@contador < 5)
	begin
		select @conteo = count(*)
		from #temp
		where  convert(datetime,convert(nvarchar, fecha_lectura, 101)) = convert(datetime,convert(nvarchar, getdate() - @contador, 101))

		if(@conteo = 0)
		begin
			insert into #temp (id_ramo_despatado, fecha_lectura, ramo_reiniciado)
			select min(ramo_despatado.id_ramo_despatado),
			min(ramo_despatado.fecha_lectura),
			0
			from ramo_despatado
			where convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101)) = convert(datetime,convert(nvarchar, getdate()- @contador, 101))
			group by convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101))

			insert into #temp (id_ramo_despatado, fecha_lectura, ramo_reiniciado)
			select max(ramo_despatado.id_ramo_despatado),
			max(ramo_despatado.fecha_lectura),
			0
			from ramo_despatado
			where convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101)) = convert(datetime,convert(nvarchar, getdate()- @contador, 101))
			group by convert(datetime,convert(nvarchar, ramo_despatado.fecha_lectura, 101))
		end
	
		set @contador = @contador + 1
	end
	
	select id_ramo_despatado,
	CONVERT(CHAR(10),fecha_lectura,110) + SUBSTRING(CONVERT(varchar,fecha_lectura,0),12,8) as fecha
	from #temp
	group by id_ramo_despatado,
	CONVERT(CHAR(10),fecha_lectura,110) + SUBSTRING(CONVERT(varchar,fecha_lectura,0),12,8)
	order by id_ramo_despatado

	drop table #temp 
end
else
if(@accion = 'consultar_hora_ultimo_reinicio')
begin
	select fecha_lectura
	from ramo_despatado
	where id_ramo_despatado = (select id_ramo_despatado from configuracion_bd)
end