set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter PROCEDURE [dbo].[na_editar_ramo_despatado_version_4]

@fecha datetime,
@idc_persona_inicial nvarchar(255),
@idc_persona_final nvarchar(255),
@accion nvarchar(255)

as

if(@accion = 'consultar')
begin
	select ramo_devuelto.id_ramo_devuelto into #temp
	from ramo,
	ramo_despatado,
	ramo_devuelto	
	where ramo.idc_ramo = ramo_despatado.idc_ramo_despatado
	and ramo_despatado.id_ramo_despatado = ramo_devuelto.id_ramo_despatado		
	
	select persona.idc_persona,
	ltrim(rtrim(persona.nombre)) as nombre,
	ltrim(rtrim(persona.apellido)) as apellido,
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor)) as nombre_supervisor,
	sum(ramo_despatado.tallos_por_ramo) as unidades,
	count(ramo_despatado.id_ramo_despatado) as cantidad_ramos,
	(
		select count(rdev.id_ramo_devuelto)
		from ramo_despatado as rdes,
		ramo_devuelto as rdev
		where rdes.id_ramo_despatado = rdev.id_ramo_despatado
		and rdes.id_persona = persona.id_persona
		and convert(datetime, convert(nvarchar,rdes.fecha_lectura, 101)) = @fecha
		and not exists
		(
			select *
			from #temp
			where #temp.id_ramo_devuelto = rdev.id_ramo_devuelto
		)
	) as cantidad_ramos_devueltos,
	isnull((
		select sum(rdes.tallos_por_ramo)
		from ramo_despatado as rdes,
		ramo_devuelto as rdev
		where rdes.id_ramo_despatado = rdev.id_ramo_despatado
		and rdes.id_persona = persona.id_persona
		and convert(datetime, convert(nvarchar,rdes.fecha_lectura, 101)) = @fecha
		and not exists
		(
			select *
			from #temp
			where #temp.id_ramo_devuelto = rdev.id_ramo_devuelto
		)
	), 0) as unidades_devueltas
	from ramo_despatado,
	mesa_trabajo_persona,
	mesa,
	persona,
	supervisor
	where supervisor.id_supervisor = persona.id_supervisor
	and mesa.id_mesa = mesa_trabajo_persona.id_mesa
	and persona.id_persona = mesa_trabajo_persona.id_persona
	and mesa_trabajo_persona.id_persona = ramo_despatado.id_persona
	and convert(datetime, convert(nvarchar,ramo_despatado.fecha_lectura, 101)) = @fecha
	and persona.idc_persona > =
	case
		when @idc_persona_inicial = '' then '%%'
		else @idc_persona_inicial
	end
	and persona.idc_persona < =
	case
		when @idc_persona_final = '' then 'ZZZZZZZZZZZZZ'
		else @idc_persona_final
	end
	and not exists
	(
		select *
		from ramo_devuelto
		where ramo_devuelto.id_ramo_despatado = ramo_despatado.id_ramo_despatado
		and not exists
		(
			select *
			from #temp
			where #temp.id_ramo_devuelto = ramo_devuelto.id_ramo_devuelto
		)
	)
	group by persona.id_persona,
	persona.idc_persona,
	ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido)),
	supervisor.idc_supervisor,
	ltrim(rtrim(supervisor.nombre_supervisor))
	order by ltrim(rtrim(persona.nombre)),
	ltrim(rtrim(persona.apellido))

	drop table #temp
end